import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/quran/references.dart';
import 'package:quran_app/data/daily_catalogue_codec.dart';
import 'package:quran_app/data/daily_content_repository.dart';
import 'package:quran_app/domain/daily/daily_content.dart';
import 'package:quran_app/domain/models/hadith.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyCatalogueCodec', () {
    final catalogue = DailyCatalogue(
      ayahs: const [
        DailyAyahEntry(surah: 94, fromAyah: 5, toAyah: 6),
        DailyAyahEntry(
          surah: 2,
          fromAyah: 183,
          toAyah: 183,
          occasion: DailyOccasion.ramadan,
        ),
      ],
      hadiths: [
        DailyHadithEntry(
          hadith: Hadith(
            collection: HadithCollection.muslim,
            number: '2564c',
            arabic: 'اللَّهَ لاَ يَنْظُرُ',
            translations: const [
              HadithTranslation(language: 'en', text: 'Verily', source: 's'),
              HadithTranslation(language: 'ur', text: 'بے شک', source: 'u'),
            ],
          ),
          occasion: DailyOccasion.friday,
        ),
      ],
    );

    Map<String, Object?> encoded() =>
        jsonDecode(jsonEncode(DailyCatalogueCodec.encode(catalogue)))
            as Map<String, Object?>;

    test('round-trips', () {
      final decoded = DailyCatalogueCodec.decode(encoded());
      expect(decoded.ayahs, catalogue.ayahs);
      final h = decoded.hadiths.single;
      expect(h.occasion, DailyOccasion.friday);
      expect(h.hadith.citation, 'Sahih Muslim 2564c');
      expect(h.hadith.translations.map((t) => t.language), ['en', 'ur']);
    });

    test('rejects an unknown schema version', () {
      final json = encoded()..['schemaVersion'] = 99;
      expect(() => DailyCatalogueCodec.decode(json), throwsFormatException);
    });

    test('rejects ayat outside the mushaf', () {
      final json = encoded();
      (json['ayahs']! as List)[0] = {'surah': 94, 'from': 5, 'to': 9};
      expect(() => DailyCatalogueCodec.decode(json), throwsFormatException);
    });

    test('rejects other collections and unknown occasions', () {
      final json = encoded();
      final hadith = (json['hadiths']! as List)[0] as Map<String, Object?>;
      hadith['collection'] = 'tirmidhi';
      expect(() => DailyCatalogueCodec.decode(json), throwsFormatException);

      hadith['collection'] = 'muslim';
      hadith['occasion'] = 'birthday';
      expect(() => DailyCatalogueCodec.decode(json), throwsFormatException);
    });

    test('rejects a hadith without a translation', () {
      final json = encoded();
      ((json['hadiths']! as List)[0] as Map<String, Object?>)['translations'] =
          <Object>[];
      expect(() => DailyCatalogueCodec.decode(json), throwsFormatException);
    });
  });

  group('the bundled catalogue', () {
    late DailyCatalogue catalogue;

    setUpAll(() async {
      // rootBundle serves what pubspec.yaml declares, so this also checks
      // that the asset is registered.
      catalogue = await DailyContentRepository(rootBundle).catalogue();
    });

    test('has a full everyday rotation', () {
      expect(catalogue.everydayAyahs.length, greaterThanOrEqualTo(100));
      expect(catalogue.everydayHadiths.length, greaterThanOrEqualTo(60));
    });

    test('every occasion has both an ayah and a hadith', () {
      for (final occasion in DailyOccasion.values) {
        final entries = catalogue.forOccasion(occasion, DailyContentMode.both);
        expect(
          entries.whereType<DailyAyahEntry>(),
          isNotEmpty,
          reason: '$occasion',
        );
        expect(
          entries.whereType<DailyHadithEntry>(),
          isNotEmpty,
          reason: '$occasion',
        );
      }
    });

    test('ayat are short passages that exist', () {
      for (final e in catalogue.ayahs) {
        expect(isValidVerseKey(e.surah, e.fromAyah), isTrue, reason: e.key);
        expect(isValidVerseKey(e.surah, e.toAyah), isTrue, reason: e.key);
        expect(e.toAyah - e.fromAyah, lessThan(5), reason: e.key);
      }
    });

    test('nothing appears twice', () {
      final keys = [
        for (final e in catalogue.ayahs) e.key,
        for (final e in catalogue.hadiths) e.hadith.citation,
      ];
      expect(keys.toSet(), hasLength(keys.length));
    });

    test('hadith are from Bukhari and Muslim, with an English translation '
        'from sunnah.com and a clean Arabic matn', () {
      for (final e in catalogue.hadiths) {
        final h = e.hadith;
        expect(HadithCollection.values, contains(h.collection));
        expect(h.number, matches(RegExp(r'^\d+[a-z]?$')), reason: h.citation);
        expect(h.sourceUrl.host, 'sunnah.com');
        final english = h.translationFor(const ['en']);
        expect(english.language, 'en', reason: h.citation);
        expect(english.source, 'sunnah.com');
        expect(english.text, isNot(contains('<')), reason: h.citation);
        expect(h.arabic, isNot(contains('[')), reason: h.citation);
        expect(h.arabic, isNot(contains('\u200F')), reason: h.citation);
        expect(h.arabic.trim(), h.arabic, reason: h.citation);
      }
    });

    test('Urdu translations come from HadeethEnc.com, unmodified', () {
      final urdu = [
        for (final e in catalogue.hadiths)
          for (final t in e.hadith.translations)
            if (t.language == 'ur') t,
      ];
      expect(urdu.length, greaterThanOrEqualTo(25));
      for (final t in urdu) {
        expect(t.source, 'HadeethEnc.com');
        expect(t.text.trim(), t.text);
        expect(t.text, isNot(contains('<')));
      }
    });
  });
}
