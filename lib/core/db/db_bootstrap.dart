// Opens the two databases on app start.
//
// On first launch (or after an app update ships new Quran data) the bundled
// content database is copied from the app's assets into the app's data
// directory. The user database lives in a separate file and is never touched
// by that copy, so bookmarks and reading positions survive every data upgrade.
//
// Pure Dart: asset loading is injected, so this runs in plain unit tests.

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../quran/references.dart';
import 'content_db.dart';
import 'user_db.dart';

/// Loads a bundled asset's bytes (e.g. `rootBundle.load` in the app).
typedef AssetLoader = Future<Uint8List> Function(String key);

/// Thrown when the content database is missing, corrupt or incomplete.
class ContentDatabaseException implements Exception {
  ContentDatabaseException(this.message);
  final String message;

  @override
  String toString() => 'ContentDatabaseException: $message';
}

/// The version stamp shipped next to the bundled database.
class ContentManifest {
  const ContentManifest({
    required this.schemaVersion,
    required this.dataVersion,
  });

  factory ContentManifest.parse(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return ContentManifest(
      schemaVersion: map['schemaVersion'] as int,
      dataVersion: map['dataVersion'] as String,
    );
  }

  final int schemaVersion;
  final String dataVersion;
}

/// Both databases, open and verified.
class OpenedDatabases {
  const OpenedDatabases({
    required this.content,
    required this.user,
    required this.contentReplaced,
  });

  final ContentDatabase content;
  final UserDatabase user;

  /// True when the content file was (re)installed during this open, so
  /// downloaded translations must be re-imported into it.
  final bool contentReplaced;

  Future<void> close() async {
    await content.close();
    await user.close();
  }
}

class DbBootstrap {
  DbBootstrap({required this.loadAsset, required this.dataDirectory});

  static const contentAsset = 'assets/db/quran.db';
  static const manifestAsset = 'assets/db/manifest.json';

  final AssetLoader loadAsset;

  /// Where the databases live, e.g. the application-support directory.
  final Directory dataDirectory;

  File get contentFile => File(p.join(dataDirectory.path, 'quran.db'));
  File get _versionFile => File(p.join(dataDirectory.path, 'quran.db.version'));
  File get userFile => File(p.join(dataDirectory.path, 'user.db'));

  /// Opens both databases, installing the bundled content when needed.
  ///
  /// [forceContentReset] re-copies the content database from the assets; it is
  /// what the recovery screen's "Restore" button does.
  Future<OpenedDatabases> open({bool forceContentReset = false}) async {
    dataDirectory.createSync(recursive: true);
    final manifest = ContentManifest.parse(
      utf8.decode(await loadAsset(manifestAsset)),
    );

    var replaced = false;
    if (forceContentReset || _needsInstall(manifest)) {
      await _installContent(manifest);
      replaced = true;
    }

    ContentDatabase content;
    try {
      content = await _openVerified(manifest);
    } on Object {
      if (replaced) rethrow;
      // A damaged copy: restore it from the assets once, then give up.
      await _installContent(manifest);
      replaced = true;
      content = await _openVerified(manifest);
    }

    final user = UserDatabase(NativeDatabase.createInBackground(userFile));
    return OpenedDatabases(
      content: content,
      user: user,
      contentReplaced: replaced,
    );
  }

  bool _needsInstall(ContentManifest manifest) {
    if (!contentFile.existsSync() || !_versionFile.existsSync()) return true;
    return _versionFile.readAsStringSync().trim() != manifest.dataVersion;
  }

  /// Copies the bundled database atomically: write a temp file, then rename.
  Future<void> _installContent(ContentManifest manifest) async {
    final bytes = await loadAsset(contentAsset);
    final temp = File('${contentFile.path}.tmp');
    await temp.writeAsBytes(bytes, flush: true);

    for (final suffix in ['', '-journal', '-wal', '-shm']) {
      final stale = File('${contentFile.path}$suffix');
      if (stale.existsSync()) stale.deleteSync();
    }
    await temp.rename(contentFile.path);
    await _versionFile.writeAsString(manifest.dataVersion, flush: true);
  }

  /// Opens the content database and checks it is complete before use.
  Future<ContentDatabase> _openVerified(ContentManifest manifest) async {
    final db = ContentDatabase(NativeDatabase.createInBackground(contentFile));
    try {
      final count = await db.ayahTable.count().getSingle();
      if (count != totalAyahCount) {
        throw ContentDatabaseException(
          'expected $totalAyahCount ayat, found $count',
        );
      }
      final version = await db.metaValue(MetaKeys.dataVersion);
      if (version != manifest.dataVersion) {
        throw ContentDatabaseException(
          'data version $version != ${manifest.dataVersion}',
        );
      }
      return db;
    } on Object {
      await db.close();
      rethrow;
    }
  }
}
