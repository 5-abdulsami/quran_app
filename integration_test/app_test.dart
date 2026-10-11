// End-to-end tests on a device or emulator, against the real bootstrap,
// the real bundled database and on-device storage.
//
// Run: flutter test integration_test
//
// "Restart" unmounts the app (closing both databases) and bootstraps a fresh
// instance from disk, which is what a cold start after being killed does.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/features/bookmarks/bookmark_tile.dart';
import 'package:quran_app/features/bootstrap/app_bootstrap.dart';
import 'package:quran_app/features/reader/ayah_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps frames until [finder] appears (database work is real I/O here).
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    expect(finder, findsWidgets);
  }

  Future<void> launch(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(AppBootstrap(key: UniqueKey(), prefs: prefs));
    await waitFor(tester, find.byType(NavigationBar));
  }

  Future<void> restart(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await launch(tester);
  }

  void go(WidgetTester tester, String location) =>
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go(location);

  // A fresh install for every test: no user data, default settings.
  setUp(() async {
    final support = await getApplicationSupportDirectory();
    final user = File(p.join(support.path, 'quran', 'user.db'));
    if (user.existsSync()) user.deleteSync();
    await (await SharedPreferences.getInstance()).clear();
  });

  testWidgets('search "2:255" lands highlighted on 2:255', (tester) async {
    await launch(tester);
    await tester.tap(find.text('Search').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '2:255');
    await waitFor(tester, find.byKey(const ValueKey('search-go-to')));

    await tester.tap(find.byKey(const ValueKey('search-go-to')));
    await waitFor(tester, find.byKey(AyahTile.keyFor('2:255')));
    final tile = tester.widget<AyahTile>(find.byKey(AyahTile.keyFor('2:255')));
    expect(tile.highlighted, isTrue);
  });

  testWidgets('a bookmark survives a restart', (tester) async {
    await launch(tester);
    go(tester, '/surah/1');
    await waitFor(tester, find.byKey(AyahTile.keyFor('1:2')));
    await tester.tap(
      find.descendant(
        of: find.byKey(AyahTile.keyFor('1:2')),
        matching: find.byTooltip('Verse actions'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bookmark this verse'));
    await tester.pumpAndSettle();

    await restart(tester);
    go(tester, '/bookmarks');
    await waitFor(tester, find.byType(BookmarkTile));
    expect(find.text('Al-Faatiha · 1:2'), findsOneWidget);
  });

  testWidgets('reading 18:50, restarting, Continue reading resumes at 18:50', (
    tester,
  ) async {
    await launch(tester);
    go(tester, '/surah/18');
    await waitFor(tester, find.byTooltip('Go to ayah'));
    await tester.tap(find.byTooltip('Go to ayah'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '50');
    await tester.tap(find.text('Go to'));
    await waitFor(tester, find.byKey(AyahTile.keyFor('18:50')));
    // Let the debounced position save complete.
    await tester.pump(const Duration(seconds: 2));

    await restart(tester);
    await waitFor(tester, find.text('Al-Kahf · 18:50'));
    await tester.tap(find.byKey(const ValueKey('continue-reading')));
    await waitFor(tester, find.byKey(AyahTile.keyFor('18:50')));
  });

  testWidgets('switching surah ↔ juz keeps the current ayah', (tester) async {
    await launch(tester);
    go(tester, '/surah/18?ayah=50');
    await waitFor(tester, find.byKey(AyahTile.keyFor('18:50')));

    await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read by juz'));
    await waitFor(tester, find.textContaining('Juz 15'));
    await waitFor(tester, find.byKey(AyahTile.keyFor('18:50')));

    await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read by surah'));
    await waitFor(tester, find.text('Al-Kahf'));
    await waitFor(tester, find.byKey(AyahTile.keyFor('18:50')));
  });
}
