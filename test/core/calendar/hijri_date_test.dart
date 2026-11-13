import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/calendar/hijri_date.dart';

void main() {
  HijriDate h(int y, int m, int d, {int adjust = 0}) =>
      HijriDate.fromGregorian(DateTime(y, m, d), adjustmentDays: adjust);

  test('the epoch is 1 Muharram 1 AH', () {
    // 16 July 622 Julian = 19 July 622 proleptic Gregorian.
    expect(h(622, 7, 19), const HijriDate(1, 1, 1));
  });

  test('matches announced dates', () {
    expect(h(2000, 1, 1), const HijriDate(1420, 9, 24));
    expect(h(2024, 3, 11), const HijriDate(1445, 9, 1)); // 1 Ramadan
    expect(h(2024, 4, 10), const HijriDate(1445, 10, 1)); // Eid al-Fitr
    expect(h(2026, 2, 18), const HijriDate(1447, 9, 1)); // 1 Ramadan
    expect(h(2026, 5, 27), const HijriDate(1447, 12, 10)); // Eid al-Adha
  });

  test('ignores the time of day', () {
    expect(
      HijriDate.fromGregorian(DateTime(2026, 2, 18, 23, 59)),
      HijriDate.fromGregorian(DateTime(2026, 2, 18)),
    );
  });

  test('adjustment moves the date by whole days', () {
    expect(h(2026, 2, 18, adjust: -1), const HijriDate(1447, 8, 29));
    expect(h(2026, 2, 18, adjust: 1), const HijriDate(1447, 9, 2));
    expect(h(2026, 2, 18, adjust: 2), h(2026, 2, 20));
  });

  test('every day advances by one, with 29 or 30 day months', () {
    var previous = h(2020, 1, 1);
    var monthLength = 0;
    for (var i = 1; i < 3000; i++) {
      final today = HijriDate.fromGregorian(DateTime(2020, 1, 1 + i));
      if (today.month == previous.month) {
        expect(today.day, previous.day + 1, reason: '$today');
        monthLength = today.day;
      } else {
        expect(today.day, 1, reason: '$today');
        expect(today.month, previous.month % 12 + 1, reason: '$today');
        if (monthLength > 0) expect(monthLength, inInclusiveRange(29, 30));
      }
      previous = today;
    }
  });
}
