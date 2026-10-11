// App-wide dependency providers.
//
// The databases and SharedPreferences are opened once during bootstrap (see
// core/db/db_bootstrap.dart) and injected here with `overrideWithValue`, so
// every repository below is synchronous to obtain and trivially fakeable in
// tests.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/settings_repository.dart';

/// Overridden in `main` once preferences are loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);
