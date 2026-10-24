import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/quran/references.dart';
import 'features/about/about_screen.dart';
import 'features/audio/recitation_settings_screen.dart';
import 'features/ayah_detail/ayah_detail_screen.dart';
import 'features/bookmarks/bookmarks_screen.dart';
import 'features/home/home_screen.dart';
import 'features/juz/juz_index_screen.dart';
import 'features/juz/juz_reader_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/translations_screen.dart';
import 'features/surahs/surah_index_screen.dart';
import 'features/surahs/surah_reader_screen.dart';
import 'ui/app_shell.dart';
import 'ui/widgets/not_found_screen.dart';

/// Every deep-linkable location, built in one place so paths never drift.
abstract final class AppRoutes {
  static const home = '/';
  static const surahs = '/surahs';
  static const juzIndex = '/juz';
  static const search = '/search';
  static const bookmarks = '/bookmarks';
  static const settings = '/settings';
  static const translations = '/settings/translations';
  static const recitation = '/settings/recitation';
  static const about = '/about';

  static String surah(int number, {int? ayah}) =>
      ayah == null ? '/surah/$number' : '/surah/$number?ayah=$ayah';

  static String juz(int number, {String? verseKey}) => verseKey == null
      ? '/juz/$number'
      : '/juz/$number?verse=${Uri.encodeQueryComponent(verseKey)}';

  static String ayah(int surah, int ayah) => '/ayah/$surah/$ayah';

  static String searchFor(String query) =>
      '/search?q=${Uri.encodeQueryComponent(query)}';

  /// Where a parsed reference leads.
  static String forTarget(NavigationTarget target) => switch (target) {
    SurahTarget(:final surah) => AppRoutes.surah(surah),
    VerseTarget(:final surah, :final ayah) => AppRoutes.surah(
      surah,
      ayah: ayah,
    ),
    JuzTarget(:final juz) => AppRoutes.juz(juz),
  };
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

int? _int(String? value) => value == null ? null : int.tryParse(value);

/// Builds the app's router. Invalid parameters render [NotFoundScreen].
GoRouter buildRouter({String initialLocation = AppRoutes.home}) => GoRouter(
  navigatorKey: _rootKey,
  initialLocation: initialLocation,
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.surahs,
              builder: (context, state) => const SurahIndexScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.juzIndex,
              builder: (context, state) => const JuzIndexScreen(),
              routes: [
                GoRoute(
                  path: ':n',
                  parentNavigatorKey: _rootKey,
                  builder: (context, state) {
                    final juz = _int(state.pathParameters['n']);
                    if (juz == null || juz < 1 || juz > juzCount) {
                      return const NotFoundScreen();
                    }
                    final verse = state.uri.queryParameters['verse'];
                    final valid = verse != null && parseVerseKey(verse) != null;
                    return JuzReaderScreen(
                      key: ValueKey('juz-$juz-$verse'),
                      juz: juz,
                      initialVerseKey: valid ? verse : null,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) => SearchScreen(
                initialQuery: state.uri.queryParameters['q'] ?? '',
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.bookmarks,
              builder: (context, state) => const BookmarksScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/surah/:n',
      parentNavigatorKey: _rootKey,
      builder: (context, state) {
        final surah = _int(state.pathParameters['n']);
        if (surah == null || ayahCount(surah) == null) {
          return const NotFoundScreen();
        }
        final ayahParam = state.uri.queryParameters['ayah'];
        final ayah = _int(ayahParam);
        if (ayahParam != null &&
            (ayah == null || !isValidVerseKey(surah, ayah))) {
          return const NotFoundScreen();
        }
        return SurahReaderScreen(
          key: ValueKey('surah-$surah-$ayah'),
          surah: surah,
          initialAyah: ayah,
        );
      },
    ),
    GoRoute(
      path: '/ayah/:surah/:ayah',
      parentNavigatorKey: _rootKey,
      builder: (context, state) {
        final surah = _int(state.pathParameters['surah']);
        final ayah = _int(state.pathParameters['ayah']);
        if (surah == null || ayah == null || !isValidVerseKey(surah, ayah)) {
          return const NotFoundScreen();
        }
        return AyahDetailScreen(
          key: ValueKey('ayah-$surah:$ayah'),
          surah: surah,
          ayah: ayah,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      parentNavigatorKey: _rootKey,
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'translations',
          parentNavigatorKey: _rootKey,
          builder: (context, state) => const TranslationsScreen(),
        ),
        GoRoute(
          path: 'recitation',
          parentNavigatorKey: _rootKey,
          builder: (context, state) => const RecitationSettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.about,
      parentNavigatorKey: _rootKey,
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
