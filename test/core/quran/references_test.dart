// Port of the Quran cases in islamic-platform/tests/unit/references.test.ts
// (the hadith cases are out of scope), plus the mobile extensions.
//
// Reference parsing has to be permissive about how people type references and
// strict about never resolving one that does not exist.

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/db/content_db.dart';
import 'package:quran_app/core/quran/references.dart';

import '../../helpers/test_databases.dart';

/// A few surahs' names exactly as AlQuran.cloud spells them, so the loose
/// matcher is tested against the real spellings.
final _fixtureNames = SurahNameIndex({
  1: ['Al-Faatiha', 'سُورَةُ ٱلْفَاتِحَةِ'],
  2: ['Al-Baqara', 'سُورَةُ البَقَرَةِ'],
  3: ['Aal-i-Imraan', 'سُورَةُ آلِ عِمۡرَانَ'],
  6: ["Al-An'aam", 'سُورَةُ الأَنۡعَامِ'],
  18: ['Al-Kahf', 'سُورَةُ الكَهۡفِ'],
  36: ['Yaseen', 'سُورَةُ يسٓ'],
  56: ['Al-Waaqia', 'سُورَةُ الوَاقِعَةِ'],
  67: ['Al-Mulk', 'سُورَةُ المُلۡكِ'],
  114: ['An-Naas', 'سُورَةُ النَّاسِ'],
});

