import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/db/user_db.dart';
import '../core/quran/references.dart';
import '../domain/models/bookmark.dart';

/// Bookmarks, one per verse, stored in the user database.
class BookmarkRepository {
  BookmarkRepository(this._db);

  final UserDatabase _db;

  /// Format marker written into exports and required on import.
  static const exportFormat = 'islamindex-quran-bookmarks';
  static const exportVersion = 1;

  /// All bookmarks, newest first.
  Stream<List<Bookmark>> watchAll() =>
      (_db.select(_db.bookmarkTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch()
          .map((rows) => rows.map(_toBookmark).toList());

  /// The set of bookmarked verse keys, for marking tiles.
  Stream<Set<String>> watchKeys() => _db
      .select(_db.bookmarkTable)
      .watch()
      .map((rows) => {for (final r in rows) r.verseKey});

  Future<bool> isBookmarked(String verseKey) async =>
      await (_db.select(
        _db.bookmarkTable,
      )..where((t) => t.verseKey.equals(verseKey))).getSingleOrNull() !=
      null;

  /// Adds or removes the bookmark; returns true when it is now bookmarked.
  Future<bool> toggle(String verseKey) async {
    if (await isBookmarked(verseKey)) {
      await remove(verseKey);
      return false;
    }
    await add(Bookmark(verseKey: verseKey, createdAt: DateTime.now()));
    return true;
  }

  /// Inserts [bookmark], keeping an existing one for the same verse.
  Future<void> add(Bookmark bookmark) async {
    if (parseVerseKey(bookmark.verseKey) == null) {
      throw ArgumentError.value(bookmark.verseKey, 'verseKey');
    }
    await _db
        .into(_db.bookmarkTable)
        .insert(
          BookmarkTableCompanion.insert(
            verseKey: bookmark.verseKey,
            createdAt: bookmark.createdAt,
            note: Value(bookmark.note),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> remove(String verseKey) => (_db.delete(
    _db.bookmarkTable,
  )..where((t) => t.verseKey.equals(verseKey))).go();

  /// Sets or clears (empty / null) the note on a bookmark.
  Future<void> setNote(String verseKey, String? note) {
    final trimmed = note?.trim();
    return (_db.update(
      _db.bookmarkTable,
    )..where((t) => t.verseKey.equals(verseKey))).write(
      BookmarkTableCompanion(
        note: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
      ),
    );
  }

  /// All bookmarks as a JSON document.
  Future<String> exportJson() async {
    final rows = await _db.select(_db.bookmarkTable).get();
    return const JsonEncoder.withIndent('  ').convert({
      'format': exportFormat,
      'version': exportVersion,
      'bookmarks': [for (final r in rows) _toBookmark(r).toJson()],
    });
  }

  /// Imports bookmarks from [exportJson] output. Existing bookmarks are kept;
  /// invalid entries are skipped. Returns the number newly added. Throws
  /// [FormatException] when the document is not a bookmarks export.
  Future<int> importJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic> || decoded['format'] != exportFormat) {
      throw const FormatException('Not a bookmarks export');
    }
    final entries = decoded['bookmarks'];
    if (entries is! List<dynamic>) {
      throw const FormatException('Not a bookmarks export');
    }

    var added = 0;
    await _db.transaction(() async {
      for (final entry in entries) {
        if (entry is! Map<String, dynamic>) continue;
        final key = entry['verseKey'];
        if (key is! String || parseVerseKey(key) == null) continue;
        if (await isBookmarked(key)) continue;
        final created = DateTime.tryParse('${entry['createdAt']}');
        final note = entry['note'];
        await add(
          Bookmark(
            verseKey: key,
            createdAt: created?.toLocal() ?? DateTime.now(),
            note: note is String ? note : null,
          ),
        );
        added++;
      }
    });
    return added;
  }

  static Bookmark _toBookmark(BookmarkRow r) =>
      Bookmark(verseKey: r.verseKey, createdAt: r.createdAt, note: r.note);
}
