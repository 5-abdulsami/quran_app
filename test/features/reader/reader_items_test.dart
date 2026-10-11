import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/db/content_db.dart';
import 'package:quran_app/data/quran_repository.dart';
import 'package:quran_app/features/reader/reader_items.dart';

import '../../helpers/test_databases.dart';

void main() {
  late ContentDatabase db;
  late QuranRepository repo;

  setUpAll(() async {
    db = await openBundledContentDb();
    repo = QuranRepository(db);
  });
  tearDownAll(() => db.close());

  Future<ReaderContent> surah(int n) async =>
      buildSurahContent((await repo.surah(n))!, await repo.surahAyahs(n));

  Future<ReaderContent> juz(int n) async =>
      buildJuzContent(await repo.surahs(), await repo.juzAyahs(n));

  group('surah content', () {
    test('al-Fatihah: header without basmalah, ayah 1 in full', () async {
      final content = await surah(1);
      final header = content.items.first as SurahHeaderItem;
      expect(header.showBismillah, isFalse);
      final first = content.items[1] as AyahItem;
      expect(first.ayah.displayText, first.ayah.textUthmani);
    });

    test('al-Baqarah: header with basmalah, ayah 1 is الٓمٓ', () async {
      final content = await surah(2);
      expect((content.items.first as SurahHeaderItem).showBismillah, isTrue);
      final first = content.items[1] as AyahItem;
      // alef, lam + maddah, mim + maddah (the source spelling of 2:1).
      expect(first.ayah.displayText.runes.toList(), [
        0x0627, 0x0644, 0x0653, 0x0645, 0x0653, //
      ]);
      expect(content.items.whereType<SurahHeaderItem>(), hasLength(1));
    });

    test('at-Tawbah: no basmalah anywhere', () async {
      final content = await surah(9);
      expect((content.items.first as SurahHeaderItem).showBismillah, isFalse);
      final first = content.items[1] as AyahItem;
      expect(first.ayah.leadingBismillah, isNull);
    });

    test('indexOf finds every verse', () async {
      final content = await surah(2);
      expect(content.indexOf('2:1'), 1);
      expect(content.indexOf('2:286'), 286);
      expect(content.indexOf('3:1'), isNull);
    });
  });

  group('juz content', () {
    test(
      'juz 30: a header before each of surahs 78–114, basmalah under each',
      () async {
        final content = await juz(30);
        final headers = content.items.whereType<SurahHeaderItem>().toList();
        expect(
          headers.map((h) => h.surah.number),
          List.generate(37, (i) => 78 + i),
        );
        expect(headers.every((h) => h.showBismillah), isTrue);
        expect(content.items.whereType<ContinuingSurahItem>(), isEmpty);
        // Each header is immediately followed by that surah's ayah 1.
        for (final (i, item) in content.items.indexed) {
          if (item is SurahHeaderItem) {
            final next = content.items[i + 1] as AyahItem;
            expect(next.ayah.surahNumber, item.surah.number);
            expect(next.ayah.ayahNumber, 1);
          }
        }
      },
    );

    test('juz 2 continues al-Baqarah from 2:142 with no basmalah', () async {
      final content = await juz(2);
      final first = content.items.first as ContinuingSurahItem;
      expect(first.surah.number, 2);
      expect(first.fromAyah, 142);
      expect(content.items.whereType<SurahHeaderItem>(), isEmpty);
    });

    test(
      'juz 10 begins mid-al-Anfal and starts at-Tawbah without basmalah',
      () async {
        final content = await juz(10);
        expect(content.items.first, isA<ContinuingSurahItem>());
        final tawbah = content.items.whereType<SurahHeaderItem>().single;
        expect(tawbah.surah.number, 9);
        expect(tawbah.showBismillah, isFalse);
      },
    );
  });

  group('markers', () {
    test('juz, hizb and page print only where they change', () async {
      final ayahs = (await surah(2)).items.whereType<AyahItem>().toList();
      for (final (i, item) in ayahs.indexed) {
        final previous = i == 0 ? null : ayahs[i - 1].ayah;
        expect(item.showJuz, previous == null || previous.juz != item.ayah.juz);
        expect(
          item.showHizb,
          previous == null || previous.hizb != item.ayah.hizb,
        );
        expect(
          item.showPage,
          previous == null || previous.page != item.ayah.page,
        );
      }
      // Al-Baqarah spans juz 1–3: three juz markers in 286 ayat.
      expect(ayahs.where((a) => a.showJuz), hasLength(3));
      expect(
        ayahs.firstWhere((a) => a.ayah.verseKey == '2:142').showJuz,
        isTrue,
      );
    });
  });
}
