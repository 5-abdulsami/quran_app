// Reads the QPC Nastaleeq text from QUL's word-by-word download.
//
// QUL (qul.tarteel.ai) offers this script only word by word, and only after
// signing in, so the downloaded file is kept in tool/sources/ (not the
// git-ignored cache): the build must stay reproducible without it.
//
// The file maps "surah:ayah:word" to {id, surah, ayah, word, text}. Words are
// joined with single spaces, in id order, into verses. Each word is trimmed
// of surrounding whitespace (one word, 6:1 "الْحَمْدُ", carries two trailing
// no-break spaces); spaces INSIDE a word are kept, because there a following
// mark is attached to the space.

import 'dart:convert';
import 'dart:io';

import 'alquran_cloud.dart' show SourceDataException;

const qpcNastaleeqSourcePath =
    'tool/sources/qul-qpc-nastaleeq-word-by-word.json';

/// Every verse of the QPC Nastaleeq text, keyed by verse key, in mushaf order.
Map<String, String> loadQpcNastaleeq(File file) {
  if (!file.existsSync()) {
    throw SourceDataException(
      '${file.path} is missing: download "QPC Nastaleeq script - Word by '
      'Word" (JSON) from qul.tarteel.ai and save it there.',
    );
  }
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final words = json.values.cast<Map<String, dynamic>>().toList()
    ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

  final verses = <String, List<String>>{};
  for (var i = 0; i < words.length; i++) {
    final w = words[i];
    if (w['id'] != i + 1) {
      throw SourceDataException('word ids are not 1..${words.length}');
    }
    final key = '${w['surah']}:${w['ayah']}';
    final list = verses.putIfAbsent(key, () => []);
    if (int.parse(w['word'] as String) != list.length + 1 ||
        w['location'] != '$key:${w['word']}') {
      throw SourceDataException('${w['location']}: words out of order');
    }
    final text = (w['text'] as String).trim();
    if (text.isEmpty) throw SourceDataException('${w['location']}: empty');
    list.add(text);
  }
  return {
    for (final MapEntry(:key, :value) in verses.entries) key: value.join(' '),
  };
}
