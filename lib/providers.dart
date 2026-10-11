// App-wide dependency providers.
//
// The databases and SharedPreferences are opened once during bootstrap (see
// features/bootstrap/app_bootstrap.dart) and injected with
// `overrideWithValue`, so every repository below is synchronous to obtain and
// trivially replaceable in tests.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/db/content_db.dart';
import 'core/db/user_db.dart';
import 'core/quran/references.dart';
import 'data/bookmark_repository.dart';
import 'data/quran_repository.dart';
import 'data/reading_position_repository.dart';
import 'data/settings_repository.dart';
import 'domain/models/juz.dart';
import 'domain/models/surah.dart';
import 'domain/models/translation_edition.dart';

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

// --- Repositories -------------------------------------------------------------

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final quranRepositoryProvider = Provider<QuranRepository>(
  (ref) => QuranRepository(ref.watch(contentDatabaseProvider)),
);

final bookmarkRepositoryProvider = Provider<BookmarkRepository>(
  (ref) => BookmarkRepository(ref.watch(userDatabaseProvider)),
);

final readingPositionRepositoryProvider = Provider<ReadingPositionRepository>(
  (ref) => ReadingPositionRepository(ref.watch(userDatabaseProvider)),
);

// --- Shared read models -------------------------------------------------------

/// All 114 surahs, in mushaf order.
final surahsProvider = FutureProvider<List<Surah>>(
  (ref) => ref.watch(quranRepositoryProvider).surahs(),
);

/// All 30 juz.
final juzsProvider = FutureProvider<List<Juz>>(
  (ref) => ref.watch(quranRepositoryProvider).juzs(),
);

/// Installed translations. Invalidate after a download or deletion.
final editionsProvider = FutureProvider<List<TranslationEdition>>(
  (ref) => ref.watch(quranRepositoryProvider).editions(),
);

/// Loose surah-name matching built from the database's own names.
final surahNameIndexProvider = FutureProvider<SurahNameIndex>((ref) async {
  final surahs = await ref.watch(surahsProvider.future);
  return SurahNameIndex({
    for (final s in surahs) s.number: [s.nameSimple, s.nameArabic],
  });
});

/// Verse keys the reader has bookmarked, kept live.
final bookmarkedKeysProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(bookmarkRepositoryProvider).watchKeys(),
);
