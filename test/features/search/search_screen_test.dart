import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/features/reader/ayah_tile.dart';
import 'package:quran_app/features/search/search_result_tile.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('searching "2:255" goes to the verse, highlighted', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/search');
    await tester.enterText(find.byType(TextField), '2:255');
    await app.settle(tester);

    final goTo = find.byKey(const ValueKey('search-go-to'));
    expect(goTo, findsOneWidget);
    expect(find.textContaining('2:255 · Al-Baqara'), findsOneWidget);

    await tester.tap(goTo);
    await app.settle(tester);
    final tile = tester.widget<AyahTile>(find.byKey(AyahTile.keyFor('2:255')));
    expect(tile.highlighted, isTrue);
    await app.dispose(tester);
  });

  testWidgets('a text query lists verses with 1:2 first for "الحمد لله"', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/search?q=الحمد لله');
    final first = find.byType(SearchResultTile).first;
    expect(tester.widget<SearchResultTile>(first).ayah.verseKey, '1:2');
    await app.dispose(tester);
  });

  testWidgets('the empty state offers examples and remembers searches', (
    tester,
  ) async {
    final app = await TestApp.pump(tester, location: '/search');
    for (final example in ['2:255', 'Yaseen', 'juz 30', 'patience', 'الصبر']) {
      expect(find.text(example), findsOneWidget);
    }
    await tester.tap(find.text('patience'));
    await app.settle(tester);
    expect(find.byType(SearchResultTile), findsWidgets);

    // Clearing the field shows the recent search.
    await tester.tap(find.byTooltip('Clear'));
    await app.settle(tester);
    expect(find.text('Recent searches'), findsOneWidget);
    await app.dispose(tester);
  });
}
