import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/calendar/hijri_date.dart';
import 'package:quran_app/data/daily_content_repository.dart';
import 'package:quran_app/data/quran_repository.dart';
import 'package:quran_app/data/settings_repository.dart';
import 'package:quran_app/domain/daily/daily_content.dart';
import 'package:quran_app/domain/daily/daily_selector.dart';
import 'package:quran_app/domain/models/app_settings.dart';
import 'package:quran_app/features/daily/daily_providers.dart';
import 'package:quran_app/features/surahs/surah_reader_screen.dart';
import 'package:quran_app/ui/widgets/quran_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DailyCatalogue catalogue;
  const selector = DailySelector();

  setUpAll(() async {
    catalogue = await DailyContentRepository(rootBundle).catalogue();
  });

  DailyEntry? entryOn(
    DateTime date, {
    DailyContentMode mode = DailyContentMode.both,
  }) => selector.pick(catalogue, (
    date: date,
    hijri: HijriDate.fromGregorian(date),
  ), mode: mode);

  /// The first ordinary day from 5 Jan 2026 whose entry is a [T].
  (DateTime, T) firstDayWith<T extends DailyEntry>() {
    for (var i = 0; i < 60; i++) {
      final date = DateTime(2026, 1, 5 + i, 9);
      if (entryOn(date) case final T entry when entry.occasion == null) {
        return (date, entry);
      }
    }
    throw StateError('no $T day');
  }

  /// The first ordinary day whose hadith has (or lacks) an Urdu translation.
  (DateTime, DailyHadithEntry) firstHadithDay({required bool urdu}) {
    for (var i = 0; i < 400; i++) {
      final date = DateTime(2026, 1, 5 + i, 9);
      if (entryOn(date) case final DailyHadithEntry entry
          when entry.occasion == null &&
              entry.hadith.translations.any((t) => t.language == 'ur') ==
                  urdu) {
        return (date, entry);
      }
    }
    throw StateError('no hadith day with urdu: $urdu');
  }

  final card = find.byKey(const ValueKey('daily-hadith'));
  final ayahCard = find.byKey(const ValueKey('daily-ayah'));

  testWidgets('the hadith of the day: translation, reference, Arabic on '
      'request, and its sunnah.com page', (tester) async {
    final (date, entry) = firstDayWith<DailyHadithEntry>();
    final hadith = entry.hadith;
    final launched = <Uri>[];
    final app = await TestApp.pump(
      tester,
      now: date,
      overrides: [
        externalLinkLauncherProvider.overrideWithValue((uri) async {
          launched.add(uri);
          return true;
        }),
      ],
    );

    expect(card, findsOneWidget);
    expect(find.text('Hadith of the Day'), findsOneWidget);
    expect(
      find.descendant(
        of: card,
        // The default Quran translation is Urdu, so Urdu comes first.
        matching: find.text(hadith.translationFor(['ur', 'en']).text),
      ),
      findsOneWidget,
    );
    expect(find.text(hadith.citation), findsOneWidget);
    expect(find.text('Sahih'), findsOneWidget);

    // Arabic is off by default, and the toggle remembers the choice.
    // The Arabic stays mounted for its cross-fade; what changes is whether
    // it is shown.
    final arabic = find.byKey(const ValueKey('daily-hadith-arabic'));
    CrossFadeState arabicState() => tester
        .widget<AnimatedCrossFade>(
          find.descendant(of: card, matching: find.byType(AnimatedCrossFade)),
        )
        .crossFadeState;
    expect(arabicState(), CrossFadeState.showFirst);
    expect(arabic.hitTestable(), findsNothing);

    await tester.ensureVisible(find.text('Show Arabic'));
    await tester.pump();
    await tester.tap(find.text('Show Arabic'));
    // Mid-animation the Arabic is partly faded in, not popped in.
    await tester.pump(); // starts the animation
    await tester.pump(const Duration(milliseconds: 200));
    final midway = tester.widget<FadeTransition>(
      find.ancestor(of: arabic, matching: find.byType(FadeTransition)).first,
    );
    expect(midway.opacity.value, inExclusiveRange(0, 1));
    await app.settle(tester);
    expect(arabicState(), CrossFadeState.showSecond);
    expect(tester.widget<Text>(arabic).data, hadith.arabic);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('settings.daily.hadithArabic'), isTrue);

    await tester.tap(find.text('Hide Arabic'));
    await app.settle(tester);
    expect(arabicState(), CrossFadeState.showFirst);
    expect(prefs.getBool('settings.daily.hadithArabic'), isFalse);

    await tester.ensureVisible(find.text('Verify source'));
    await tester.pump();
    await tester.tap(find.text('Verify source'));
    await app.settle(tester);
    expect(launched, [hadith.sourceUrl]);

    await app.dispose(tester);
  });

  testWidgets('a link that cannot be opened says so', (tester) async {
    final (date, _) = firstDayWith<DailyHadithEntry>();
    final app = await TestApp.pump(
      tester,
      now: date,
      overrides: [
        externalLinkLauncherProvider.overrideWithValue((_) async => false),
      ],
    );
    await tester.ensureVisible(find.text('Verify source'));
    await tester.pump();
    await tester.tap(find.text('Verify source'));
    await app.settle(tester);
    expect(find.text("Couldn't open the link."), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('the ayah of the day: Arabic, the chosen translation, and '
      'Read in context', (tester) async {
    final (date, entry) = firstDayWith<DailyAyahEntry>();
    final app = await TestApp.pump(tester, now: date);
    final passage = (await tester.runAsync(
      () => QuranRepository(app.content).passage(
        entry.surah,
        entry.fromAyah,
        entry.toAyah,
        translationIds: const ['ur.jalandhry'],
      ),
    ))!;

    expect(ayahCard, findsOneWidget);
    expect(find.text('Ayah of the Day'), findsOneWidget);
    expect(
      find.descendant(of: ayahCard, matching: find.byType(QuranText)),
      findsNWidgets(passage.length),
    );
    final urdu = passage.map((a) => a.translations.single.text).join(' ');
    expect(
      find.descendant(of: ayahCard, matching: find.text(urdu)),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Read in context'));
    await tester.pump();
    await tester.tap(find.text('Read in context'));
    await app.settle(tester);
    final reader = tester.widget<SurahReaderScreen>(
      find.byType(SurahReaderScreen),
    );
    expect(reader.surah, entry.surah);
    expect(reader.initialAyah, entry.fromAyah);

    await app.dispose(tester);
  });

  testWidgets('ayah-only mode never shows a hadith', (tester) async {
    final (date, _) = firstDayWith<DailyHadithEntry>();
    final app = await TestApp.pump(
      tester,
      now: date,
      prefs: {'settings.daily.content': 'ayahOnly'},
    );
    expect(card, findsNothing);
    expect(ayahCard, findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('Fridays show the Friday list', (tester) async {
    final friday = DateTime(2026, 1, 9, 9);
    final expected = entryOn(friday)!;
    expect(expected.occasion, DailyOccasion.friday);
    final app = await TestApp.pump(tester, now: friday);
    expect(expected is DailyHadithEntry ? card : ayahCard, findsOneWidget);
    if (expected case DailyHadithEntry(:final hadith)) {
      expect(find.text(hadith.citation), findsOneWidget);
    }
    await app.dispose(tester);
  });

  testWidgets('turned off in Settings, the card is gone', (tester) async {
    final app = await TestApp.pump(
      tester,
      prefs: {'settings.daily.show': false},
    );
    expect(card, findsNothing);
    expect(ayahCard, findsNothing);
    await app.dispose(tester);
  });

  testWidgets('localised: the Urdu UI', (tester) async {
    final (date, _) = firstDayWith<DailyHadithEntry>();
    final app = await TestApp.pump(
      tester,
      now: date,
      prefs: {'settings.language': 'ur'},
    );
    expect(find.text('آج کی حدیث'), findsOneWidget);
    expect(find.text('حوالہ دیکھیں'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('a hadith reads in the Quran translation language, credited', (
    tester,
  ) async {
    final (date, entry) = firstHadithDay(urdu: true);
    final urdu = entry.hadith.translationFor(['ur']);
    expect(urdu.language, 'ur');

    // Urdu Quran translation (the default): the Urdu hadith translation.
    var app = await TestApp.pump(tester, now: date);
    expect(
      find.descendant(of: card, matching: find.text(urdu.text)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('HadeethEnc.com')),
      findsOneWidget,
    );
    await app.dispose(tester);

    // English Quran translation: the English one, from sunnah.com.
    app = await TestApp.pump(
      tester,
      now: date,
      prefs: {
        'settings.translationIds': ['en.sahih'],
      },
    );
    expect(
      find.descendant(
        of: card,
        matching: find.text(entry.hadith.translationFor(['en']).text),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('sunnah.com')),
      findsOneWidget,
    );
    await app.dispose(tester);
  });

  testWidgets('without an Urdu translation, the English one is shown', (
    tester,
  ) async {
    final (date, entry) = firstHadithDay(urdu: false);
    final app = await TestApp.pump(tester, now: date);
    expect(
      find.descendant(
        of: card,
        matching: find.text(entry.hadith.translationFor(['en']).text),
      ),
      findsOneWidget,
    );
    await app.dispose(tester);
  });

  for (final width in [320.0, 900.0]) {
    testWidgets('lays out without overflow at ${width.toInt()}px, with '
        'Arabic and the largest text', (tester) async {
      for (final type in [DailyHadithEntry, DailyAyahEntry]) {
        final (date, _) = type == DailyHadithEntry
            ? firstDayWith<DailyHadithEntry>()
            : firstDayWith<DailyAyahEntry>();
        final app = await TestApp.pump(
          tester,
          now: date,
          size: Size(width, 900),
          prefs: {
            'settings.daily.hadithArabic': true,
            'settings.arabicFontSize': 44.0,
            'settings.translationFontSize': 26.0,
            'settings.language': 'ur',
          },
        );
        expect(card.evaluate().length + ayahCard.evaluate().length, 1);
        await app.dispose(tester);
      }
    });
  }

  testWidgets('Settings: content, Arabic and the Hijri adjustment', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/settings');
    final prefs = await SharedPreferences.getInstance();

    await tester.scrollUntilVisible(
      find.text('Hijri date adjustment'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await app.settle(tester);
    expect(find.text('Ayah & Hadith of the Day'), findsOneWidget);

    // 5 Jan 2026 is 16 Rajab 1447 by calculation.
    expect(find.textContaining('16 Rajab 1447 AH'), findsOneWidget);
    await tester.tap(find.byTooltip('Increase'));
    await app.settle(tester);
    expect(prefs.getInt('settings.hijriAdjustment'), 1);
    expect(find.textContaining('17 Rajab 1447 AH'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    await tester.tap(find.byTooltip('Increase'));
    await app.settle(tester);
    // The limit is two days either way.
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byIcon(Icons.add_circle_outline),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Hadith'));
    await app.settle(tester);
    expect(prefs.getString('settings.daily.content'), 'hadithOnly');

    await tester.tap(find.text('Arabic text of the hadith'));
    await app.settle(tester);
    expect(prefs.getBool('settings.daily.hadithArabic'), isTrue);

    await app.dispose(tester);
  });

  test('daily settings persist, and bad values fall back', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SettingsRepository(await SharedPreferences.getInstance());
    final defaults = repo.load();
    expect(defaults.showDailyCard, isTrue);
    expect(defaults.dailyContentMode, DailyContentMode.both);
    expect(defaults.showHadithArabic, isFalse);
    expect(defaults.hijriAdjustment, 0);

    await repo.save(
      const AppSettings(
        showDailyCard: false,
        dailyContentMode: DailyContentMode.hadithOnly,
        showHadithArabic: true,
        hijriAdjustment: -2,
      ),
    );
    final loaded = repo.load();
    expect(loaded.showDailyCard, isFalse);
    expect(loaded.dailyContentMode, DailyContentMode.hadithOnly);
    expect(loaded.showHadithArabic, isTrue);
    expect(loaded.hijriAdjustment, -2);

    SharedPreferences.setMockInitialValues({
      'settings.daily.content': 'nonsense',
      'settings.hijriAdjustment': 9,
    });
    final fallback = SettingsRepository(
      await SharedPreferences.getInstance(),
    ).load();
    expect(fallback.dailyContentMode, DailyContentMode.both);
    expect(fallback.hijriAdjustment, AppSettings.maxHijriAdjustment);
  });
}
