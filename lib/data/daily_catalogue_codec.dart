// The JSON form of a DailyCatalogue: written by tool/build_daily_content.dart
// into assets/daily/daily_content.json, read by DailyContentRepository.
//
// Decoding is strict. A malformed asset fails loudly in tests and in the
// build, instead of quietly showing the wrong verse or a hadith without its
// reference.

import '../core/quran/references.dart';
import '../domain/daily/daily_content.dart';
import '../domain/models/hadith.dart';

abstract final class DailyCatalogueCodec {
  /// Bump when the JSON shape changes incompatibly.
  static const schemaVersion = 1;

  static Map<String, Object?> encode(DailyCatalogue catalogue) => {
    'schemaVersion': schemaVersion,
    'ayahs': [
      for (final e in catalogue.ayahs)
        {
          'surah': e.surah,
          'from': e.fromAyah,
          'to': e.toAyah,
          if (e.occasion case final occasion?) 'occasion': occasion.name,
        },
    ],
    'hadiths': [
      for (final e in catalogue.hadiths)
        {
          'collection': e.hadith.collection.id,
          'number': e.hadith.number,
          'arabic': e.hadith.arabic,
          'translations': [
            for (final t in e.hadith.translations)
              {'language': t.language, 'text': t.text, 'source': t.source},
          ],
          if (e.occasion case final occasion?) 'occasion': occasion.name,
        },
    ],
  };

  /// Throws [FormatException] on anything unexpected.
  static DailyCatalogue decode(Object? json) {
    final root = _map(json, 'catalogue');
    final version = root['schemaVersion'];
    if (version != schemaVersion) {
      throw FormatException('Unsupported daily content schema: $version');
    }
    return DailyCatalogue(
      ayahs: [for (final a in _list(root['ayahs'], 'ayahs')) _ayah(a)],
      hadiths: [for (final h in _list(root['hadiths'], 'hadiths')) _hadith(h)],
    );
  }

  static DailyAyahEntry _ayah(Object? json) {
    final map = _map(json, 'ayah');
    final surah = _int(map['surah'], 'surah');
    final from = _int(map['from'], 'from');
    final to = _int(map['to'], 'to');
    if (from > to ||
        !isValidVerseKey(surah, from) ||
        !isValidVerseKey(surah, to)) {
      throw FormatException('Invalid ayah range $surah:$from-$to');
    }
    return DailyAyahEntry(
      surah: surah,
      fromAyah: from,
      toAyah: to,
      occasion: _occasion(map['occasion']),
    );
  }

  static DailyHadithEntry _hadith(Object? json) {
    final map = _map(json, 'hadith');
    final collectionId = _string(map['collection'], 'collection');
    final collection = HadithCollection.byId(collectionId);
    if (collection == null) {
      throw FormatException('Unknown hadith collection "$collectionId"');
    }
    final translations = [
      for (final t in _list(map['translations'], 'translations'))
        _translation(t),
    ];
    if (translations.isEmpty) {
      throw FormatException('${map['number']} has no translation');
    }
    return DailyHadithEntry(
      hadith: Hadith(
        collection: collection,
        number: _string(map['number'], 'number'),
        arabic: _string(map['arabic'], 'arabic'),
        translations: translations,
      ),
      occasion: _occasion(map['occasion']),
    );
  }

  static HadithTranslation _translation(Object? json) {
    final map = _map(json, 'translation');
    return HadithTranslation(
      language: _string(map['language'], 'language'),
      text: _string(map['text'], 'text'),
      source: _string(map['source'], 'source'),
    );
  }

  static DailyOccasion? _occasion(Object? value) {
    if (value == null) return null;
    final name = _string(value, 'occasion');
    for (final occasion in DailyOccasion.values) {
      if (occasion.name == name) return occasion;
    }
    throw FormatException('Unknown occasion "$name"');
  }

  static Map<String, Object?> _map(Object? value, String what) =>
      value is Map<String, Object?>
      ? value
      : throw FormatException('Expected an object for $what');

  static List<Object?> _list(Object? value, String what) => value is List
      ? value.cast<Object?>()
      : throw FormatException('Expected a list for $what');

  static int _int(Object? value, String what) =>
      value is int ? value : throw FormatException('Expected a number: $what');

  static String _string(Object? value, String what) =>
      value is String && value.trim().isNotEmpty
      ? value
      : throw FormatException('Expected text: $what');
}
