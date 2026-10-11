// The Quran content database.
//
// Mirrors islamic-platform/src/db/schema/quran.ts, adapted to SQLite. It is
// generated at build time by tool/build_quran_db.dart (which creates it through
// this very class, so the schema can never drift between the two) and shipped
// as assets/db/quran.db.
//
// At runtime it is read-only apart from optional downloaded translations.
// Nothing user-owned lives here: bookmarks and reading positions are in
// UserDatabase, so replacing this file on a data upgrade cannot touch them.
//
// Pure Dart (no Flutter imports) so the build tool can use it.

import 'package:drift/drift.dart';

part 'content_db.g.dart';

@DataClassName('SurahRow')
class SurahTable extends Table {
  @override
  String get tableName => 'surah';

  IntColumn get number => integer()();
  TextColumn get nameArabic => text()();
  TextColumn get nameSimple => text()();
  TextColumn get nameTranslated => text()();

  /// 'makkah' | 'madinah'
  TextColumn get revelationPlace => text()();

  /// Not published by AlQuran.cloud, so null rather than guessed.
  IntColumn get revelationOrder => integer().nullable()();
  IntColumn get ayahCount => integer()();

  /// `number != 1 && number != 9`: a structural fact about the mushaf.
  BoolColumn get bismillahPre => boolean()();
  IntColumn get pageStart => integer()();
  IntColumn get pageEnd => integer()();

  @override
  Set<Column<Object>> get primaryKey => {number};
}

@DataClassName('AyahRow')
@TableIndex(name: 'ayah_surah_ayah_idx', columns: {#surahNumber, #ayahNumber})
@TableIndex(name: 'ayah_juz_idx', columns: {#juz})
@TableIndex(name: 'ayah_page_idx', columns: {#page})
class AyahTable extends Table {
  @override
  String get tableName => 'ayah';

  /// Mushaf-wide index, 1..6236.
  IntColumn get id => integer()();
  IntColumn get surahNumber => integer().references(SurahTable, #number)();
  IntColumn get ayahNumber => integer()();

  /// "2:255" — the canonical citation key.
  TextColumn get verseKey => text().unique()();

  /// The verse exactly as the source supplied it (after sanitizeSourceText).
  /// Never modified and never normalised.
  TextColumn get textUthmani => text()();

  /// normalizeForSearch(textUthmani); used only for matching, never rendered.
  TextColumn get textSearch => text()();

  IntColumn get juz => integer()();
  IntColumn get hizb => integer()();
  IntColumn get rubElHizb => integer()();
  IntColumn get ruku => integer()();
  IntColumn get manzil => integer()();
  IntColumn get page => integer()();

  /// null | 'recommended' | 'obligatory'
  TextColumn get sajdahType => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TranslationEditionRow')
class TranslationEditionTable extends Table {
  @override
  String get tableName => 'translation_edition';

  /// AlQuran.cloud identifier, e.g. 'en.sahih'.
  TextColumn get id => text()();
  TextColumn get language => text()();

  /// Edition title (AlQuran.cloud `englishName`).
  TextColumn get name => text()();

  /// Translator credit (AlQuran.cloud `name`).
  TextColumn get translator => text()();

  /// 'ltr' | 'rtl'
  TextColumn get direction => text()();

  /// Licence-required credit, from attributionForTranslation.
  TextColumn get attribution => text()();

  /// Shipped with the app (cannot be deleted) vs downloaded at runtime.
  BoolColumn get bundled => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TranslationRow')
class TranslationTable extends Table {
  @override
  String get tableName => 'translation';

  TextColumn get editionId => text().references(TranslationEditionTable, #id)();
  IntColumn get ayahId => integer().references(AyahTable, #id)();

  /// The translation text (SQL column `text`; `text` is reserved in drift's
  /// table DSL, hence the getter name).
  TextColumn get body => text().named('text')();

  /// normalizeForSearch(text); used only for matching, never rendered.
  TextColumn get textSearch => text()();

  @override
  Set<Column<Object>> get primaryKey => {editionId, ayahId};
}

@DataClassName('JuzRow')
class JuzTable extends Table {
  @override
  String get tableName => 'juz';

  IntColumn get number => integer()();

  /// Boundaries are computed from the ayah data, never typed in.
  TextColumn get firstVerseKey => text()();
  TextColumn get lastVerseKey => text()();

  /// Traditional names. Labels only.
  TextColumn get nameArabic => text()();
  TextColumn get nameTransliterated => text()();

  @override
  Set<Column<Object>> get primaryKey => {number};
}

@DataClassName('MetaRow')
class MetaTable extends Table {
  @override
  String get tableName => 'meta';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Keys of the `meta` table.
abstract final class MetaKeys {
  static const schemaVersion = 'schema_version';
  static const dataVersion = 'data_version';
  static const buildDate = 'build_date';
  static const arabicEdition = 'arabic_edition';
  static const translationEditions = 'translation_editions';
  static const source = 'source';
}

@DriftDatabase(
  tables: [
    SurahTable,
    AyahTable,
    TranslationEditionTable,
    TranslationTable,
    JuzTable,
    MetaTable,
  ],
)
class ContentDatabase extends _$ContentDatabase {
  ContentDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Reads one value from the `meta` table.
  Future<String?> metaValue(String key) async {
    final row = await (select(
      metaTable,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }
}
