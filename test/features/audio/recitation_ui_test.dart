import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/data/settings_repository.dart';
import 'package:quran_app/domain/models/app_settings.dart';
import 'package:quran_app/domain/models/reciter.dart';
import 'package:quran_app/features/reader/ayah_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_app.dart';

void main() {
  test('recitation settings persist, and bad values fall back', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SettingsRepository(await SharedPreferences.getInstance());
    expect(repo.load().recitationMode, RecitationMode.arabic);
    expect(repo.load().reciter.id, Reciters.defaultArabicId);

    await repo.save(
      const AppSettings(
        recitationMode: RecitationMode.arabicThenUrdu,
        reciterId: 'husary',
        urduReciterId: 'ur.farhathashmi',
      ),
    );
    final loaded = repo.load();
    expect(loaded.recitationMode, RecitationMode.arabicThenUrdu);
    expect(loaded.reciterId, 'husary');
    expect(loaded.urduReciterId, 'ur.farhathashmi');
    expect(loaded.activeReciters.map((r) => r.id), [
      'husary',
      'ur.farhathashmi',
    ]);

    SharedPreferences.setMockInitialValues({
      'settings.recitationMode': 'nonsense',
      'settings.reciter': 'removed-reciter',
    });
    final fallback = SettingsRepository(
      await SharedPreferences.getInstance(),
    ).load();
    expect(fallback.recitationMode, RecitationMode.arabic);
    expect(fallback.reciterId, Reciters.defaultArabicId);
  });

  testWidgets('every verse in the reader has a play button', (tester) async {
    final app = await TestApp.pump(tester, location: '/surah/112');
    final firstVerse = find.byKey(AyahTile.keyFor('112:1'));
    expect(
      find.descendant(
        of: firstVerse,
        matching: find.byTooltip('Play from this verse'),
      ),
      findsOneWidget,
    );
    // Nothing plays until asked: no player bar.
    expect(find.byTooltip('Stop'), findsNothing);

    await tester.tap(
      find.descendant(
        of: firstVerse,
        matching: find.byTooltip('Verse actions'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Play from this verse'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('choosing what to listen to and the reciter', (tester) async {
    final app = await TestApp.pump(tester, location: '/settings/recitation');
    expect(find.text('Mishary Rashid Alafasy'), findsOneWidget);
    // Urdu reciters appear only when Urdu is played.
    expect(find.text('Shamshad Ali Khan'), findsNothing);

    await tester.tap(find.text('Arabic + Urdu'));
    await tester.pumpAndSettle();
    expect(find.text('Shamshad Ali Khan'), findsOneWidget);

    await tester.tap(find.text('Mahmoud Khalil Al-Husary'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings.reciter'), 'husary');
    expect(prefs.getString('settings.recitationMode'), 'arabicThenUrdu');

    // Surahs can be downloaded for offline listening.
    expect(find.text('Offline audio'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Al-Faatiha'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.ancestor(
        of: find.byTooltip('Download'),
        matching: find.byType(ListTile),
      ),
      findsWidgets,
    );
    await app.dispose(tester);
  });

  testWidgets('Settings links to the recitation screen', (tester) async {
    final app = await TestApp.pump(tester, location: '/settings');
    await tester.scrollUntilVisible(
      find.text('Recitation'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Recitation'));
    await app.settle(tester);
    expect(find.text('Listen to'), findsOneWidget);
    await app.dispose(tester);
  });
}
