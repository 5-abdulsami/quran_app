import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/quran/citation.dart';
import 'package:quran_app/core/quran/references.dart';

void main() {
  test('a single verse and a passage are labelled and cited', () {
    expect(verseRangeLabel(2, 255, 255), '2:255');
    expect(verseRangeLabel(94, 5, 6), '94:5–6');
    expect(
      formatQuranPassageCitation(94, 5, 6, 'Ash-Sharh'),
      "Qur'an 94:5–6 (Surah Ash-Sharh)",
    );
    expect(formatQuranPassageCitation(2, 255, 255), "Qur'an 2:255");
  });

  test('a passage payload ends with its citation', () {
    expect(
      passagePayload(
        surah: 94,
        fromAyah: 5,
        toAyah: 6,
        surahName: 'Ash-Sharh',
        arabic: 'عربي',
        translations: const ['English'],
      ),
      "عربي\n\nEnglish\n\nQur'an 94:5–6 (Surah Ash-Sharh)",
    );
  });

  test('versePayload is unchanged for a single verse', () {
    expect(
      versePayload(surah: 2, ayah: 255, surahName: 'Al-Baqarah'),
      "Qur'an 2:255 (Surah Al-Baqarah)",
    );
  });
}
