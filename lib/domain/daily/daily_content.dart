import 'package:meta/meta.dart';

import '../models/hadith.dart';

/// What the home screen's daily card may show.
enum DailyContentMode {
  /// Alternates day by day between an ayah and a hadith.
  both,
  ayahOnly,
  hadithOnly;

  bool get includesAyah => this != hadithOnly;
  bool get includesHadith => this != ayahOnly;
}

/// Days whose daily pick comes from their own list.
enum DailyOccasion { ramadan, dhulHijjah, friday }

/// One curated entry. An entry with an [occasion] is shown only on that
/// occasion; the rest make up the everyday rotation.
@immutable
sealed class DailyEntry {
  const DailyEntry({this.occasion});

  final DailyOccasion? occasion;
}

/// A short passage of whole verses within one surah.
@immutable
final class DailyAyahEntry extends DailyEntry {
  const DailyAyahEntry({
    required this.surah,
    required this.fromAyah,
    required this.toAyah,
    super.occasion,
  }) : assert(fromAyah <= toAyah, 'an empty passage');

  final int surah;
  final int fromAyah;
  final int toAyah;

  /// "94:5" or "94:5-6"
  String get key =>
      fromAyah == toAyah ? '$surah:$fromAyah' : '$surah:$fromAyah-$toAyah';

  @override
  bool operator ==(Object other) =>
      other is DailyAyahEntry &&
      other.surah == surah &&
      other.fromAyah == fromAyah &&
      other.toAyah == toAyah &&
      other.occasion == occasion;

  @override
  int get hashCode => Object.hash(surah, fromAyah, toAyah, occasion);

  @override
  String toString() => 'DailyAyahEntry($key, $occasion)';
}

/// A hadith, carried in full: hadith text ships with the app.
@immutable
final class DailyHadithEntry extends DailyEntry {
  const DailyHadithEntry({required this.hadith, super.occasion});

  final Hadith hadith;

  @override
  String toString() => 'DailyHadithEntry(${hadith.citation}, $occasion)';
}

/// Every curated entry, in rotation order.
@immutable
class DailyCatalogue {
  DailyCatalogue({
    required List<DailyAyahEntry> ayahs,
    required List<DailyHadithEntry> hadiths,
  }) : ayahs = List.unmodifiable(ayahs),
       hadiths = List.unmodifiable(hadiths);

  final List<DailyAyahEntry> ayahs;
  final List<DailyHadithEntry> hadiths;

  /// The everyday ayah rotation (occasion entries excluded).
  late final List<DailyAyahEntry> everydayAyahs = List.unmodifiable([
    for (final e in ayahs)
      if (e.occasion == null) e,
  ]);

  /// The everyday hadith rotation (occasion entries excluded).
  late final List<DailyHadithEntry> everydayHadiths = List.unmodifiable([
    for (final e in hadiths)
      if (e.occasion == null) e,
  ]);

  /// The entries for [occasion] that [mode] allows, alternating ayah and
  /// hadith so consecutive days differ.
  List<DailyEntry> forOccasion(DailyOccasion occasion, DailyContentMode mode) {
    final a = [
      if (mode.includesAyah)
        for (final e in ayahs)
          if (e.occasion == occasion) e,
    ];
    final h = [
      if (mode.includesHadith)
        for (final e in hadiths)
          if (e.occasion == occasion) e,
    ];
    return [
      for (var i = 0; i < a.length || i < h.length; i++) ...[
        if (i < a.length) a[i],
        if (i < h.length) h[i],
      ],
    ];
  }
}
