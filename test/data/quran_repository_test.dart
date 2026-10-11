import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/db/content_db.dart';
import 'package:quran_app/core/quran/bismillah.dart';
import 'package:quran_app/data/quran_repository.dart';
import 'package:quran_app/domain/models/ayah.dart';

import '../helpers/test_databases.dart';

void main() {
  late ContentDatabase db;
  late QuranRepository repo;

  setUpAll(() async {
    db = await openBundledContentDb();
    repo = QuranRepository(db);
  });
  tearDownAll(() => db.close());

  Future<List<Ayah>> everyAyah() async => [
    for (var s = 1; s <= 114; s++) ...await repo.surahAyahs(s),
  ];

  group('data integrity through the repository', () {
    test('114 surahs and 6236 ayat, none with an empty displayText', () async {
      expect(await repo.surahs(), hasLength(114));
      final ayahs = await everyAyah();
      expect(ayahs, hasLength(6236));
      for (final a in ayahs) {
        expect(a.displayText.trim(), isNotEmpty, reason: a.verseKey);
      }
    });

    test(
      'displayText differs from the stored text only for 112 ayah-1s',
      () async {
        final changed = (await everyAyah()).where(
          (a) => a.displayText != a.textUthmani,
        );
        expect(changed, hasLength(112));
        for (final a in changed) {
          expect(a.ayahNumber, 1);
          expect(a.surahNumber, isNot(anyOf(1, 9)));
          expect(a.leadingBismillah, isNotNull);
        }
      },
    );

    test('1:1 is the basmalah in full; 9:1 and 27:30 are untouched', () async {
      final fatiha = (await repo.ayah('1:1'))!;
      expect(fatiha.displayText, fatiha.textUthmani);
      expect(fatiha.leadingBismillah, isNull);
      for (final key in ['9:1', '27:30']) {
        final a = (await repo.ayah(key))!;
        expect(a.displayText, a.textUthmani, reason: key);
      }
    });

    test('2:1 displays "الٓمٓ" after the basmalah is separated', () async {
      final a = (await repo.ayah('2:1'))!;
      expect(a.displayText.runes.toList(), [
        0x0627, 0x0644, 0x0653, 0x0645, 0x0653, //
      ]);
      expect(a.leadingBismillah, isNotNull);
    });
  });

  group('translations', () {
    test('are returned in the requested order', () async {
      final a = (await repo.ayah(
        '2:255',
        translationIds: const ['ur.jalandhry', 'en.sahih'],
      ))!;
      expect(a.translations.map((t) => t.editionId), [
        'ur.jalandhry',
        'en.sahih',
      ]);
      expect(a.translations.first.isRtl, isTrue);
      expect(a.translations.last.isRtl, isFalse);
    });

    test('unknown edition ids are ignored, empty list means none', () async {
      final a = (await repo.ayah('1:1', translationIds: const ['xx.none']))!;
      expect(a.translations, isEmpty);
      final b = (await repo.ayah('1:1'))!;
      expect(b.translations, isEmpty);
    });

    test('a whole juz loads one translation per ayah', () async {
      final ayahs = await repo.juzAyahs(30, translationIds: const ['en.sahih']);
      expect(ayahs.first.verseKey, '78:1');
      expect(ayahs.last.verseKey, '114:6');
      expect(ayahs.every((a) => a.translations.length == 1), isTrue);
    });
  });

  group('lookups', () {
    test('ayahIdFor matches the database ids', () async {
      for (final key in ['1:1', '2:255', '18:50', '114:6']) {
        expect(QuranRepository.ayahIdFor(key), (await repo.ayah(key))!.id);
      }
      expect(QuranRepository.ayahIdFor('2:300'), isNull);
    });

    test('ayahsByIds keeps the requested order', () async {
      final ayahs = await repo.ayahsByIds([262, 1, 6236]);
      expect(ayahs.map((a) => a.verseKey), ['2:255', '1:1', '114:6']);
    });

    test('juz carry their surah spans', () async {
      final juzs = await repo.juzs();
      expect(juzs, hasLength(30));
      expect(juzs[1].surahNumbers, [2]);
      expect(juzs[29].surahNumbers, List.generate(37, (i) => 78 + i));
      expect(juzs[0].firstAyahId, 1);
      expect(juzs[29].lastAyahId, 6236);
    });

    test('impossible references return null', () async {
      expect(await repo.ayah('2:300'), isNull);
      expect(await repo.surah(115), isNull);
    });
  });

  group('architecture', () {
    // As in the web app, presentVerse has exactly one caller, and no view
    // special-cases surah 1 or 9 itself.
    final sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.contains('generated'))
        .toList();
    String rel(File f) => f.path.replaceAll(r'\', '/');

    test('presentVerse is called only by QuranRepository', () {
      final callers = [
        for (final f in sources)
          if (f.readAsStringSync().contains('presentVerse(') &&
              !rel(f).endsWith('core/quran/bismillah.dart'))
            rel(f),
      ];
      expect(callers, ['lib/data/quran_repository.dart']);
    });

    test('no surah == 9 / == 1 checks outside bismillah.dart', () {
      final pattern = RegExp(r'surah\w*\s*[!=]=\s*[19]\b');
      final offenders = [
        for (final f in sources)
          if (!rel(f).endsWith('core/quran/bismillah.dart') &&
              !rel(f).contains('tool/') &&
              pattern.hasMatch(f.readAsStringSync()))
            rel(f),
      ];
      expect(offenders, isEmpty);
    });

    test('the basmalah constant is the code-point original', () {
      expect(basmalah.runes.first, 0x0628);
      expect(basmalah.runes.length, 38);
    });
  });
}
