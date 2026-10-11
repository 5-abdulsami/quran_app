import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/app.dart';
import 'package:quran_app/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {String location = '/'}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: QuranApp(initialLocation: location),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the five bottom-navigation tabs', (tester) async {
    await pumpApp(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Home', 'Surahs', 'Juz', 'Search', 'Saved']) {
      expect(find.text(label), findsWidgets);
    }
  });

  testWidgets('an impossible surah shows the not-found screen', (tester) async {
    await pumpApp(tester, location: '/surah/115');
    expect(find.text('We could not find that page.'), findsOneWidget);
  });

  testWidgets('an impossible ayah shows the not-found screen', (tester) async {
    await pumpApp(tester, location: '/ayah/2/300');
    expect(find.text('We could not find that page.'), findsOneWidget);
  });
}
