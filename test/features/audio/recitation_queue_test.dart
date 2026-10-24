import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/domain/models/reciter.dart';
import 'package:quran_app/domain/models/surah.dart';
import 'package:quran_app/domain/recitation_queue.dart';

Surah _surah(int number, int ayahCount) => Surah(
  number: number,
  nameArabic: '',
  nameSimple: 'S$number',
  nameTranslated: '',
  revelationPlace: RevelationPlace.makkah,
  ayahCount: ayahCount,
  bismillahPre: number != 1 && number != 9,
  pageStart: 1,
  pageEnd: 1,
);

final _arabic = Reciters.arabic.first;
final _urdu = Reciters.urdu.first;

List<String> _files(List<RecitationTrack> queue) => [
  for (final t in queue) '${t.reciter.language}/${t.fileName}',
];

void main() {
  test('file names are three-digit surah and ayah', () {
    expect(verseFileName(2, 255), '002255.mp3');
    expect(verseFileName(114, 6), '114006.mp3');
  });

  test('a surah opens with the basmalah, except Al-Fatihah and At-Tawbah', () {
    List<String> opening(Surah s) => _files(
      buildRecitationQueue(
        [(s, 1)],
        mode: RecitationMode.arabic,
        arabic: _arabic,
        urdu: _urdu,
      ),
    );
    expect(opening(_surah(2, 286)), ['ar/001001.mp3', 'ar/002001.mp3']);
    expect(opening(_surah(1, 7)), ['ar/001001.mp3']);
    expect(opening(_surah(9, 129)), ['ar/009001.mp3']);
  });

  test('no basmalah when starting mid-surah', () {
    final queue = buildRecitationQueue(
      [(_surah(2, 286), 255), (_surah(2, 286), 256)],
      mode: RecitationMode.arabic,
      arabic: _arabic,
      urdu: _urdu,
    );
    expect(_files(queue), ['ar/002255.mp3', 'ar/002256.mp3']);
  });

  test('Arabic + Urdu interleaves each verse, basmalah included', () {
    final surah = _surah(112, 4);
    final queue = buildRecitationQueue(
      [(surah, 1), (surah, 2)],
      mode: RecitationMode.arabicThenUrdu,
      arabic: _arabic,
      urdu: _urdu,
    );
    expect(_files(queue), [
      'ar/001001.mp3',
      'ur/001001.mp3',
      'ar/112001.mp3',
      'ur/112001.mp3',
      'ar/112002.mp3',
      'ur/112002.mp3',
    ]);
    // The basmalah belongs to the verse it opens.
    expect(queue.first.verseKey, '112:1');
    expect(queue.first.isBasmalah, isTrue);
  });

  test('Urdu only plays the translation recording', () {
    final queue = buildRecitationQueue(
      [(_surah(114, 6), 6)],
      mode: RecitationMode.urdu,
      arabic: _arabic,
      urdu: _urdu,
    );
    expect(_files(queue), ['ur/114006.mp3']);
    expect(
      queue.single.reciter.folder,
      'translations/urdu_shamshad_ali_khan_46kbps',
    );
  });

  test('a surah download includes the basmalah it needs', () {
    expect(surahFileNames(_surah(1, 7)), [
      for (var a = 1; a <= 7; a++) verseFileName(1, a),
    ]);
    expect(surahFileNames(_surah(9, 129)).first, '009001.mp3');
    expect(surahFileNames(_surah(112, 4)), [
      '001001.mp3',
      '112001.mp3',
      '112002.mp3',
      '112003.mp3',
      '112004.mp3',
    ]);
  });

  test('unknown reciter ids fall back to the defaults', () {
    expect(Reciters.arabicById('gone').id, Reciters.defaultArabicId);
    expect(Reciters.urduById('gone').id, Reciters.defaultUrduId);
    final ids = [...Reciters.arabic, ...Reciters.urdu].map((r) => r.id);
    expect(ids.toSet().length, ids.length, reason: 'ids must be unique');
  });
}
