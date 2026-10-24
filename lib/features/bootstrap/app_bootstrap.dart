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
import '../../data/recitation_audio_store.dart';
import '../../data/settings_repository.dart';
import '../../data/translation_download_service.dart';
import '../../domain/models/reciter.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../ui/theme/app_theme.dart';
import 'loading_splash.dart';

/// Opens the databases, then hands over to [QuranApp].
///
/// While opening it shows the animated splash; if opening fails it shows a recovery
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
  late Directory _translationStore;
  late Directory _audioStore;
  Object? _error;

  /// The splash stays mounted until its fade-out has finished.
  bool _splashMounted = true;

  /// Long enough for the splash animation to read as intentional, short
  /// enough never to hold back a fast start.
  static const _minimumSplash = Duration(milliseconds: 700);
  static const _fadeOut = Duration(milliseconds: 450);

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
    final minimum = Future<void>.delayed(_minimumSplash);
    try {
      final support = await getApplicationSupportDirectory();
      final dataDir = p.join(support.path, 'quran');
      _translationStore = Directory(p.join(dataDir, 'translations'));
      _audioStore = Directory(p.join(dataDir, 'audio'));
      // Free the space of recordings no longer offered (in the background).
      RecitationAudioStore(directory: _audioStore).removeUnknownReciters({
        for (final r in [...Reciters.arabic, ...Reciters.urdu]) r.id,
      }).ignore();
      final databases = await DbBootstrap(
        loadAsset: (key) async =>
            (await rootBundle.load(key)).buffer.asUint8List(),
        dataDirectory: Directory(dataDir),
      ).open(forceContentReset: forceContentReset);

      if (databases.contentReplaced) {
        // A fresh content file has no downloaded translations; re-import them.
        await TranslationDownloadService.restoreDownloaded(
          databases.content,
          storeDirectory: _translationStore,
        );
      }
      await minimum;
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
    final ready = databases != null;

    // The app is built underneath as soon as it can be, and the splash fades
    // out on top of it: no blank frame, no abrupt cut.
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        if (databases != null)
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(widget.prefs),
              contentDatabaseProvider.overrideWithValue(databases.content),
              userDatabaseProvider.overrideWithValue(databases.user),
              translationStoreDirectoryProvider.overrideWithValue(
                _translationStore,
              ),
              audioStoreDirectoryProvider.overrideWithValue(_audioStore),
            ],
            child: const QuranApp(),
          ),
        if (_splashMounted)
          IgnorePointer(
            ignoring: ready,
            child: AnimatedOpacity(
              opacity: ready ? 0 : 1,
              duration: _fadeOut,
              curve: Curves.easeOut,
              onEnd: () {
                if (ready) setState(() => _splashMounted = false);
              },
              child: _startupScreen(),
            ),
          ),
      ],
    );
  }

  /// The splash, or the recovery screen when opening failed.
  Widget _startupScreen() {
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
          ? const LoadingSplash()
          : _RecoveryScreen(
              onRetry: _open,
              onRestore: () => _open(forceContentReset: true),
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
