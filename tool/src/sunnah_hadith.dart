// Rows of sunnah.com's `HadithTable` dump, and the display text extracted
// from them.
//
// Extraction never rewrites the narration. It only removes markup and
// formatting the dump carries for sunnah.com's own website:
//   - English: HTML tags (<p>, <br>, <i>, ...) and runs of whitespace;
//   - Arabic: the narrator / place markup, and the right-to-left marks
//     around quotation marks. Only the matn (the words of the Prophet, ﷺ, as
//     sunnah.com marks them with [matn]...[/matn]) is kept; the full chain
//     of narrators stays one tap away on sunnah.com.

import 'mysql_dump.dart';

/// The `HadithTable` columns, in dump order.
const _columns = [
  'collection',
  'bookNumber',
  'babID',
  'englishBabNumber',
  'arabicBabNumber',
  'hadithNumber',
  'ourHadithNumber',
  'arabicURN',
  'arabicBabName',
  'arabicText',
  'arabicgrade1',
  'englishURN',
  'englishBabName',
  'englishText',
  'englishgrade1',
  'last_updated',
  'xrefs',
];

/// One hadith as sunnah.com stores it.
class SunnahHadithRow {
  SunnahHadithRow._(this._values);

  final Map<String, String?> _values;

  String get collection => _values['collection']!;

  /// sunnah.com's own number, e.g. "1", "2564 c", "5641, 5642".
  String get hadithNumber => _values['hadithNumber']!;
  String get arabicText => _values['arabicText'] ?? '';
  String get englishText => _values['englishText'] ?? '';
  String get englishGrade => _values['englishgrade1'] ?? '';

  /// The number as sunnah.com writes it in a URL: "2564 c" -> "2564c".
  String get urlNumber => urlHadithNumber(hadithNumber);
}

/// "2564 c" -> "2564c", the form sunnah.com uses in its links.
String urlHadithNumber(String number) => number.replaceAll(' ', '');

/// Every row of the dump, indexed by "collection:urlNumber".
Map<String, SunnahHadithRow> readSunnahDump(
  String sql, {
  Set<String>? collections,
}) {
  final rows = <String, SunnahHadithRow>{};
  for (final values in mysqlInsertRows(sql, 'HadithTable')) {
    if (values.length != _columns.length) {
      throw FormatException(
        'HadithTable row has ${values.length} columns, '
        'expected ${_columns.length}',
      );
    }
    final row = SunnahHadithRow._(Map.fromIterables(_columns, values));
    if (collections != null && !collections.contains(row.collection)) {
      continue;
    }
    rows['${row.collection}:${row.urlNumber}'] = row;
  }
  return rows;
}

final _htmlTag = RegExp('<[^>]+>');
final _whitespace = RegExp(r'\s+');
final _matn = RegExp(r'\[matn\](.*?)\[/matn\]', dotAll: true);
final _markupTag = RegExp(r'\[/?[a-z]+[^\]]*\]');

/// U+200F RIGHT-TO-LEFT MARK, which the dump places around quotation marks.
const _rlm = '\u200F';

/// The English translation as plain text: tags removed, whitespace collapsed.
String cleanEnglishText(String html) =>
    html.replaceAll(_htmlTag, ' ').replaceAll(_whitespace, ' ').trim();

/// The Arabic matn, without markup, or null when the dump marks none.
///
/// The quotation marks that open and close the Prophet's words sit at the
/// edges of the [matn] span; they are trimmed with the surrounding space.
/// Quotation marks inside the matn (in a dialogue) are kept.
String? arabicMatn(String arabic) {
  final match = _matn.firstMatch(arabic);
  if (match == null) return null;
  final text = match
      .group(1)!
      .replaceAll(_markupTag, '')
      .replaceAll(_rlm, '')
      .replaceAll(_whitespace, ' ');
  final trimmed = _trimQuotes(text);
  return trimmed.isEmpty ? null : trimmed;
}

String _trimQuotes(String text) {
  var start = 0;
  var end = text.length;
  bool edge(int i) => text[i] == ' ' || text[i] == '"';
  while (start < end && edge(start)) {
    start++;
  }
  while (end > start && edge(end - 1)) {
    end--;
  }
  return text.substring(start, end);
}
