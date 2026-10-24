import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../domain/models/reciter.dart';
import '../domain/models/surah.dart';
import '../domain/recitation_queue.dart';

/// Thrown when a surah's audio could not be downloaded. Nothing partial is
/// kept: files are written whole or not at all.
class RecitationDownloadException implements Exception {
  RecitationDownloadException(this.message);
  final String message;

  @override
  String toString() => 'RecitationDownloadException: $message';
}

/// Recitation audio: streamed from EveryAyah.com, or played from a surah the
/// user downloaded. Nothing is bundled, so the app stays small.
///
/// Downloads live under `[directory]/{reciter id}/SSSAAA.mp3`, outside the
/// databases, so they survive content upgrades.
class RecitationAudioStore {
  RecitationAudioStore({required this.directory, http.Client? client})
    : _client = client ?? http.Client();

  final Directory directory;
  final http.Client _client;

  static const baseUrl = 'https://everyayah.com/data';

  /// Files fetched at once while downloading a surah.
  static const _parallel = 4;

  Uri remoteUri(Reciter reciter, String fileName) =>
      Uri.parse('$baseUrl/${reciter.folder}/$fileName');

  File localFile(Reciter reciter, String fileName) =>
      File(p.join(directory.path, reciter.id, fileName));

  /// The downloaded file when there is one, otherwise the stream URL.
  Uri sourceFor(RecitationTrack track) {
    final file = localFile(track.reciter, track.fileName);
    return file.existsSync()
        ? file.uri
        : remoteUri(track.reciter, track.fileName);
  }

  /// Names of the files downloaded for [reciter].
  Future<Set<String>> downloadedFiles(Reciter reciter) async {
    final dir = Directory(p.join(directory.path, reciter.id));
    if (!await dir.exists()) return {};
    return {
      await for (final entity in dir.list())
        if (entity is File && entity.path.endsWith('.mp3'))
          p.basename(entity.path),
    };
  }

  /// Downloads every file [surah] needs with [reciter], skipping those already
  /// present. [onProgress] reports files done out of the total.
  Future<void> downloadSurah(
    Reciter reciter,
    Surah surah, {
    void Function(int done, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final names = surahFileNames(surah);
    final have = await downloadedFiles(reciter);
    final missing = names.where((n) => !have.contains(n)).toList();
    var done = names.length - missing.length;
    onProgress?.call(done, names.length);

    await Directory(p.join(directory.path, reciter.id)).create(recursive: true);
    var next = 0;
    var failed = false;
    Future<void> worker() async {
      while (next < missing.length && !failed) {
        if (isCancelled?.call() ?? false) return;
        final name = missing[next++];
        try {
          await _downloadFile(reciter, name);
        } on Object {
          failed = true; // Stop the other workers too.
          rethrow;
        }
        onProgress?.call(++done, names.length);
      }
    }

    await Future.wait([for (var i = 0; i < _parallel; i++) worker()]);
  }

  Future<void> _downloadFile(Reciter reciter, String name) async {
    final http.Response response;
    try {
      response = await _client
          .get(remoteUri(reciter, name))
          .timeout(const Duration(seconds: 60));
    } on Exception catch (e) {
      throw RecitationDownloadException('$name: $e');
    }
    if (response.statusCode != 200 || !_looksLikeMp3(response.bodyBytes)) {
      throw RecitationDownloadException(
        '$name: HTTP ${response.statusCode}, ${response.bodyBytes.length} bytes',
      );
    }
    final file = localFile(reciter, name);
    final partial = File('${file.path}.part');
    await partial.writeAsBytes(response.bodyBytes, flush: true);
    await partial.rename(file.path);
  }

  /// An ID3 tag or an MPEG frame sync: rejects HTML error pages.
  static bool _looksLikeMp3(Uint8List bytes) =>
      bytes.length > 128 &&
      ((bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) ||
          (bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0));

  /// Removes [surah]'s files for [reciter]. The shared basmalah file is kept
  /// while any other downloaded surah still needs it.
  Future<void> deleteSurah(Reciter reciter, Surah surah) async {
    for (final name in surahFileNames(surah)) {
      if (name == basmalahFileName) continue;
      await _deleteIfExists(localFile(reciter, name));
    }
    final remaining = await downloadedFiles(reciter);
    if (remaining.every((n) => n == basmalahFileName)) {
      await _deleteIfExists(localFile(reciter, basmalahFileName));
    }
  }

  /// Removes downloads of recordings the app no longer offers.
  Future<void> removeUnknownReciters(Set<String> knownIds) async {
    if (!await directory.exists()) return;
    await for (final entity in directory.list()) {
      if (entity is Directory && !knownIds.contains(p.basename(entity.path))) {
        await entity.delete(recursive: true);
      }
    }
  }

  /// Removes every downloaded recitation.
  Future<void> deleteAll() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  }

  /// Bytes used by downloads.
  Future<int> bytesUsed() async {
    if (!await directory.exists()) return 0;
    var total = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  static Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) await file.delete();
  }

  void close() => _client.close();
}
