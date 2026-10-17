import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/quran/references.dart';
import '../../domain/models/bookmark.dart';
import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../ui/app_shell.dart';
import '../../ui/keyboard.dart';
import '../bookmarks/bookmark_providers.dart';
import '../bookmarks/bookmark_tile.dart';

/// Continue reading, go to any verse, shortcuts and recent bookmarks.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final surahs = ref.watch(surahsProvider).value ?? const <Surah>[];
    final recent = ref.watch(bookmarkedVersesProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [SettingsAction()],
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ContinueReadingCard(surahs: surahs),
          const SizedBox(height: 16),
          const _GoToVerseField(),
          const SizedBox(height: 24),
          _SectionTitle(l10n.quickAccess),
          _Shortcuts(surahs: surahs),
          if (recent.isNotEmpty && surahs.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _SectionTitle(l10n.recentBookmarks)),
                TextButton(
                  onPressed: () => context.go(AppRoutes.bookmarks),
                  child: Text(l10n.seeAll),
                ),
              ],
            ),
            Card(
              child: Column(
                children: [
                  for (final (:bookmark, :ayah) in recent.take(3))
                    BookmarkTile(
                      bookmark: bookmark,
                      ayah: ayah,
                      surah: surahs[ayah.surahNumber - 1],
                      onTap: () => context.push(
                        AppRoutes.surah(
                          ayah.surahNumber,
                          ayah: ayah.ayahNumber,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

/// Resumes the exact ayah last read, in surah or juz mode.
class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard({required this.surahs});

  final List<Surah> surahs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final position = ref.watch(mostRecentPositionProvider).value;
    final verse = position == null ? null : parseVerseKey(position.verseKey);
    final surah = verse == null
        ? null
        : surahs.elementAtOrNull(verse.surah - 1);

    final String subtitle;
    final String location;
    if (position != null && verse != null && surah != null) {
      final where = '${surah.nameSimple} · ${position.verseKey}';
      subtitle = position.mode == ReadingMode.juz
          ? '${l10n.juzNumber(position.ref)} · $where'
          : where;
      location = position.mode == ReadingMode.juz
          ? AppRoutes.juz(position.ref, verseKey: position.verseKey)
          : AppRoutes.surah(verse.surah, ayah: verse.ayah);
    } else {
      // Nothing read yet: the card starts at the beginning of the mushaf.
      subtitle = l10n.continueReadingEmpty;
      location = AppRoutes.surah(1);
    }

    return Card(
      key: const ValueKey('continue-reading'),
      color: theme.colorScheme.primaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.auto_stories, color: theme.colorScheme.primary),
        title: Text(
          l10n.continueReading,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => context.push(location),
      ),
    );
  }
}

/// Accepts anything the reference parser does: "2:255", "Yaseen", "juz 30".
class _GoToVerseField extends ConsumerStatefulWidget {
  const _GoToVerseField();

  @override
  ConsumerState<_GoToVerseField> createState() => _GoToVerseFieldState();
}

class _GoToVerseFieldState extends ConsumerState<_GoToVerseField> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String text) async {
    if (text.trim().isEmpty) return;
    final names = await ref.read(surahNameIndexProvider.future);
    final target = parseNavigationTarget(text, names: names);
    if (!mounted) return;
    if (target == null) {
      setState(() => _error = AppLocalizations.of(context).invalidReference);
      return;
    }
    setState(() => _error = null);
    _controller.clear();
    await context.push(AppRoutes.forTarget(target));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      onTapOutside: dismissKeyboard,
      key: const ValueKey('go-to-verse'),
      controller: _controller,
      textInputAction: TextInputAction.go,
      onSubmitted: _submit,
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      decoration: InputDecoration(
        labelText: l10n.goToVerse,
        hintText: l10n.goToVerseHint,
        errorText: _error,
        prefixIcon: const Icon(Icons.near_me_outlined),
        suffixIcon: IconButton(
          tooltip: l10n.goTo,
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => _submit(_controller.text),
        ),
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts({required this.surahs});

  final List<Surah> surahs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String name(int n) => surahs.elementAtOrNull(n - 1)?.nameSimple ?? '$n';

    final shortcuts = <(String, String)>[
      (name(18), AppRoutes.surah(18)),
      (name(36), AppRoutes.surah(36)),
      (name(67), AppRoutes.surah(67)),
      (name(56), AppRoutes.surah(56)),
      ('${l10n.ayatAlKursi} · 2:255', AppRoutes.surah(2, ayah: 255)),
      ('2:285–286', AppRoutes.surah(2, ayah: 285)),
      (l10n.juzNumber(30), AppRoutes.juz(30)),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (label, location) in shortcuts)
          ActionChip(
            label: Text(label),
            onPressed: () => context.push(location),
          ),
      ],
    );
  }
}