void main() {
  group('AYAH_COUNTS', () {
    test('has one entry per surah', () {
      expect(ayahCounts, hasLength(114));
    });

    test('sums to 6,236 ayat', () {
      // The canonical total. If this ever fails, the table has been corrupted
      // and every reference validation downstream is unreliable.
      expect(ayahCounts.reduce((a, b) => a + b), 6236);
    });

    test('matches known chapter lengths', () {
      expect(ayahCount(1), 7);
      expect(ayahCount(2), 286);
      expect(ayahCount(36), 83);
      expect(ayahCount(55), 78);
      expect(ayahCount(112), 4);
      expect(ayahCount(114), 6);
    });

    test('returns null outside the mushaf', () {
      expect(ayahCount(0), isNull);
      expect(ayahCount(115), isNull);
    });
  });

  group('isValidVerseKey', () {
    test('accepts real references', () {
      expect(isValidVerseKey(2, 255), isTrue);
      expect(isValidVerseKey(1, 1), isTrue);
      expect(isValidVerseKey(114, 6), isTrue);
    });

    test('rejects an ayah beyond the end of its surah', () {
      // 2:300 looks plausible and does not exist.
      expect(isValidVerseKey(2, 287), isFalse);
      expect(isValidVerseKey(114, 7), isFalse);
    });

    test('rejects out-of-range surahs', () {
      // (Non-integers are unrepresentable in Dart's int signature.)
      expect(isValidVerseKey(0, 1), isFalse);
      expect(isValidVerseKey(115, 1), isFalse);
      expect(isValidVerseKey(2, 0), isFalse);
    });
  });

  group('parseReference — Quran', () {
    test('parses the canonical colon form', () {
      expect(
        parseReference('2:255'),
        const QuranReference(surah: 2, ayah: 255, verseKey: '2:255'),
      );
    });

    test('parses the separators people actually type', () {
      for (final input in ['2.255', '2 255', 'Q2:255', 'quran 2:255']) {
        expect(parseReference(input)?.ayah, 255, reason: input);
      }
    });

    test('parses a verse range', () {
      final result = parseReference('2:285-286');
      expect(result?.surah, 2);
      expect(result?.ayah, 285);
      expect(result?.ayahEnd, 286);
    });

    test('ignores a reversed range rather than inverting it', () {
      final result = parseReference('2:286-285');
      expect(result?.surah, 2);
      expect(result?.ayah, 286);
      expect(result?.ayahEnd, isNull);
    });

    test('refuses a reference that does not exist', () {
      expect(parseReference('2:999'), isNull);
      expect(parseReference('200:1'), isNull);
    });

    test('parses a bare surah request', () {
      expect(parseReference('surah 36'), const QuranReference(surah: 36));
      expect(parseReference('chapter 1'), const QuranReference(surah: 1));
    });

    test('parses well-known passage names', () {
      expect(parseReference('ayatul kursi')?.ayah, 255);
      expect(parseReference('Ayat al Kursi')?.ayah, 255);
      expect(parseReference('throne verse')?.ayah, 255);
      expect(parseReference('surah yaseen')?.surah, 36);
    });
  });

  group('parseReference — non-references', () {
    test('returns null for a natural-language question', () {
      expect(parseReference('what breaks wudu'), isNull);
      expect(parseReference('is music haram'), isNull);
      expect(parseReference('kya neend se wuzu toot jata hai'), isNull);
    });

    test('returns null for empty input', () {
      expect(parseReference(''), isNull);
      expect(parseReference('   '), isNull);
    });
  });

  group('parseVerseKey', () {
    test('round-trips a valid key', () {
      expect(parseVerseKey('2:255'), (surah: 2, ayah: 255));
    });

    test('rejects a malformed or impossible key', () {
      expect(parseVerseKey('2-255'), isNull);
      expect(parseVerseKey('2:0'), isNull);
      expect(parseVerseKey('2:287'), isNull);
    });
  });

  group('formatQuranCitation', () {
    test('includes the surah name when known', () {
      expect(
        formatQuranCitation(2, 255, 'Al-Baqarah'),
        "Qur'an 2:255 (Surah Al-Baqarah)",
      );
    });

    test('falls back to the bare reference', () {
      expect(formatQuranCitation(2, 255), "Qur'an 2:255");
    });
  });

  // ---------------------------------------------------------------------------
  // Mobile extensions
  // ---------------------------------------------------------------------------

  NavigationTarget? parse(String q) =>
      parseNavigationTarget(q, names: _fixtureNames);

  group('parseNavigationTarget — verse forms', () {
    test('accepts every separator and dash', () {
      expect(parse('2:255'), const VerseTarget(2, 255));
      expect(parse('2 255'), const VerseTarget(2, 255));
      expect(parse('2.255'), const VerseTarget(2, 255));
      expect(parse('2:255-257'), const VerseTarget(2, 255, ayahEnd: 257));
      expect(parse('2:255–257'), const VerseTarget(2, 255, ayahEnd: 257));
    });

    test('accepts Arabic-Indic and Persian digits', () {
      expect(parse('٢:٢٥٥'), const VerseTarget(2, 255));
      expect(parse('۲:۲۵۵'), const VerseTarget(2, 255));
      expect(parse('٣٦'), const SurahTarget(36));
    });

    test('a bare number is a surah', () {
      expect(parse('2'), const SurahTarget(2));
      expect(parse('114'), const SurahTarget(114));
    });

    test('named passages resolve', () {
      expect(parse('ayatul kursi'), const VerseTarget(2, 255));
      expect(
        parse('last two verses of baqarah'),
        const VerseTarget(2, 285, ayahEnd: 286),
      );
    });
  });

  group('parseNavigationTarget — impossible references', () {
    test('returns null, never clamps', () {
      expect(parse('2:300'), isNull);
      expect(parse('115:1'), isNull);
      expect(parse('115'), isNull);
      expect(parse('0'), isNull);
      expect(parse('2:255-300'), isNull);
      expect(parse('juz 31'), isNull);
      expect(parse('juz 0'), isNull);
      expect(parse('baqarah 300'), isNull);
    });

    test('ordinary words are not references', () {
      expect(parse('patience'), isNull);
      expect(parse('mercy of allah'), isNull);
      expect(parse(''), isNull);
    });
  });

  group('parseNavigationTarget — juz', () {
    test('juz, para, parah and sipara forms', () {
      for (final input in [
        'juz 30',
        'Juz 30',
        'juz30',
        "juz' 30",
        'para 30',
        'parah 30',
        'sipara 30',
        'juz ٣٠',
        'پارہ 30',
        'جزء 30',
      ]) {
        expect(parse(input), const JuzTarget(30), reason: input);
      }
      expect(parse('juz 1'), const JuzTarget(1));
    });
  });

  group('parseNavigationTarget — loose surah names', () {
    test('ignore case, surah/sura, articles, hyphens and doubled vowels', () {
      for (final input in [
        'baqarah',
        'baqara',
        'Al-Baqara',
        'al baqarah',
        'surah al-baqarah',
        'sura baqara',
        'AL-BAQARAH',
      ]) {
        expect(parse(input), const SurahTarget(2), reason: input);
      }
    });

    test('Yaseen spellings', () {
      for (final input in [
        'yaseen',
        'yasin',
        'ya-sin',
        'Ya Sin',
        'surah yasin',
      ]) {
        expect(parse(input), const SurahTarget(36), reason: input);
      }
    });

    test('apostrophes and family names', () {
      expect(parse("al-an'am"), const SurahTarget(6));
      expect(parse('anam'), const SurahTarget(6));
      expect(parse('imran'), const SurahTarget(3));
      expect(parse('al imran'), const SurahTarget(3));
      expect(parse('fatihah'), const SurahTarget(1));
      expect(parse('waqiah'), const SurahTarget(56));
      expect(parse('an-nas'), const SurahTarget(114));
    });

    test('Arabic names, with or without سورة and the article', () {
      expect(parse('البقرة'), const SurahTarget(2));
      expect(parse('سورة البقرة'), const SurahTarget(2));
      expect(parse('بقره'), const SurahTarget(2));
      expect(parse('الكهف'), const SurahTarget(18));
    });

    test('a name followed by an ayah', () {
      expect(parse('baqarah 255'), const VerseTarget(2, 255));
      expect(parse('al-kahf:10'), const VerseTarget(18, 10));
      expect(parse('mulk 1-5'), const VerseTarget(67, 1, ayahEnd: 5));
    });
  });

  group('SurahNameIndex over the bundled database', () {
    late SurahNameIndex index;
    late List<SurahRow> rows;

    setUpAll(() async {
      final ContentDatabase db = await openBundledContentDb();
      rows = await db.select(db.surahTable).get();
      index = SurahNameIndex({
        for (final r in rows) r.number: [r.nameSimple, r.nameArabic],
      });
      await db.close();
    });

    test('no two surahs fold to the same key', () {
      for (final names in [
        rows.map((r) => r.nameSimple),
        rows.map((r) => r.nameArabic),
      ]) {
        final keys = names.map(SurahNameIndex.foldName).toList();
        final duplicates = keys.where(
          (k) => keys.where((x) => x == k).length > 1,
        );
        expect(duplicates.toSet(), isEmpty);
      }
    });

    test('every surah resolves by its own names', () {
      for (final r in rows) {
        expect(index.lookup(r.nameSimple), r.number, reason: r.nameSimple);
        expect(index.lookup(r.nameArabic), r.number, reason: r.nameArabic);
      }
    });

    test('resolves the names people type to the right surah', () {
      final cases = {
        'kahf': 18,
        'yaseen': 36,
        'yasin': 36,
        'mulk': 67,
        'waqiah': 56,
        'rahman': 55,
        'baqarah': 2,
        'fatiha': 1,
        'ikhlas': 112,
        'tawbah': 9,
        'maryam': 19,
        'nisa': 4,
        'الملك': 67,
      };
      for (final MapEntry(key: query, value: surah) in cases.entries) {
        expect(index.lookup(query), surah, reason: query);
      }
    });
  });
}
