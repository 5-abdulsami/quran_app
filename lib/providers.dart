// App-wide dependency providers.
//
// The databases and SharedPreferences are opened once during bootstrap (see
// core/db/db_bootstrap.dart) and injected here with `overrideWithValue`, so
// every repository below is synchronous to obtain and trivially fakeable in
// tests.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/db/content_db.dart';
import 'core/db/user_db.dart';
import 'data/settings_repository.dart';

/// Overridden in `main` once preferences are loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

/// The Quran content database. Overridden after bootstrap.
final contentDatabaseProvider = Provider<ContentDatabase>(
  (ref) => throw UnimplementedError('contentDatabaseProvider not overridden'),
);

/// The user's bookmarks and reading positions. Overridden after bootstrap.
final userDatabaseProvider = Provider<UserDatabase>(
  (ref) => throw UnimplementedError('userDatabaseProvider not overridden'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);
