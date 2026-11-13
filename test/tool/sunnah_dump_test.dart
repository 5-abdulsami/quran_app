import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/mysql_dump.dart';
import '../../tool/src/sunnah_hadith.dart';

void main() {
  group('mysqlInsertRows', () {
    test('reads strings, escapes, numbers and NULL', () {
      const sql = r"""
-- comment
INSERT INTO `T` VALUES ('a\'b',1.50,NULL,'line\nbreak','x''y'),
('(paren), comma',-2,'back\\slash','\"q\"','');
INSERT INTO `Other` VALUES ('skip');
INSERT INTO `T` VALUES ('second',3,NULL,'','');
""";
      final rows = mysqlInsertRows(sql, 'T').toList();
      expect(rows, [
        ["a'b", '1.50', null, 'line\nbreak', "x'y"],
        ['(paren), comma', '-2', r'back\slash', '"q"', ''],
        ['second', '3', null, '', ''],
      ]);
    });

    test('rejects a truncated statement', () {
      expect(
        () => mysqlInsertRows("INSERT INTO `T` VALUES ('open", 'T').toList(),
        throwsFormatException,
      );
    });
  });

  group('sunnah.com text', () {
    test('English loses HTML and extra whitespace only', () {
      expect(
        cleanEnglishText(
          '\n<p>\n\n     Narrated Anas:\n<p>\n\n     The Prophet said, '
          '"None of you will have faith till he wishes for his \n     '
          '(Muslim) brother what he likes for himself."\n<p>\n\n\n',
        ),
        'Narrated Anas: The Prophet said, "None of you will have faith till '
        'he wishes for his (Muslim) brother what he likes for himself."',
      );
    });

    test('the Arabic matn is extracted without markup or edge quotes', () {
      const arabic =
          '[prematn]حَدَّثَنَا [narrator id="7426" role="first" '
          'tooltip="مسدد"]مُسَدَّدٌ[/narrator] قَالَ \u200F"\u200F '
          '[/prematn][matn]لا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ '
          'مَا يُحِبُّ لِنَفْسِهِ \u200F"[/matn]\u200F\u200F.\u200F   ';
      expect(
        arabicMatn(arabic),
        'لا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      );
    });

    test('quotation marks inside a dialogue are kept', () {
      expect(
        arabicMatn(
          '[matn]لاَ تَغْضَبْ ". فَرَدَّدَ مِرَارًا، قَالَ " لاَ تَغْضَبْ "[/matn]',
        ),
        'لاَ تَغْضَبْ ". فَرَدَّدَ مِرَارًا، قَالَ " لاَ تَغْضَبْ',
      );
    });

    test('no matn marked means no Arabic', () {
      expect(arabicMatn('حَدَّثَنَا'), isNull);
      expect(arabicMatn('[matn] " [/matn]'), isNull);
    });

    test('URL numbers drop the space before the letter', () {
      expect(urlHadithNumber('2564 c'), '2564c');
      expect(urlHadithNumber('1'), '1');
    });
  });
}
