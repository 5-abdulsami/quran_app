import 'package:meta/meta.dart';

enum SajdahType { recommended, obligatory }

/// One translation of one ayah.
@immutable
class AyahTranslation {
  const AyahTranslation({
    required this.editionId,
    required this.text,
    required this.language,
    required this.isRtl,
  });

  final String editionId;
  final String text;
  final String language;
  final bool isRtl;
}

/// One verse, ready to display. Mirrors `AyahView` in the web app.
///
/// Built ONLY by `QuranRepository`, which is the single place that calls
/// `presentVerse`. Every view renders [displayText].
@immutable
class Ayah {
  const Ayah({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.textUthmani,
    required this.displayText,
    required this.leadingBismillah,
    required this.bismillahPre,
    required this.juz,
    required this.hizb,
    required this.rubElHizb,
    required this.ruku,
    required this.manzil,
    required this.page,
    required this.sajdahType,
    required this.translations,
  });

  /// Mushaf-wide index, 1..6236.
  final int id;
  final int surahNumber;
  final int ayahNumber;

  /// The verse exactly as the source supplied it. Never modified, and never
  /// what a reader sees for ayah 1 of a surah whose header shows the basmalah.
  final String textUthmani;

  /// What to render. Identical to [textUthmani] except for the first ayah of a
  /// surah whose header already shows the basmalah, where the duplicate prefix
  /// is separated out.
  final String displayText;

  /// The separated basmalah, when one was split off. Usually null.
  final String? leadingBismillah;

  /// Whether this surah's header renders a standalone basmalah.
  final bool bismillahPre;

  final int juz;
  final int hizb;
  final int rubElHizb;
  final int ruku;
  final int manzil;
  final int page;
  final SajdahType? sajdahType;

  /// The requested translations, in the reader's chosen order.
  final List<AyahTranslation> translations;

  /// "2:255"
  String get verseKey => '$surahNumber:$ayahNumber';
}
