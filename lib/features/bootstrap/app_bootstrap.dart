import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../core/db/db_bootstrap.dart';
import '../../data/settings_repository.dart';
import '../../data/translation_download_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../ui/theme/app_theme.dart';

/// Opens the databases, then hands over to [QuranApp].
///
/// While opening it shows a quiet splash; if opening fails it shows a recovery
/// screen instead of crashing, with the option to restore the bundled Quran
/// database (bookmarks live in a separate file and are never affected).
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({required this.prefs, super.key});

  final SharedPreferences prefs;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  OpenedDatabases? _databases;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    _databases?.close();
    super.dispose();
  }

  Future<void> _open({bool forceContentReset = false}) async {
    setState(() => _error = null);
    try {
      final support = await getApplicationSupportDirectory();
      final dataDir = p.join(support.path, 'quran');
      final databases = await DbBootstrap(
        loadAsset: (key) async =>
            (await rootBundle.load(key)).buffer.asUint8List(),
        dataDirectory: Directory(dataDir),
      ).open(forceContentReset: forceContentReset);

      if (databases.contentReplaced) {
        // A fresh content file has no downloaded translations; re-import them.
        await TranslationDownloadService.restoreDownloaded(
          databases.content,
          storeDirectory: Directory(p.join(dataDir, 'translations')),
        );
      }
      if (!mounted) {
        await databases.close();
        return;
      }
      setState(() => _databases = databases);
    } on Object catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'bootstrap',
        ),
      );
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final databases = _databases;
    if (databases != null) {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(widget.prefs),
          contentDatabaseProvider.overrideWithValue(databases.content),
          userDatabaseProvider.overrideWithValue(databases.user),
        ],
        child: const QuranApp(),
      );
    }

    final settings = SettingsRepository(widget.prefs).load();
    final language = settings.languageCode;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightFor(settings.themeMode),
      darkTheme: AppTheme.dark(),
      themeMode: AppTheme.themeModeFor(settings.themeMode),
      locale: language == null ? null : Locale(language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _error == null
          ? const _Splash()
          : _RecoveryScreen(
              onRetry: _open,
              onRestore: () => _open(forceContentReset: true),
            ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            const SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(height: 16),
            Text(l10n.preparingQuran, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _RecoveryScreen extends StatelessWidget {
  const _RecoveryScreen({required this.onRetry, required this.onRestore});

  final VoidCallback onRetry;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.dbErrorTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(l10n.dbErrorBody, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: onRestore,
                  child: Text(l10n.restoreDatabase),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
