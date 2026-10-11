// Port of islamic-platform/src/lib/references.ts (Quran half only; the
// hadith aliases and parser are intentionally not ported).
//
// Deterministic reference parsing.
//
// If a user types "2:255", no search should be involved: we resolve the
// reference exactly and navigate straight to the verse. The parser is
// permissive about how people type references and strict about never resolving
// one that does not exist (2:300 and 115:1 return null; nothing is clamped).
//
// Below the port sits [parseNavigationTarget], the mobile app's extension:
// juz / para input, Arabic-Indic digits, bare surah numbers and loose surah
// names ("baqarah", "yaseen", "al-mulk").

import '../text/arabic_digits.dart';
import '../text/normalize.dart';

/// Number of surahs in the mushaf.
const int surahCount = 114;

/// Number of juz (parts) in the mushaf.
const int juzCount = 30;

/// Total number of ayat in the mushaf, by the counting this mushaf uses.
const int totalAyahCount = 6236;

/// Ayah counts per surah, used to reject impossible references like 2:300.
///
/// (`AYAH_COUNTS` in the TypeScript original.)
const List<int> ayahCounts = [
  7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, //
  111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54,
  45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62,
  55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28,
  20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15,
  21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6,
];

/// Number of ayat in [surah], or null outside the mushaf.
int? ayahCount(int surah) =>
    surah >= 1 && surah <= ayahCounts.length ? ayahCounts[surah - 1] : null;

/// True when the surah/ayah pair actually exists in the mushaf.
bool isValidVerseKey(int surah, int ayah) {
  final count = ayahCount(surah);
  return count != null && ayah >= 1 && ayah <= count;
}

/// A resolved Quran reference: a surah, a verse, or a verse range.
class QuranReference {
  const QuranReference({
    required this.surah,
    this.ayah,
    this.ayahEnd,
    this.verseKey,
  });

  final int surah;
  final int? ayah;
  final int? ayahEnd;

  /// "2:255" when [ayah] is set.
  final String? verseKey;

  @override
  bool operator ==(Object other) =>
      other is QuranReference &&
      other.surah == surah &&
      other.ayah == ayah &&
      other.ayahEnd == ayahEnd &&
      other.verseKey == verseKey;

  @override
  int get hashCode => Object.hash(surah, ayah, ayahEnd, verseKey);

  @override
  String toString() =>
      'QuranReference(surah: $surah, ayah: $ayah, ayahEnd: $ayahEnd)';
}

/// Well-known passage names. Kept small and factual — each entry is a widely
/// used name for a specific, verifiable location in the mushaf, not an
/// interpretation.
///
/// (`NAMED_PASSAGES` in the TypeScript original.)
const Map<String, QuranReference> namedPassages = {
  'ayatul kursi': QuranReference(surah: 2, ayah: 255, verseKey: '2:255'),
  'ayat al kursi': QuranReference(surah: 2, ayah: 255, verseKey: '2:255'),
  'ayat ul kursi': QuranReference(surah: 2, ayah: 255, verseKey: '2:255'),
  'aayat ul kursi': QuranReference(surah: 2, ayah: 255, verseKey: '2:255'),
  'throne verse': QuranReference(surah: 2, ayah: 255, verseKey: '2:255'),
  'al fatihah': QuranReference(surah: 1),
  'fatiha': QuranReference(surah: 1),
  'surah yaseen': QuranReference(surah: 36),
  'surah yasin': QuranReference(surah: 36),
  'surah rahman': QuranReference(surah: 55),
  'surah mulk': QuranReference(surah: 67),
  'surah kahf': QuranReference(surah: 18),
  'surah waqiah': QuranReference(surah: 56),
  'ayatain of baqarah': QuranReference(
    surah: 2,
    ayah: 285,
    ayahEnd: 286,
    verseKey: '2:285',
  ),
  'last two verses of baqarah': QuranReference(
    surah: 2,
    ayah: 285,
    ayahEnd: 286,
    verseKey: '2:285',
  ),
  'al ikhlas': QuranReference(surah: 112),
  'al falaq': QuranReference(surah: 113),
  'an nas': QuranReference(surah: 114),
  'muawwidhatayn': QuranReference(
    surah: 113,
    ayah: 1,
    ayahEnd: 6,
    verseKey: '113:1',
  ),
};

final RegExp _numericReference = RegExp(
  r'^(?:q(?:uran)?\.?\s*)?(\d{1,3})\s*[:.\-\s]\s*(\d{1,3})(?:\s*[-–]\s*(\d{1,3}))?$',
  caseSensitive: false,
);
final RegExp _surahOnly = RegExp(
  r'^(?:surah?|chapter)\s*(\d{1,3})$',
  caseSensitive: false,
);

