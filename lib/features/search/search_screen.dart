import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/quran/references.dart';
import '../../data/search_repository.dart';
import '../../domain/models/juz.dart';
import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../ui/app_shell.dart';
import '../../ui/keyboard.dart';
import '../../ui/widgets/async_value_view.dart';
import '../reader/verse_actions.dart';
import '../surahs/surah_list_tile.dart';
import 'search_controller.dart';
import 'search_result_tile.dart';

/// Offline search: references go straight to the verse; otherwise surah names
/// and verse text (Arabic and the selected translations).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({required this.initialQuery, super.key});

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final _query = TextEditingController(text: widget.initialQuery);
  Timer? _debounce;

  static const _debounceDelay = Duration(milliseconds: 250);
  static const examples = ['2:255', 'Yaseen', 'juz 30', 'patience', 'الصبر'];

  @override
  void initState() {
    super.initState();
    ref.read(searchRepositoryProvider).warmUp().ignore();
    if (widget.initialQuery.isNotEmpty) {
      Future.microtask(() => _controller.search(widget.initialQuery));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  QuranSearchController get _controller =>
      ref.read(searchControllerProvider.notifier);

  void _onChanged(String text) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => _controller.search(text));
  }

  void _searchNow(String text) {
    _debounce?.cancel();
    _query
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
    setState(() {});
    _controller.search(text);
    _remember();
  }

  void _remember() =>
      ref.read(recentSearchesProvider.notifier).add(_query.text);

  void _open(String location) {
    // Unfocus first, or the field regains focus (and the keyboard reopens)
    // when the pushed page is popped.
    dismissKeyboard();
    _remember();
    context.push(location);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: TextField(
          onTapOutside: dismissKeyboard,
          controller: _query,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: _searchNow,
          decoration: InputDecoration(
            hintText: l10n.searchPlaceholder,
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            suffixIcon: _query.text.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.clear,
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchNow(''),
                  ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.search,
            isSelected: !state.filters.isDefault,
            icon: Badge(
              isLabelVisible: !state.filters.isDefault,
              smallSize: 8,
              child: const Icon(Icons.tune),
            ),
            onPressed: () => _showFilters(context, state.filters),
          ),
          const SettingsAction(),
        ],
      ),
      body: state.query.isEmpty
          ? _EmptySearch(onPick: _searchNow)
          : AsyncValueView(
              value: state.results,
              onRetry: () => _controller.search(state.query),
              data: (results) =>
                  _Results(state: state, results: results, onOpen: _open),
            ),
    );
  }

  Future<void> _showFilters(BuildContext context, SearchFilters current) async {
    dismissKeyboard();
    final chosen = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FiltersSheet(initial: current),
    );
    if (chosen != null) await _controller.setFilters(chosen);
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.state,
    required this.results,
    required this.onOpen,
  });

  final SearchState state;
  final SearchResults results;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final surahs = ref.watch(surahsProvider).value ?? const <Surah>[];
    final juzs = ref.watch(juzsProvider).value ?? const <Juz>[];
    final theme = Theme.of(context);

    if (results.isEmpty) {
      return ErrorMessage(message: l10n.noResults(results.query));
    }

    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    final verses = state.verses;
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 600) {
          ref.read(searchControllerProvider.notifier).loadMore();
        }
        return false;
      },
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          if (results.goTo case final target?)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                color: theme.colorScheme.primaryContainer,
                child: ListTile(
                  key: const ValueKey('search-go-to'),
                  leading: const Icon(Icons.arrow_forward),
                  title: Text(l10n.goTo),
                  subtitle: Text(_describe(target, surahs, juzs, l10n)),
                  onTap: () => onOpen(AppRoutes.forTarget(target)),
                ),
              ),
            ),
          if (results.surahs.isNotEmpty) ...[
            sectionTitle(l10n.surahs),
            for (final surah in results.surahs)
              SurahListTile(
                surah: surah,
                onTap: () => onOpen(AppRoutes.surah(surah.number)),
              ),
          ],
          if (results.rankedAyahIds.isNotEmpty) ...[
            sectionTitle(
              '${l10n.versesSection} · ${l10n.resultsCount(results.rankedAyahIds.length)}',
            ),
            for (final ayah in verses) ...[
              SearchResultTile(
                key: SearchResultTile.keyFor(ayah.verseKey),
                ayah: ayah,
                surah: surahs[ayah.surahNumber - 1],
                terms: results.terms,
                onTap: () => onOpen(
                  AppRoutes.surah(ayah.surahNumber, ayah: ayah.ayahNumber),
                ),
                onLongPress: () {
                  dismissKeyboard();
                  showVerseActions(
                    context,
                    ayah: ayah,
                    surah: surahs[ayah.surahNumber - 1],
                    showReadInContext: true,
                  );
                },
              ),
              const Divider(indent: 16, endIndent: 16),
            ],
            if (state.hasMore)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: state.loadingMore
                      ? const CircularProgressIndicator()
                      : OutlinedButton(
                          onPressed: ref
                              .read(searchControllerProvider.notifier)
                              .loadMore,
                          child: Text(l10n.loadMore),
                        ),
                ),
              ),
          ] else if (results.goTo == null && results.surahs.isEmpty)
            ErrorMessage(message: l10n.noResults(results.query)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static String _describe(
    NavigationTarget target,
    List<Surah> surahs,
    List<Juz> juzs,
    AppLocalizations l10n,
  ) {
    String surahName(int n) => surahs.elementAtOrNull(n - 1)?.nameSimple ?? '';
    return switch (target) {
      VerseTarget(:final surah, :final ayah, :final ayahEnd) =>
        '$surah:$ayah${ayahEnd == null ? '' : '–$ayahEnd'} · ${surahName(surah)}',
      SurahTarget(:final surah) => '${l10n.surah} $surah · ${surahName(surah)}',
      JuzTarget(:final juz) =>
        '${l10n.juzNumber(juz)} · ${juzs.elementAtOrNull(juz - 1)?.nameTransliterated ?? ''}',
    };
  }
}

