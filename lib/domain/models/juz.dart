import 'package:meta/meta.dart';

/// One juz (part). Boundaries come from the data; names are labels only.
@immutable
class Juz {
  const Juz({
    required this.number,
    required this.firstVerseKey,
    required this.lastVerseKey,
    required this.firstAyahId,
    required this.lastAyahId,
    required this.nameArabic,
    required this.nameTransliterated,
    required this.surahNumbers,
  });

  final int number;
  final String firstVerseKey;
  final String lastVerseKey;

  /// Mushaf-wide ids of the first and last ayah, for progress.
  final int firstAyahId;
  final int lastAyahId;

  final String nameArabic;
  final String nameTransliterated;

  /// Every surah this juz spans, in order.
  final List<int> surahNumbers;

  int get ayahCount => lastAyahId - firstAyahId + 1;
}
