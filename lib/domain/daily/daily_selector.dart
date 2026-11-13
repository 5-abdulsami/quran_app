import '../../core/calendar/hijri_date.dart';
import 'daily_content.dart';

/// The calendar day being chosen for, in both calendars.
typedef DailyDate = ({DateTime date, HijriDate hijri});

/// Whole days since a fixed epoch for [date]'s calendar day. The same local
/// day always gives the same number, whatever the time or time zone.
int dayNumber(DateTime date) => DateTime.utc(
  date.year,
  date.month,
  date.day,
).difference(DateTime.utc(2000)).inDays;

/// Decides whether a day is an occasion with its own list, and which entry of
/// that list the day takes.
abstract interface class OccasionRule {
  DailyOccasion get occasion;

  /// A stable position within the occasion's list for [day], or null when
  /// [day] is not this occasion.
  int? slot(DailyDate day);
}

/// Every day of Ramadan; day N of the month takes entry N.
final class RamadanRule implements OccasionRule {
  const RamadanRule();

  @override
  DailyOccasion get occasion => DailyOccasion.ramadan;

  @override
  int? slot(DailyDate day) =>
      day.hijri.month == HijriDate.ramadan ? day.hijri.day - 1 : null;
}

/// The first ten days of Dhu al-Hijjah and the days of tashriq (11–13).
final class DhulHijjahRule implements OccasionRule {
  const DhulHijjahRule();

  static const lastDay = 13;

  @override
  DailyOccasion get occasion => DailyOccasion.dhulHijjah;

  @override
  int? slot(DailyDate day) =>
      day.hijri.month == HijriDate.dhulHijjah && day.hijri.day <= lastDay
      ? day.hijri.day - 1
      : null;
}

/// Every Friday; consecutive Fridays take consecutive entries.
final class FridayRule implements OccasionRule {
  const FridayRule();

  @override
  DailyOccasion get occasion => DailyOccasion.friday;

  @override
  int? slot(DailyDate day) => day.date.weekday == DateTime.friday
      ? dayNumber(day.date) ~/ DateTime.daysPerWeek
      : null;
}

/// Picks the day's entry from a [DailyCatalogue]. Deterministic: everyone
/// sees the same entry on the same day, with no state kept.
///
/// [rules] are tried in order; the first that matches (and has entries for
/// the chosen [DailyContentMode]) wins. Otherwise the everyday rotation is
/// used: with [DailyContentMode.both], even days show an ayah and odd days a
/// hadith, each list advancing one entry per appearance.
class DailySelector {
  const DailySelector({this.rules = defaultRules});

  /// Ramadan first, so a Friday in Ramadan stays a Ramadan day.
  static const List<OccasionRule> defaultRules = [
    RamadanRule(),
    DhulHijjahRule(),
    FridayRule(),
  ];

  final List<OccasionRule> rules;

  /// Null only when the catalogue has nothing [mode] allows.
  DailyEntry? pick(
    DailyCatalogue catalogue,
    DailyDate day, {
    required DailyContentMode mode,
  }) {
    for (final rule in rules) {
      final slot = rule.slot(day);
      if (slot == null) continue;
      final entries = catalogue.forOccasion(rule.occasion, mode);
      if (entries.isNotEmpty) return entries[slot % entries.length];
    }

    final n = dayNumber(day.date);
    final ayahs = mode.includesAyah
        ? catalogue.everydayAyahs
        : const <DailyAyahEntry>[];
    final hadiths = mode.includesHadith
        ? catalogue.everydayHadiths
        : const <DailyHadithEntry>[];
    if (ayahs.isEmpty && hadiths.isEmpty) return null;
    if (hadiths.isEmpty) return ayahs[n % ayahs.length];
    if (ayahs.isEmpty) return hadiths[n % hadiths.length];
    final turn = n ~/ 2;
    return n.isEven
        ? ayahs[turn % ayahs.length]
        : hadiths[turn % hadiths.length];
  }
}
