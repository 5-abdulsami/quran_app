import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/quran/attribution.dart';
import 'package:quran_app/features/reader/ayah_tile.dart';
import 'package:quran_app/ui/app_shell.dart';
import 'package:quran_app/ui/theme/app_theme.dart';
import 'package:quran_app/ui/widgets/quran_text.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('choosing Dark switches the app theme', (tester) async {
    final app = await TestApp.pump(tester, location: '/settings');
    await tester.tap(find.text('Dark'));
    await app.settle(tester);
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    await app.dispose(tester);
  });

  testWidgets('sepia replaces the light theme', (tester) async {
    final app = await TestApp.pump(tester, prefs: {'settings.theme': 'sepia'});
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      materialApp.theme?.scaffoldBackgroundColor,
      AppTheme.sepia().scaffoldBackgroundColor,
    );
    await app.dispose(tester);
  });

  testWidgets('Urdu and Arabic UIs are right-to-left; Quran text stays RTL', (
    tester,
  ) async {
    for (final language in ['ur', 'ar']) {
      final app = await TestApp.pump(
        tester,
        location: '/surah/1',
        prefs: {'settings.language': language},
      );
      final shellDirection = Directionality.of(
        tester.element(find.byType(AyahTile).first),
      );
      expect(shellDirection, TextDirection.rtl, reason: language);
      final quran = tester.widget<Text>(find.byKey(QuranText.textKey).first);
      expect(quran.textDirection, TextDirection.rtl);
      await app.dispose(tester);
    }
  });

  testWidgets('the Urdu UI uses the web dictionary wording', (tester) async {
    final app = await TestApp.pump(tester, prefs: {'settings.language': 'ur'});
    expect(find.text('صفحۂ اول'), findsWidgets); // nav.home in ur.ts
    expect(
      find.text('پڑھنا جاری رکھیں'),
      findsOneWidget,
    ); // home.continueReading
    expect(find.byType(AppShell), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('About credits the Arabic source and every translator', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/about');
    expect(find.text(attributionArabic), findsOneWidget);
    expect(
      find.textContaining('Saheeh International. Supplied by AlQuran.cloud.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Fateh Muhammad Jalandhry, translated by'),
      findsOneWidget,
    );
    expect(find.textContaining('SIL Open Font License'), findsOneWidget);
    await app.dispose(tester);
  });

  // The test font draws every Arabic mark as a full-width box, so the Arabic
  // block is far taller than on a device: scroll to what is asserted.
  // Scrolls the page's list by its position rather than by dragging: a drag
  // that starts on SelectableText becomes a text selection, not a scroll.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    final list = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    for (var i = 0; i < 40; i++) {
      if (finder.hitTestable().evaluate().isNotEmpty) return;
      final position = list.position;
      position.jumpTo(
        (position.pixels + 400).clamp(0, position.maxScrollExtent),
      );
      await tester.pump();
    }
    expect(finder.hitTestable(), findsWidgets);
  }

  testWidgets('ayah detail: selectable Arabic, all translations, metadata', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/ayah/2/255');
    expect(find.byType(SelectableText), findsWidgets);
    await scrollTo(tester, find.text('Page 42'));
    expect(find.text('Juz 3'), findsOneWidget);
    await scrollTo(
      tester,
      find.byWidgetPredicate(
        (w) =>
            w is SelectableText &&
            (w.data ?? '').contains('Allah - there is no deity'),
      ),
    );
    await scrollTo(tester, find.textContaining('Fateh Muhammad Jalandhry'));
    await scrollTo(tester, find.text('2:256'));
    expect(find.text('Read in context'), findsOneWidget);
    expect(find.text('2:254'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('a sajdah verse shows the web wording', (tester) async {
    final app = await TestApp.pump(tester, location: '/ayah/32/15');
    await scrollTo(tester, find.text('Obligatory prostration'));
    expect(find.text('Obligatory prostration'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('Arabic-only mode hides translations in the reader', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/1');
    expect(
      tester.widget<AyahTile>(find.byType(AyahTile).first).ayah.translations,
      isNotEmpty,
    );
    await tester.tap(find.byTooltip('Choose a translation'));
    await app.settle(tester);
    await tester.tap(find.text('Arabic only'));
    await app.settle(tester);
    expect(
      tester.widget<AyahTile>(find.byType(AyahTile).first).ayah.translations,
      isEmpty,
    );
    await app.dispose(tester);
  });

  testWidgets('the reader menu adds and removes Urdu', (tester) async {
    final app = await TestApp.pump(tester, location: '/juz/30');
    List<String> shown() => tester
        .widget<AyahTile>(find.byType(AyahTile).first)
        .ayah
        .translations
        .map((t) => t.editionId)
        .toList();
    expect(shown(), ['en.sahih']);

    Future<void> pick(String label) async {
      await tester.tap(find.byTooltip('Choose a translation'));
      await app.settle(tester);
      await tester.tap(find.text(label));
      await app.settle(tester);
    }

    await pick('اردو'); // add Urdu
    expect(shown(), ['en.sahih', 'ur.jalandhry']);
    final urdu = tester.widget<AyahTile>(find.byType(AyahTile).first).ayah;
    expect(urdu.translations.last.isRtl, isTrue);

    await pick('English'); // remove English, Urdu only
    expect(shown(), ['ur.jalandhry']);

    await pick('اردو'); // removing the last one means Arabic only
    expect(shown(), isEmpty);

    await pick('English'); // back from Arabic only: exactly what was picked
    expect(shown(), ['en.sahih']);
    await app.dispose(tester);
  });
}
