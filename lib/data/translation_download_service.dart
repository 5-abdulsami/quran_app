import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../core/db/content_db.dart';
import '../core/quran/attribution.dart';
import '../core/quran/references.dart';
import '../core/text/direction.dart';
import '../core/text/normalize.dart';

/// A translation edition offered by AlQuran.cloud.
class AvailableEdition {
  const AvailableEdition({
    required this.id,
    required this.language,
    required this.name,
    required this.englishName,
    required this.direction,
  });

  factory AvailableEdition.fromJson(Map<String, dynamic> json) =>
      AvailableEdition(
        id: json['identifier'] as String,
        language: json['language'] as String,
        name: json['name'] as String,
        englishName: json['englishName'] as String,
        direction: textDirectionFor(
          json['language'] as String,
          reported: json['direction'] as String?,
        ),
      );

  /// e.g. 'fr.hamidullah'
  final String id;
  final String language;

  /// Translator credit (provider `name`).
  final String name;

  /// Edition title (provider `englishName`).
  final String englishName;
  final String direction;

  Map<String, Object> toJson() => {
    'identifier': id,
    'language': language,
    'name': name,
    'englishName': englishName,
    'direction': direction,
  };
}

/// Thrown when a download is unusable. The app keeps working regardless.
class TranslationDownloadException implements Exception {
  TranslationDownloadException(this.message);
  final String message;

  @override
  String toString() => 'TranslationDownloadException: $message';
}

