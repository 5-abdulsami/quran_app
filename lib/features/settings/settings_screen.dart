import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../domain/models/app_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../reader/reader_controls.dart';
import 'settings_controller.dart';

/// Appearance, language, reading preferences, translations and user data.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Endonyms, so each language is recognisable whatever the UI language.
  static const _languageNames = {
    'en': 'English',
    'ur': 'اردو',
    'ar': 'العربية',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Section(l10n.appearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AppThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: AppThemeMode.system,
                  label: Text(l10n.themeSystem),
                ),
                ButtonSegment(
                  value: AppThemeMode.light,
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: AppThemeMode.dark,
                  label: Text(l10n.themeDark),
                ),
                ButtonSegment(
                  value: AppThemeMode.sepia,
                  label: Text(l10n.themeSepia),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => controller.setThemeMode(s.single),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(
              _languageNames[settings.languageCode] ?? l10n.themeSystem,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickLanguage(context, ref, settings.languageCode),
          ),
          _Section(l10n.reading),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextSizeControls(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.translate),
            title: Text(l10n.showTranslation),
            value: settings.showTranslation,
            onChanged: (show) => controller.setShowTranslation(show: show),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.bookmark_border),
            title: Text(l10n.showMarkers),
            value: settings.showMarkers,
            onChanged: (show) => controller.setShowMarkers(show: show),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.light_mode_outlined),
            title: Text(l10n.keepScreenAwake),
            value: settings.keepScreenAwake,
            onChanged: (keep) => controller.setKeepScreenAwake(keepAwake: keep),
          ),
          ListTile(
            leading: const Icon(Icons.library_books_outlined),
            title: Text(l10n.translations),
            subtitle: Text(l10n.manageTranslations),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.translations),
          ),
          _Section(l10n.yourData),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: Text(l10n.exportBookmarks),
            onTap: () => _exportBookmarks(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.importBookmarks),
            onTap: () => _importBookmarks(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: Text(l10n.resetProgress),
            onTap: () => _resetProgress(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutSources),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.about),
          ),
        ],
      ),
    );
  }

  /// Choose the UI language; null follows the device.
  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final options = <(String?, String)>[
      (null, l10n.themeSystem),
      for (final MapEntry(key: code, value: name) in _languageNames.entries)
        (code, name),
    ];
    final chosen = await showDialog<(String?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.language),
        children: [
          for (final (code, name) in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop((code,)),
              child: Row(
                children: [
                  Expanded(child: Text(name)),
                  if (code == current) const Icon(Icons.check),
                ],
              ),
            ),
        ],
      ),
    );
    if (chosen != null) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setLanguage(chosen.$1);
    }
  }

  Future<void> _exportBookmarks(BuildContext context, WidgetRef ref) async {
    final subject = AppLocalizations.of(context).exportBookmarks;
    final json = await ref.read(bookmarkRepositoryProvider).exportJson();
    final file = File(
      p.join(Directory.systemTemp.path, 'quran-bookmarks.json'),
    );
    await file.writeAsString(json, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: subject,
      ),
    );
  }

  Future<void> _importBookmarks(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (picked == null) return;
    try {
      final count = await ref
          .read(bookmarkRepositoryProvider)
          .importJson(await picked.xFile.readAsString());
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importedBookmarks(count))),
      );
    } on FormatException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed)));
    }
  }

  Future<void> _resetProgress(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetProgress),
        content: Text(l10n.resetProgressConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(readingPositionRepositoryProvider).clear();
    messenger.showSnackBar(SnackBar(content: Text(l10n.progressReset)));
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
