// The flat list a reader screen renders: surah headers, "continuing" cards and
// ayat. Built by pure functions so the basmalah and marker rules are unit
// tested without any widgets.

import '../../domain/models/ayah.dart';
import '../../domain/models/surah.dart';

sealed class ReaderItem {
  const ReaderItem();
}

/// A surah's opening header, followed by the basmalah when
/// [Surah.rendersHeaderBismillah] says so (never for 1 or 9).
final class SurahHeaderItem extends ReaderItem {
  const SurahHeaderItem(this.surah);
  final Surah surah;

  bool get showBismillah => surah.rendersHeaderBismillah;
}

/// Opens a juz that begins mid-surah: "Continuing Surah X from ayah N".
/// Never followed by a basmalah.
final class ContinuingSurahItem extends ReaderItem {
  const ContinuingSurahItem(this.surah, this.fromAyah);
  final Surah surah;
  final int fromAyah;
}

/// One verse, with the markers to print above it.
final class AyahItem extends ReaderItem {
  const AyahItem(
    this.ayah,
    this.surah, {
    required this.showJuz,
    required this.showHizb,
    required this.showPage,
  });

  final Ayah ayah;
  final Surah surah;

  /// Juz, hizb and page are printed only where they CHANGE, so they read as
  /// markers in the margin rather than a label stamped on every verse (as on
  /// the web's surah page).
  final bool showJuz;
  final bool showHizb;
  final bool showPage;
}

/// The items of one reader screen, plus a verse-key index for jumping.
class ReaderContent {
  ReaderContent(this.items)
    : _indexByVerse = {
        for (final (i, item) in items.indexed)
          if (item is AyahItem) item.ayah.verseKey: i,
      };

  final List<ReaderItem> items;
  final Map<String, int> _indexByVerse;

  /// List index of [verseKey], or null when it is not on this screen.
  int? indexOf(String verseKey) => _indexByVerse[verseKey];

  /// The first ayah at or after list index [index].
  AyahItem? ayahAtOrAfter(int index) {
    for (var i = index; i < items.length; i++) {
      if (items[i] case final AyahItem item) return item;
    }
    return null;
  }
}

/// A surah from start to finish: header (with basmalah where it applies),
/// then every ayah.
ReaderContent buildSurahContent(Surah surah, List<Ayah> ayahs) =>
    ReaderContent([
      SurahHeaderItem(surah),
      ..._withMarkers(ayahs, [surah]),
    ]);

/// A juz across surah boundaries.
///
/// Whenever a surah STARTS inside the juz, a full header (and the basmalah
/// under the same rule as the surah reader) is inserted. A juz that begins
/// mid-surah opens with a "continuing" card and no basmalah.
ReaderContent buildJuzContent(List<Surah> allSurahs, List<Ayah> ayahs) {
  final items = <ReaderItem>[];
  final ayahItems = _withMarkers(ayahs, allSurahs);
  for (final item in ayahItems) {
    final ayah = item.ayah;
    if (ayah.ayahNumber == 1) {
      items.add(SurahHeaderItem(item.surah));
    } else if (items.isEmpty) {
      items.add(ContinuingSurahItem(item.surah, ayah.ayahNumber));
    }
    items.add(item);
  }
  return ReaderContent(items);
}

List<AyahItem> _withMarkers(List<Ayah> ayahs, List<Surah> surahs) {
  final bySurah = {for (final s in surahs) s.number: s};
  return [
    for (final (i, ayah) in ayahs.indexed)
      AyahItem(
        ayah,
        bySurah[ayah.surahNumber]!,
        showJuz: i == 0 || ayahs[i - 1].juz != ayah.juz,
        showHizb: i == 0 || ayahs[i - 1].hizb != ayah.hizb,
        showPage: i == 0 || ayahs[i - 1].page != ayah.page,
      ),
  ];
}
