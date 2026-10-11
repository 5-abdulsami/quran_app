import '../core/quran/references.dart';
import '../core/text/arabic_digits.dart';
import '../core/text/normalize.dart';
import 'models/surah.dart';

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
    final keys = _keysFor(s);
    return keys.normalized.any((k) => k.contains(normalized)) ||
        (folded.isNotEmpty && keys.folded.any((k) => k.contains(folded)));
  }

  return [
    for (final s in surahs)
      if (matchesPlace(s) && matchesQuery(s)) s,
  ];
}

/// A surah's names, normalised once: folding them on every keystroke would
/// cost more than the rest of a search put together.
typedef _SurahKeys = ({List<String> normalized, List<String> folded});

final Expando<_SurahKeys> _keyCache = Expando('surahKeys');

_SurahKeys _keysFor(Surah s) => _keyCache[s] ??= (
  normalized: [
    normalizeForSearch(s.nameSimple),
    normalizeForSearch(s.nameTranslated),
    normalizeForSearch(s.nameArabic),
  ],
  folded: [
    SurahNameIndex.foldName(s.nameSimple),
    SurahNameIndex.foldName(s.nameArabic),
  ],
);
