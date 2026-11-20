/// A verse of the IndoPak Nastaleeq text (which ends with its own verse-end
/// glyph) ready to render: its last space, the one before that glyph, becomes
/// a no-break space, so the glyph never wraps onto a line of its own.
///
/// The font has no U+00A0, so HarfBuzz draws its space glyph in its place:
/// the shaped result is identical for every verse (checked over all 6236).
String keepVerseEndOnLine(String text) {
  final i = text.lastIndexOf(' ');
  return i < 0 ? text : text.replaceRange(i, i + 1, '\u00A0');
}
