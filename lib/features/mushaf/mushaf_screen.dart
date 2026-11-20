import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/quran/references.dart';
import '../../data/reading_position_repository.dart';
import '../../domain/models/bookmark.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../audio/player_bar.dart';
import '../audio/recitation_controller.dart';
import '../reader/reader_controls.dart';
import 'mushaf_ayah_sheet.dart';
import 'mushaf_page_view.dart';
import 'mushaf_providers.dart';

/// The mushaf, page after page in one vertical scroll: Arabic only, as
/// printed, for reading without translations in the way. A tap on a verse
/// shows its translation; the text is selectable throughout.
///
/// Like the readers, it opens at the top unless sent to a verse (Continue
/// reading), and saves the place only once the reader actually reads.
class MushafScreen extends ConsumerStatefulWidget {
  const MushafScreen({this.initialPage = 1, this.initialVerseKey, super.key});

  /// 1..[mushafPageCount].
  final int initialPage;

  /// Briefly tinted on arrival, when the reader was sent to a verse.
  final String? initialVerseKey;

  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen>
    with KeepAwakeWhileReading {
  final _scroll = ItemScrollController();
  final _positions = ItemPositionsListener.create();

  /// Captured once, so the final save can run while the screen is closing,
  /// when `ref` can no longer be used.
  late final ProviderContainer _container = ProviderScope.containerOf(
    context,
    listen: false,
  );
  late final ReadingPositionRepository _saved = _container.read(
    readingPositionRepositoryProvider,
  );

  /// The page at the top of the screen.
  late int _page = widget.initialPage;

  /// See ReaderView: no saving until the reader scrolls, recites or jumps.
  late bool _tracking = widget.initialVerseKey != null;

  late String? _marked = widget.initialVerseKey;
  Timer? _unmark;
  Timer? _debounce;

  static const _markDuration = Duration(milliseconds: 2500);
  static const _saveDelay = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _container; // Resolve before any dispose-time save needs them.
    _saved;
    _positions.itemPositions.addListener(_onPositionsChanged);
    if (_marked != null) {
      _unmark = Timer(_markDuration, () => setState(() => _marked = null));
    }
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_onPositionsChanged);
    _unmark?.cancel();
    // Leaving within the save delay must not lose the reader's place.
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      _save(_page);
    }
    super.dispose();
  }

  /// The current page is the one taking up most of the screen: right as
  /// pages scroll past, and right at the end, where the last page cannot
  /// reach the top.
  void _onPositionsChanged() {
    ItemPosition? best;
    var bestShare = 0.0;
    for (final p in _positions.itemPositions.value) {
      final share =
          (p.itemTrailingEdge.clamp(0, 1) - p.itemLeadingEdge.clamp(0, 1))
              .toDouble();
      if (share > bestShare) {
        bestShare = share;
        best = p;
      }
    }
    if (best == null) return;
    final page = best.index + 1;
    if (page == _page) return;
    setState(() => _page = page);
    if (_tracking) _scheduleSave();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    final page = _page;
    _debounce = Timer(_saveDelay, () => _save(page));
  }

  /// Saves [page] by its first verse, once that page has loaded.
  void _save(int page) {
    final first = _container.read(mushafPageProvider(page)).value?.firstAyah;
    if (first != null) {
      _saved.save(ReadingMode.page, page, first.verseKey).ignore();
    }
  }

  bool _onUserScroll(UserScrollNotification notification) {
    if (!_tracking && notification.direction != ScrollDirection.idle) {
      _tracking = true;
      _scheduleSave();
    }
    return false;
  }

  void _jumpToPage(int page) {
    _tracking = true;
    _scroll.jumpTo(index: page - 1);
  }

  void _scrollToStart() => _scroll.scrollTo(
    index: 0,
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeInOutCubic,
  );

  /// Keeps the page of the verse being recited on screen.
  Future<void> _follow(String verseKey) async {
    final ayah = await ref.read(quranRepositoryProvider).ayah(verseKey);
    if (ayah == null || !mounted || !_scroll.isAttached) return;
    final onScreen = _positions.itemPositions.value.any(
      (p) => p.index == ayah.page - 1 && p.itemTrailingEdge > 0.1,
    );
    if (onScreen) return;
    _tracking = true;
    await _scroll.scrollTo(
      index: ayah.page - 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  /// The surah reader, at the first verse of the page on screen.
  void _openTranslationView() {
    final first = ref.read(mushafPageProvider(_page)).value?.firstAyah;
    if (first == null) return;
    context.pushReplacement(
      AppRoutes.surah(first.surahNumber, ayah: first.ayahNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final top = ref.watch(mushafPageProvider(_page)).value;
    final reciting = ref.watch(
      recitationControllerProvider.select((s) => s.current?.verseKey),
    );
    ref.listen(
      recitationControllerProvider.select((s) => s.current?.verseKey),
      (_, verseKey) {
        if (verseKey != null) _follow(verseKey).ignore();
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.pageNumber(_page)),
            if (top != null)
              Text(
                '${top.sections.first.surah.nameSimple} · '
                '${l10n.juzNumber(top.juz)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.goToPage,
            icon: const Icon(Icons.pin_outlined),
            onPressed: () async {
              final page = await showGoToNumberDialog(
                context,
                title: l10n.goToPage,
                label: l10n.pageNumberRange(mushafPageCount),
                max: mushafPageCount,
              );
              if (page != null) _jumpToPage(page);
            },
          ),
          IconButton(
            tooltip: l10n.fontSizeArabic,
            icon: const Icon(Icons.format_size),
            onPressed: () => showTextSizeSheet(context),
          ),
          PopupMenuButton<VoidCallback>(
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _openTranslationView,
                child: Text(l10n.translationView),
              ),
              PopupMenuItem(
                value: _scrollToStart,
                child: Text(l10n.backToStart),
              ),
              PopupMenuItem(
                value: () => context.push(AppRoutes.settings),
                child: Text(l10n.settings),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: RecitationPlayerBarScope.isProvided(context)
          ? null
          : const RecitationPlayerBar(safeBottom: true),
      body: SelectionArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: _onUserScroll,
          child: ScrollablePositionedList.builder(
            itemScrollController: _scroll,
            itemPositionsListener: _positions,
            initialScrollIndex: widget.initialPage - 1,
            itemCount: mushafPageCount,
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemBuilder: (context, index) => MushafPageView(
              page: index + 1,
              markedVerseKey: reciting ?? _marked,
              onAyahTap: (ayah, surah) =>
                  showMushafAyahSheet(context, ayah: ayah, surah: surah),
            ),
          ),
        ),
      ),
    );
  }
}
