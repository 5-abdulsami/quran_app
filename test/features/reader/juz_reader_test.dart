import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/domain/models/juz.dart';
import 'package:quran_app/features/juz/juz_index_screen.dart';
import 'package:quran_app/features/reader/ayah_tile.dart';
import 'package:quran_app/features/reader/bismillah_header.dart';
import 'package:quran_app/features/reader/surah_header.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets(
    'juz 30 opens with an-Naba: header and basmalah, no continuation',
    (tester) async {
      final app = await TestApp.pump(tester, location: '/juz/30');
      expect(find.byType(ContinuingSurahCard), findsNothing);
      expect(find.text('78. An-Naba'), findsOneWidget);
      expect(find.byType(BismillahHeader), findsOneWidget);
      await app.dispose(tester);
    },
  );

  testWidgets('juz 30 deep link to 114:1 shows An-Naas header and basmalah', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/juz/30?verse=114:1');
    // Deep in the juz: the last surah's header and basmalah are on screen
    // directly above its first verse.
    expect(find.text('114. An-Naas'), findsOneWidget);
    expect(find.byType(BismillahHeader), findsWidgets);
    expect(find.byKey(AyahTile.keyFor('114:1')), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('juz 2 continues al-Baqarah with no basmalah', (tester) async {
    final app = await TestApp.pump(tester, location: '/juz/2');
    expect(
      find.text('Continuing Surah Al-Baqara from ayah 142'),
      findsOneWidget,
    );
    expect(find.byType(SurahHeader), findsNothing);
    expect(find.byType(BismillahHeader), findsNothing);
    expect(find.byKey(AyahTile.keyFor('2:142')), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('juz index lists all 30 with names', (tester) async {
    final app = await TestApp.pump(tester, location: '/juz');
    expect(find.text('Juz 1 · Alif Lam Mim'), findsOneWidget);
    expect(
      find.textContaining('1:1 – 2:141'),
      findsOneWidget,
    );
    await app.dispose(tester);
  });

  test('juz progress follows the saved position', () {
    const juz = Juz(
      number: 30,
      firstVerseKey: '78:1',
      lastVerseKey: '114:6',
      firstAyahId: 5673,
      lastAyahId: 6236,
      nameArabic: '',
      nameTransliterated: '',
      surahNumbers: [],
    );
    expect(juzProgress(juz, null), isNull);
    expect(juzProgress(juz, '2:255'), isNull);
    expect(juzProgress(juz, '114:6'), 1);
    expect(juzProgress(juz, '78:1'), closeTo(1 / 564, 1e-9));
  });

  testWidgets('switching surah → juz → surah keeps the current ayah', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/surah/18?ayah=50');
    expect(find.byKey(AyahTile.keyFor('18:50')), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
    await app.settle(tester);
    await tester.tap(find.text('Read by juz'));
    await app.settle(tester);
    expect(find.textContaining('Juz 15'), findsOneWidget);
    expect(find.byKey(AyahTile.keyFor('18:50')), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
    await app.settle(tester);
    await tester.tap(find.text('Read by surah'));
    await app.settle(tester);
    expect(find.text('Al-Kahf'), findsOneWidget);
    expect(find.byKey(AyahTile.keyFor('18:50')), findsOneWidget);
    await app.dispose(tester);
  });
}
