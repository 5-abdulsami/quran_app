import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/search_repository.dart';
import '../../domain/models/ayah.dart';
import '../../providers.dart';
import '../settings/settings_controller.dart';

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(
    ref.watch(contentDatabaseProvider),
    ref.watch(quranRepositoryProvider),
  ),
);

/// The search screen's state: the query, its filters, and loaded results.
class SearchState {
  const SearchState({
    this.query = '',
    this.filters = const SearchFilters(),
    this.results = const AsyncData(SearchResults.empty),
    this.verses = const [],
    this.loadingMore = false,
  });

  final String query;
  final SearchFilters filters;
  final AsyncValue<SearchResults> results;

  /// Verse results loaded so far (a page at a time).
  final List<Ayah> verses;
  final bool loadingMore;

  bool get hasMore =>
      verses.length < (results.value?.rankedAyahIds.length ?? 0);

  SearchState copyWith({
    String? query,
    SearchFilters? filters,
    AsyncValue<SearchResults>? results,
    List<Ayah>? verses,
    bool? loadingMore,
  }) => SearchState(
    query: query ?? this.query,
    filters: filters ?? this.filters,
    results: results ?? this.results,
    verses: verses ?? this.verses,
    loadingMore: loadingMore ?? this.loadingMore,
  );
}

class QuranSearchController extends Notifier<SearchState> {
  /// Bumped per search, so a slow earlier search never overwrites a newer one.
  int _generation = 0;

  @override
  SearchState build() => const SearchState();

  List<String> get _searchedTranslations =>
      ref.read(settingsControllerProvider).translationIds;

  List<String> get _shownTranslations =>
      ref.read(settingsControllerProvider).visibleTranslationIds;

  Future<void> search(String query) async {
    final generation = ++_generation;
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        query: '',
        results: const AsyncData(SearchResults.empty),
        verses: const [],
      );
      return;
    }

    state = state.copyWith(query: trimmed, results: const AsyncLoading());
    try {
      final repo = ref.read(searchRepositoryProvider);
      final results = await repo.search(
        trimmed,
        filters: state.filters,
        translationIds: _searchedTranslations,
        names: await ref.read(surahNameIndexProvider.future),
      );
      final firstPage = await repo.page(
        results,
        0,
        translationIds: _shownTranslations,
      );
      if (generation != _generation) return;
      state = state.copyWith(results: AsyncData(results), verses: firstPage);
    } on Object catch (error, stack) {
      if (generation != _generation) return;
      state = state.copyWith(results: AsyncError(error, stack));
    }
  }

  Future<void> setFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
    return search(state.query);
  }

  Future<void> loadMore() async {
    final results = state.results.value;
    if (results == null || !state.hasMore || state.loadingMore) return;
    final generation = _generation;
    state = state.copyWith(loadingMore: true);
    final next = await ref
        .read(searchRepositoryProvider)
        .page(
          results,
          state.verses.length ~/ SearchRepository.pageSize,
          translationIds: _shownTranslations,
        );
    if (generation != _generation) return;
    state = state.copyWith(
      verses: [...state.verses, ...next],
      loadingMore: false,
    );
  }
}

final searchControllerProvider =
    NotifierProvider<QuranSearchController, SearchState>(
      QuranSearchController.new,
    );

/// Recent searches, most recent first; can be cleared.
class RecentSearches extends Notifier<List<String>> {
  @override
  List<String> build() =>
      ref.watch(settingsRepositoryProvider).recentSearches();

  Future<void> add(String query) async {
    state = await ref.read(settingsRepositoryProvider).addRecentSearch(query);
  }

  Future<void> clear() async {
    await ref.read(settingsRepositoryProvider).clearRecentSearches();
    state = const [];
  }
}

final recentSearchesProvider = NotifierProvider<RecentSearches, List<String>>(
  RecentSearches.new,
);
