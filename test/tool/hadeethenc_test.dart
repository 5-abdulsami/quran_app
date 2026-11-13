import 'package:flutter_test/flutter_test.dart';

import '../../tool/fetch_hadeethenc.dart' show citesHadith, matnSimilarity;

void main() {
  const reference =
      'صحيح البخاري (9/ 2) (6864).\n'
      'صحيح مسلم (3/ 1304) (1678).\n'
      'خلاصة الكلام شرح عمدة الأحكام، لفيصل آل مبارك (ص319).';

  group('citesHadith', () {
    test('matches the book and the hadith number', () {
      expect(citesHadith(reference, 'bukhari:6864'), isTrue);
      expect(citesHadith(reference, 'muslim:1678'), isTrue);
    });

    test("ignores the sub-narration letter of Muslim's numbering", () {
      expect(citesHadith(reference, 'muslim:1678b'), isTrue);
    });

    test('a number in another book, or a page number, is not a match', () {
      expect(citesHadith(reference, 'bukhari:1678'), isFalse);
      expect(citesHadith(reference, 'muslim:6864'), isFalse);
      expect(citesHadith(reference, 'bukhari:2'), isFalse); // volume/page
      expect(citesHadith('', 'bukhari:1'), isFalse);
    });
  });

  group('matnSimilarity', () {
    const ours =
        'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ';

    test('only the quoted words count, and diacritics do not', () {
      expect(
        matnSimilarity(
          ours,
          'عن أبي هريرة رضي الله عنه أن رسول الله صلى الله عليه وسلم قال: '
          '«ليس الشديد بالصرعة، إنما الشديد الذي يملك نفسه عند الغضب».',
        ),
        1,
      );
    });

    test('an added sentence makes it inexact', () {
      expect(
        matnSimilarity(
          ours,
          '«ليس الشديد بالصرعة، إنما الشديد الذي يملك نفسه عند الغضب، '
          'وإذا غضب أحدكم فليسكت»',
        ),
        lessThan(1),
      );
    });

    test('a different hadith scores low', () {
      expect(matnSimilarity(ours, '«إنما الأعمال بالنيات»'), lessThan(0.3));
    });
  });
}
