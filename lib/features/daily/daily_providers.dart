import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/calendar/hijri_date.dart';
import '../../domain/daily/daily_content.dart';
import '../../domain/daily/daily_selector.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/hadith.dart';
import '../../domain/models/surah.dart';
import '../../providers.dart';
import '../settings/settings_controller.dart';

/// The current time. Overridden in tests to pin the day.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Opens a web page outside the app. Overridden in tests.
final externalLinkLauncherProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

/// The local calendar day. Moves forward at midnight, and when the app comes
/// back to the foreground on a later day.
class TodayNotifier extends Notifier<DateTime> {
  Timer? _midnight;

  @override
  DateTime build() {
    final lifecycle = AppLifecycleListener(onResume: _refresh);
    ref.onDispose(() {
      _midnight?.cancel();
      lifecycle.dispose();
    });
    return _scheduleNext();
  }

  /// Today's date, with a timer set for the start of tomorrow.
  DateTime _scheduleNext() {
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _midnight?.cancel();
    _midnight = Timer(tomorrow.difference(now), _refresh);
    return today;
  }

  void _refresh() {
    final today = _scheduleNext();
    if (today != state) state = today;
  }
}

final todayProvider = NotifierProvider<TodayNotifier, DateTime>(
  TodayNotifier.new,
);

/// Today in both calendars, with the reader's Hijri adjustment applied.
final dailyDateProvider = Provider<DailyDate>((ref) {
  final today = ref.watch(todayProvider);
  final adjustment = ref.watch(
    settingsControllerProvider.select((s) => s.hijriAdjustment),
  );
  return (
    date: today,
    hijri: HijriDate.fromGregorian(today, adjustmentDays: adjustment),
  );
});

final dailySelectorProvider = Provider<DailySelector>(
  (ref) => const DailySelector(),
);

/// What the home screen's daily card shows today, ready to render.
@immutable
sealed class DailyReminder {
  const DailyReminder();
}

/// A passage, with the reader's chosen translations.
final class DailyAyahReminder extends DailyReminder {
  const DailyAyahReminder({required this.surah, required this.ayahs});

  final Surah surah;

  /// Consecutive verses of [surah]; never empty.
  final List<Ayah> ayahs;

  int get fromAyah => ayahs.first.ayahNumber;
  int get toAyah => ayahs.last.ayahNumber;
}

final class DailyHadithReminder extends DailyReminder {
  const DailyHadithReminder(this.hadith);

  final Hadith hadith;
}

/// Today's reminder, or null when there is nothing to show.
final dailyReminderProvider = FutureProvider<DailyReminder?>((ref) async {
  final day = ref.watch(dailyDateProvider);
  final (mode, translationIds) = ref.watch(
    settingsControllerProvider.select(
      (s) => (s.dailyContentMode, s.visibleTranslationIds),
    ),
  );
  final selector = ref.watch(dailySelectorProvider);
  final daily = ref.watch(dailyContentRepositoryProvider);
  final quran = ref.watch(quranRepositoryProvider);

  final entry = selector.pick(await daily.catalogue(), day, mode: mode);
  switch (entry) {
    case null:
      return null;
    case DailyHadithEntry(:final hadith):
      return DailyHadithReminder(hadith);
    case DailyAyahEntry(:final surah, :final fromAyah, :final toAyah):
      final (meta, ayahs) = await (
        quran.surah(surah),
        quran.passage(surah, fromAyah, toAyah, translationIds: translationIds),
      ).wait;
      if (meta == null || ayahs.isEmpty) return null;
      return DailyAyahReminder(surah: meta, ayahs: ayahs);
  }
});
