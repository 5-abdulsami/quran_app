import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../features/audio/player_bar.dart';
import '../l10n/generated/app_localizations.dart';
import '../router.dart';
import 'keyboard.dart';
import 'toast.dart';

/// The bottom-navigation frame around the five top-level tabs.
///
/// Back on a tab's first page returns to Home; on Home it must be pressed
/// twice within [Toast.duration] to leave the app.
class AppShell extends StatefulWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  DateTime? _lastBack;

  StatefulNavigationShell get shell => widget.shell;

  void _onBack(bool didPop, Object? _) {
    if (didPop) return;
    dismissKeyboard();
    if (shell.currentIndex != 0) {
      shell.goBranch(0);
      return;
    }
    final now = DateTime.now();
    final messenger = ScaffoldMessenger.of(context);
    if (_lastBack case final last? when now.difference(last) < Toast.duration) {
      messenger.hideCurrentSnackBar();
      SystemNavigator.pop();
      return;
    }
    _lastBack = now;
    messenger.showToast(AppLocalizations.of(context).pressBackAgainToExit);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: _scaffold(l10n),
    );
  }

  Widget _scaffold(AppLocalizations l10n) {
    return Scaffold(
      body: RecitationPlayerBarScope(child: shell),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RecitationPlayerBar(onOpen: _openVerse),
          _navigationBar(l10n),
        ],
      ),
    );
  }

  void _openVerse(String verseKey) {
    final [surah, ayah] = verseKey.split(':').map(int.parse).toList();
    context.push(AppRoutes.surah(surah, ayah: ayah));
  }

  Widget _navigationBar(AppLocalizations l10n) {
    // Five tabs share the width, so labels are short and their text scale is
    // capped: a large system font must not push them off-screen.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Re-tapping the current tab returns it to its first page. The
        // keyboard closes so it never follows the user to another tab.
        onDestinationSelected: (index) {
          dismissKeyboard();
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.navSurahs,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_stories_outlined),
            selectedIcon: const Icon(Icons.auto_stories),
            label: l10n.navJuz,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: l10n.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline),
            selectedIcon: const Icon(Icons.bookmark),
            label: l10n.navSaved,
          ),
        ],
      ),
    );
  }
}

/// The app-bar button that opens Settings, shown on every tab.
class SettingsAction extends StatelessWidget {
  const SettingsAction({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).settings,
    icon: const Icon(Icons.settings_outlined),
    onPressed: () => context.push('/settings'),
  );
}
