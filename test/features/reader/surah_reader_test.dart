import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/quran/indopak.dart';
import 'package:quran_app/core/quran/qpc_nastaleeq.dart';
import 'package:quran_app/core/quran/verse_end.dart';
import 'package:quran_app/core/text/arabic_digits.dart';
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

/// The spans of a verse's Arabic block: the verse, then any ornament.
List<InlineSpan> spansOf(WidgetTester tester, String verseKey) =>
    (tester
                .widget<Text>(
                  find.descendant(
                    of: find.byKey(AyahTile.keyFor(verseKey)),
                    matching: find.byKey(QuranText.textKey),
                  ),
                )
                .textSpan!
            as TextSpan)
        .children!;

/// An Uthmani font, for the Uthmani-text checks.
const uthmani = {'settings.quranFont': 'scheherazadeNew'};

/// The IndoPak Nastaleeq font, for its own text.
const indopak = {'settings.quranFont': 'indoPakNastaleeq'};

/// The text of the basmalah under a surah header.
String headerBasmalah(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(
        of: find.byType(BismillahHeader),
        matching: find.byKey(QuranText.textKey),
      ),
    )
    .textSpan!
    .toPlainText();

void main() {
  testWidgets('surah 1: no header basmalah, ayah 1 shown in full', (
    tester,
  ) async {
    final app = await TestApp.pump(
      tester,
      location: '/surah/1',
      prefs: uthmani,
    );
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
    final app = await TestApp.pump(
      tester,
      location: '/surah/2',
      prefs: uthmani,
    );
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

  testWidgets('KFGQPC (default): 1:1 is the basmalah, then the ornament', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/1');
    expect(find.byType(BismillahHeader), findsNothing);
    expect(spansOf(tester, '1:1').map((s) => s.toPlainText()), [
      qpcNastaleeqBasmalah,
      '${String.fromCharCode(0xA0)}${endOfAyahMarker(1)}',
    ]);
    await app.dispose(tester);
  });

  testWidgets('KFGQPC (default): surah 2 shows its basmalah once', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/2');
    expect(headerBasmalah(tester), qpcNastaleeqBasmalah);
    // الٓمّٓ, the ornament numbered 1, then the text's own sign above it.
    expect(spansOf(tester, '2:1').map((s) => s.toPlainText()), [
      startsWith(String.fromCharCodes([0x627, 0x644, 0x653])),
      '${String.fromCharCode(0xA0)}${endOfAyahMarker(1)}',
      String.fromCharCode(0xFD94),
    ]);
    await app.dispose(tester);
  });

  testWidgets('Indo-Pak: 1:1 is the basmalah with its circle numbered 1', (
    tester,
  ) async {
    final app = await TestApp.pump(
      tester,
      location: '/surah/1',
      prefs: indopak,
    );
    expect(find.byType(BismillahHeader), findsNothing);
    final ayah1 = await tester.runAsync(
      () => app.content
          .customSelect(
            "SELECT text_indopak t FROM ayah WHERE verse_key = '1:1'",
          )
          .getSingle(),
    );
    expect(
      arabicOf(tester, '1:1'),
      keepVerseEndOnLine(ayah1!.read<String>('t')),
    );
    expect(arabicOf(tester, '1:1'), startsWith(indopakBasmalah));
    expect(arabicOf(tester, '1:1').runes.last, 0xF500);
    await app.dispose(tester);
  });

  testWidgets('Indo-Pak: surah 2 shows the Indo-Pak basmalah once', (
    tester,
  ) async {
    final app = await TestApp.pump(
      tester,
      location: '/surah/2',
      prefs: indopak,
    );
    expect(find.byType(BismillahHeader), findsOneWidget);
    expect(headerBasmalah(tester), indopakBasmalah);
    // الٓمّٓ, then the circle numbered 1.
    expect(arabicOf(tester, '2:1'), startsWith('\u0627\u0644\u0653'));
    expect(arabicOf(tester, '2:1').runes.last, 0xF500);
    await app.dispose(tester);
  });

  testWidgets('surah 9: no basmalah anywhere', (tester) async {
    final app = await TestApp.pump(tester, location: '/surah/9');
    expect(find.byType(SurahHeader), findsOneWidget);
    expect(find.byType(BismillahHeader), findsNothing);
    await app.dispose(tester);
  });

  testWidgets(
    'ayah tile renders Quran text in KFGQPC Nastaleeq, RTL, Arabic locale',
    (tester) async {
      final app = await TestApp.pump(tester, location: '/surah/1');
      final tile = find.byKey(AyahTile.keyFor('1:2'));
      final text = tester.widget<Text>(
        find.descendant(of: tile, matching: find.byKey(QuranText.textKey)),
      );
      expect(
        text.style?.fontFamily,
        QuranFonts.of(QuranFont.kfgqpcNastaleeq).family,
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
    // Tall enough for 2:141 and 2:142 at the default text sizes.
    final app = await TestApp.pump(
      tester,
      location: '/surah/2?ayah=141',
      size: const Size(420, 1600),
    );
    AyahTile tile(String key) =>
        tester.widget<AyahTile>(find.byKey(AyahTile.keyFor(key)));
    expect(tile('2:141').showJuz, isFalse);
    expect(tile('2:142').showJuz, isTrue);
    expect(find.text('Juz 2 · Hizb 3 · Page 22'), findsOneWidget);
    await app.dispose(tester);
  });
}
