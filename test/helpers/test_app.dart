import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/app.dart';
import 'package:quran_app/core/db/content_db.dart';
import 'package:quran_app/core/db/user_db.dart';
import 'package:quran_app/data/daily_content_repository.dart';
import 'package:quran_app/features/daily/daily_providers.dart';
import 'package:quran_app/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_databases.dart';

/// The real app, wired to a private copy of the bundled content database and
/// an in-memory user database.
///
/// The clock is pinned, so the home screen's daily card shows the same entry
/// whatever day the tests run.
class TestApp {
  /// An ordinary weekday: not a Friday, and not in Ramadan or Dhu al-Hijjah.
  static final defaultNow = DateTime(2026, 1, 5, 9);

  TestApp._(this.content, this.user);

  final ContentDatabase content;
  final UserDatabase user;

  /// Pumps the app at [location] and waits until it has finished loading.
  static Future<TestApp> pump(
    WidgetTester tester, {
    String location = '/',
    Map<String, Object> prefs = const {},
    Size size = const Size(420, 900),
    DateTime? now,
    List<Override> overrides = const [],
  }) async {
    tester.view.physicalSize = size * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);

    final content = (await tester.runAsync(openBundledContentDb))!;
    final user = inMemoryUserDb();
    SharedPreferences.setMockInitialValues(prefs);
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          contentDatabaseProvider.overrideWithValue(content),
          userDatabaseProvider.overrideWithValue(user),
          translationStoreDirectoryProvider.overrideWithValue(
            Directory.systemTemp.createTempSync('quran_translations_'),
          ),
          audioStoreDirectoryProvider.overrideWithValue(
            Directory.systemTemp.createTempSync('quran_audio_'),
          ),
          clockProvider.overrideWithValue(() => now ?? defaultNow),
          // A bundle per app: rootBundle caches each asset's Future, and one
          // completed inside an earlier test's zone never resolves in a later
          // test.
          dailyContentRepositoryProvider.overrideWithValue(
            DailyContentRepository(PlatformAssetBundle()),
          ),
          ...overrides,
        ],
        child: QuranApp(initialLocation: location),
      ),
    );
    final app = TestApp._(content, user);
    await app.settle(tester);
    return app;
  }

  /// Lets database futures and animations finish.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }

  /// Unmounts the app and closes the databases (call at the end of a test).
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    await tester.runAsync(() async {
      await content.close();
      await user.close();
    });
  }
}