/// Parses an explicit Quran reference out of a query. Returns null when the
/// query is not a reference lookup.
QuranReference? parseReference(String rawQuery) {
  final query = rawQuery.trim();
  if (query.isEmpty) return null;

  // --- "2:255", "2:255-257", "2.255", "q 2:255", "quran 2 255" -------------
  final numeric = _numericReference.firstMatch(query);
  if (numeric != null) {
    final surah = int.parse(numeric.group(1)!);
    final ayah = int.parse(numeric.group(2)!);
    final endGroup = numeric.group(3);
    final ayahEnd = endGroup == null ? null : int.parse(endGroup);
    if (isValidVerseKey(surah, ayah) &&
        (ayahEnd == null || isValidVerseKey(surah, ayahEnd))) {
      return QuranReference(
        surah: surah,
        ayah: ayah,
        // A reversed range is ignored rather than inverted.
        ayahEnd: ayahEnd != null && ayahEnd > ayah ? ayahEnd : null,
        verseKey: '$surah:$ayah',
      );
    }
  }

  // --- "surah 36", "chapter 1" ----------------------------------------------
  final surahOnly = _surahOnly.firstMatch(query);
  if (surahOnly != null) {
    final surah = int.parse(surahOnly.group(1)!);
    if (surah >= 1 && surah <= surahCount) return QuranReference(surah: surah);
  }

  // --- Named passages -------------------------------------------------------
  return namedPassages[normalizeForSearch(query)];
}

/// Formats a citation label exactly as it is displayed and cited.
String formatQuranCitation(int surah, int ayah, [String? surahName]) =>
    surahName != null
    ? "Qur'an $surah:$ayah (Surah $surahName)"
    : "Qur'an $surah:$ayah";

final RegExp _verseKeyPattern = RegExp(r'^(\d{1,3}):(\d{1,3})$');

/// Parses a "surah:ayah" key back into numbers, validating existence.
({int surah, int ayah})? parseVerseKey(String key) {
  final match = _verseKeyPattern.firstMatch(key);
  if (match == null) return null;
  final surah = int.parse(match.group(1)!);
  final ayah = int.parse(match.group(2)!);
  return isValidVerseKey(surah, ayah) ? (surah: surah, ayah: ayah) : null;
}

// =============================================================================
// Mobile extension: navigation targets
// =============================================================================

/// Where a typed reference should take the reader.
sealed class NavigationTarget {
  const NavigationTarget();
}

/// A whole surah, e.g. "36", "yaseen".
final class SurahTarget extends NavigationTarget {
  const SurahTarget(this.surah);
  final int surah;

  @override
  bool operator ==(Object other) => other is SurahTarget && other.surah == surah;
  @override
  int get hashCode => surah.hashCode;
  @override
  String toString() => 'SurahTarget($surah)';
}

/// A verse or verse range, e.g. "2:255", "2:285-286".
final class VerseTarget extends NavigationTarget {
  const VerseTarget(this.surah, this.ayah, {this.ayahEnd});
  final int surah;
  final int ayah;
  final int? ayahEnd;

  String get verseKey => '$surah:$ayah';

  @override
  bool operator ==(Object other) =>
      other is VerseTarget &&
      other.surah == surah &&
      other.ayah == ayah &&
      other.ayahEnd == ayahEnd;
  @override
  int get hashCode => Object.hash(surah, ayah, ayahEnd);
  @override
  String toString() => 'VerseTarget($surah:$ayah${ayahEnd == null ? '' : '-$ayahEnd'})';
}

/// A juz, e.g. "juz 30", "para 30".
final class JuzTarget extends NavigationTarget {
  const JuzTarget(this.juz);
  final int juz;

  @override
  bool operator ==(Object other) => other is JuzTarget && other.juz == juz;
  @override
  int get hashCode => juz.hashCode;
  @override
  String toString() => 'JuzTarget($juz)';
}

final RegExp _juzPattern = RegExp(
  r"^(?:juz['’]?|juzz|juzu|para|parah|sipara|siparah|part|جزء|الجزء|پارہ|پاره|سپارہ)\s*(\d{1,3})$",
  caseSensitive: false,
  unicode: true,
);
final RegExp _bareNumber = RegExp(r'^\d{1,3}$');
final RegExp _nameWithAyah = RegExp(
  r'^(.*?\D)\s*[:\s.]\s*(\d{1,3})(?:\s*[-–]\s*(\d{1,3}))?$',
);

