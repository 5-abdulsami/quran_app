import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/translation_download_service.dart';
import '../../domain/models/translation_edition.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../ui/widgets/async_value_view.dart';
import 'settings_controller.dart';
import 'translations_controller.dart';

/// Choose, order, download and delete translations.
class TranslationsScreen extends ConsumerWidget {
  const TranslationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final installed = ref.watch(editionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translations)),
      body: AsyncValueView(
        value: installed,
        onRetry: () => ref.invalidate(editionsProvider),
        data: (editions) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Heading(l10n.installed, l10n.translationOrderHint),
            ),
            _InstalledList(editions: editions),
            SliverToBoxAdapter(child: _Heading(l10n.availableToDownload, null)),
            _AvailableList(installedIds: {for (final e in editions) e.id}),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.title, this.hint);
  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          if (hint != null)
            Text(
              hint!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// Installed editions: selected ones first, in reader order (draggable),
/// then the unselected ones.
class _InstalledList extends ConsumerWidget {
  const _InstalledList({required this.editions});

  final List<TranslationEdition> editions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedIds = ref.watch(settingsControllerProvider).translationIds;
    final byId = {for (final e in editions) e.id: e};
    final ordered = [
      for (final id in selectedIds) ?byId[id],
      for (final e in editions)
        if (!selectedIds.contains(e.id)) e,
    ];
    final settings = ref.read(settingsControllerProvider.notifier);

    void setSelected(List<TranslationEdition> list) =>
        settings.setTranslationIds([for (final e in list) e.id]);

    return SliverReorderableList(
      itemCount: ordered.length,
      onReorder: (from, to) {
        final selected = ordered
            .where((e) => selectedIds.contains(e.id))
            .toList();
        // Only selected editions have an order; the rest stay below them.
        if (from >= selected.length) return;
        final target = (to > from ? to - 1 : to).clamp(0, selected.length - 1);
        final moved = selected.removeAt(from);
        selected.insert(target, moved);
        setSelected(selected);
      },
      itemBuilder: (context, index) {
        final edition = ordered[index];
        final selected = selectedIds.contains(edition.id);
        return Material(
          key: ValueKey('edition-${edition.id}'),
          child: CheckboxListTile(
            value: selected,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(edition.name),
            subtitle: Text(
              [
                edition.language,
                edition.translator,
                if (edition.bundled) l10n.bundled,
              ].join(' · '),
            ),
            onChanged: (checked) {
              final current = ordered
                  .where((e) => selectedIds.contains(e.id))
                  .toList();
              if (checked ?? false) {
                setSelected([...current, edition]);
              } else if (current.length == 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.atLeastOneTranslation)),
                );
              } else {
                setSelected(current.where((e) => e.id != edition.id).toList());
              }
            },
            secondary: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!edition.bundled)
                  IconButton(
                    tooltip: l10n.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref
                        .read(translationDownloadsProvider.notifier)
                        .delete(edition.id),
                  ),
                if (selected)
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AvailableList extends ConsumerWidget {
  const _AvailableList({required this.installedIds});

  final Set<String> installedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final available = ref.watch(availableEditionsProvider);
    final downloads = ref.watch(translationDownloadsProvider);

    return available.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => SliverToBoxAdapter(
        child: ErrorMessage(
          message: l10n.loadEditionsFailed,
          onRetry: () => ref.invalidate(availableEditionsProvider),
        ),
      ),
      data: (editions) {
        final notInstalled =
            [
              for (final e in editions)
                if (!installedIds.contains(e.id)) e,
            ]..sort(
              (a, b) => (
                a.language,
                a.englishName,
              ).toString().compareTo((b.language, b.englishName).toString()),
            );
        return SliverList.builder(
          itemCount: notInstalled.length,
          itemBuilder: (context, index) => _AvailableTile(
            edition: notInstalled[index],
            status: downloads[notInstalled[index].id],
          ),
        );
      },
    );
  }
}

class _AvailableTile extends ConsumerWidget {
  const _AvailableTile({required this.edition, required this.status});

  final AvailableEdition edition;
  final DownloadStatus? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = this.status;

    return ListTile(
      title: Text(edition.englishName),
      subtitle: Text(
        switch (status) {
          Downloading() => l10n.downloading,
          DownloadFailed() => l10n.downloadFailed,
          null => '${edition.language} · ${edition.name}',
        },
        style: status is DownloadFailed
            ? TextStyle(color: theme.colorScheme.error)
            : null,
      ),
      trailing: switch (status) {
        Downloading(:final progress) => SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(value: progress, strokeWidth: 3),
        ),
        _ => IconButton(
          tooltip: l10n.download,
          icon: const Icon(Icons.download_outlined),
          onPressed: () =>
              ref.read(translationDownloadsProvider.notifier).download(edition),
        ),
      },
    );
  }
}
