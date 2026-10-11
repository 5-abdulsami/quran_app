import 'package:drift/drift.dart';

import '../core/db/content_db.dart';
import '../core/quran/references.dart';
import '../core/text/normalize.dart';
import '../core/text/search_terms.dart';
import '../domain/models/ayah.dart';
import '../domain/models/surah.dart';
import '../domain/surah_filter.dart';
import 'quran_repository.dart';

/// Which text a search looks in.
enum SearchScope { both, arabic, translation }

/// Optional narrowing of a search.
class SearchFilters {
  const SearchFilters({this.scope = SearchScope.both, this.surah, this.juz});

  final SearchScope scope;
  final int? surah;
  final int? juz;

  bool get isDefault =>
      scope == SearchScope.both && surah == null && juz == null;

  SearchFilters copyWith({
    SearchScope? scope,
    int? Function()? surah,
    int? Function()? juz,
  }) => SearchFilters(
    scope: scope ?? this.scope,
    surah: surah != null ? surah() : this.surah,
    juz: juz != null ? juz() : this.juz,
  );
}

/// Everything one query found. Verse results are ranked ids; their text is
/// loaded a page at a time with [SearchRepository.page].
class SearchResults {
  const SearchResults({
    required this.query,
    required this.terms,
    required this.goTo,
    required this.surahs,
    required this.rankedAyahIds,
  });

  static const empty = SearchResults(
    query: '',
    terms: [],
    goTo: null,
    surahs: [],
    rankedAyahIds: [],
  );

  final String query;
  final List<SearchTerm> terms;

  /// The reference the query names, if any ("2:255", "Yaseen", "juz 30").
  final NavigationTarget? goTo;

  /// Surahs whose name matches.
  final List<Surah> surahs;

  /// Matching ayah ids, best first.
  final List<int> rankedAyahIds;

  bool get isEmpty => goTo == null && surahs.isEmpty && rankedAyahIds.isEmpty;
}

/// Offline search over the folded `text_search` columns.
///
/// Every term must match (AND). Arabic-script terms match anywhere in a word
/// (Arabic attaches prefixes to words); Latin terms match at the start of a
/// word. Results are ranked: exact phrase, then all terms, then by how close
/// together the terms are, then mushaf order. Folded text is used only for
/// matching and is never displayed.
class SearchRepository {
  SearchRepository(this._db, this._quran);

  final ContentDatabase _db;
  final QuranRepository _quran;

  static const pageSize = 50;

  Future<Map<int, String>>? _firstAyahsFolded;

  /// Folded display text of each surah's first ayah, by ayah id. Computed
  /// once: it never changes, and presentVerse is too costly to rerun per query.
  Future<Map<int, String>> _shownFirstAyahs() =>
      _firstAyahsFolded ??= () async {
        final ids = [
          for (var s = 1; s <= surahCount; s++)
            QuranRepository.ayahIdFor('$s:1')!,
        ];
        return {
          for (final ayah in await _quran.ayahsByIds(ids))
            ayah.id: normalizeForSearch(ayah.displayText),
        };
      }();

  /// Prepares the one-off data search needs, so the first query is fast.
  Future<void> warmUp() async {
    await _shownFirstAyahs();
    // Builds the cached folded surah names that filterSurahs uses.
    filterSurahs(await _quran.surahs(), query: 'a');
  }

