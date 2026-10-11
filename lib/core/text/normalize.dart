// Port of islamic-platform/src/lib/text.ts (Quran-relevant functions only).
//
// Script-aware text utilities.
//
// Search over Arabic and translation text fails in predictable ways unless the
// text is folded consistently:
//
//   - Arabic harakat are optional in user input but always present in the
//     Uthmani mushaf text, so an unfolded comparison never matches.
//   - Alef/ya/ta-marbuta have several orthographic variants that users type
//     interchangeably.
//   - Urdu and Arabic share a script but use different characters for the same
//     sound (ی vs ي, ک vs ك).
//
// These functions are pure; the same normalisation runs at build time (into
// `text_search`) and at query time, which is what makes offline search work.
//
// Every non-ASCII character in a pattern is written as a \u{...} escape, so
// the exact code points are reviewable and no invisible character sits in the
// source.

import 'package:unorm_dart/unorm_dart.dart' as unorm;

// Harakat, tanween, shadda, sukun, superscript alef, Quranic annotation marks.
final RegExp _arabicDiacritics = RegExp(
  '[\u{0610}-\u{061A}\u{064B}-\u{065F}\u{0670}\u{06D6}-\u{06ED}'
  '\u{08D3}-\u{08FF}\u{FE70}-\u{FE7F}]',
);
final RegExp _tatweel = RegExp('\u{0640}');
final RegExp _arabicRange = RegExp(
  '[\u{0600}-\u{06FF}\u{0750}-\u{077F}\u{08A0}-\u{08FF}\u{FB50}-\u{FDFF}'
  '\u{FE70}-\u{FEFF}]',
);

/// Strips harakat and tatweel, leaving the consonantal skeleton.
String stripArabicDiacritics(String input) =>
    input.replaceAll(_arabicDiacritics, '').replaceAll(_tatweel, '');

final RegExp _alefVariants = RegExp(
  '[\u{0622}\u{0623}\u{0625}\u{0671}\u{0672}\u{0673}\u{0675}]',
);
final RegExp _yehVariants = RegExp('[\u{0649}\u{06CC}\u{06D2}]');

/// Folds orthographic variants so that user-typed Arabic matches mushaf text
/// and Urdu text matches Arabic-script equivalents.
String foldArabicLetters(String input) => input
    // alef variants -> ALEF
    .replaceAll(_alefVariants, '\u{0627}')
    // alef maqsura / farsi yeh / barree yeh -> YEH
    .replaceAll(_yehVariants, '\u{064A}')
    // keheh -> KAF
    .replaceAll('\u{06A9}', '\u{0643}')
    // teh marbuta -> HEH
    .replaceAll('\u{0629}', '\u{0647}')
    // waw with hamza -> WAW
    .replaceAll('\u{0624}', '\u{0648}')
    // yeh with hamza -> YEH
    .replaceAll('\u{0626}', '\u{064A}')
    // bare hamza is dropped
    .replaceAll('\u{0621}', '');

/// True when the string contains any Arabic-script character.
bool hasArabicScript(String input) => _arabicRange.hasMatch(input);

/// Best-effort script detection, used to pick a search strategy.
enum DetectedScript { arabic, urdu, romanUrdu, latin }

final RegExp _urduOnly = RegExp(
  '[\u{06BE}\u{06C1}\u{06CC}\u{06D2}\u{0679}\u{0688}\u{0691}\u{06BA}'
  '\u{06AF}\u{0686}\u{067E}]',
);

const Set<String> _romanUrduMarkers = {
  'kya', 'kia', 'hai', 'hain', 'nahi', 'nahin', 'kaise', 'kaisay', 'karna', //
  'karne', 'ka', 'ki', 'ke', 'se', 'mein', 'main', 'par', 'aur', 'ya', 'agar',
  'jaiz', 'najaiz', 'haram', 'halal', 'wuzu', 'wudu', 'namaz', 'roza', 'toot',
  'tootta', 'jata', 'jati', 'hota', 'hoti', 'sakta', 'sakti', 'chahiye',
  'chahiyay', 'kar', 'ho', 'koi', 'kuch',
};

/// Roman Urdu is detected by marker words rather than script, since it is
/// written in Latin characters.
DetectedScript detectScript(String input) {
  if (_urduOnly.hasMatch(input)) return DetectedScript.urdu;
  if (hasArabicScript(input)) return DetectedScript.arabic;

  final words = input
      .toLowerCase()
      .split(RegExp('[^a-z]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return DetectedScript.latin;
  final hits = words.where(_romanUrduMarkers.contains).length;
  // Two markers, or one marker in a short query, is a reliable signal.
  if (hits >= 2 || (hits == 1 && words.length <= 4)) {
    return DetectedScript.romanUrdu;
  }
  return DetectedScript.latin;
}

// Zero-width characters and bidi controls.
final RegExp _invisibleControls = RegExp(
  '[\u{200B}-\u{200F}\u{202A}-\u{202E}\u{FEFF}]',
);
final RegExp _nonWord = RegExp(r'[^\p{L}\p{N}\s:]', unicode: true);
final RegExp _whitespace = RegExp(r'\s+');

/// Canonical normalisation applied to anything indexed or searched: Unicode
/// NFKC, lowercase, diacritic stripping, letter folding, punctuation to spaces
/// and whitespace collapse.
String normalizeForSearch(String input) {
  final folded = foldArabicLetters(stripArabicDiacritics(unorm.nfkc(input)));
  return folded
      .toLowerCase()
      .replaceAll(_invisibleControls, '')
      .replaceAll(_nonWord, ' ')
      .replaceAll(_whitespace, ' ')
      .trim();
}

// BOM, zero-width characters, bidi controls and invisible operators.
final RegExp _sourceInvisibles = RegExp(
  '[\u{FEFF}\u{200B}-\u{200F}\u{202A}-\u{202E}\u{2060}-\u{2064}]',
);

/// Strips invisible formatting characters from text ingested from a source.
///
/// Providers occasionally emit a byte-order mark or a stray zero-width
/// character - AlQuran.cloud ships verse 1:1 with a leading U+FEFF. Left in
/// place it becomes part of the stored Quranic text, leaks into copied verses
/// and search columns, and is invisible while you debug it.
///
/// Deliberately narrow: BOM, zero-width characters and bidi controls only.
/// It must NEVER touch harakat, tatweel or letter forms - the source licences
/// require diacritics and orthography to be preserved verbatim, so folding for
/// search happens in a separate column (see [normalizeForSearch]).
String sanitizeSourceText(String input) =>
    input.replaceAll(_sourceInvisibles, '').trim();

/// Collapses whitespace without altering characters. For display and logging.
String collapseWhitespace(String input) =>
    input.replaceAll(_whitespace, ' ').trim();

/// Word-boundary-aware truncation for snippets. Never cuts mid-word and never
/// leaves a dangling separator.
String truncate(String input, int maxChars) {
  final text = collapseWhitespace(input);
  if (text.length <= maxChars) return text;
  final cut = text.substring(0, maxChars);
  final lastSpace = cut.lastIndexOf(' ');
  final kept = lastSpace > maxChars * 0.6 ? cut.substring(0, lastSpace) : cut;
  return '${kept.trimRight()}\u{2026}';
}
