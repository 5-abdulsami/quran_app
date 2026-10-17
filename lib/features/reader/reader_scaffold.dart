import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/reading_position_repository.dart';
import '../../domain/models/bookmark.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../ui/widgets/async_value_view.dart';
import 'reader_controls.dart';
import 'reader_items.dart';
import 'reader_providers.dart';
import 'reader_view.dart';
import 'translation_menu.dart';

/// An extra item in a reader's overflow menu.
class ReaderMenuAction {
  const ReaderMenuAction(this.label, this.onSelected);
  final String label;
  final void Function(AyahItem? current) onSelected;
}

/// Everything the surah and juz readers share: app-bar controls, loading,
/// resuming the saved position, saving it as the reader scrolls, and keeping
/// the screen awake.
class ReaderScaffold extends ConsumerStatefulWidget {
  const ReaderScaffold({
    required this.title,
    required this.content,
    required this.mode,
    required this.ref,
    this.initialVerseKey,
    this.extraActions,
    this.menuActions = const [],
    this.footerBuilder,
    super.key,
  });

  final String title;
  final AsyncValue<ReaderContent> content;

  /// What is being read, for saving the position.
  final ReadingMode mode;
  final int ref;

  /// Open (and highlight) this verse; otherwise resume the saved position.
  final String? initialVerseKey;

  /// Screen-specific app-bar buttons, shown before the shared ones.
  final List<Widget> Function(GlobalKey<ReaderViewState> reader)? extraActions;

  final List<ReaderMenuAction> menuActions;

  /// The previous/next footer under the last verse.
  final Widget Function(List<String> attribution)? footerBuilder;

  @override
  ConsumerState<ReaderScaffold> createState() => _ReaderScaffoldState();
}

class _ReaderScaffoldState extends ConsumerState<ReaderScaffold>
    with KeepAwakeWhileReading {
  final _readerKey = GlobalKey<ReaderViewState>();

  /// Captured once, so the final save can run while the screen is closing.
  late final ReadingPositionRepository _positions = ref.read(
    readingPositionRepositoryProvider,
  );

  @override
  void initState() {
    super.initState();
    _positions; // Resolve before any dispose-time save needs it.
  }

  void _savePosition(AyahItem item) =>
      _positions.save(widget.mode, widget.ref, item.ayah.verseKey);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saved = widget.initialVerseKey == null
        ? ref.watch(savedPositionProvider((widget.mode, widget.ref)))
        : const AsyncData<ReadingPosition?>(null);
    final attribution =
        ref.watch(visibleAttributionsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ...?widget.extraActions?.call(_readerKey),
          const TranslationMenuButton(),
          IconButton(
            tooltip: l10n.fontSizeArabic,
            icon: const Icon(Icons.format_size),
            onPressed: () => showTextSizeSheet(context),
          ),
          PopupMenuButton<VoidCallback>(
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              for (final action in widget.menuActions)
                PopupMenuItem(
                  value: () => action.onSelected(
                    _readerKey.currentState?.currentAyah ??
                        widget.content.value?.ayahAtOrAfter(0),
                  ),
                  child: Text(action.label),
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
        value: widget.content,
        data: (content) => AsyncValueView(
          value: saved,
          data: (position) => ReaderView(
            key: _readerKey,
            content: content,
            initialVerseKey: widget.initialVerseKey ?? position?.verseKey,
            highlightInitial: widget.initialVerseKey != null,
            onVisibleAyah: _savePosition,
            footer: widget.footerBuilder?.call(attribution),
          ),
        ),
      ),
    );
  }
}
