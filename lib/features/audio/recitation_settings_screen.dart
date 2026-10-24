import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/reciter.dart';
import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../ui/toast.dart';
import '../../ui/widgets/number_medallion.dart';
import '../settings/settings_controller.dart';
import 'audio_downloads.dart';

/// What to listen to, which recordings, and surahs saved for offline use.
class RecitationSettingsScreen extends ConsumerWidget {
  const RecitationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final surahs = ref.watch(surahsProvider).value ?? const <Surah>[];
    final bytes = ref.watch(audioBytesUsedProvider).value ?? 0;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    Widget reciterTile(Reciter reciter, String selectedId) => ListTile(
      title: Text(reciter.name),
      trailing: reciter.id == selectedId
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      selected: reciter.id == selectedId,
      onTap: () => controller.setReciter(reciter),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recitation)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          section(l10n.listenTo),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<RecitationMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: RecitationMode.arabic,
                  label: Text(l10n.modeArabic),
                ),
                ButtonSegment(
                  value: RecitationMode.urdu,
                  label: Text(l10n.modeUrdu),
                ),
                ButtonSegment(
                  value: RecitationMode.arabicThenUrdu,
                  label: Text(l10n.modeArabicUrdu),
                ),
              ],
              selected: {settings.recitationMode},
              onSelectionChanged: (s) => controller.setRecitationMode(s.single),
            ),
          ),
          if (settings.recitationMode.includesArabic) ...[
            section(l10n.reciter),
            for (final r in Reciters.arabic) reciterTile(r, settings.reciterId),
          ],
          if (settings.recitationMode.includesUrdu) ...[
            section(l10n.urduTranslationAudio),
            for (final r in Reciters.urdu)
              reciterTile(r, settings.urduReciterId),
          ],
          section(l10n.offlineAudio),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.offlineAudioHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (bytes > 0)
            ListTile(
              leading: const Icon(Icons.sd_storage_outlined),
              title: Text(l10n.audioStorageUsed(formatBytes(bytes))),
              trailing: TextButton(
                onPressed: () => _confirmDeleteAll(context, ref),
                child: Text(l10n.deleteAllDownloads),
              ),
            ),
          for (final surah in surahs) _SurahDownloadTile(surah: surah),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllDownloads),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(audioDownloadsProvider.notifier).deleteAll();
    }
  }
}

class _SurahDownloadTile extends ConsumerWidget {
  const _SurahDownloadTile({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(
      audioDownloadsProvider.select((d) => d[surah.number]),
    );
    final downloaded = ref.watch(
      downloadedSurahsProvider.select((s) => s.contains(surah.number)),
    );
    final downloads = ref.read(audioDownloadsProvider.notifier);

    final Widget trailing;
    if (progress != null) {
      trailing = IconButton(
        tooltip: l10n.cancel,
        onPressed: () => downloads.cancel(surah.number),
        icon: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            value: progress == 0 ? null : progress,
            strokeWidth: 3,
          ),
        ),
      );
    } else if (downloaded) {
      trailing = IconButton(
        tooltip: l10n.delete,
        icon: const Icon(Icons.delete_outline),
        onPressed: () => downloads.delete(surah),
      );
    } else {
      trailing = IconButton(
        tooltip: l10n.download,
        icon: const Icon(Icons.download_outlined),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          if (!await downloads.download(surah)) {
            messenger.showToast(l10n.downloadFailed);
          }
        },
      );
    }

    return ListTile(
      leading: NumberMedallion(surah.number, size: 36),
      title: Text(surah.nameSimple),
      subtitle: downloaded ? Text(l10n.downloaded) : null,
      trailing: trailing,
    );
  }
}

/// e.g. "12.4 MB".
String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(unit < 2 ? 0 : 1)} ${units[unit]}';
}
