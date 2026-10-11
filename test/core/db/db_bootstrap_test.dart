import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/db/db_bootstrap.dart';
import 'package:quran_app/core/db/user_db.dart';

void main() {
  late Directory dataDir;
  late String manifestJson;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    dataDir = await Directory.systemTemp.createTemp('quran_bootstrap_');
    manifestJson = File('assets/db/manifest.json').readAsStringSync();
  });

  DbBootstrap bootstrap() => DbBootstrap(
    dataDirectory: dataDir,
    loadAsset: (key) async => key == DbBootstrap.manifestAsset
        ? Uint8List.fromList(utf8.encode(manifestJson))
        : File(key).readAsBytesSync(),
  );

  test('first open installs the bundled database', () async {
    final dbs = await bootstrap().open();
    expect(dbs.contentReplaced, isTrue);
    expect(await dbs.content.ayahTable.count().getSingle(), 6236);
    await dbs.close();
  });

  test('second open reuses the installed copy', () async {
    await (await bootstrap().open()).close();
    final dbs = await bootstrap().open();
    expect(dbs.contentReplaced, isFalse);
    await dbs.close();
  });

  test('a damaged copy is restored from the assets automatically', () async {
    await (await bootstrap().open()).close();
    File('${dataDir.path}/quran.db').writeAsStringSync('not a database');
    final dbs = await bootstrap().open();
    expect(dbs.contentReplaced, isTrue);
    expect(await dbs.content.ayahTable.count().getSingle(), 6236);
    await dbs.close();
  });

  test('a content upgrade never touches user data', () async {
    final first = await bootstrap().open();
    await first.user
        .into(first.user.bookmarkTable)
        .insert(
          BookmarkTableCompanion.insert(
            verseKey: '2:255',
            createdAt: DateTime(2026),
          ),
        );
    await first.close();

    // Simulate an app update that ships new data: the installed version no
    // longer matches, so the content database is replaced.
    File('${dataDir.path}/quran.db.version').writeAsStringSync('older-version');
    final second = await bootstrap().open();
    expect(second.contentReplaced, isTrue);
    final bookmarks = await second.user.select(second.user.bookmarkTable).get();
    expect(bookmarks.single.verseKey, '2:255');
    await second.close();
  });

  test('a forced reset reinstalls the content database', () async {
    await (await bootstrap().open()).close();
    final dbs = await bootstrap().open(forceContentReset: true);
    expect(dbs.contentReplaced, isTrue);
    await dbs.close();
  });
}
