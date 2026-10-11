import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/data/bookmark_repository.dart';
import 'package:quran_app/features/bookmarks/bookmark_tile.dart';
import 'package:quran_app/features/reader/ayah_tile.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('reading 18:50 then Continue reading resumes at 18:50', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/18?ayah=50');
    // The position is saved after a short debounce.
    await tester.pump(const Duration(seconds: 1));
    await app.settle(tester);

    GoRouter.of(tester.element(find.byType(AyahTile).first)).go('/');
    await app.settle(tester);
    expect(find.text('Al-Kahf · 18:50'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('continue-reading')));
    await app.settle(tester);
    expect(find.byKey(AyahTile.keyFor('18:50')), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('Go to verse accepts names and rejects impossible verses', (
    tester,
  ) async {
    final app = await TestApp.pump(tester);
    final field = find.byKey(const ValueKey('go-to-verse'));

    await tester.enterText(field, '2:300');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await app.settle(tester);
    expect(
      find.text('That reference does not exist in the Quran.'),
      findsOneWidget,
    );

    await tester.enterText(field, 'yaseen');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await app.settle(tester);
    expect(find.text('36. Yaseen'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('bookmarks list, swipe to delete, undo', (tester) async {
    final app = await TestApp.pump(tester, location: '/bookmarks');
    expect(find.textContaining('No bookmarks yet'), findsOneWidget);

    await tester.runAsync(() => BookmarkRepository(app.user).toggle('2:255'));
    await app.settle(tester);
    expect(find.byType(BookmarkTile), findsOneWidget);
    expect(find.text('Al-Baqara · 2:255'), findsOneWidget);

    await tester.drag(find.byType(BookmarkTile), const Offset(-600, 0));
    await app.settle(tester);
    expect(find.byType(BookmarkTile), findsNothing);

    await tester.tap(find.text('Undo'));
    await app.settle(tester);
    expect(find.byType(BookmarkTile), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('bookmarking from the verse actions marks the tile', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/1');
    await tester.tap(
      find.descendant(
        of: find.byKey(AyahTile.keyFor('1:1')),
        matching: find.byTooltip('Verse actions'),
      ),
    );
    await app.settle(tester);
    await tester.tap(find.text('Bookmark this verse'));
    await app.settle(tester);
    expect(
      tester.widget<AyahTile>(find.byKey(AyahTile.keyFor('1:1'))).bookmarked,
      isTrue,
    );
    await app.dispose(tester);
  });
}
