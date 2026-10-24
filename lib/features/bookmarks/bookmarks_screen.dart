import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../ui/app_shell.dart';
import '../../ui/keyboard.dart';
import '../../ui/toast.dart';
import '../../ui/widgets/async_value_view.dart';
import 'bookmark_providers.dart';
import 'bookmark_tile.dart';

enum BookmarkSort { newest, mushaf }

/// Every bookmark: tap to read in context, swipe to delete (with undo).
class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  BookmarkSort _sort = BookmarkSort.newest;

  Future<void> _editNote(String verseKey, String? current) async {
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _NoteDialog(initial: current),
    );
    if (note != null) {
      await ref.read(bookmarkRepositoryProvider).setNote(verseKey, note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final verses = ref.watch(bookmarkedVersesProvider);
    final surahs = ref.watch(surahsProvider).value ?? const <Surah>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navBookmarks),
        actions: [
          PopupMenuButton<BookmarkSort>(
            tooltip: l10n.sort,
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (sort) => setState(() => _sort = sort),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: BookmarkSort.newest,
                child: Text(l10n.sortNewest),
              ),
              PopupMenuItem(
                value: BookmarkSort.mushaf,
                child: Text(l10n.sortMushaf),
              ),
            ],
          ),
          const SettingsAction(),
        ],
      ),
      body: AsyncValueView(
        value: verses,
        onRetry: () => ref.invalidate(bookmarkedVersesProvider),
        data: (all) {
          if (all.isEmpty || surahs.isEmpty) {
            return ErrorMessage(message: l10n.bookmarksEmpty);
          }
          final sorted = _sort == BookmarkSort.newest
              ? all
              : ([...all]..sort((a, b) => a.ayah.id.compareTo(b.ayah.id)));
          return ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, _) =>
                const Divider(indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final (:bookmark, :ayah) = sorted[index];
              return Dismissible(
                key: ValueKey('bookmark-${bookmark.verseKey}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Icon(Icons.delete_outline, semanticLabel: l10n.delete),
                ),
                onDismissed: (_) async {
                  final repo = ref.read(bookmarkRepositoryProvider);
                  final messenger = ScaffoldMessenger.of(context);
                  await repo.remove(bookmark.verseKey);
                  messenger.showToast(
                    l10n.bookmarkRemoved,
                    action: SnackBarAction(
                      label: l10n.undo,
                      onPressed: () => repo.add(bookmark),
                    ),
                  );
                },
                child: BookmarkTile(
                  bookmark: bookmark,
                  ayah: ayah,
                  surah: surahs[ayah.surahNumber - 1],
                  onTap: () => context.push(
                    AppRoutes.surah(ayah.surahNumber, ayah: ayah.ayahNumber),
                  ),
                  onEditNote: () => _editNote(bookmark.verseKey, bookmark.note),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({this.initial});
  final String? initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.initial == null ? l10n.addNote : l10n.editNote),
      content: TextField(
        onTapOutside: dismissKeyboard,
        controller: _controller,
        autofocus: true,
        maxLines: 4,
        maxLength: 500,
        decoration: InputDecoration(hintText: l10n.note),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
