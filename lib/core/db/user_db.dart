// The user's own data: bookmarks and reading positions.
//
// Deliberately a separate SQLite file from the Quran content, so replacing the
// content database on a data upgrade can never touch anything the user made.
//
// Pure Dart (no Flutter imports).

import 'package:drift/drift.dart';

part 'user_db.g.dart';

@DataClassName('BookmarkRow')
class BookmarkTable extends Table {
  @override
  String get tableName => 'bookmark';

  IntColumn get id => integer().autoIncrement()();

  /// One bookmark per verse.
  TextColumn get verseKey => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get note => text().nullable()();
}

@DataClassName('ReadingPositionRow')
class ReadingPositionTable extends Table {
  @override
  String get tableName => 'reading_position';

  /// 'surah' | 'juz'
  TextColumn get mode => text()();

  /// The surah or juz number, as text so other modes (e.g. page) fit later.
  TextColumn get ref => text()();

  TextColumn get verseKey => text()();

  /// Milliseconds since the epoch. Millisecond precision matters: switching
  /// between surah and juz mode saves two positions within the same second,
  /// and the most recent one must win.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {mode, ref};
}

@DriftDatabase(tables: [BookmarkTable, ReadingPositionTable])
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());
}
