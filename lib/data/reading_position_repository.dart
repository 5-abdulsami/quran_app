import 'package:drift/drift.dart';

import '../core/db/user_db.dart';
import '../domain/models/bookmark.dart';

/// Where the reader stopped, per surah and per juz.
///
/// The most recently updated row across both modes is the global "continue
/// reading" position.
class ReadingPositionRepository {
  ReadingPositionRepository(this._db);

  final UserDatabase _db;

  Future<void> save(ReadingMode mode, int ref, String verseKey) => _db
      .into(_db.readingPositionTable)
      .insertOnConflictUpdate(
        ReadingPositionTableCompanion.insert(
          mode: mode.name,
          ref: '$ref',
          verseKey: verseKey,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  Future<ReadingPosition?> position(ReadingMode mode, int ref) async {
    final row =
        await (_db.select(_db.readingPositionTable)
              ..where((t) => t.mode.equals(mode.name) & t.ref.equals('$ref')))
            .getSingleOrNull();
    return row == null ? null : _toPosition(row);
  }

  /// The global most recent position, for "Continue reading".
  Stream<ReadingPosition?> watchMostRecent() =>
      (_db.select(_db.readingPositionTable)
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
            ..limit(1))
          .watchSingleOrNull()
          .map((row) => row == null ? null : _toPosition(row));

  /// Last-read verse per juz, for the juz index's progress indicator.
  Stream<Map<int, String>> watchJuzPositions() =>
      (_db.select(
        _db.readingPositionTable,
      )..where((t) => t.mode.equals(ReadingMode.juz.name))).watch().map(
        (rows) => {for (final r in rows) ?int.tryParse(r.ref): r.verseKey},
      );

  /// Clears every saved position ("Reset reading progress").
  Future<void> clear() => _db.delete(_db.readingPositionTable).go();

  static ReadingPosition? _toPosition(ReadingPositionRow r) {
    final mode = ReadingMode.values.where((m) => m.name == r.mode).firstOrNull;
    final ref = int.tryParse(r.ref);
    if (mode == null || ref == null) return null;
    return ReadingPosition(
      mode: mode,
      ref: ref,
      verseKey: r.verseKey,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(r.updatedAt),
    );
  }
}
