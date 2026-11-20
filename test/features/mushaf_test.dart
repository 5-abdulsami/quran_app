import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/core/quran/references.dart';
import 'package:quran_app/data/quran_repository.dart';
import 'package:quran_app/features/mushaf/mushaf_page_view.dart';
import 'package:quran_app/features/mushaf/mushaf_screen.dart';
import 'package:quran_app/features/reader/ayah_tile.dart';
import 'package:quran_app/features/surahs/surah_reader_screen.dart';
import 'package:quran_app/ui/theme/quran_typography.dart';
import 'package:quran_app/ui/widgets/not_found_screen.dart';

import '../helpers/test_app.dart';
import '../helpers/test_databases.dart';

/// Taps the verse [verseKey] inside the mushaf's flowing text.
void tapVerse(WidgetTester tester, String verseKey, String displayText) {
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    final root = text.textSpan;
    final spans = root is TextSpan
        ? root.children ?? const <InlineSpan>[]
        : const <InlineSpan>[];
    for (final span in spans) {
      if (span is TextSpan &&
          span.text == displayText &&
          span.recognizer is TapGestureRecognizer) {
        (span.recognizer! as TapGestureRecognizer).onTap!();
        return;
      }
    }
  }
  fail('verse $verseKey not found in the mushaf text');
}

void main() {
  test('every ayah is on exactly one page, pages in mushaf order', () async {
    final db = await openBundledContentDb();
    addTearDown(db.close);
    final repo = QuranRepository(db);
    var expectedId = 1;
    for (var page = 1; page <= mushafPageCount; page++) {
      final ayahs = await repo.pageAyahs(page);
      expect(ayahs, isNotEmpty, reason: 'page $page');
      for (final ayah in ayahs) {
        expect(ayah.id, expectedId++, reason: 'page $page');
        expect(ayah.page, page);
      }
    }
    expect(expectedId - 1, totalAyahCount);
    expect(await repo.pageAyahs(0), isEmpty);
    expect(await repo.pageAyahs(605), isEmpty);
  });

  testWidgets('page 1 shows al-Fatihah; a tap on a verse shows its '
      'translation', (tester) async {
    final app = await TestApp.pump(tester, location: '/mushaf');
    expect(find.byType(MushafScreen), findsOneWidget);
    expect(find.text('Page 1'), findsWidgets);
    expect(find.byKey(MushafPageView.keyFor(1)), findsOneWidget);

    final fatiha2 = (await tester.runAsync(
      () => QuranRepository(
        app.content,
      ).ayah('1:2', translationIds: const ['ur.jalandhry']),
    ))!;
    // The default font shows the QPC Nastaleeq text.
    tapVerse(tester, '1:2', QuranScript.qpcNastaleeq.verseText(fatiha2));
    await app.settle(tester);
    expect(find.text('Al-Faatiha · 1:2'), findsOneWidget);
    expect(find.text(fatiha2.translations.single.text), findsOneWidget);
    expect(find.text('Play from this verse'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('Go to page jumps to the last page', (tester) async {
    final app = await TestApp.pump(tester, location: '/mushaf');
    await tester.tap(find.byTooltip('Go to page'));
    await app.settle(tester);
    await tester.enterText(find.byType(TextField), '604');
    await tester.pump();
    await tester.tap(find.text('Go to'));
    await app.settle(tester);
    expect(find.byKey(MushafPageView.keyFor(604)), findsOneWidget);
    expect(find.text('Page 604'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('the surah reader opens the mushaf at the page on screen, and '
      'back again', (tester) async {
    final app = await TestApp.pump(tester, location: '/surah/2?ayah=255');
    await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
    await app.settle(tester);
    await tester.tap(find.text('Mushaf view'));
    await app.settle(tester);
    final mushaf = tester.widget<MushafScreen>(find.byType(MushafScreen));
    expect(mushaf.initialPage, 42); // 2:255 is on page 42

    await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
    await app.settle(tester);
    await tester.tap(find.text('Translation view'));
    await app.settle(tester);
    final reader = tester.widget<SurahReaderScreen>(
      find.byType(SurahReaderScreen),
    );
    expect(reader.surah, 2);
    await app.dispose(tester);
  });

  testWidgets('Continue reading resumes the mushaf page', (tester) async {
    final app = await TestApp.pump(tester, location: '/mushaf?page=50');
    // Reading (a scroll) is what saves the place.
    await tester.dragFrom(const Offset(200, 450), const Offset(0, -300));
    await tester.pump(const Duration(seconds: 1));
    await app.settle(tester);
    final page = int.parse(
      RegExp(r'Page (\d+)')
          .firstMatch(
            tester.widgetList<Text>(find.textContaining('Page ')).first.data!,
          )!
          .group(1)!,
    );

    GoRouter.of(tester.element(find.byType(MushafScreen))).go('/');
    await app.settle(tester);
    expect(find.textContaining('Mushaf · Page $page'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('continue-reading')));
    await app.settle(tester);
    expect(
      tester.widget<MushafScreen>(find.byType(MushafScreen)).initialPage,
      page,
    );
    await app.dispose(tester);
  });

  testWidgets('opening the mushaf without reading keeps the saved place', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/18?ayah=50');
    await tester.pump(const Duration(seconds: 1));
    await app.settle(tester);
    GoRouter.of(
      tester.element(find.byType(AyahTile).first),
    ).go('/mushaf?page=300');
    await tester.pump(const Duration(seconds: 1));
    await app.settle(tester);
    GoRouter.of(tester.element(find.byType(MushafScreen))).go('/');
    await app.settle(tester);
    expect(find.text('Al-Kahf · 18:50'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('impossible pages are not found', (tester) async {
    final app = await TestApp.pump(tester, location: '/mushaf?page=605');
    expect(find.byType(NotFoundScreen), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('Quran text and translations are selectable', (tester) async {
    var app = await TestApp.pump(tester, location: '/surah/112');
    expect(find.byType(SelectionArea), findsWidgets);
    await app.dispose(tester);
    app = await TestApp.pump(tester, location: '/mushaf');
    expect(find.byType(SelectionArea), findsWidgets);
    await app.dispose(tester);
  });
}
