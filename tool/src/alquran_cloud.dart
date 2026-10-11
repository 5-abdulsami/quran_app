// AlQuran.cloud client for the build script.
//
// Mirrors the field mapping of
// islamic-platform/src/modules/ingestion/adapters/alquran-cloud.ts. Every
// response is cached under tool/cache/ (git-ignored): the provider asks callers
// to cache aggressively, and it makes re-runs fully offline.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:quran_app/core/quran/attribution.dart';
import 'package:quran_app/core/text/direction.dart';

/// Thrown when the API returns something the build cannot trust.
class SourceDataException implements Exception {
  SourceDataException(this.message);
  final String message;

  @override
  String toString() => 'SourceDataException: $message';
}

class CloudSurah {
  CloudSurah.fromJson(Map<String, dynamic> json)
    : number = json['number'] as int,
      name = json['name'] as String,
      englishName = json['englishName'] as String,
      englishNameTranslation = json['englishNameTranslation'] as String,
      numberOfAyahs = json['numberOfAyahs'] as int,
      revelationType = json['revelationType'] as String;

  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  /// Same rule as the web adapter.
  String get revelationPlace =>
      revelationType.toLowerCase().startsWith('mec') ? 'makkah' : 'madinah';
}

class CloudAyah {
  CloudAyah.fromJson(this.surahNumber, Map<String, dynamic> json)
    : number = json['number'] as int,
      text = json['text'] as String,
      numberInSurah = json['numberInSurah'] as int,
      juz = json['juz'] as int,
      manzil = json['manzil'] as int,
      page = json['page'] as int,
      ruku = json['ruku'] as int,
      hizbQuarter = json['hizbQuarter'] as int,
      sajdahType = _sajdah(json['sajda']);

  final int surahNumber;
  final int number;
  final String text;
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final String? sajdahType;

  String get verseKey => '$surahNumber:$numberInSurah';

  /// The provider reports quarter-hizb (1..240); hizb is derived from it.
  int get hizb => (hizbQuarter / 4).ceil();

  /// `sajda` is `false` or `{id, recommended, obligatory}`.
  static String? _sajdah(Object? value) {
    if (value is Map<String, dynamic>) {
      return value['obligatory'] == true ? 'obligatory' : 'recommended';
    }
    return null;
  }
}

class CloudEdition {
  /// [reportedDirection] comes from `/edition`, because the `/quran/{id}`
  /// response omits it.
  CloudEdition.fromJson(Map<String, dynamic> json, {String? reportedDirection})
    : identifier = json['identifier'] as String,
      language = json['language'] as String,
      name = json['name'] as String,
      englishName = json['englishName'] as String,
      direction = textDirectionFor(
        json['language'] as String,
        reported: (json['direction'] as String?) ?? reportedDirection,
      );

  final String identifier;
  final String language;
  final String name;
  final String englishName;

  /// 'ltr' | 'rtl'
  final String direction;

  String get attribution =>
      attributionForTranslation(name: name, englishName: englishName);
}

/// A complete edition: its metadata and every ayah, in mushaf order.
class CloudQuran {
  CloudQuran(this.edition, this.ayahs);
  final CloudEdition edition;
  final List<CloudAyah> ayahs;
}

class AlQuranCloudClient {
  AlQuranCloudClient({required this.cacheDir, http.Client? client})
    : _client = client ?? http.Client();

  final Directory cacheDir;
  final http.Client _client;

  void close() => _client.close();

  Future<List<CloudSurah>> surahs() async {
    final data = await _getData('surah', 'surah.json');
    return (data as List<dynamic>)
        .map((s) => CloudSurah.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  /// `GET /meta` — used to cross-check juz boundaries.
  Future<Map<String, dynamic>> meta() async =>
      (await _getData('meta', 'meta.json')) as Map<String, dynamic>;

  /// `GET /edition?format=text&type=translation`, keyed by identifier.
  Future<Map<String, Map<String, dynamic>>> translationEditions() async {
    final data = await _getData(
      'edition?format=text&type=translation',
      'editions-translation.json',
    );
    return {
      for (final e in (data as List<dynamic>).cast<Map<String, dynamic>>())
        e['identifier'] as String: e,
    };
  }

  /// `GET /quran/{edition}` — the whole Quran in one edition.
  Future<CloudQuran> quran(String edition, {String? reportedDirection}) async {
    final data =
        (await _getData('quran/$edition', 'quran-$edition.json'))
            as Map<String, dynamic>;
    final ayahs = <CloudAyah>[];
    for (final surah in data['surahs'] as List<dynamic>) {
      final surahJson = surah as Map<String, dynamic>;
      final number = surahJson['number'] as int;
      for (final ayah in surahJson['ayahs'] as List<dynamic>) {
        ayahs.add(CloudAyah.fromJson(number, ayah as Map<String, dynamic>));
      }
    }
    return CloudQuran(
      CloudEdition.fromJson(
        data['edition'] as Map<String, dynamic>,
        reportedDirection: reportedDirection,
      ),
      ayahs,
    );
  }

  /// Returns the envelope's `data`, from cache when present.
  Future<Object?> _getData(String path, String cacheName) async {
    final cacheFile = File(p.join(cacheDir.path, cacheName));
    String body;
    if (cacheFile.existsSync()) {
      body = cacheFile.readAsStringSync();
    } else {
      body = await _fetch('$alQuranCloudApiBase/$path');
      cacheDir.createSync(recursive: true);
      cacheFile.writeAsStringSync(body);
    }

    final envelope = jsonDecode(body) as Map<String, dynamic>;
    if (envelope['code'] != 200) {
      throw SourceDataException('$path: status ${envelope['status']}');
    }
    return envelope['data'];
  }

  Future<String> _fetch(String url) async {
    const attempts = 3;
    for (var attempt = 1; ; attempt++) {
      try {
        stdout.writeln('  GET $url');
        final response = await _client
            .get(Uri.parse(url))
            .timeout(const Duration(minutes: 2));
        if (response.statusCode != 200) {
          throw SourceDataException('$url: HTTP ${response.statusCode}');
        }
        // Decode explicitly as UTF-8 whatever the response headers claim.
        return utf8.decode(response.bodyBytes);
      } on Exception {
        if (attempt >= attempts) rethrow;
        await Future<void>.delayed(Duration(seconds: 2 * attempt));
      }
    }
  }
}
