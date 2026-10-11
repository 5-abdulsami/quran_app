import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:quran_app/core/db/content_db.dart';
import 'package:quran_app/core/db/user_db.dart';

/// Path of the bundled content database, relative to the package root.
const bundledContentDbPath = 'assets/db/quran.db';

/// Opens a private copy of the bundled content database, so no test can ever
/// modify the shipped asset.
Future<ContentDatabase> openBundledContentDb() async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final dir = await Directory.systemTemp.createTemp('quran_content_');
  final copy = await File(
    bundledContentDbPath,
  ).copy(p.join(dir.path, 'quran.db'));
  return ContentDatabase(NativeDatabase(copy));
}

/// A fresh, empty user database in memory.
UserDatabase inMemoryUserDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return UserDatabase(NativeDatabase.memory());
}
