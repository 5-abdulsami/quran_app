// Port of islamic-platform/tests/unit/bismillah.test.ts, plus a corpus test
// against the bundled database.
//
// Religious source data, so the tests are about what must NEVER happen as much
// as what should. Every case here corresponds to a way a naive string replace
// would corrupt the mushaf.
//
// Fixtures are built from code points: combining marks are unreviewable as
// glyphs and an editor can silently renormalise them.

import 'package:flutter_test/flutter_test.dart' hide collapseWhitespace;
import 'package:quran_app/core/db/content_db.dart';
import 'package:quran_app/core/quran/bismillah.dart';
import 'package:quran_app/core/text/normalize.dart';

import '../../helpers/test_databases.dart';

String ch(List<int> codes) => String.fromCharCodes(codes);

/// The shadda-on-ba variant used by surahs 95 and 97.
final basmalahShadda = ch(const [
  0x0628, 0x0651, 0x0650, 0x0633, 0x0652, 0x0645, 0x0650, 0x0020, //
  0x0671, 0x0644, 0x0644, 0x0651, 0x064e, 0x0647, 0x0650, 0x0020,
  0x0671, 0x0644, 0x0631, 0x0651, 0x064e, 0x062d, 0x0652, 0x0645, 0x064e,
  0x0670, 0x0646, 0x0650, 0x0020,
  0x0671, 0x0644, 0x0631, 0x0651, 0x064e, 0x062d, 0x0650, 0x064a, 0x0645,
  0x0650,
]);

/// "alif lam mim", the whole of al-Baqarah 2:1 after its basmalah.
final alifLamMim = ch(const [0x0627, 0x0653, 0x0644, 0x0653, 0x0645, 0x0653]);

/// A combining mark, for the grapheme-boundary tests.
final kasra = ch(const [0x0650]);

bool isCombining(String s) {
  final c = s.runes.isEmpty ? 0 : s.runes.first;
  return (c >= 0x0610 && c <= 0x061a) ||
      (c >= 0x064b && c <= 0x065f) ||
      c == 0x0670 ||
      (c >= 0x06d6 && c <= 0x06ed);
}

final _whitespace = RegExp(r'\s+');

