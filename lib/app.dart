import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/settings/settings_controller.dart';
import 'l10n/generated/app_localizations.dart';
import 'router.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/quran_typography.dart';

/// The root widget: theme, locale and router, all driven by settings.
class QuranApp extends ConsumerStatefulWidget {
  const QuranApp({this.initialLocation = AppRoutes.home, super.key});

  /// Lets tests start on any deep link.
  final String initialLocation;

  @override
  ConsumerState<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends ConsumerState<QuranApp> {
  late final GoRouter _router = buildRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final language = settings.languageCode;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
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
      routerConfig: _router,
      // Every QuranText below reads the chosen Quran font from this scope.
      builder: (context, child) => QuranFontScope(
        family: QuranTypography.familyFor(settings.quranFont),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
