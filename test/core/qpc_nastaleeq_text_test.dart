import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/quran/qpc_nastaleeq.dart';
import 'package:quran_app/core/quran/references.dart';
import 'package:quran_app/core/quran/verse_end.dart';
import 'package:quran_app/core/text/arabic_digits.dart';

import '../helpers/font_cmap.dart';
import '../helpers/test_databases.dart';

/// The bundled QPC Nastaleeq text, checked verse by verse against its own
/// numbers and against the KFGQPC Nastaleeq font that draws it.
void main() {
  final font = fontCodePoints('assets/fonts/KFGQPCNastaleeq-Regular.ttf');

  late List<({String key, int ayah, String text, bool sajdah})> verses;

  setUpAll(() async {
    final db = await openBundledContentDb();
    final rows = await db
        .customSelect(
          'SELECT verse_key, ayah_number, text_qpc_nastaleeq, sajdah_type '
          'FROM ayah ORDER BY id',
        )
        .get();
    await db.close();
    verses = [
      for (final r in rows)
        (
          key: r.read<String>('verse_key'),
          ayah: r.read<int>('ayah_number'),
          text: r.read<String>('text_qpc_nastaleeq'),
          sajdah: r.read<String?>('sajdah_type') != null,
        ),
    ];
  });

  test('every verse is present and drawn by the font', () {
    expect(verses, hasLength(totalAyahCount));
    final missing = {
      for (final v in verses) ...v.text.runes.where((c) => !font.contains(c)),
    }..remove(0x20);
    expect(missing, isEmpty);
  });

  test('every verse ends with its own number, then only verse-end signs', () {
    for (final v in verses) {
      final end = v.text.substring(v.text.lastIndexOf(' ') + 1);
      final digits = toArabicIndicDigits(v.ayah);
      expect(end, startsWith(digits), reason: v.key);
      expect(
        end.substring(digits.length).runes.every(isQpcNastaleeqSign),
        isTrue,
        reason: v.key,
      );
      // No other number anywhere in the verse.
      expect(
        RegExp('[\u0660-\u0669]').allMatches(v.text).length,
        digits.length,
        reason: v.key,
      );
    }
  });

  test('sajdah signs match the sajdah verses (22:77 is Shafi\'i only)', () {
    for (final v in verses) {
      final signed = v.text.runes.any(qpcNastaleeqSajdahSigns.contains);
      expect(signed, v.sajdah && v.key != '22:77', reason: v.key);
    }
  });

  test(
    'al-Fatihah opens with the basmalah numbered 1; no surah repeats it',
    () {
      expect(verses.first.text, '$qpcNastaleeqBasmalah \u0661');
      final prefix = qpcNastaleeqBasmalah.split(' ').first;
      for (final v in verses.where((v) => v.ayah == 1 && v.key != '1:1')) {
        expect(v.text.startsWith(prefix), isFalse, reason: v.key);
      }
    },
  );

  test('display text only makes the space before the number unbreakable', () {
    for (final v in verses) {
      final shown = keepVerseEndOnLine(v.text);
      expect(shown.replaceAll('\u00A0', ' '), v.text, reason: v.key);
      expect('\u00A0'.allMatches(shown), hasLength(1), reason: v.key);
    }
  });
}
