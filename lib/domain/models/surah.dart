import 'package:meta/meta.dart';

import '../../core/quran/bismillah.dart';

enum RevelationPlace { makkah, madinah }

/// One surah's metadata. Mirrors `SurahSummary` in the web app's read model.
@immutable
class Surah {
  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameSimple,
    required this.nameTranslated,
    required this.revelationPlace,
    required this.ayahCount,
    required this.bismillahPre,
    required this.pageStart,
    required this.pageEnd,
    this.revelationOrder,
  });

  final int number;

  /// e.g. "سُورَةُ البَقَرَةِ", as supplied by the source.
  final String nameArabic;

  /// e.g. "Al-Baqara".
  final String nameSimple;

  /// e.g. "The Cow".
  final String nameTranslated;
  final RevelationPlace revelationPlace;

  /// Not published by the source; null rather than guessed.
  final int? revelationOrder;
  final int ayahCount;
  final bool bismillahPre;
  final int pageStart;
  final int pageEnd;

  /// Whether this surah's header shows a standalone basmalah. The one rule
  /// every header uses; see core/quran/bismillah.dart.
  bool get rendersHeaderBismillah =>
      shouldRenderHeaderBismillah(number, bismillahPre: bismillahPre);

  @override
  bool operator ==(Object other) => other is Surah && other.number == number;

  @override
  int get hashCode => number.hashCode;
}
