import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/db/user_db.dart';
import 'package:quran_app/data/bookmark_repository.dart';
import 'package:quran_app/data/reading_position_repository.dart';
import 'package:quran_app/domain/models/bookmark.dart';

import '../helpers/test_databases.dart';

void main() {
  late UserDatabase db;
  late BookmarkRepository bookmarks;
  late ReadingPositionRepository positions;

  setUp(() {
    db = inMemoryUserDb();
    bookmarks = BookmarkRepository(db);
    positions = ReadingPositionRepository(db);
  });
  tearDown(() => db.close());

  group('bookmarks', () {
    test('toggle adds then removes', () async {
      expect(await bookmarks.toggle('2:255'), isTrue);
      expect(await bookmarks.isBookmarked('2:255'), isTrue);
      expect(await bookmarks.toggle('2:255'), isFalse);
      expect(await bookmarks.isBookmarked('2:255'), isFalse);
    });

    test('one bookmark per verse; invalid keys are rejected', () async {
      await bookmarks.toggle('1:1');
      await bookmarks.add(Bookmark(verseKey: '1:1', createdAt: DateTime(2020)));
      expect(await bookmarks.watchAll().first, hasLength(1));
      expect(
        () => bookmarks.add(
          Bookmark(verseKey: '2:300', createdAt: DateTime(2020)),
        ),
        throwsArgumentError,
      );
    });

    test('notes are set, trimmed and cleared', () async {
      await bookmarks.toggle('18:10');
      await bookmarks.setNote('18:10', '  cave  ');
      expect((await bookmarks.watchAll().first).single.note, 'cave');
      await bookmarks.setNote('18:10', '   ');
      expect((await bookmarks.watchAll().first).single.note, isNull);
    });

    test('newest first; removal then re-adding restores it (undo)', () async {
      final first = Bookmark(verseKey: '1:1', createdAt: DateTime(2024));
      await bookmarks.add(first);
      await bookmarks.add(
        Bookmark(verseKey: '2:255', createdAt: DateTime(2025)),
      );
      expect((await bookmarks.watchAll().first).map((b) => b.verseKey), [
        '2:255',
        '1:1',
      ]);
      await bookmarks.remove('1:1');
      await bookmarks.add(first);
      final restored = (await bookmarks.watchAll().first).last;
      expect(restored.verseKey, '1:1');
      expect(restored.createdAt, DateTime(2024));
    });

    test(
      'export and import round-trip, skipping duplicates and junk',
      () async {
        await bookmarks.add(
          Bookmark(
            verseKey: '2:255',
            createdAt: DateTime.utc(2025),
            note: 'kursi',
          ),
        );
        final json = await bookmarks.exportJson();

        final other = BookmarkRepository(inMemoryUserDb());
        expect(await other.importJson(json), 1);
        expect(await other.importJson(json), 0, reason: 'already present');
        final imported = (await other.watchAll().first).single;
        expect(imported.verseKey, '2:255');
        expect(imported.note, 'kursi');
        expect(imported.createdAt.toUtc(), DateTime.utc(2025));

        const mixed =
            '{"format":"${BookmarkRepository.exportFormat}","version":1,'
            '"bookmarks":[{"verseKey":"2:300"},{"verseKey":"1:1"},5]}';
        expect(await other.importJson(mixed), 1);
      },
    );

    test('import rejects anything that is not an export', () async {
      expect(() => bookmarks.importJson('not json'), throwsFormatException);
      expect(
        () => bookmarks.importJson('{"bookmarks":[]}'),
        throwsFormatException,
      );
    });

    test('bookmarks survive closing and reopening the database', () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final dir = await Directory.systemTemp.createTemp('quran_user_');
      final file = File('${dir.path}/user.db');

      final first = UserDatabase(NativeDatabase(file));
      await BookmarkRepository(first).toggle('36:1');
      await first.close();

      final reopened = UserDatabase(NativeDatabase(file));
      expect(await BookmarkRepository(reopened).isBookmarked('36:1'), isTrue);
      await reopened.close();
    });
  });

  group('reading positions', () {
    test('per surah and per juz, with a global most recent', () async {
      await positions.save(ReadingMode.surah, 18, '18:50');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await positions.save(ReadingMode.juz, 30, '78:5');

      expect(
        (await positions.position(ReadingMode.surah, 18))?.verseKey,
        '18:50',
      );
      final recent = await positions.watchMostRecent().first;
      expect(recent?.mode, ReadingMode.juz);
      expect(recent?.ref, 30);
      expect(await positions.watchJuzPositions().first, {30: '78:5'});
    });

    test('saving again moves the position; clear resets everything', () async {
      await positions.save(ReadingMode.surah, 2, '2:10');
      await positions.save(ReadingMode.surah, 2, '2:20');
      expect(
        (await positions.position(ReadingMode.surah, 2))?.verseKey,
        '2:20',
      );
      await positions.clear();
      expect(await positions.watchMostRecent().first, isNull);
    });
  });
}
