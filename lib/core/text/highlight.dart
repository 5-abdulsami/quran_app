// Whole-word highlighting of search matches in ORIGINAL text.
//
// The folded search text is never displayed. Instead each whitespace-separated
// word of the original is folded on its own and compared with the search
// terms; matching words are highlighted by their offsets in the original, so
// the rendered characters are exactly the source characters.

import 'normalize.dart';
import 'search_terms.dart';

/// A half-open range [start, end) of UTF-16 offsets in the original text.
typedef TextSlice = ({int start, int end});

final RegExp _word = RegExp(r'\S+');

/// Ranges of the words in [original] that match any of [terms].
List<TextSlice> highlightRanges(String original, List<SearchTerm> terms) {
  if (terms.isEmpty) return const [];
  return [
    for (final match in _word.allMatches(original))
      if (_matches(normalizeForSearch(match.group(0)!), terms))
        (start: match.start, end: match.end),
  ];
}

bool _matches(String foldedWord, List<SearchTerm> terms) {
  if (foldedWord.isEmpty) return false;
  // Punctuation inside a word folds to a space ("Lord's" -> "lord s").
  return terms.any((t) => foldedWord.split(' ').any(t.matches));
}

/// Splits [text] into (segment, highlighted) runs for rendering.
List<(String, bool)> splitHighlights(String text, List<TextSlice> ranges) {
  if (ranges.isEmpty) return [(text, false)];
  final runs = <(String, bool)>[];
  var cursor = 0;
  for (final range in ranges) {
    if (range.start > cursor) {
      runs.add((text.substring(cursor, range.start), false));
    }
    runs.add((text.substring(range.start, range.end), true));
    cursor = range.end;
  }
  if (cursor < text.length) runs.add((text.substring(cursor), false));
  return runs;
}
