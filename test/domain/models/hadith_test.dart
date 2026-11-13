import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/hadith/hadith_citation.dart';
import 'package:quran_app/domain/models/hadith.dart';

void main() {
  final hadith = Hadith(
    collection: HadithCollection.muslim,
    number: '2564c',
    arabic: 'اللَّهَ لاَ يَنْظُرُ',
    translations: const [
      HadithTranslation(language: 'en', text: 'English', source: 'sunnah.com'),
      HadithTranslation(language: 'ur', text: 'اردو', source: 'Urdu source'),
    ],
  );

  test('cites and links to sunnah.com', () {
    expect(hadith.citation, 'Sahih Muslim 2564c');
    expect(hadith.sourceUrl.toString(), 'https://sunnah.com/muslim:2564c');
    expect(
      Hadith(
        collection: HadithCollection.bukhari,
        number: '1',
        arabic: 'a',
        translations: const [
          HadithTranslation(language: 'en', text: 't', source: 's'),
        ],
      ).sourceUrl.toString(),
      'https://sunnah.com/bukhari:1',
    );
  });

  test('picks the first preferred translation available', () {
    expect(hadith.translationFor(['ur', 'en']).language, 'ur');
    expect(hadith.translationFor(['ar', 'en']).language, 'en');
    expect(hadith.translationFor(['fr']).language, 'en'); // first available
  });

  test('collections are looked up by sunnah.com id', () {
    expect(HadithCollection.byId('bukhari'), HadithCollection.bukhari);
    expect(HadithCollection.byId('tirmidhi'), isNull);
  });

  test('shared text always ends with the citation and the link', () {
    final payload = hadithPayload(
      arabic: hadith.arabic,
      translation: 'English',
      citation: hadith.citation,
      source: hadith.sourceUrl,
    );
    expect(
      payload,
      'اللَّهَ لاَ يَنْظُرُ\n\nEnglish\n\n'
      'Sahih Muslim 2564c · https://sunnah.com/muslim:2564c',
    );
    expect(
      hadithPayload(
        translation: 'English',
        citation: hadith.citation,
        source: hadith.sourceUrl,
      ),
      startsWith('English\n\n'),
    );
  });

  test('a translation from another publisher is credited when shared', () {
    expect(
      hadithPayload(
        translation: 'اردو',
        translationSource: 'HadeethEnc.com',
        citation: hadith.citation,
        source: hadith.sourceUrl,
      ),
      'اردو\n\nSahih Muslim 2564c (HadeethEnc.com) · '
      'https://sunnah.com/muslim:2564c',
    );
    expect(
      hadithPayload(
        translation: 'English',
        translationSource: 'sunnah.com',
        citation: hadith.citation,
        source: hadith.sourceUrl,
      ),
      endsWith('Sahih Muslim 2564c · https://sunnah.com/muslim:2564c'),
    );
  });
}
