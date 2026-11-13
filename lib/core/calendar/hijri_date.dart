// The tabular (arithmetic) Islamic calendar. Pure Dart.
//
// The tabular calendar uses a fixed 30-year cycle of 354/355-day years, so it
// needs no data and never changes. Actual months begin with the sighting of
// the new moon, which differs by country and can fall a day or two either
// side of the tabular date. Callers therefore apply the reader's own
// adjustment (see `AppSettings.hijriAdjustment`) rather than trusting this as
// the official date.

import 'package:meta/meta.dart';

/// A date in the Islamic calendar. [month] is 1 (Muharram) to 12
/// (Dhu al-Hijjah).
@immutable
class HijriDate {
  const HijriDate(this.year, this.month, this.day);

  /// The tabular Hijri date of [date]'s calendar day, shifted by
  /// [adjustmentDays] (positive moves the Hijri date later).
  ///
  /// Only the year, month and day of [date] are used; the time of day and
  /// time zone are ignored.
  factory HijriDate.fromGregorian(DateTime date, {int adjustmentDays = 0}) =>
      _fromJulianDay(_julianDay(date) + adjustmentDays);

  static const int muharram = 1;
  static const int ramadan = 9;
  static const int dhulHijjah = 12;

  final int year;
  final int month;
  final int day;

  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year-$month-$day AH';
}

/// The Julian Day Number of a Gregorian calendar day.
int _julianDay(DateTime date) {
  final a = (14 - date.month) ~/ 12;
  final y = date.year + 4800 - a;
  final m = date.month + 12 * a - 3;
  return date.day +
      (153 * m + 2) ~/ 5 +
      365 * y +
      y ~/ 4 -
      y ~/ 100 +
      y ~/ 400 -
      32045;
}

/// The arithmetic conversion from a Julian Day Number, using the civil
/// epoch (1 Muharram 1 AH = 16 July 622 CE, Julian).
HijriDate _fromJulianDay(int julianDay) {
  var l = julianDay - 1948440 + 10632;
  final n = (l - 1) ~/ 10631;
  l = l - 10631 * n + 354;
  final j =
      ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
      (l ~/ 5670) * ((43 * l) ~/ 15238);
  l =
      l -
      ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
      (j ~/ 16) * ((15238 * j) ~/ 43) +
      29;
  final month = (24 * l) ~/ 709;
  final day = l - (709 * month) ~/ 24;
  final year = 30 * n + j - 30;
  return HijriDate(year, month, day);
}
