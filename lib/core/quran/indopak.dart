// The Indo-Pak (Nastaleeq) Quran text, as familiar from South Asian mushafs.
//
// Source: Quran.com's `indopak_nastaleeq` text, which QUL (qul.tarteel.ai)
// pairs with the "IndoPak Nastaleeq" font by QuranWBW. The two must always be
// used together: the text's waqf signs, ruku and hizb markers and verse-end
// circles are private-use code points (U+E000–F8FF) that only that font draws.
//
// Every verse ends with its own verse-end glyph: a circle holding the verse
// number, or a composed glyph that also carries the ruku or sajdah sign above
// it. So unlike the Uthmani text, no ornament is appended when it is shown.

/// The basmalah in the Indo-Pak text (al-Fatihah 1:1 without its verse end),
/// from code points so the characters are reviewable.
///
///   ba kasra / sin sukun / mim kasra / space
///   alef lam lam shadda superscript-alef ha kasra / space
///   alef lam ra shadda fatha ha sukun mim superscript-alef nun kasra / space
///   alef lam ra shadda fatha ha kasra farsi-yeh sukun mim kasra
final String indopakBasmalah = String.fromCharCodes(const [
  0x0628, 0x0650, 0x0633, 0x0652, 0x0645, 0x0650, 0x0020, //
  0x0627, 0x0644, 0x0644, 0x0651, 0x0670, 0x0647, 0x0650, 0x0020,
  0x0627, 0x0644, 0x0631, 0x0651, 0x064e, 0x062d, 0x0652, 0x0645, 0x0670,
  0x0646, 0x0650, 0x0020,
  0x0627, 0x0644, 0x0631, 0x0651, 0x064e, 0x062d, 0x0650, 0x06cc, 0x0652,
  0x0645, 0x0650,
]);

/// The font's plain verse-end circle numbered [ayah] (1..286):
/// U+F500 is ١, U+F501 is ٢, and so on.
String indopakVerseEnd(int ayah) {
  assert(ayah >= 1 && ayah <= 286, 'no verse-end glyph for $ayah');
  return String.fromCharCode(0xF4FF + ayah);
}

/// Composed verse-end glyphs (number plus the ruku/sajdah signs drawn above
/// it), by code point, with the verse number each one shows. Checked by eye
/// against the font, glyph by glyph; the build validates every verse against
/// this table or [indopakVerseEnd].
const Map<int, int> indopakComposedVerseEnds = {
  0xF631: 6, 0xF632: 11, 0xF633: 18, 0xF634: 31, 0xF636: 44, 0xF637: 54,
  0xF638: 58, 0xF639: 60, 0xF63A: 69, 0xF63C: 171, 0xF63D: 208,
  0xF690: 36, 0xF691: 91, 0xF595: 150,
  // With the sajdah sign ("السجدة").
  0xF681: 15, 0xF683: 19, 0xF684: 21, 0xF685: 24, 0xF686: 26, 0xF687: 38,
  0xF688: 50, 0xF689: 58, 0xF68A: 60, 0xF68C: 62, 0xF68D: 109, 0xF68E: 206,
  0xF692: 18, 0xF693: 77,
};

/// The composed glyphs that carry the sajdah sign.
const Set<int> indopakSajdahVerseEnds = {
  0xF681,
  0xF683,
  0xF684,
  0xF685,
  0xF686,
  0xF687,
  0xF688,
  0xF689,
  0xF68A,
  0xF68C,
  0xF68D,
  0xF68E,
  0xF692,
  0xF693,
};

/// The verse number shown by the verse-end glyph [code], or null when [code]
/// is not a verse-end glyph.
int? indopakVerseEndNumber(int code) {
  if (code >= 0xF500 && code <= 0xF61D) return code - 0xF4FF;
  return indopakComposedVerseEnds[code];
}
