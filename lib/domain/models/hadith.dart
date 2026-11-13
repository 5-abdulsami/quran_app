import 'package:meta/meta.dart';

/// The hadith collections the app quotes from. Both are Sahih in their
/// entirety by the consensus of the scholars of hadith, so no per-hadith
/// grade is needed.
enum HadithCollection {
  bukhari('bukhari', 'Sahih al-Bukhari'),
  muslim('muslim', 'Sahih Muslim');

  const HadithCollection(this.id, this.englishName);

  /// sunnah.com's identifier, used in links: "bukhari".
  final String id;

  /// The name used in copied and shared text, in every UI language (as
  /// Quran citations are), so a shared hadith can always be looked up.
  final String englishName;

  static HadithCollection? byId(String id) {
    for (final collection in values) {
      if (collection.id == id) return collection;
    }
    return null;
  }
}

/// One translation of a hadith.
@immutable
class HadithTranslation {
  const HadithTranslation({
    required this.language,
    required this.text,
    required this.source,
  });

  /// ISO 639-1 code: 'en', 'ur', ...
  final String language;
  final String text;

  /// Where the translation comes from, credited wherever it is shown.
  final String source;
}

/// A hadith, with its Arabic text and one or more translations.
@immutable
class Hadith {
  Hadith({
    required this.collection,
    required this.number,
    required this.arabic,
    required List<HadithTranslation> translations,
  }) : assert(translations.isNotEmpty, 'a hadith needs a translation'),
       translations = List.unmodifiable(translations);

  final HadithCollection collection;

  /// sunnah.com's number, e.g. "1" or "2564c".
  final String number;

  /// The Arabic matn: the words of the Prophet ﷺ, without the chain.
  final String arabic;

  /// Never empty.
  final List<HadithTranslation> translations;

  /// "Sahih al-Bukhari 1"
  String get citation => '${collection.englishName} $number';

  /// This hadith's page on sunnah.com, with its full chain and chapter.
  Uri get sourceUrl => Uri.https('sunnah.com', '/${collection.id}:$number');

  /// The first translation in [preferredLanguages] order, falling back to
  /// the first one available.
  HadithTranslation translationFor(Iterable<String> preferredLanguages) {
    for (final language in preferredLanguages) {
      for (final translation in translations) {
        if (translation.language == language) return translation;
      }
    }
    return translations.first;
  }
}
