import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/calendar/hijri_date.dart';
import 'package:quran_app/domain/daily/daily_content.dart';
import 'package:quran_app/domain/daily/daily_selector.dart';
import 'package:quran_app/domain/models/hadith.dart';

DailyAyahEntry ayah(int surah, int from, [DailyOccasion? occasion]) =>
    DailyAyahEntry(
      surah: surah,
      fromAyah: from,
      toAyah: from,
      occasion: occasion,
    );

DailyHadithEntry hadith(String number, [DailyOccasion? occasion]) =>
    DailyHadithEntry(
      hadith: Hadith(
        collection: HadithCollection.bukhari,
        number: number,
        arabic: 'نص',
        translations: const [
          HadithTranslation(language: 'en', text: 'text', source: 'test'),
        ],
      ),
      occasion: occasion,
    );

DailyDate day(DateTime date) =>
    (date: date, hijri: HijriDate.fromGregorian(date));

void main() {
  const selector = DailySelector();
  final catalogue = DailyCatalogue(
    ayahs: [
      ayah(1, 1),
      ayah(2, 1),
      ayah(3, 1),
      ayah(2, 183, DailyOccasion.ramadan),
      ayah(62, 9, DailyOccasion.friday),
    ],
    hadiths: [
      hadith('1'),
      hadith('2'),
      hadith('38', DailyOccasion.ramadan),
      hadith('935', DailyOccasion.friday),
    ],
  );

  // A Monday, outside every occasion.
  final monday = DateTime(2026, 1, 5);

  DailyEntry? pick(
    DateTime date, [
    DailyContentMode mode = DailyContentMode.both,
  ]) => selector.pick(catalogue, day(date), mode: mode);

  List<DailyEntry?> week(
    DateTime start, [
    DailyContentMode mode = DailyContentMode.both,
  ]) => [
    for (var i = 0; i < 4; i++)
      pick(DateTime(start.year, start.month, start.day + i), mode),
  ];

  test('dayNumber depends only on the calendar day', () {
    expect(
      dayNumber(DateTime(2026, 1, 5, 0, 1)),
      dayNumber(DateTime(2026, 1, 5, 23, 59)),
    );
    expect(
      dayNumber(DateTime(2026, 1, 6)) - dayNumber(DateTime(2026, 1, 5)),
      1,
    );
    // Across a month and a year boundary.
    expect(
      dayNumber(DateTime(2027, 1, 1)) - dayNumber(DateTime(2026, 12, 31)),
      1,
    );
  });

  test('both: alternates ayah and hadith, each advancing in turn', () {
    final picks = week(monday);
    expect(picks.map((e) => e.runtimeType).toSet(), {
      DailyAyahEntry,
      DailyHadithEntry,
    });
    for (var i = 0; i + 1 < picks.length; i++) {
      expect(picks[i].runtimeType, isNot(picks[i + 1].runtimeType));
    }
    final ayahs = picks.whereType<DailyAyahEntry>().toList();
    final hadiths = picks.whereType<DailyHadithEntry>().toList();
    expect(ayahs[0], isNot(ayahs[1]));
    expect(hadiths[0].hadith.number, isNot(hadiths[1].hadith.number));
  });

  test('ayah-only and hadith-only use a single rotation', () {
    expect(
      week(monday, DailyContentMode.ayahOnly),
      everyElement(isA<DailyAyahEntry>()),
    );
    expect(
      week(monday, DailyContentMode.hadithOnly),
      everyElement(isA<DailyHadithEntry>()),
    );
    final ayahs = week(monday, DailyContentMode.ayahOnly);
    expect(ayahs.toSet(), hasLength(3)); // all three, then wraps
  });

  test('is deterministic', () {
    expect(pick(monday), pick(DateTime(2026, 1, 5, 22)));
  });

  test('never shows an occasion entry on an ordinary day', () {
    for (var i = 0; i < 4; i++) {
      final entry = pick(DateTime(2026, 1, 5 + i));
      expect(entry!.occasion, isNull);
    }
  });

  test('Fridays use the Friday list, in turn', () {
    final friday = DateTime(2026, 1, 9);
    final a = pick(friday)!;
    final b = pick(DateTime(2026, 1, 16))!;
    expect(a.occasion, DailyOccasion.friday);
    expect(b.occasion, DailyOccasion.friday);
    expect(a.runtimeType, isNot(b.runtimeType));
  });

  test('Ramadan takes precedence over Friday', () {
    // 20 Feb 2026 is a Friday and 3 Ramadan 1447.
    final entry = pick(DateTime(2026, 2, 20))!;
    expect(entry.occasion, DailyOccasion.ramadan);
  });

  test(
    'an occasion without entries for the mode falls back to the rotation',
    () {
      final noFridayHadith = DailyCatalogue(
        ayahs: catalogue.ayahs,
        hadiths: [hadith('1'), hadith('2')],
      );
      final entry = selector.pick(
        noFridayHadith,
        day(DateTime(2026, 1, 9)),
        mode: DailyContentMode.hadithOnly,
      );
      expect(entry, isA<DailyHadithEntry>());
      expect(entry!.occasion, isNull);
    },
  );

  test('the Hijri adjustment decides when Ramadan starts', () {
    // 17 Feb 2026 is 29 Sha'ban by calculation; +1 makes it 1 Ramadan.
    final date = DateTime(2026, 2, 17);
    final plain = selector.pick(
      catalogue,
      day(date),
      mode: DailyContentMode.both,
    );
    final adjusted = selector.pick(catalogue, (
      date: date,
      hijri: HijriDate.fromGregorian(date, adjustmentDays: 1),
    ), mode: DailyContentMode.both);
    expect(plain!.occasion, isNull);
    expect(adjusted!.occasion, DailyOccasion.ramadan);
  });

  test('Dhu al-Hijjah covers days 1–13 only', () {
    const rule = DhulHijjahRule();
    DailyDate at(int d) => (date: monday, hijri: HijriDate(1447, 12, d));
    expect(rule.slot(at(1)), 0);
    expect(rule.slot(at(13)), 12);
    expect(rule.slot(at(14)), isNull);
  });

  test('an empty catalogue picks nothing', () {
    expect(
      selector.pick(
        DailyCatalogue(ayahs: const [], hadiths: const []),
        day(monday),
        mode: DailyContentMode.both,
      ),
      isNull,
    );
  });

  test('forOccasion interleaves ayat and hadith', () {
    final entries = catalogue.forOccasion(
      DailyOccasion.ramadan,
      DailyContentMode.both,
    );
    expect(entries.map((e) => e.runtimeType), [
      DailyAyahEntry,
      DailyHadithEntry,
    ]);
  });
}
