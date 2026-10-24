import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quran_app/data/recitation_audio_store.dart';
import 'package:quran_app/domain/models/reciter.dart';
import 'package:quran_app/domain/models/surah.dart';
import 'package:quran_app/domain/recitation_queue.dart';

const _ikhlas = Surah(
  number: 112,
  nameArabic: '',
  nameSimple: 'Al-Ikhlaas',
  nameTranslated: '',
  revelationPlace: RevelationPlace.makkah,
  ayahCount: 4,
  bismillahPre: true,
  pageStart: 604,
  pageEnd: 604,
);

const _nas = Surah(
  number: 114,
  nameArabic: '',
  nameSimple: 'An-Naas',
  nameTranslated: '',
  revelationPlace: RevelationPlace.makkah,
  ayahCount: 6,
  bismillahPre: true,
  pageStart: 604,
  pageEnd: 604,
);

/// A tiny body that starts like an MP3 (ID3 tag).
final _mp3 = Uint8List.fromList([0x49, 0x44, 0x33, ...List.filled(200, 0)]);

void main() {
  final reciter = Reciters.arabic.first;
  late Directory dir;
  final requested = <String>[];

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('quran_audio_');
    requested.clear();
  });
  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  RecitationAudioStore storeWith(
    http.Response Function(http.Request request) handler,
  ) => RecitationAudioStore(
    directory: dir,
    client: MockClient((request) async {
      requested.add(request.url.toString());
      return handler(request);
    }),
  );

  test('streams from EveryAyah until a file is downloaded', () async {
    final store = storeWith((_) => http.Response.bytes(_mp3, 200));
    const track = RecitationTrack(
      reciter: Reciter(
        id: 'alafasy',
        name: '',
        folder: 'Alafasy_128kbps',
        language: 'ar',
      ),
      surah: _ikhlas,
      ayah: 1,
    );
    expect(
      store.sourceFor(track).toString(),
      'https://everyayah.com/data/Alafasy_128kbps/112001.mp3',
    );
    await store.downloadSurah(reciter, _ikhlas);
    expect(store.sourceFor(track).scheme, 'file');
  });

  test('downloads every file a surah needs, with progress', () async {
    final store = storeWith((_) => http.Response.bytes(_mp3, 200));
    final progress = <int>[];
    await store.downloadSurah(
      reciter,
      _ikhlas,
      onProgress: (done, total) => progress.add(done),
    );
    expect(
      await store.downloadedFiles(reciter),
      surahFileNames(_ikhlas).toSet(),
    );
    expect(progress.last, surahFileNames(_ikhlas).length);
    expect(await store.bytesUsed(), greaterThan(0));

    // Already present files are not fetched again.
    requested.clear();
    await store.downloadSurah(reciter, _ikhlas);
    expect(requested, isEmpty);
  });

  test('rejects error pages and keeps no partial files', () async {
    final store = storeWith(
      (request) => request.url.path.endsWith('112003.mp3')
          ? http.Response('<html>Not found</html>', 200)
          : http.Response.bytes(_mp3, 200),
    );
    await expectLater(
      store.downloadSurah(reciter, _ikhlas),
      throwsA(isA<RecitationDownloadException>()),
    );
    final files = await store.downloadedFiles(reciter);
    expect(files, isNot(contains('112003.mp3')));
    final leftovers = dir
        .listSync(recursive: true)
        .where((e) => e.path.endsWith('.part'));
    expect(leftovers, isEmpty);
  });

  test('a failed request is reported', () async {
    final store = storeWith((_) => http.Response('', 404));
    await expectLater(
      store.downloadSurah(reciter, _ikhlas),
      throwsA(isA<RecitationDownloadException>()),
    );
  });

  test('deleting a surah keeps the basmalah other surahs need', () async {
    final store = storeWith((_) => http.Response.bytes(_mp3, 200));
    await store.downloadSurah(reciter, _ikhlas);
    await store.downloadSurah(reciter, _nas);

    await store.deleteSurah(reciter, _ikhlas);
    expect(await store.downloadedFiles(reciter), surahFileNames(_nas).toSet());

    await store.deleteSurah(reciter, _nas);
    expect(await store.downloadedFiles(reciter), isEmpty);
  });

  test('downloads of recordings no longer offered are removed', () async {
    final store = storeWith((_) => http.Response.bytes(_mp3, 200));
    await store.downloadSurah(reciter, _ikhlas);
    final stale = Directory('${dir.path}/ur.removed')..createSync();
    File('${stale.path}/112001.mp3').writeAsBytesSync(_mp3);

    await store.removeUnknownReciters({reciter.id});
    expect(stale.existsSync(), isFalse);
    expect(await store.downloadedFiles(reciter), isNotEmpty);
  });

  test('delete all removes every download', () async {
    final store = storeWith((_) => http.Response.bytes(_mp3, 200));
    await store.downloadSurah(reciter, _ikhlas);
    await store.deleteAll();
    expect(await store.bytesUsed(), 0);
  });
}
