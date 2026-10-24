import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../domain/models/translation_edition.dart';
import '../../providers.dart';
import '../../router.dart';
import '../audio/recitation_controller.dart';
import '../settings/settings_controller.dart';
import 'ayah_tile.dart';
import 'reader_items.dart';
import 'surah_header.dart';
import 'verse_actions.dart';

/// The scrolling body shared by the surah and juz readers.
///
/// Built lazily with a positioned list, so jumping to any verse (even 2:286)
/// is exact without laying out everything before it. Reports the first fully
/// visible verse, debounced, so the screen can save the reading position.
class ReaderView extends ConsumerStatefulWidget {
  const ReaderView({
    required this.content,
    required this.onVisibleAyah,
    this.initialVerseKey,
    this.highlightInitial = false,
    this.footer,
    super.key,
  });

  final ReaderContent content;

  /// Called (debounced) with the first fully visible verse.
  final ValueChanged<AyahItem> onVisibleAyah;

  /// Where to open; the top of the content when null.
  final String? initialVerseKey;

  /// Briefly highlight the initial verse (when the reader was sent to it).
  final bool highlightInitial;

  /// Shown after the last verse, e.g. previous/next navigation.
  final Widget? footer;

  @override
  ConsumerState<ReaderView> createState() => ReaderViewState();
}

class ReaderViewState extends ConsumerState<ReaderView> {
  final _scroll = ItemScrollController();
  final _positions = ItemPositionsListener.create();

  String? _highlighted;
  Timer? _highlightTimer;
  Timer? _debounce;
  AyahItem? _current;

  static const _highlightDuration = Duration(milliseconds: 2500);
  static const _saveDelay = Duration(milliseconds: 600);

  /// The verse at the top of the screen right now.
  AyahItem? get currentAyah => _current;

  @override
  void initState() {
    super.initState();
    _positions.itemPositions.addListener(_onPositionsChanged);
    final initial = widget.initialVerseKey;
    if (initial != null && widget.highlightInitial) _highlight(initial);
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_onPositionsChanged);
    _highlightTimer?.cancel();
    // Leaving within the save delay must not lose the reader's place.
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      if (_current case final current?) widget.onVisibleAyah(current);
    }
    super.dispose();
  }

  /// Scrolls so [verseKey] is at the top, and highlights it.
  void jumpToVerse(String verseKey, {bool highlight = true}) {
    final index = _indexFor(verseKey);
    if (index == null || !_scroll.isAttached) return;
    _scroll.jumpTo(index: index);
    if (highlight) _highlight(verseKey);
  }

  /// List index to open at for [verseKey]. The first verse of a surah opens at
  /// its header, so the surah name and basmalah are not scrolled past.
  int? _indexFor(String verseKey) {
    final index = widget.content.indexOf(verseKey);
    if (index == null) return null;
    final previous = index > 0 ? widget.content.items[index - 1] : null;
    return previous is SurahHeaderItem ? index - 1 : index;
  }

  void _highlight(String verseKey) {
    _highlightTimer?.cancel();
    setState(() => _highlighted = verseKey);
    _highlightTimer = Timer(_highlightDuration, () {
      if (mounted) setState(() => _highlighted = null);
    });
  }

  /// Recites from list index [index] to the end of this screen's content.
  void _playFrom(int index) =>
      ref.read(recitationControllerProvider.notifier).playVerses([
        for (final item in widget.content.items.skip(index))
          if (item is AyahItem) (item.surah, item.ayah.ayahNumber),
      ]);

  /// Keeps the verse being recited on screen.
  void _follow(String verseKey) {
    final index = _indexFor(verseKey);
    if (index == null || !_scroll.isAttached) return;
    final target = widget.content.indexOf(verseKey);
    final onScreen = _positions.itemPositions.value.any(
      (p) =>
          p.index == target &&
          p.itemLeadingEdge >= 0 &&
          p.itemTrailingEdge <= 1,
    );
    if (onScreen) return;
    _scroll.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void _onPositionsChanged() {
    final visible = _positions.itemPositions.value.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final items = widget.content.items;

    AyahItem? fullyVisible;
    AyahItem? partlyVisible;
    for (final position in visible) {
      if (position.index >= items.length) continue;
      final item = items[position.index];
      if (item is! AyahItem || position.itemTrailingEdge <= 0) continue;
      partlyVisible ??= item;
      if (position.itemLeadingEdge >= -0.001) {
        fullyVisible = item;
        break;
      }
    }
    // A verse taller than the screen is never fully visible; use the one the
    // reader is inside.
    final current = fullyVisible ?? partlyVisible;
    if (current == null || current.ayah.id == _current?.ayah.id) return;
    _current = current;
    _debounce?.cancel();
    _debounce = Timer(_saveDelay, () => widget.onVisibleAyah(current));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final bookmarked = ref.watch(bookmarkedKeysProvider).value ?? const {};
    final editionNames = <String, String>{
      for (final e
          in ref.watch(editionsProvider).value ?? const <TranslationEdition>[])
        e.id: e.name,
    };
    final items = widget.content.items;
    final initial = widget.initialVerseKey;
    final (recitingKey, recitingNow) = ref.watch(
      recitationControllerProvider.select(
        (s) => (s.current?.verseKey, s.playing),
      ),
    );
    ref.listen(
      recitationControllerProvider.select((s) => s.current?.verseKey),
      (_, verseKey) {
        if (verseKey != null) _follow(verseKey);
      },
    );

    return ScrollablePositionedList.builder(
      itemScrollController: _scroll,
      itemPositionsListener: _positions,
      initialScrollIndex: initial == null ? 0 : (_indexFor(initial) ?? 0),
      itemCount: items.length + 1,
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return widget.footer ?? const SizedBox(height: 24);
        }
        return switch (items[index]) {
          SurahHeaderItem(:final surah) => SurahHeader(
            surah: surah,
            arabicFontSize: settings.arabicFontSize,
          ),
          ContinuingSurahItem(:final surah, :final fromAyah) =>
            ContinuingSurahCard(surah: surah, fromAyah: fromAyah),
          final AyahItem item => Column(
            children: [
              AyahTile(
                key: AyahTile.keyFor(item.ayah.verseKey),
                ayah: item.ayah,
                surah: item.surah,
                arabicFontSize: settings.arabicFontSize,
                translationFontSize: settings.translationFontSize,
                showJuz: settings.showMarkers && item.showJuz,
                showHizb: settings.showMarkers && item.showHizb,
                showPage: settings.showMarkers && item.showPage,
                editionNames: editionNames,
                highlighted: _highlighted == item.ayah.verseKey,
                bookmarked: bookmarked.contains(item.ayah.verseKey),
                recitation: recitingKey != item.ayah.verseKey
                    ? AyahRecitation.idle
                    : recitingNow
                    ? AyahRecitation.playing
                    : AyahRecitation.paused,
                onPlay: recitingKey == item.ayah.verseKey
                    ? ref.read(recitationControllerProvider.notifier).togglePlay
                    : () => _playFrom(index),
                onActions: () => showVerseActions(
                  context,
                  ayah: item.ayah,
                  surah: item.surah,
                  onPlay: () => _playFrom(index),
                ),
                onOpenDetail: () => context.push(
                  AppRoutes.ayah(item.ayah.surahNumber, item.ayah.ayahNumber),
                ),
              ),
              const Divider(indent: 16, endIndent: 16),
            ],
          ),
        };
      },
    );
  }
}
