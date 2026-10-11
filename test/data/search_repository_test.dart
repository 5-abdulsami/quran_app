import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/db/content_db.dart';
import 'package:quran_app/core/quran/bismillah.dart';
import 'package:quran_app/core/quran/references.dart';
import 'package:quran_app/core/text/highlight.dart';
import 'package:quran_app/core/text/search_terms.dart';
import 'package:quran_app/data/quran_repository.dart';
import 'package:quran_app/data/search_repository.dart';

import '../helpers/test_databases.dart';

void main() {
  late ContentDatabase db;
  late QuranRepository quran;
  late SearchRepository search;
  late SurahNameIndex names;

  setUpAll(() async {
    db = await openBundledContentDb();
    quran = QuranRepository(db);
    search = SearchRepository(db, quran);
    names = SurahNameIndex({
      for (final s in await quran.surahs())
        s.number: [s.nameSimple, s.nameArabic],
    });
  });
  tearDownAll(() => db.close());

  Future<SearchResults> find(
    String query, {
    SearchFilters filters = const SearchFilters(),
  }) => search.search(
    query,
    filters: filters,
    translationIds: const ['en.sahih', 'ur.jalandhry'],
    names: names,
  );

  String keyOf(int id) {
    var remaining = id;
    for (var s = 1; s <= 114; s++) {
      if (remaining <= ayahCounts[s - 1]) return '$s:$remaining';
      remaining -= ayahCounts[s - 1];
    }
    throw StateError('id $id');
  }

  group('references go straight to the verse', () {
    test('"ayatul kursi" → go to 2:255', () async {
      expect((await find('ayatul kursi')).goTo, const VerseTarget(2, 255));
    });

    test('"juz 30" → go to the juz', () async {
      final results = await find('juz 30');
      expect(results.goTo, const JuzTarget(30));
      expect(results.surahs, isEmpty);
    });

    test('"2:255" → go to the verse, no surah list', () async {
      final results = await find('2:255');
      expect(results.goTo, const VerseTarget(2, 255));
      expect(results.surahs, isEmpty);
    });

    test('"Yaseen" → go to the surah and list it', () async {
      final results = await find('Yaseen');
      expect(results.goTo, const SurahTarget(36));
      expect(results.surahs.map((s) => s.number), contains(36));
    });
  });

  group('text search', () {
    test('"الحمد لله" ranks 1:2 first', () async {
      final results = await find('الحمد لله');
      expect(keyOf(results.rankedAyahIds.first), '1:2');
      expect(results.rankedAyahIds.length, greaterThan(5));
    });

    test('"رحمن" finds ٱلرَّحْمَٰنِ in al-Fatihah', () async {
      final keys = (await find('رحمن')).rankedAyahIds.map(keyOf);
      expect(keys, containsAll(['1:1', '1:3']));
    });

    test('"mercy" finds Mercy and merciful in en.sahih', () async {
      final keys = (await find('mercy')).rankedAyahIds.map(keyOf).toSet();
      expect(keys, containsAll(['1:1', '6:12']));
    });

    test('every term must match (AND)', () async {
      final both = (await find('patience prayer')).rankedAyahIds.map(keyOf);
      expect(both, contains('2:45'));
      final patience = (await find('patience')).rankedAyahIds.length;
      expect(both.length, lessThan(patience));
    });

    test('the basmalah matches only the verses that display it', () async {
      final keys = (await find(basmalah)).rankedAyahIds.map(keyOf).toList();
      // 1:1 is the basmalah; 27:30 quotes it. The 112 ayah-1s that show it in
      // the header instead are not returned.
      expect(keys, ['1:1', '27:30']);
    });

    test('Urdu queries search the Urdu translation', () async {
      expect((await find('صبر')).rankedAyahIds, isNotEmpty);
    });

    test('nonsense finds nothing', () async {
      expect((await find('qwxzv')).isEmpty, isTrue);
    });
  });

  group('filters', () {
    test('surah and juz narrow the results', () async {
      final inSurah = await find(
        'mercy',
        filters: const SearchFilters(surah: 2),
      );
      expect(
        inSurah.rankedAyahIds.map(keyOf).every((k) => k.startsWith('2:')),
        isTrue,
      );
      final inJuz = await find('mercy', filters: const SearchFilters(juz: 30));
      expect(inJuz.rankedAyahIds.every((id) => id >= 5673), isTrue);
    });

    test('Arabic-only scope ignores translations', () async {
      final results = await find(
        'mercy',
        filters: const SearchFilters(scope: SearchScope.arabic),
      );
      expect(results.rankedAyahIds, isEmpty);
    });
  });

  group('pagination and speed', () {
    test('pages of 50 in ranked order', () async {
      final results = await find('allah');
      expect(results.rankedAyahIds.length, greaterThan(100));
      final first = await search.page(results, 0);
      final second = await search.page(results, 1);
      expect(first, hasLength(50));
      expect(first.first.id, results.rankedAyahIds.first);
      expect(second.first.id, results.rankedAyahIds[50]);
    });

    test('a broad query completes quickly', () async {
      // The search screen warms these caches when it opens.
      await search.warmUp();
      final watch = Stopwatch()..start();
      await find('the lord of the worlds');
      await find('الله');
      watch.stop();
      // Two broad queries on a desktop host; the phone target is < 100 ms each.
      expect(watch.elapsedMilliseconds, lessThan(400));
    });
  });

  group('highlighting', () {
    test('highlights whole original words that match', () {
      const text = 'In the name of Allah, the Entirely Merciful.';
      final ranges = highlightRanges(text, searchTermsFor('mercy allah'));
      final words = [for (final r in ranges) text.substring(r.start, r.end)];
      expect(words, ['Allah,', 'Merciful.']);
    });

    test(
      'Arabic highlights cover original words, diacritics included',
      () async {
        final ayah = (await quran.ayah('1:2'))!;
        final ranges = highlightRanges(
          ayah.displayText,
          searchTermsFor('الحمد'),
        );
        expect(ranges, hasLength(1));
        final word = ayah.displayText.substring(
          ranges.single.start,
          ranges.single.end,
        );
        expect(word, ayah.displayText.split(' ').first);
      },
    );

    test('splitting keeps every character', () {
      const text = 'abc def ghi';
      final runs = splitHighlights(text, const [(start: 4, end: 7)]);
      expect(runs.map((r) => r.$1).join(), text);
      expect(runs, [('abc ', false), ('def', true), (' ghi', false)]);
    });
  });
}
