import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_app/core/db/content_db.dart';
import 'package:quran_app/core/quran/references.dart';
import 'package:quran_app/data/quran_repository.dart';
import 'package:quran_app/data/translation_download_service.dart';

import '../helpers/test_databases.dart';

const _edition = AvailableEdition(
  id: 'fr.test',
  language: 'fr',
  name: 'Traducteur Test',
  englishName: 'Test French',
  direction: 'ltr',
);

/// A well-formed `/quran/{edition}` response, reusing real verse numbering.
String quranResponse({int dropLast = 0, String Function(int id)? text}) {
  var id = 0;
  final surahs = [
    for (var s = 1; s <= surahCount; s++)
      {
        'number': s,
        'ayahs': [
          for (var a = 1; a <= ayahCounts[s - 1]; a++)
            {
              'number': ++id,
              'numberInSurah': a,
              'text': text?.call(id) ?? 'verse $id',
            },
        ],
      },
  ];
  if (dropLast > 0) {
    final last = surahs.last['ayahs']! as List<Object?>;
    last.removeRange(last.length - dropLast, last.length);
  }
  return jsonEncode({
    'code': 200,
    'status': 'OK',
    'data': {'surahs': surahs},
  });
}

void main() {
  late ContentDatabase db;
  late Directory store;

  setUp(() async {
    db = await openBundledContentDb();
    store = await Directory.systemTemp.createTemp('quran_store_');
  });
  tearDown(() => db.close());

  TranslationDownloadService serviceWith(String body, {int status = 200}) =>
      TranslationDownloadService(
        db,
        storeDirectory: store,
        client: MockClient(
          (request) async => http.Response.bytes(
            utf8.encode(body),
            status,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );

  test('lists editions with their direction', () async {
    final service = serviceWith(
      jsonEncode({
        'code': 200,
        'data': [
          {
            'identifier': 'ur.test',
            'language': 'ur',
            'name': 'x',
            'englishName': 'X',
          },
          {
            'identifier': 'en.test',
            'language': 'en',
            'name': 'y',
            'englishName': 'Y',
            'direction': 'ltr',
          },
        ],
      }),
    );
    final editions = await service.fetchAvailable();
    expect(editions.map((e) => e.direction), ['rtl', 'ltr']);
  });

  test('a valid download is stored, imported and readable', () async {
    double? lastProgress;
    await serviceWith(
      quranResponse(),
    ).download(_edition, onProgress: (p) => lastProgress = p);
    expect(lastProgress, anyOf(isNull, 1.0));

    final repo = QuranRepository(db);
    final editions = await repo.editions();
    final added = editions.firstWhere((e) => e.id == 'fr.test');
    expect(added.bundled, isFalse);
    expect(added.attribution, contains('translated by Traducteur Test'));

    final ayah = await repo.ayah('114:6', translationIds: const ['fr.test']);
    expect(ayah!.translations.single.text, 'verse 6236');
    expect(File('${store.path}/fr.test.json').existsSync(), isTrue);
  });

  test('an incomplete download is rejected and nothing is stored', () async {
    await expectLater(
      serviceWith(quranResponse(dropLast: 1)).download(_edition),
      throwsA(isA<TranslationDownloadException>()),
    );
    expect(store.listSync(), isEmpty);
    expect(
      (await QuranRepository(db).editions()).map((e) => e.id),
      isNot(contains('fr.test')),
    );
  });

  test('an empty verse text is rejected', () async {
    await expectLater(
      serviceWith(
        quranResponse(text: (id) => id == 300 ? '\u{FEFF} ' : 'v$id'),
      ).download(_edition),
      throwsA(isA<TranslationDownloadException>()),
    );
  });

  test('a server error is reported, not thrown past the service', () async {
    await expectLater(
      serviceWith('oops', status: 503).download(_edition),
      throwsA(isA<TranslationDownloadException>()),
    );
  });

  test('downloads can be deleted; bundled editions cannot', () async {
    final service = serviceWith(quranResponse());
    await service.download(_edition);
    await service.delete('fr.test');
    final ids = (await QuranRepository(db).editions()).map((e) => e.id);
    expect(ids, isNot(contains('fr.test')));
    expect(store.listSync(), isEmpty);
    await expectLater(
      service.delete('en.sahih'),
      throwsA(isA<TranslationDownloadException>()),
    );
  });

  test(
    'downloads are restored into a freshly installed content database',
    () async {
      await serviceWith(quranResponse()).download(_edition);
      final fresh = await openBundledContentDb();
      await TranslationDownloadService.restoreDownloaded(
        fresh,
        storeDirectory: store,
      );
      final ayah = await QuranRepository(
        fresh,
      ).ayah('2:255', translationIds: const ['fr.test']);
      expect(ayah!.translations.single.text, 'verse 262');
      await fresh.close();
    },
  );
}
