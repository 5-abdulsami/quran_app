// The QPC Nastaleeq text: the King Fahd Complex's Indo-Pak (Nastaleeq) Quran
// text, drawn by its "KFGQPC Nastaleeq" font.
//
// Source: QUL (qul.tarteel.ai) "QPC Nastaleeq script - Word by Word", kept in
// tool/sources/ and joined into verses by tool/build_quran_db.dart. The two
// must always be used together: the text's waqf, ruku and sajdah signs are
// code points from U+FD30–FDFF that the font draws as those signs (any other
// font would show unrelated ligatures), so it is only ever rendered in it.
//
// Every verse ends with its number as a separate word: Arabic-Indic digits,
// which the font draws inside a verse-end circle, optionally followed by the
// signs shown above that circle. So, like the IndoPak Nastaleeq text and
// unlike the Uthmani one, no ornament is appended when it is shown.

/// The basmalah in this text (al-Fatihah 1:1 without its verse number),
/// from code points so the characters are reviewable.
///
///   ba kasra / sin sukun / mim kasra / space
///   alef lam lam shadda superscript-alef ha kasra / space
///   alef lam ra shadda fatha ha sukun mim superscript-alef nun kasra / space
///   alef lam ra shadda fatha ha kasra yeh sukun mim kasra
final String qpcNastaleeqBasmalah = String.fromCharCodes(const [
  0x0628, 0x0650, 0x0633, 0x0652, 0x0645, 0x0650, 0x0020, //
  0x0627, 0x0644, 0x0644, 0x0651, 0x0670, 0x0647, 0x0650, 0x0020,
  0x0627, 0x0644, 0x0631, 0x0651, 0x064e, 0x062d, 0x0652, 0x0645, 0x0670,
  0x0646, 0x0650, 0x0020,
  0x0627, 0x0644, 0x0631, 0x0651, 0x064e, 0x062d, 0x0650, 0x064a, 0x0652,
  0x0645, 0x0650,
]);

/// The signs that may follow a verse number: U+FD30–FDFF, each drawn by the
/// font as a waqf, ruku, hizb or sajdah sign.
bool isQpcNastaleeqSign(int code) => code >= 0xFD30 && code <= 0xFDFF;

/// The verse-end signs that include "السجدة" (checked by eye against the
/// font). This text follows the Hanafi Indo-Pak mushaf, which does not mark
/// 22:77 as a sajdah; every other sajdah verse carries one of these.
const Set<int> qpcNastaleeqSajdahSigns = {0xFDB6, 0xFDB7, 0xFDC2, 0xFDF3};
