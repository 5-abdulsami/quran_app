import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/bookmark.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../ui/widgets/async_value_view.dart';
import '../reader/reader_controls.dart';
import '../reader/reader_footer.dart';
import '../reader/reader_items.dart';
import '../reader/reader_providers.dart';
import '../reader/reader_view.dart';
import '../settings/settings_controller.dart';

/// Reads one surah from start to finish (mirrors the web's /quran/[surah]).
class SurahReaderScreen extends ConsumerStatefulWidget {
  const SurahReaderScreen({required this.surah, this.initialAyah, super.key});

  final int surah;

  /// Open at this ayah and highlight it; otherwise resume where the reader
  /// stopped in this surah.
  final int? initialAyah;

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen>
    with KeepAwakeWhileReading {
  final _readerKey = GlobalKey<ReaderViewState>();

  void _savePosition(AyahItem item) => ref
      .read(readingPositionRepositoryProvider)
      .save(ReadingMode.surah, widget.surah, item.ayah.verseKey);

  Future<void> _goToAyah(int max) async {
    final ayah = await showGoToAyahDialog(context, max: max);
    if (ayah != null) {
      _readerKey.currentState?.jumpToVerse('${widget.surah}:$ayah');
    }
  }

  /// Switches to the juz reader at the verse currently on screen.
  void _readByJuz(ReaderContent content) {
    final current =
        _readerKey.currentState?.currentAyah ?? content.ayahAtOrAfter(0);
    if (current == null) return;
    context.pushReplacement(
      AppRoutes.juz(current.ayah.juz, verseKey: current.ayah.verseKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(surahContentProvider(widget.surah));
    final saved = widget.initialAyah == null
        ? ref.watch(savedPositionProvider((ReadingMode.surah, widget.surah)))
        : const AsyncData<ReadingPosition?>(null);
    final surahs = ref.watch(surahsProvider).value;
    // Surah n is at index n - 1, so its neighbours are at n - 2 and n.
    final surah = surahs?.elementAtOrNull(widget.surah - 1);
    final previous = widget.surah > 1
        ? surahs?.elementAtOrNull(widget.surah - 2)
        : null;
    final next = surahs?.elementAtOrNull(widget.surah);
    final showTranslation = ref.watch(
      settingsControllerProvider.select((s) => s.showTranslation),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(surah?.nameSimple ?? ''),
        actions: [
          if (surah != null)
            IconButton(
              tooltip: l10n.goToAyah,
              icon: const Icon(Icons.pin_outlined),
              onPressed: () => _goToAyah(surah.ayahCount),
            ),
          IconButton(
            tooltip: showTranslation ? l10n.arabicOnly : l10n.showTranslation,
            isSelected: showTranslation,
            icon: const Icon(Icons.translate),
            onPressed: () => ref
                .read(settingsControllerProvider.notifier)
                .setShowTranslation(show: !showTranslation),
          ),
          IconButton(
            tooltip: l10n.fontSizeArabic,
            icon: const Icon(Icons.format_size),
            onPressed: () => showTextSizeSheet(context),
          ),
          PopupMenuButton<VoidCallback>(
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              if (content.value case final loaded?)
                PopupMenuItem(
                  value: () => _readByJuz(loaded),
                  child: Text(l10n.readByJuz),
                ),
              PopupMenuItem(
                value: () => context.push(AppRoutes.settings),
                child: Text(l10n.settings),
              ),
            ],
          ),
        ],
      ),
      body: AsyncValueView(
        value: content,
        data: (loaded) => AsyncValueView(
          value: saved,
          data: (position) {
            final attribution = ref.watch(visibleAttributionsProvider).value;
            return ReaderView(
              key: _readerKey,
              content: loaded,
              initialVerseKey: widget.initialAyah != null
                  ? '${widget.surah}:${widget.initialAyah}'
                  : position?.verseKey,
              highlightInitial: widget.initialAyah != null,
              onVisibleAyah: _savePosition,
              footer: ReaderFooter(
                attribution: attribution,
                previousLabel: previous?.nameSimple,
                onPrevious: previous == null
                    ? null
                    : () => context.pushReplacement(
                        AppRoutes.surah(previous.number),
                      ),
                nextLabel: next?.nameSimple,
                onNext: next == null
                    ? null
                    : () =>
                          context.pushReplacement(AppRoutes.surah(next.number)),
              ),
            );
          },
        ),
      ),
    );
  }
}
