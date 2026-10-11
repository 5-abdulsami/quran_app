// Query-side term handling for offline search. Not a port: the web app
// delegated this to PostgreSQL full-text search, which the mobile app does not
// have. Both sides of every comparison are produced by normalizeForSearch, so
// matching stays consistent with the indexed `text_search` columns.

import 'normalize.dart';

/// How one search term is matched against folded text.
enum TermMatch {
  /// Arabic script: anywhere in a word, because Arabic attaches prefixes
  /// (و ف ب ل ال) to words — "رحمن" must find "الرحمن".
  substring,

  /// Latin script: at the start of a word — "pray" finds "prayer".
  wordPrefix,
}

/// One normalised query term and how to match it.
class SearchTerm {
  const SearchTerm(this.text, this.match);

  final String text;
  final TermMatch match;

  /// True when [folded] (a `text_search` value) contains this term.
  bool matches(String folded) => indexIn(folded) >= 0;

  /// Position of the first match in [folded], or -1.
  int indexIn(String folded) {
    if (match == TermMatch.substring) return folded.indexOf(text);
    if (folded.startsWith(text)) return 0;
    final at = folded.indexOf(' $text');
    return at < 0 ? -1 : at + 1;
  }

  /// SQL fragment and argument for a `text_search` column.
  (String, String) sql(String column) => match == TermMatch.substring
      ? ('instr($column, ?) > 0', text)
      : ("instr(' ' || $column, ?) > 0", ' $text');

  @override
  bool operator ==(Object other) =>
      other is SearchTerm && other.text == text && other.match == match;

  @override
  int get hashCode => Object.hash(text, match);

  @override
  String toString() => 'SearchTerm($text, ${match.name})';
}

/// Splits a raw query into distinct search terms.
List<SearchTerm> searchTermsFor(String query) {
  final seen = <SearchTerm>{};
  for (final word in normalizeForSearch(
    query,
  ).replaceAll(':', ' ').split(' ')) {
    if (word.isEmpty) continue;
    seen.add(
      hasArabicScript(word)
          ? SearchTerm(word, TermMatch.substring)
          : SearchTerm(latinStem(word), TermMatch.wordPrefix),
    );
  }
  return seen.toList();
}

/// A deliberately light English stem for prefix matching: drops a plural or
/// final "y" so that "mercy" also finds "merciful" and "mercies", and
/// "believers" finds "believer". Short words are left alone.
String latinStem(String word) {
  if (word.length < 4) return word;
  if (word.endsWith('ies')) return word.substring(0, word.length - 3);
  if (word.endsWith('ss')) return word;
  if (word.endsWith('s') || word.endsWith('y')) {
    return word.substring(0, word.length - 1);
  }
  return word;
}
