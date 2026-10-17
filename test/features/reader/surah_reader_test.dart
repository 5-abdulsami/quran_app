import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/domain/models/app_settings.dart';
import 'package:quran_app/features/reader/ayah_tile.dart';
import 'package:quran_app/features/reader/bismillah_header.dart';
import 'package:quran_app/features/reader/surah_header.dart';
import 'package:quran_app/ui/theme/quran_typography.dart';
import 'package:quran_app/ui/widgets/quran_text.dart';

import '../../helpers/test_app.dart';

/// Text of the Arabic block inside a verse's tile.
String arabicOf(WidgetTester tester, String verseKey) {
  final text = tester.widget<Text>(
    find.descendant(
      of: find.byKey(AyahTile.keyFor(verseKey)),
      matching: find.byKey(QuranText.textKey),
    ),
  );
  // The verse span comes first; the end-of-ayah ornament follows it.
  return (text.textSpan! as TextSpan).children!.first.toPlainText();
}

void main() {
  testWidgets('surah 1: no header basmalah, ayah 1 shown in full', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/1');
    expect(find.byType(SurahHeader), findsOneWidget);
    expect(find.byType(BismillahHeader), findsNothing);
    final ayah1 = await tester.runAsync(
      () => app.content
          .customSelect(
            "SELECT text_uthmani t FROM ayah WHERE verse_key = '1:1'",
          )
          .getSingle(),
    );
    expect(arabicOf(tester, '1:1'), ayah1!.read<String>('t'));
    await app.dispose(tester);
  });

  testWidgets('surah 2: header basmalah once, ayah 1 is الٓمٓ', (tester) async {
    final app = await TestApp.pump(tester, location: '/surah/2');
    expect(find.byType(BismillahHeader), findsOneWidget);
    expect(arabicOf(tester, '2:1').runes.toList(), [
      0x0627,
      0x0644,
      0x0653,
      0x0645,
      0x0653,
    ]);
    await app.dispose(tester);
  });

  testWidgets('surah 9: no basmalah anywhere', (tester) async {
    final app = await TestApp.pump(tester, location: '/surah/9');
    expect(find.byType(SurahHeader), findsOneWidget);
    expect(find.byType(BismillahHeader), findsNothing);
    await app.dispose(tester);
  });

  testWidgets(
    'ayah tile renders Quran text in Amiri Quran, RTL, Arabic locale',
    (tester) async {
      final app = await TestApp.pump(tester, location: '/surah/1');
      final tile = find.byKey(AyahTile.keyFor('1:2'));
      final text = tester.widget<Text>(
        find.descendant(of: tile, matching: find.byKey(QuranText.textKey)),
      );
      expect(
        text.style?.fontFamily,
        QuranFonts.of(QuranFont.scheherazadeNew).family,
      );
      expect(text.style?.height, QuranTypography.lineHeight);
      expect(text.textDirection, TextDirection.rtl);
      expect(text.locale, const Locale('ar'));
      expect(text.textAlign, TextAlign.start);
      final directionality = tester.widget<Directionality>(
        find
            .ancestor(
              of: find.byKey(QuranText.textKey).first,
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(directionality.textDirection, TextDirection.rtl);
      await app.dispose(tester);
    },
  );

  testWidgets('opening at an ayah jumps to it and highlights it', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/2?ayah=255');
    expect(find.byKey(AyahTile.keyFor('2:255')), findsOneWidget);
    expect(find.byKey(AyahTile.keyFor('2:1')), findsNothing);
    final tile = tester.widget<AyahTile>(find.byKey(AyahTile.keyFor('2:255')));
    expect(tile.highlighted, isTrue);
    await app.dispose(tester);
  });

  testWidgets('a juz marker shows only where the juz changes', (tester) async {
    final app = await TestApp.pump(tester, location: '/surah/2?ayah=141');
    AyahTile tile(String key) =>
        tester.widget<AyahTile>(find.byKey(AyahTile.keyFor(key)));
    expect(tile('2:141').showJuz, isFalse);
    expect(tile('2:142').showJuz, isTrue);
    expect(find.text('Juz 2 · Hizb 3 · Page 22'), findsOneWidget);
    await app.dispose(tester);
  });
}