  Future<SearchResults> search(
    String query, {
    SearchFilters filters = const SearchFilters(),
    List<String> translationIds = const [],
    SurahNameIndex? names,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return SearchResults.empty;

    final surahs = await _quran.surahs();
    final terms = searchTermsFor(trimmed);
    final goTo = parseNavigationTarget(trimmed, names: names);
    final surahMatches = goTo is JuzTarget || isNumericQuery(trimmed)
        ? const <Surah>[]
        : filterSurahs(surahs, query: trimmed).take(5).toList();

    final ranked = terms.isEmpty
        ? const <int>[]
        : await _rankedIds(trimmed, terms, filters, translationIds);

    return SearchResults(
      query: trimmed,
      terms: terms,
      goTo: goTo,
      surahs: surahMatches,
      rankedAyahIds: ranked,
    );
  }

  /// One page of verse results, with the requested translations.
  Future<List<Ayah>> page(
    SearchResults results,
    int page, {
    List<String> translationIds = const [],
  }) {
    final start = page * pageSize;
    if (start >= results.rankedAyahIds.length) return Future.value(const []);
    final end = (start + pageSize).clamp(0, results.rankedAyahIds.length);
    return _quran.ayahsByIds(
      results.rankedAyahIds.sublist(start, end),
      translationIds: translationIds,
    );
  }

  // ---------------------------------------------------------------------------

  Future<List<int>> _rankedIds(
    String query,
    List<SearchTerm> terms,
    SearchFilters filters,
    List<String> translationIds,
  ) async {
    // Folded text per candidate ayah, from every column that matched.
    final candidates = <int, List<String>>{};
    void add(int id, String folded) => (candidates[id] ??= []).add(folded);

    if (filters.scope != SearchScope.translation) {
      final rows = await _select('ayah a', 'a.text_search', terms, filters);
      // Ayah 1 of most surahs is displayed without its leading basmalah (it
      // is shown in the header instead). Match what the reader will see, so a
      // search for the basmalah does not return 112 verses that do not show it.
      final shownFirstAyahs = await _shownFirstAyahs();
      for (final row in rows) {
        final folded = row.ayahNumber == 1
            ? shownFirstAyahs[row.id]!
            : row.folded;
        if (terms.every((t) => t.matches(folded))) add(row.id, folded);
      }
    }

    if (filters.scope != SearchScope.arabic && translationIds.isNotEmpty) {
      final placeholders = List.filled(translationIds.length, '?').join(',');
      final rows = await _select(
        'translation t JOIN ayah a ON a.id = t.ayah_id',
        't.text_search',
        terms,
        filters,
        extraWhere: 't.edition_id IN ($placeholders)',
        extraArgs: translationIds,
      );
      for (final row in rows) {
        add(row.id, row.folded);
      }
    }

    final phrase = normalizeForSearch(query);
    final scored = [
      for (final MapEntry(key: id, value: texts) in candidates.entries)
        (
          id: id,
          score: texts.map((t) => _score(t, phrase, terms)).reduce(_best),
        ),
    ];
    scored.sort((a, b) {
      final byTier = a.score.$1.compareTo(b.score.$1);
      if (byTier != 0) return byTier;
      final bySpan = a.score.$2.compareTo(b.score.$2);
      return bySpan != 0 ? bySpan : a.id.compareTo(b.id);
    });
    return [for (final s in scored) s.id];
  }

  Future<List<({int id, int ayahNumber, String folded})>> _select(
    String from,
    String column,
    List<SearchTerm> terms,
    SearchFilters filters, {
    String? extraWhere,
    List<Object> extraArgs = const [],
  }) async {
    final where = <String>[];
    final args = <Object>[];
    for (final term in terms) {
      final (sql, arg) = term.sql(column);
      where.add(sql);
      args.add(arg);
    }
    if (filters.surah case final surah?) {
      where.add('a.surah_number = ?');
      args.add(surah);
    }
    if (filters.juz case final juz?) {
      where.add('a.juz = ?');
      args.add(juz);
    }
    if (extraWhere != null) {
      where.add(extraWhere);
      args.addAll(extraArgs);
    }

    final rows = await _db
        .customSelect(
          'SELECT a.id, a.ayah_number, $column AS folded FROM $from '
          'WHERE ${where.join(' AND ')}',
          variables: [for (final a in args) _variable(a)],
        )
        .get();
    return [
      for (final r in rows)
        (
          id: r.read<int>('id'),
          ayahNumber: r.read<int>('ayah_number'),
          folded: r.read<String>('folded'),
        ),
    ];
  }

  static Variable<Object> _variable(Object value) => switch (value) {
    final int v => Variable<int>(v),
    final String v => Variable<String>(v),
    _ => throw ArgumentError.value(value),
  };

  /// (tier, span): tier 0 = exact phrase, 1 = all terms; span = the number of
  /// words in the shortest stretch of text containing every term.
  static (int, int) _score(
    String folded,
    String phrase,
    List<SearchTerm> terms,
  ) {
    final words = folded.split(' ');
    final exact = terms.length > 1 && ' $folded '.contains(' $phrase ');
    final positions = [
      for (final term in terms)
        [
          for (final (i, word) in words.indexed)
            if (term.matches(word)) i,
        ],
    ];
    return (exact ? 0 : 1, _minimalSpan(positions));
  }

  static (int, int) _best((int, int) a, (int, int) b) =>
      a.$1 != b.$1 ? (a.$1 < b.$1 ? a : b) : (a.$2 <= b.$2 ? a : b);

  /// Smallest window (in words) containing one position from every list.
  static int _minimalSpan(List<List<int>> positions) {
    if (positions.any((p) => p.isEmpty)) return 1 << 20;
    if (positions.length == 1) return 1;
    final events = [
      for (final (term, list) in positions.indexed)
        for (final p in list) (pos: p, term: term),
    ]..sort((a, b) => a.pos.compareTo(b.pos));
    final counts = List.filled(positions.length, 0);
    var covered = 0;
    var best = 1 << 20;
    var left = 0;
    for (final event in events) {
      if (counts[event.term]++ == 0) covered++;
      while (covered == positions.length) {
        final start = events[left];
        best = best < event.pos - start.pos + 1
            ? best
            : event.pos - start.pos + 1;
        if (--counts[start.term] == 0) covered--;
        left++;
      }
    }
    return best;
  }
}

/// True for a query made only of digits and reference punctuation ("2:255"),
/// which should not also list surahs by number prefix.
bool isNumericQuery(String query) => RegExp(r'^[\d\s:.\-–]+$').hasMatch(query);
