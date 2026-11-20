// Quran.com client for the build script: the Indo-Pak (Nastaleeq) Arabic text.
//
// `GET /api/v4/quran/verses/indopak_nastaleeq?chapter_number=N` returns each
// verse as `text_indopak_nastaleeq`: the Indo-Pak mushaf text that QUL
// (qul.tarteel.ai) pairs with the "IndoPak Nastaleeq" font. Its waqf signs,
// ruku/hizb markers and verse-end circles are private-use code points drawn by
// that font, so the text is only ever rendered in it.
//
// Every response is cached under tool/cache/ (git-ignored), so re-runs are
// fully offline and reproducible.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'alquran_cloud.dart' show SourceDataException;

const String quranComApiBase = 'https://api.quran.com/api/v4';

/// The Quran.com text variant, and the JSON field it is returned in.
const String indopakVariant = 'indopak_nastaleeq';
const String _indopakField = 'text_$indopakVariant';

class QuranComClient {
  QuranComClient({required this.cacheDir, http.Client? client})
    : _client = client ?? http.Client();

  final Directory cacheDir;
  final http.Client _client;

  void close() => _client.close();

  /// Every verse of the Indo-Pak text, keyed by verse key ("2:255"), in
  /// mushaf order.
  Future<Map<String, String>> indopak() async {
    final verses = <String, String>{};
    for (var surah = 1; surah <= 114; surah++) {
      final name =
          'qurancom-$indopakVariant-'
          '${surah.toString().padLeft(3, '0')}.json';
      final body = await _cached(
        '$quranComApiBase/quran/verses/$indopakVariant?chapter_number=$surah',
        name,
      );
      final rows =
          ((jsonDecode(body) as Map<String, dynamic>)['verses']
                  as List<dynamic>)
              .cast<Map<String, dynamic>>();
      for (final row in rows) {
        // An unknown variant silently falls back to another text, so the
        // field name is checked rather than trusted.
        final text = row[_indopakField];
        if (text is! String) {
          throw SourceDataException('$name: no $_indopakField field');
        }
        final key = row['verse_key'] as String;
        if (!key.startsWith('$surah:')) {
          throw SourceDataException('$name: unexpected verse $key');
        }
        verses[key] = text;
      }
    }
    return verses;
  }

  Future<String> _cached(String url, String cacheName) async {
    final file = File(p.join(cacheDir.path, cacheName));
    if (file.existsSync()) return file.readAsStringSync();
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
        final body = utf8.decode(response.bodyBytes);
        cacheDir.createSync(recursive: true);
        file.writeAsStringSync(body);
        return body;
      } on Exception {
        if (attempt >= attempts) rethrow;
        await Future<void>.delayed(Duration(seconds: 2 * attempt));
      }
    }
  }
}