/// Resolves what the reader typed into a place in the mushaf, or null.
///
/// Accepts everything [parseReference] accepts, plus Arabic-Indic and Persian
/// digits, "juz 30" / "para 30" / "sipara 30", a bare surah number, and loose
/// surah names (with an optional ayah: "baqarah 255") resolved via [names].
NavigationTarget? parseNavigationTarget(String raw, {SurahNameIndex? names}) {
  final query = toAsciiDigits(raw).trim();
  if (query.isEmpty) return null;

  final juz = _juzPattern.firstMatch(query);
  if (juz != null) {
    final number = int.parse(juz.group(1)!);
    return number >= 1 && number <= juzCount ? JuzTarget(number) : null;
  }

  final reference = parseReference(query);
  if (reference != null) return _toTarget(reference);

  if (_bareNumber.hasMatch(query)) {
    final surah = int.parse(query);
    return surah >= 1 && surah <= surahCount ? SurahTarget(surah) : null;
  }

  if (names == null) return null;

  final surah = names.lookup(query);
  if (surah != null) return SurahTarget(surah);

  // "baqarah 255", "al-kahf:10", "yaseen 1-12"
  final withAyah = _nameWithAyah.firstMatch(query);
  if (withAyah != null) {
    final named = names.lookup(withAyah.group(1)!);
    if (named == null) return null;
    final ayah = int.parse(withAyah.group(2)!);
    final endGroup = withAyah.group(3);
    final ayahEnd = endGroup == null ? null : int.parse(endGroup);
    if (!isValidVerseKey(named, ayah)) return null;
    if (ayahEnd != null && !isValidVerseKey(named, ayahEnd)) return null;
    return VerseTarget(
      named,
      ayah,
      ayahEnd: ayahEnd != null && ayahEnd > ayah ? ayahEnd : null,
    );
  }

  return null;
}

NavigationTarget _toTarget(QuranReference reference) {
  final ayah = reference.ayah;
  if (ayah == null) return SurahTarget(reference.surah);
  return VerseTarget(reference.surah, ayah, ayahEnd: reference.ayahEnd);
}

/// Loose, typo-tolerant lookup of surah names.
///
/// Both the stored names and the query are reduced to the same key, so
/// "Al-Baqara", "baqarah" and "al baqarah" all meet at "baqara"; "Yaseen",
/// "yasin" and "ya-sin" at "yasin". Arabic names fold the same way
/// ("سورة البقرة", "البقرة" and "بقره" all match).
class SurahNameIndex {
  /// Builds the index from every known name of each surah.
  SurahNameIndex(Map<int, Iterable<String>> namesBySurah) {
    for (final entry in namesBySurah.entries) {
      for (final name in entry.value) {
        final key = foldName(name);
        if (key.isNotEmpty) _bySurahKey.putIfAbsent(key, () => entry.key);
      }
    }
  }

  final Map<String, int> _bySurahKey = {};

  static const Set<String> _surahWords = {
    'surah', 'surat', 'sura', 'suraah', 'soorah', 'chapter', //
    'سوره', 'سورت',
  };
  static const Set<String> _articles = {
    'al', 'an', 'ar', 'as', 'at', 'ad', 'adh', 'ash', 'az', 'ath', 'aal', //
    'ali', 'ale', 'el',
  };
  static final RegExp _apostrophes = RegExp("['’‘`ʿʾ]");
  static final RegExp _doubled = RegExp(r'(.)\1+');

  /// The surah number for [query], or null when no name matches exactly.
  int? lookup(String query) {
    final key = foldName(query);
    return key.isEmpty ? null : _bySurahKey[key];
  }

  /// Reduces a surah name to its comparison key.
  static String foldName(String input) {
    final normalized = normalizeForSearch(input.replaceAll(_apostrophes, ''));
    final tokens = normalized.split(' ').where((t) => t.isNotEmpty).toList();
    if (tokens.length > 1 && _surahWords.contains(tokens.first)) {
      tokens.removeAt(0);
    }
    if (tokens.length > 1 && _articles.contains(tokens.first)) {
      tokens.removeAt(0);
    }
    if (tokens.isEmpty) return '';

    var key = tokens.join();
    if (hasArabicScript(key)) {
      // Arabic: drop a glued definite article.
      return key.startsWith('ال') && key.length > 3 ? key.substring(2) : key;
    }
    // Latin transliteration: doubled letters, e/i and o/u, and a final h are
    // all spelled inconsistently ("Yaseen" / "Yasin", "Baqarah" / "Baqara").
    key = key
        .replaceAllMapped(_doubled, (m) => m.group(1)!)
        .replaceAll('e', 'i')
        .replaceAll('o', 'u')
        .replaceAllMapped(_doubled, (m) => m.group(1)!);
    if (key.length > 3 && key.endsWith('h')) {
      key = key.substring(0, key.length - 1);
    }
    return key;
  }
}