void main() {
  group('splitLeadingBismillah', () {
    test('separates a leading basmalah from the verse', () {
      final result = splitLeadingBismillah('$basmalah $alifLamMim');
      expect(result.separated, isTrue);
      expect(result.bismillah, basmalah);
      expect(result.text, alifLamMim);
    });

    test('handles the shadda orthographic variant used by surahs 95 and 97', () {
      // The single most likely thing to break: a literal string match misses
      // this spelling entirely and those two surahs silently keep a duplicate.
      final result = splitLeadingBismillah('$basmalahShadda $alifLamMim');
      expect(result.separated, isTrue);
      expect(result.text, alifLamMim);
      // The ORIGINAL spelling is returned, not the canonical one.
      expect(result.bismillah, basmalahShadda);
    });

    test('never strands a combining mark at the start of the verse', () {
      // The folded comparison matches on the last consonant, before its vowel
      // mark. Splitting there would corrupt both halves.
      final result = splitLeadingBismillah('$basmalah $alifLamMim');
      expect(isCombining(result.text), isFalse);
      expect(result.bismillah?.endsWith(kasra), isTrue);
    });

    test('is lossless: the two halves reconstruct the original', () {
      final original = '$basmalah $alifLamMim';
      final result = splitLeadingBismillah(original);
      final rebuilt = '${result.bismillah} ${result.text}';
      expect(
        rebuilt.replaceAll(_whitespace, ' '),
        original.replaceAll(_whitespace, ' '),
      );
    });

    test('refuses to split when the basmalah is the entire verse', () {
      // Al-Fatihah 1:1. Splitting would delete a verse and shift every verse
      // number in the surah.
      final result = splitLeadingBismillah(basmalah);
      expect(result.separated, isFalse);
      expect(result.text, basmalah);
    });

    test('leaves a verse with no leading basmalah untouched', () {
      final result = splitLeadingBismillah(alifLamMim);
      expect(result.separated, isFalse);
      expect(result.text, alifLamMim);
    });

    test('does not match a basmalah that appears later in the verse', () {
      // An-Naml 27:30 quotes the basmalah mid-verse. A global replace
      // mutilates it.
      final verse = '$alifLamMim $basmalah';
      final result = splitLeadingBismillah(verse);
      expect(result.separated, isFalse);
      expect(result.text, verse);
    });

    test('handles empty input without throwing', () {
      expect(splitLeadingBismillah('').separated, isFalse);
    });
  });

  group('shouldRenderHeaderBismillah', () {
    test('is false for al-Fatihah, whose basmalah is ayah 1', () {
      expect(shouldRenderHeaderBismillah(1, bismillahPre: true), isFalse);
    });

    test('is false for at-Tawbah, which has no basmalah', () {
      expect(shouldRenderHeaderBismillah(9, bismillahPre: true), isFalse);
      expect(shouldRenderHeaderBismillah(9, bismillahPre: false), isFalse);
    });

    test('is true for an ordinary surah', () {
      for (final surah in [2, 27, 95, 97, 114]) {
        expect(shouldRenderHeaderBismillah(surah, bismillahPre: true), isTrue);
      }
    });

    test('respects a stored false, so the database remains authoritative', () {
      expect(shouldRenderHeaderBismillah(2, bismillahPre: false), isFalse);
    });
  });

  group('presentVerse', () {
    final verse = '$basmalah $alifLamMim';

    test('separates for an ordinary surah', () {
      final result = presentVerse(
        surahNumber: 2,
        ayahNumber: 1,
        text: verse,
        bismillahPre: true,
      );
      expect(result.separated, isTrue);
      expect(result.text, alifLamMim);
    });

    test('never separates for al-Fatihah', () {
      // The header renders nothing, so ayah 1 must render in full.
      final result = presentVerse(
        surahNumber: 1,
        ayahNumber: 1,
        text: basmalah,
        bismillahPre: false,
      );
      expect(result.separated, isFalse);
      expect(result.text, basmalah);
    });

    test('never separates for at-Tawbah', () {
      final result = presentVerse(
        surahNumber: 9,
        ayahNumber: 1,
        text: alifLamMim,
        bismillahPre: false,
      );
      expect(result.separated, isFalse);
      expect(result.text, alifLamMim);
    });

    test('never touches any ayah other than the first', () {
      // 27:30 is the case that matters, but the rule is general.
      for (final ayahNumber in [2, 30, 286]) {
        final result = presentVerse(
          surahNumber: 27,
          ayahNumber: ayahNumber,
          text: verse,
          bismillahPre: true,
        );
        expect(result.separated, isFalse);
        expect(result.text, verse);
      }
    });

    test(
      'handles both orthographic variants through the public entry point',
      () {
        for (final surah in [95, 97]) {
          final result = presentVerse(
            surahNumber: surah,
            ayahNumber: 1,
            text: '$basmalahShadda $alifLamMim',
            bismillahPre: true,
          );
          expect(result.separated, isTrue, reason: 'surah $surah');
          expect(result.text, alifLamMim);
        }
      },
    );
  });

  group('corpus (bundled database)', () {
    late ContentDatabase db;
    late List<_Row> rows;

    setUpAll(() async {
      db = await openBundledContentDb();
      final result = await db
          .customSelect(
            'SELECT a.surah_number, a.ayah_number, a.verse_key, '
            'a.text_uthmani, s.bismillah_pre FROM ayah a '
            'JOIN surah s ON s.number = a.surah_number ORDER BY a.id',
          )
          .get();
      rows = [
        for (final r in result)
          _Row(
            surah: r.read<int>('surah_number'),
            ayah: r.read<int>('ayah_number'),
            verseKey: r.read<String>('verse_key'),
            text: r.read<String>('text_uthmani'),
            bismillahPre: r.read<bool>('bismillah_pre'),
          ),
      ];
    });
    tearDownAll(() => db.close());

    SplitVerse present(_Row r) => presentVerse(
      surahNumber: r.surah,
      ayahNumber: r.ayah,
      text: r.text,
      bismillahPre: r.bismillahPre,
    );

    test('all 112 header-basmalah surahs separate on ayah 1', () {
      final firsts = rows.where((r) => r.ayah == 1).toList();
      expect(firsts, hasLength(114));
      var separated = 0;
      for (final r in firsts) {
        final result = present(r);
        final header = shouldRenderHeaderBismillah(
          r.surah,
          bismillahPre: r.bismillahPre,
        );
        expect(result.separated, header, reason: r.verseKey);
        if (result.separated) {
          separated++;
          expect(result.text.trim(), isNotEmpty, reason: r.verseKey);
          expect(isCombining(result.text), isFalse, reason: r.verseKey);
        }
      }
      expect(separated, 112);
    });

    test('1:1, 9:1 and 27:30 are shown unchanged', () {
      for (final key in ['1:1', '9:1', '27:30']) {
        final r = rows.firstWhere((x) => x.verseKey == key);
        final result = present(r);
        expect(result.separated, isFalse, reason: key);
        expect(result.text, r.text, reason: key);
      }
      // 27:30 really does contain the basmalah mid-verse.
      final naml = rows.firstWhere((x) => x.verseKey == '27:30');
      expect(
        stripArabicDiacritics(naml.text),
        contains(stripArabicDiacritics(basmalah)),
      );
    });

    test('no ayah has an empty display text', () {
      for (final r in rows) {
        expect(present(r).text.trim(), isNotEmpty, reason: r.verseKey);
      }
    });

    test('every split rebuilds the stored text exactly', () {
      for (final r in rows) {
        final result = present(r);
        if (!result.separated) continue;
        expect(
          collapseWhitespace('${result.bismillah} ${result.text}'),
          collapseWhitespace(r.text),
          reason: r.verseKey,
        );
      }
    });

    test('surahs 95 and 97 carry the shadda variant in the real data', () {
      for (final surah in [95, 97]) {
        final r = rows.firstWhere((x) => x.surah == surah && x.ayah == 1);
        expect(r.text.startsWith(ch(const [0x0628, 0x0651])), isTrue);
        expect(present(r).separated, isTrue);
      }
    });
  });
}

class _Row {
  const _Row({
    required this.surah,
    required this.ayah,
    required this.verseKey,
    required this.text,
    required this.bismillahPre,
  });

  final int surah;
  final int ayah;
  final String verseKey;
  final String text;
  final bool bismillahPre;
}
