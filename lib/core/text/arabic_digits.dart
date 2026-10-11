// Conversions between Western, Arabic-Indic and Extended (Persian/Urdu)
// Arabic-Indic digits. Pure Dart, used by the reference parser and the
// end-of-ayah marker.

const int _arabicIndicZero = 0x0660; // ٠
const int _extendedArabicIndicZero = 0x06F0; // ۰ (Persian / Urdu)

/// Renders [value] in Arabic-Indic digits, e.g. 255 -> ٢٥٥.
String toArabicIndicDigits(int value) => String.fromCharCodes(
  value.toString().codeUnits.map((c) => _arabicIndicZero + (c - 0x30)),
);

/// Replaces Arabic-Indic and Persian digits with ASCII digits, leaving every
/// other character untouched.
String toAsciiDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= _arabicIndicZero && rune <= _arabicIndicZero + 9) {
      buffer.writeCharCode(0x30 + rune - _arabicIndicZero);
    } else if (rune >= _extendedArabicIndicZero &&
        rune <= _extendedArabicIndicZero + 9) {
      buffer.writeCharCode(0x30 + rune - _extendedArabicIndicZero);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// U+06DD ARABIC END OF AYAH followed by the verse number in Arabic-Indic
/// digits. Fonts with Quranic support (Amiri Quran) compose the digits inside
/// the ornament.
String endOfAyahMarker(int ayahNumber) =>
    '\u{06DD}${toArabicIndicDigits(ayahNumber)}';