class _EmptySearch extends ConsumerWidget {
  const _EmptySearch({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final recent = ref.watch(recentSearchesProvider);

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.recentSearches,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: ref.read(recentSearchesProvider.notifier).clear,
                child: Text(l10n.clear),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final query in recent)
                ActionChip(
                  avatar: const Icon(Icons.history, size: 18),
                  label: Text(query),
                  onPressed: () => onPick(query),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        Text(l10n.searchTry, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final example in _SearchScreenState.examples)
              ActionChip(
                label: Text(example),
                onPressed: () => onPick(example),
              ),
          ],
        ),
      ],
    );
  }
}

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet({required this.initial});

  final SearchFilters initial;

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  late SearchFilters _filters = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final surahs = ref.watch(surahsProvider).value ?? const <Surah>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<SearchScope>(
              segments: [
                ButtonSegment(
                  value: SearchScope.both,
                  label: Text(l10n.scopeBoth),
                ),
                ButtonSegment(
                  value: SearchScope.arabic,
                  label: Text(l10n.scopeArabic),
                ),
                ButtonSegment(
                  value: SearchScope.translation,
                  label: Text(l10n.scopeTranslation),
                ),
              ],
              selected: {_filters.scope},
              onSelectionChanged: (s) =>
                  setState(() => _filters = _filters.copyWith(scope: s.single)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _filters.surah,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.surah),
              items: [
                DropdownMenuItem(child: Text(l10n.anySurah)),
                for (final s in surahs)
                  DropdownMenuItem(
                    value: s.number,
                    child: Text('${s.number}. ${s.nameSimple}'),
                  ),
              ],
              onChanged: (v) =>
                  setState(() => _filters = _filters.copyWith(surah: () => v)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _filters.juz,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.juz),
              items: [
                DropdownMenuItem(child: Text(l10n.anyJuz)),
                for (var j = 1; j <= juzCount; j++)
                  DropdownMenuItem(value: j, child: Text(l10n.juzNumber(j))),
              ],
              onChanged: (v) =>
                  setState(() => _filters = _filters.copyWith(juz: () => v)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(const SearchFilters()),
                  child: Text(l10n.reset),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_filters),
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
