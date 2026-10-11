import '../../core/quran/references.dart';
import '../../core/text/arabic_digits.dart';
import '../../core/text/normalize.dart';
import '../../domain/models/surah.dart';

enum RevelationFilter { all, makki, madani }

/// Filters the surah list by number, English name, meaning or Arabic name
/// (all folded, so "baqara", "Al-Baqarah", "cow", "2" and "البقرة" all work),
/// and by revelation place.
List<Surah> filterSurahs(
  List<Surah> surahs, {
  String query = '',
  RevelationFilter revelation = RevelationFilter.all,
}) {
  final q = toAsciiDigits(query).trim();
  final normalized = normalizeForSearch(q);
  final folded = SurahNameIndex.foldName(q);
  final number = int.tryParse(q);

  bool matchesPlace(Surah s) => switch (revelation) {
    RevelationFilter.all => true,
    RevelationFilter.makki => s.revelationPlace == RevelationPlace.makkah,
    RevelationFilter.madani => s.revelationPlace == RevelationPlace.madinah,
  };

  bool matchesQuery(Surah s) {
    if (q.isEmpty) return true;
    if (number != null) return '${s.number}'.startsWith(q);
    return normalizeForSearch(s.nameSimple).contains(normalized) ||
        normalizeForSearch(s.nameTranslated).contains(normalized) ||
        normalizeForSearch(s.nameArabic).contains(normalized) ||
        (folded.isNotEmpty &&
            (SurahNameIndex.foldName(s.nameSimple).contains(folded) ||
                SurahNameIndex.foldName(s.nameArabic).contains(folded)));
  }

  return [
    for (final s in surahs)
      if (matchesPlace(s) && matchesQuery(s)) s,
  ];
}
