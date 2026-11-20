import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/quran/indopak.dart';
import 'package:quran_app/core/quran/references.dart';
import 'package:quran_app/core/quran/verse_end.dart';

import '../helpers/font_cmap.dart';
import '../helpers/test_databases.dart';

/// The bundled Indo-Pak text, checked verse by verse against its own numbers
/// and against the font that draws it.
void main() {
  final font = fontCodePoints('assets/fonts/IndoPakNastaleeq-Regular.ttf');

  late List<({String key, int ayah, String text, bool sajdah})> verses;

  setUpAll(() async {
    final db = await openBundledContentDb();
    final rows = await db
        .customSelect(
          'SELECT verse_key, ayah_number, text_indopak, sajdah_type '
          'FROM ayah ORDER BY id',
        )
        .get();
    await db.close();
    verses = [
      for (final r in rows)
        (
          key: r.read<String>('verse_key'),
          ayah: r.read<int>('ayah_number'),
          text: r.read<String>('text_indopak'),
          sajdah: r.read<String?>('sajdah_type') != null,
        ),
    ];
  });

  test('every verse is present and non-empty', () {
    expect(verses, hasLength(totalAyahCount));
    for (final v in verses) {
      expect(v.text.trim(), isNotEmpty, reason: v.key);
    }
  });

  test('every verse ends with the verse-end glyph of its own number', () {
    for (final v in verses) {
      final ends = v.text.runes.where((c) => indopakVerseEndNumber(c) != null);
      expect(ends, hasLength(1), reason: v.key);
      expect(indopakVerseEndNumber(ends.single), v.ayah, reason: v.key);
      expect(
        indopakSajdahVerseEnds.contains(ends.single),
        v.sajdah,
        reason: '${v.key}: sajdah sign',
      );
    }
  });

  test('al-Fatihah is numbered 1..7 and opens with the basmalah', () {
    final fatiha = verses.where((v) => v.key.startsWith('1:')).toList();
    expect(fatiha, hasLength(7));
    for (final v in fatiha) {
      expect(v.text.runes.last, 0xF4FF + v.ayah, reason: v.key);
    }
    expect(fatiha.first.text, '$indopakBasmalah \u06DF${indopakVerseEnd(1)}');
  });

  test('no surah opening repeats the basmalah shown in its header', () {
    final prefix = indopakBasmalah.split(' ').first;
    for (final v in verses.where((v) => v.ayah == 1 && v.key != '1:1')) {
      expect(v.text.startsWith(prefix), isFalse, reason: v.key);
    }
  });

  test('the font draws every verse-end glyph', () {
    expect(
      [
        for (var n = 1; n <= 286; n++) indopakVerseEnd(n).runes.single,
        ...indopakComposedVerseEnds.keys,
      ].where((c) => !font.contains(c)),
      isEmpty,
    );
  });

  test('display text only makes the last space unbreakable', () {
    for (final v in verses) {
      final shown = keepVerseEndOnLine(v.text);
      expect(shown.length, v.text.length, reason: v.key);
      expect(shown.replaceAll('\u00A0', ' '), v.text, reason: v.key);
      expect('\u00A0'.allMatches(shown), hasLength(1), reason: v.key);
    }
  });
}