/// Optional extra translations, downloaded at runtime.
///
/// A download is validated exactly like the bundled data (one non-empty row per
/// ayah, in mushaf order) before anything is stored. The validated text is
/// kept as a small JSON file outside the content database, so it is
/// re-imported automatically when an app update replaces that database.
class TranslationDownloadService {
  TranslationDownloadService(
    this._db, {
    required this.storeDirectory,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final ContentDatabase _db;
  final http.Client _client;
  final Directory storeDirectory;

  static const _timeout = Duration(minutes: 2);

  void close() => _client.close();

  /// Every text translation the provider offers.
  Future<List<AvailableEdition>> fetchAvailable() async {
    final response = await _client
        .get(
          Uri.parse(
            '$alQuranCloudApiBase/edition?format=text&type=translation',
          ),
        )
        .timeout(_timeout);
    final data = _unwrap(response.statusCode, utf8.decode(response.bodyBytes));
    return (data as List<dynamic>)
        .map((e) => AvailableEdition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Downloads, validates, stores and imports [edition].
  ///
  /// [onProgress] receives 0..1 while downloading, or null when the server
  /// does not report a size.
  Future<void> download(
    AvailableEdition edition, {
    void Function(double? progress)? onProgress,
  }) async {
    final request = http.Request(
      'GET',
      Uri.parse(
        '$alQuranCloudApiBase/quran/${Uri.encodeComponent(edition.id)}',
      ),
    );
    final response = await _client.send(request).timeout(_timeout);
    final total = response.contentLength;
    final bytes = <int>[];
    await for (final chunk in response.stream.timeout(_timeout)) {
      bytes.addAll(chunk);
      onProgress?.call(
        total == null || total == 0 ? null : bytes.length / total,
      );
    }

    final data = _unwrap(response.statusCode, utf8.decode(bytes));
    final texts = _validatedTexts(data as Map<String, dynamic>, edition.id);
    final stored = _StoredTranslation(edition, texts);

    await _writeStore(stored);
    await _import(_db, stored);
  }

  /// Removes a downloaded edition. Bundled editions cannot be deleted.
  Future<void> delete(String editionId) async {
    final edition = await (_db.select(
      _db.translationEditionTable,
    )..where((t) => t.id.equals(editionId))).getSingleOrNull();
    if (edition == null) return;
    if (edition.bundled) {
      throw TranslationDownloadException('$editionId is bundled');
    }
    await _db.transaction(() async {
      await (_db.delete(
        _db.translationTable,
      )..where((t) => t.editionId.equals(editionId))).go();
      await (_db.delete(
        _db.translationEditionTable,
      )..where((t) => t.id.equals(editionId))).go();
    });
    final file = _storeFile(storeDirectory, editionId);
    if (file.existsSync()) file.deleteSync();
  }

  /// Re-imports every stored download into a freshly installed content
  /// database. A damaged store file is skipped, never fatal.
  static Future<void> restoreDownloaded(
    ContentDatabase db, {
    required Directory storeDirectory,
  }) async {
    if (!storeDirectory.existsSync()) return;
    for (final file in storeDirectory.listSync().whereType<File>()) {
      if (!file.path.endsWith('.json')) continue;
      try {
        final stored = _StoredTranslation.fromJson(
          jsonDecode(await file.readAsString()) as Map<String, dynamic>,
        );
        await _import(db, stored);
      } on Object {
        // Corrupt or outdated file: the user can download it again.
      }
    }
  }

  // ---------------------------------------------------------------------------

  static Object? _unwrap(int statusCode, String body) {
    if (statusCode != 200) {
      throw TranslationDownloadException('HTTP $statusCode');
    }
    final envelope = jsonDecode(body) as Map<String, dynamic>;
    if (envelope['code'] != 200) {
      throw TranslationDownloadException('status ${envelope['status']}');
    }
    return envelope['data'];
  }

  /// One sanitised, non-empty text per ayah, in mushaf order — or a throw.
  static List<String> _validatedTexts(Map<String, dynamic> data, String id) {
    final texts = <String>[];
    for (final surah in data['surahs'] as List<dynamic>) {
      final surahJson = surah as Map<String, dynamic>;
      final surahNumber = surahJson['number'] as int;
      final ayahs = surahJson['ayahs'] as List<dynamic>;
      if (ayahs.length != ayahCount(surahNumber)) {
        throw TranslationDownloadException(
          '$id: surah $surahNumber incomplete',
        );
      }
      for (final (index, ayah) in ayahs.indexed) {
        final json = ayah as Map<String, dynamic>;
        if (json['numberInSurah'] != index + 1 ||
            json['number'] != texts.length + 1) {
          throw TranslationDownloadException(
            '$id: out of order at $surahNumber',
          );
        }
        final text = sanitizeSourceText(json['text'] as String);
        if (text.isEmpty) {
          throw TranslationDownloadException(
            '$id: empty $surahNumber:${index + 1}',
          );
        }
        texts.add(text);
      }
    }
    if (texts.length != totalAyahCount) {
      throw TranslationDownloadException('$id: ${texts.length} rows');
    }
    return texts;
  }

  static File _storeFile(Directory dir, String id) =>
      File(p.join(dir.path, '${Uri.encodeComponent(id)}.json'));

  Future<void> _writeStore(_StoredTranslation stored) async {
    storeDirectory.createSync(recursive: true);
    final file = _storeFile(storeDirectory, stored.edition.id);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(stored.toJson()), flush: true);
    if (file.existsSync()) file.deleteSync();
    await temp.rename(file.path);
  }

  static Future<void> _import(ContentDatabase db, _StoredTranslation stored) {
    final e = stored.edition;
    return db.transaction(() async {
      await db
          .into(db.translationEditionTable)
          .insertOnConflictUpdate(
            TranslationEditionTableCompanion.insert(
              id: e.id,
              language: e.language,
              name: e.englishName,
              translator: e.name,
              direction: e.direction,
              attribution: attributionForTranslation(
                name: e.name,
                englishName: e.englishName,
              ),
              bundled: false,
            ),
          );
      await db.batch((batch) {
        for (final (index, text) in stored.texts.indexed) {
          batch.insert(
            db.translationTable,
            TranslationTableCompanion.insert(
              editionId: e.id,
              ayahId: index + 1,
              body: text,
              textSearch: normalizeForSearch(text),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });
  }
}

/// The on-disk form of a downloaded translation: metadata plus 6236 texts.
class _StoredTranslation {
  _StoredTranslation(this.edition, this.texts);

  factory _StoredTranslation.fromJson(Map<String, dynamic> json) {
    final texts = (json['texts'] as List<dynamic>).cast<String>();
    if (texts.length != totalAyahCount || texts.any((t) => t.isEmpty)) {
      throw TranslationDownloadException('stored file incomplete');
    }
    return _StoredTranslation(
      AvailableEdition.fromJson(json['edition'] as Map<String, dynamic>),
      texts,
    );
  }

  final AvailableEdition edition;
  final List<String> texts;

  Map<String, Object> toJson() => {'edition': edition.toJson(), 'texts': texts};
}
