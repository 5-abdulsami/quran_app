// Port of islamic-platform/src/modules/quran/bismillah.ts
//
// Bismillah presentation.
//
// THE PROBLEM
//
// The Uthmani text supplied by our source prepends the basmalah to the first
// ayah of every surah except at-Tawbah. A surah screen also renders the
// basmalah in its header, so the opening verse appeared twice:
//
//   بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ        <- header
//   بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ الٓمٓ   <- ayah 1, duplicated
//
// THE APPROACH
//
// The canonical text in `ayah.text_uthmani` is NEVER modified. This is a
// presentation concern, so it is solved in a presentation function: the stored
// verse stays exactly as the source supplied it, and the reader is shown the
// basmalah once.
//
// WHY NOT A STRING REPLACE
//
// Verified against the corpus, three things break a naive
// `text.replaceAll(basmalah, '')`:
//
//   1. TWO ORTHOGRAPHIC VARIANTS. Surahs 95 and 97 spell it with a shadda on
//      the ba (U+0628 U+0651 U+0650) where the other 111 use a bare kasra
//      (U+0628 U+0650). A literal match silently misses those two surahs.
//
//   2. AL-FATIHAH. Its basmalah is not a preface — it IS ayah 1 of 7, by the
//      counting this mushaf uses. Stripping it would delete a verse and shift
//      every verse number in the surah.
//
//   3. AN-NAML 27:30. The basmalah appears legitimately *inside* that verse,
//      quoting Sulayman's letter. A global replace would mutilate it.
//
// So matching is done on the diacritic-folded form (which makes both variants
// identical), only ever against the *start* of ayah 1, and only for surahs
// where `bismillahPre` is true — which the build script sets to false for
// both al-Fatihah and at-Tawbah.

import '../text/normalize.dart';

/// The basmalah, from code points.
///
/// Written this way rather than pasted so the exact characters are reviewable
/// and cannot be silently normalised by an editor or a transport layer.
///
///   ba kasra / sin sukun / mim kasra / space
///   alef-wasla lam lam shadda fatha ha kasra / space
///   alef-wasla lam ra shadda fatha ha sukun mim fatha superscript-alef nun kasra / space
///   alef-wasla lam ra shadda fatha ha kasra ya mim kasra
///
/// (`BASMALAH` in the TypeScript original; renamed to Dart style.)
final String basmalah = String.fromCharCodes(const [
  0x0628, 0x0650, 0x0633, 0x0652, 0x0645, 0x0650, 0x0020, //
  0x0671, 0x0644, 0x0644, 0x0651, 0x064e, 0x0647, 0x0650, 0x0020,
  0x0671, 0x0644, 0x0631, 0x0651, 0x064e, 0x062d, 0x0652, 0x0645, 0x064e,
  0x0670, 0x0646, 0x0650, 0x0020,
  0x0671, 0x0644, 0x0631, 0x0651, 0x064e, 0x062d, 0x0650, 0x064a, 0x0645,
  0x0650,
]);

final RegExp _whitespace = RegExp(r'\s+');
final RegExp _leadingWhitespace = RegExp(r'^\s+');

/// Comparison key: diacritics removed, whitespace collapsed.
String _fold(String input) =>
    stripArabicDiacritics(input).replaceAll(_whitespace, ' ').trim();

final String _foldedBasmalah = _fold(basmalah);

/// True for an Arabic combining mark: harakat, tanween, shadda, sukun,
/// superscript alef and the Quranic annotation marks.
///
/// These attach to the preceding consonant, so a split must never fall between
/// a consonant and its marks.
bool _isCombiningMark(int code) =>
    (code >= 0x0610 && code <= 0x061a) ||
    (code >= 0x064b && code <= 0x065f) ||
    code == 0x0670 ||
    (code >= 0x06d6 && code <= 0x06ed) ||
    (code >= 0x08d3 && code <= 0x08ff);

