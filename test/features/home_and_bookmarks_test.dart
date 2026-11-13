import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/data/bookmark_repository.dart';
import 'package:quran_app/features/bookmarks/bookmark_tile.dart';
import 'package:quran_app/features/reader/ayah_tile.dart';

import '../helpers/test_app.dart';

void main() {
  continueReadingAndKeyboardTests();

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

  testWidgets('opening the surah any other way starts at its beginning', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/18?ayah=50');
    await tester.pump(const Duration(seconds: 1));
    await app.settle(tester);

    // As from the surah list, search or a shortcut: no verse in the link.
    GoRouter.of(tester.element(find.byType(AyahTile).first)).go('/');
    await app.settle(tester);
    GoRouter.of(
      tester.element(find.byKey(const ValueKey('continue-reading'))),
    ).push<void>('/surah/18').ignore();
    await app.settle(tester);
    expect(find.byKey(AyahTile.keyFor('18:1')), findsOneWidget);
    expect(find.byKey(AyahTile.keyFor('18:50')), findsNothing);

    // The saved place is untouched: Continue reading still resumes at 18:50.
    GoRouter.of(tester.element(find.byType(AyahTile).first)).go('/');
    await app.settle(tester);
    expect(find.text('Al-Kahf · 18:50'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('scrolling a surah opened at the top does save the place', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/18');
    // From mid-screen: the first verse sits below the surah's tall header.
    await tester.dragFrom(const Offset(200, 450), const Offset(0, -2500));
    await tester.pump(const Duration(seconds: 1));
    await app.settle(tester);

    GoRouter.of(tester.element(find.byType(AyahTile).first)).go('/');
    await app.settle(tester);
    expect(find.textContaining('Al-Kahf · 18:'), findsOneWidget);
    expect(find.text('Al-Kahf · 18:1'), findsNothing);
    await app.dispose(tester);
  });

  testWidgets('Back to start scrolls a reader to its first verse', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/18?ayah=50');
    expect(find.byKey(AyahTile.keyFor('18:1')), findsNothing);

    await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
    await app.settle(tester);
    await tester.tap(find.text('Back to start'));
    await app.settle(tester);
    expect(find.byKey(AyahTile.keyFor('18:1')), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('Go to verse accepts names and rejects impossible verses', (
    tester,
  ) async {
    final app = await TestApp.pump(tester);
    final field = find.byKey(const ValueKey('go-to-verse'));
    // Below the daily card on a phone-sized screen.
    await tester.scrollUntilVisible(field, 200);

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

void continueReadingAndKeyboardTests() {
  testWidgets('with nothing read yet, Continue reading opens Al-Fatihah', (
    tester,
  ) async {
    final app = await TestApp.pump(tester);
    await tester.tap(find.byKey(const ValueKey('continue-reading')));
    await app.settle(tester);
    expect(find.text('1. Al-Faatiha'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('leaving a reader at once still saves the place', (tester) async {
    final app = await TestApp.pump(tester, location: '/surah/36?ayah=12');
    // Back to Home before the position-save delay has passed.
    GoRouter.of(tester.element(find.byType(AyahTile).first)).go('/');
    await app.settle(tester);
    expect(find.text('Yaseen · 36:12'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('tapping outside a text field closes the keyboard', (
    tester,
  ) async {
    final app = await TestApp.pump(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('go-to-verse')),
      200,
    );
    await tester.tap(find.byKey(const ValueKey('go-to-verse')));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.text('Quran Urdu')); // the app bar title
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
    await app.dispose(tester);
  });
}