/// The result of separating a leading basmalah from a verse.
class SplitVerse {
  const SplitVerse({
    required this.bismillah,
    required this.text,
    required this.separated,
  });

  /// The basmalah, exactly as it appeared in the source, or null.
  final String? bismillah;

  /// The verse with the leading basmalah removed, or the verse unchanged.
  final String text;

  /// True when a leading basmalah was found and separated.
  final bool separated;

  @override
  String toString() =>
      'SplitVerse(separated: $separated, bismillah: $bismillah, text: $text)';
}

/// Splits a leading basmalah off a verse, preserving the original characters.
///
/// Walks the original string accumulating its folded form until that matches
/// the folded basmalah. This is what makes both orthographic variants work: the
/// comparison ignores diacritics, but the text returned is sliced from the
/// original, so nothing is normalised, reordered or lost.
///
/// Iterates by Unicode code point (`runes`), matching JavaScript's `[...text]`.
///
/// Returns the verse untouched when no leading basmalah is present.
SplitVerse splitLeadingBismillah(String text) {
  final characters = text.runes.toList();
  final accumulated = StringBuffer();

  for (var i = 0; i < characters.length; i += 1) {
    accumulated.writeCharCode(characters[i]);
    final folded = _fold(accumulated.toString());

    if (folded.length > _foldedBasmalah.length) break;

    if (folded == _foldedBasmalah) {
      // The folded comparison ignores diacritics, so it matches as soon as the
      // last CONSONANT is consumed - before that consonant's own vowel mark.
      // Splitting there would strand a combining kasra at the head of the
      // verse and corrupt both halves. Advance over any trailing combining
      // marks so the split falls on a grapheme boundary.
      var end = i;
      while (end + 1 < characters.length &&
          _isCombiningMark(characters[end + 1])) {
        end += 1;
      }

      final bismillah = String.fromCharCodes(characters.sublist(0, end + 1));
      final remainder = String.fromCharCodes(
        characters.sublist(end + 1),
      ).replaceFirst(_leadingWhitespace, '');
      // A surah whose ayah 1 is the basmalah and nothing else (al-Fatihah) has
      // no remainder. Never return an empty verse: that would delete a verse.
      if (remainder.isEmpty) {
        return SplitVerse(bismillah: null, text: text, separated: false);
      }
      return SplitVerse(bismillah: bismillah, text: remainder, separated: true);
    }
  }

  return SplitVerse(bismillah: null, text: text, separated: false);
}

/// Whether a surah's header should render a standalone basmalah.
///
/// Mirrors `surah.bismillah_pre`, which the build script sets from a
/// structural fact about the mushaf rather than from a provider field:
///
///   - al-Fatihah (1): false. Its basmalah is counted as ayah 1, so the header
///     must not repeat it.
///   - at-Tawbah (9): false. It has no basmalah at all.
///   - every other surah: true.
bool shouldRenderHeaderBismillah(int surahNumber, {required bool bismillahPre}) {
  if (surahNumber == 1 || surahNumber == 9) return false;
  return bismillahPre;
}

/// The single entry point every Quran view uses.
///
/// Centralised deliberately: the alternative is a `surah == 9` condition
/// scattered through the surah reader, the juz reader, search results, copied
/// text and bookmarks, where one of them will eventually be missed.
///
/// `separated` is only ever true when the header is rendering the basmalah, so
/// the text is shown exactly once no matter which view is asking.
SplitVerse presentVerse({
  required int surahNumber,
  required int ayahNumber,
  required String text,
  required bool bismillahPre,
}) {
  // Only ayah 1 can carry a prefixed basmalah. 27:30 contains it mid-surah,
  // legitimately, and must never be touched.
  if (ayahNumber != 1) {
    return SplitVerse(bismillah: null, text: text, separated: false);
  }

  if (!shouldRenderHeaderBismillah(surahNumber, bismillahPre: bismillahPre)) {
    return SplitVerse(bismillah: null, text: text, separated: false);
  }

  return splitLeadingBismillah(text);
}
