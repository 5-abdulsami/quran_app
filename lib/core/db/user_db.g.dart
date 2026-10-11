// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_db.dart';

// ignore_for_file: type=lint
class $BookmarkTableTable extends BookmarkTable
    with TableInfo<$BookmarkTableTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _verseKeyMeta = const VerificationMeta(
    'verseKey',
  );
  @override
  late final GeneratedColumn<String> verseKey = GeneratedColumn<String>(
    'verse_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, verseKey, createdAt, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmark';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('verse_key')) {
      context.handle(
        _verseKeyMeta,
        verseKey.isAcceptableOrUnknown(data['verse_key']!, _verseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_verseKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      verseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verse_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $BookmarkTableTable createAlias(String alias) {
    return $BookmarkTableTable(attachedDatabase, alias);
  }
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final int id;

  /// One bookmark per verse.
  final String verseKey;
  final DateTime createdAt;
  final String? note;
  const BookmarkRow({
    required this.id,
    required this.verseKey,
    required this.createdAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['verse_key'] = Variable<String>(verseKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  BookmarkTableCompanion toCompanion(bool nullToAbsent) {
    return BookmarkTableCompanion(
      id: Value(id),
      verseKey: Value(verseKey),
      createdAt: Value(createdAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory BookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      id: serializer.fromJson<int>(json['id']),
      verseKey: serializer.fromJson<String>(json['verseKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'verseKey': serializer.toJson<String>(verseKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  BookmarkRow copyWith({
    int? id,
    String? verseKey,
    DateTime? createdAt,
    Value<String?> note = const Value.absent(),
  }) => BookmarkRow(
    id: id ?? this.id,
    verseKey: verseKey ?? this.verseKey,
    createdAt: createdAt ?? this.createdAt,
    note: note.present ? note.value : this.note,
  );
  BookmarkRow copyWithCompanion(BookmarkTableCompanion data) {
    return BookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      verseKey: data.verseKey.present ? data.verseKey.value : this.verseKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('id: $id, ')
          ..write('verseKey: $verseKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, verseKey, createdAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.id == this.id &&
          other.verseKey == this.verseKey &&
          other.createdAt == this.createdAt &&
          other.note == this.note);
}

class BookmarkTableCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<int> id;
  final Value<String> verseKey;
  final Value<DateTime> createdAt;
  final Value<String?> note;
  const BookmarkTableCompanion({
    this.id = const Value.absent(),
    this.verseKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.note = const Value.absent(),
  });
  BookmarkTableCompanion.insert({
    this.id = const Value.absent(),
    required String verseKey,
    required DateTime createdAt,
    this.note = const Value.absent(),
  }) : verseKey = Value(verseKey),
       createdAt = Value(createdAt);
  static Insertable<BookmarkRow> custom({
    Expression<int>? id,
    Expression<String>? verseKey,
    Expression<DateTime>? createdAt,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (verseKey != null) 'verse_key': verseKey,
      if (createdAt != null) 'created_at': createdAt,
      if (note != null) 'note': note,
    });
  }

  BookmarkTableCompanion copyWith({
    Value<int>? id,
    Value<String>? verseKey,
    Value<DateTime>? createdAt,
    Value<String?>? note,
  }) {
    return BookmarkTableCompanion(
      id: id ?? this.id,
      verseKey: verseKey ?? this.verseKey,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (verseKey.present) {
      map['verse_key'] = Variable<String>(verseKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkTableCompanion(')
          ..write('id: $id, ')
          ..write('verseKey: $verseKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $ReadingPositionTableTable extends ReadingPositionTable
    with TableInfo<$ReadingPositionTableTable, ReadingPositionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingPositionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseKeyMeta = const VerificationMeta(
    'verseKey',
  );
  @override
  late final GeneratedColumn<String> verseKey = GeneratedColumn<String>(
    'verse_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [mode, ref, verseKey, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_position';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingPositionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    } else if (isInserting) {
      context.missing(_refMeta);
    }
    if (data.containsKey('verse_key')) {
      context.handle(
        _verseKeyMeta,
        verseKey.isAcceptableOrUnknown(data['verse_key']!, _verseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_verseKeyMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mode, ref};
  @override
  ReadingPositionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingPositionRow(
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      )!,
      verseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verse_key'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReadingPositionTableTable createAlias(String alias) {
    return $ReadingPositionTableTable(attachedDatabase, alias);
  }
}

class ReadingPositionRow extends DataClass
    implements Insertable<ReadingPositionRow> {
  /// 'surah' | 'juz'
  final String mode;

  /// The surah or juz number, as text so other modes (e.g. page) fit later.
  final String ref;
  final String verseKey;
  final DateTime updatedAt;
  const ReadingPositionRow({
    required this.mode,
    required this.ref,
    required this.verseKey,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mode'] = Variable<String>(mode);
    map['ref'] = Variable<String>(ref);
    map['verse_key'] = Variable<String>(verseKey);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingPositionTableCompanion toCompanion(bool nullToAbsent) {
    return ReadingPositionTableCompanion(
      mode: Value(mode),
      ref: Value(ref),
      verseKey: Value(verseKey),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingPositionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingPositionRow(
      mode: serializer.fromJson<String>(json['mode']),
      ref: serializer.fromJson<String>(json['ref']),
      verseKey: serializer.fromJson<String>(json['verseKey']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mode': serializer.toJson<String>(mode),
      'ref': serializer.toJson<String>(ref),
      'verseKey': serializer.toJson<String>(verseKey),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingPositionRow copyWith({
    String? mode,
    String? ref,
    String? verseKey,
    DateTime? updatedAt,
  }) => ReadingPositionRow(
    mode: mode ?? this.mode,
    ref: ref ?? this.ref,
    verseKey: verseKey ?? this.verseKey,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReadingPositionRow copyWithCompanion(ReadingPositionTableCompanion data) {
    return ReadingPositionRow(
      mode: data.mode.present ? data.mode.value : this.mode,
      ref: data.ref.present ? data.ref.value : this.ref,
      verseKey: data.verseKey.present ? data.verseKey.value : this.verseKey,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPositionRow(')
          ..write('mode: $mode, ')
          ..write('ref: $ref, ')
          ..write('verseKey: $verseKey, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mode, ref, verseKey, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingPositionRow &&
          other.mode == this.mode &&
          other.ref == this.ref &&
          other.verseKey == this.verseKey &&
          other.updatedAt == this.updatedAt);
}

class ReadingPositionTableCompanion
    extends UpdateCompanion<ReadingPositionRow> {
  final Value<String> mode;
  final Value<String> ref;
  final Value<String> verseKey;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReadingPositionTableCompanion({
    this.mode = const Value.absent(),
    this.ref = const Value.absent(),
    this.verseKey = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingPositionTableCompanion.insert({
    required String mode,
    required String ref,
    required String verseKey,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : mode = Value(mode),
       ref = Value(ref),
       verseKey = Value(verseKey),
       updatedAt = Value(updatedAt);
  static Insertable<ReadingPositionRow> custom({
    Expression<String>? mode,
    Expression<String>? ref,
    Expression<String>? verseKey,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mode != null) 'mode': mode,
      if (ref != null) 'ref': ref,
      if (verseKey != null) 'verse_key': verseKey,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingPositionTableCompanion copyWith({
    Value<String>? mode,
    Value<String>? ref,
    Value<String>? verseKey,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReadingPositionTableCompanion(
      mode: mode ?? this.mode,
      ref: ref ?? this.ref,
      verseKey: verseKey ?? this.verseKey,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (verseKey.present) {
      map['verse_key'] = Variable<String>(verseKey.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPositionTableCompanion(')
          ..write('mode: $mode, ')
          ..write('ref: $ref, ')
          ..write('verseKey: $verseKey, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDatabase extends GeneratedDatabase {
  _$UserDatabase(QueryExecutor e) : super(e);
  $UserDatabaseManager get managers => $UserDatabaseManager(this);
  late final $BookmarkTableTable bookmarkTable = $BookmarkTableTable(this);
  late final $ReadingPositionTableTable readingPositionTable =
      $ReadingPositionTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookmarkTable,
    readingPositionTable,
  ];
}

typedef $$BookmarkTableTableCreateCompanionBuilder =
    BookmarkTableCompanion Function({
      Value<int> id,
      required String verseKey,
      required DateTime createdAt,
      Value<String?> note,
    });
typedef $$BookmarkTableTableUpdateCompanionBuilder =
    BookmarkTableCompanion Function({
      Value<int> id,
      Value<String> verseKey,
      Value<DateTime> createdAt,
      Value<String?> note,
    });

class $$BookmarkTableTableFilterComposer
    extends Composer<_$UserDatabase, $BookmarkTableTable> {
  $$BookmarkTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarkTableTableOrderingComposer
    extends Composer<_$UserDatabase, $BookmarkTableTable> {
  $$BookmarkTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarkTableTableAnnotationComposer
    extends Composer<_$UserDatabase, $BookmarkTableTable> {
  $$BookmarkTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get verseKey =>
      $composableBuilder(column: $table.verseKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$BookmarkTableTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $BookmarkTableTable,
          BookmarkRow,
          $$BookmarkTableTableFilterComposer,
          $$BookmarkTableTableOrderingComposer,
          $$BookmarkTableTableAnnotationComposer,
          $$BookmarkTableTableCreateCompanionBuilder,
          $$BookmarkTableTableUpdateCompanionBuilder,
          (
            BookmarkRow,
            BaseReferences<_$UserDatabase, $BookmarkTableTable, BookmarkRow>,
          ),
          BookmarkRow,
          PrefetchHooks Function()
        > {
  $$BookmarkTableTableTableManager(_$UserDatabase db, $BookmarkTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> verseKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => BookmarkTableCompanion(
                id: id,
                verseKey: verseKey,
                createdAt: createdAt,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String verseKey,
                required DateTime createdAt,
                Value<String?> note = const Value.absent(),
              }) => BookmarkTableCompanion.insert(
                id: id,
                verseKey: verseKey,
                createdAt: createdAt,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarkTableTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $BookmarkTableTable,
      BookmarkRow,
      $$BookmarkTableTableFilterComposer,
      $$BookmarkTableTableOrderingComposer,
      $$BookmarkTableTableAnnotationComposer,
      $$BookmarkTableTableCreateCompanionBuilder,
      $$BookmarkTableTableUpdateCompanionBuilder,
      (
        BookmarkRow,
        BaseReferences<_$UserDatabase, $BookmarkTableTable, BookmarkRow>,
      ),
      BookmarkRow,
      PrefetchHooks Function()
    >;
typedef $$ReadingPositionTableTableCreateCompanionBuilder =
    ReadingPositionTableCompanion Function({
      required String mode,
      required String ref,
      required String verseKey,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ReadingPositionTableTableUpdateCompanionBuilder =
    ReadingPositionTableCompanion Function({
      Value<String> mode,
      Value<String> ref,
      Value<String> verseKey,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ReadingPositionTableTableFilterComposer
    extends Composer<_$UserDatabase, $ReadingPositionTableTable> {
  $$ReadingPositionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingPositionTableTableOrderingComposer
    extends Composer<_$UserDatabase, $ReadingPositionTableTable> {
  $$ReadingPositionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingPositionTableTableAnnotationComposer
    extends Composer<_$UserDatabase, $ReadingPositionTableTable> {
  $$ReadingPositionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get verseKey =>
      $composableBuilder(column: $table.verseKey, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReadingPositionTableTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $ReadingPositionTableTable,
          ReadingPositionRow,
          $$ReadingPositionTableTableFilterComposer,
          $$ReadingPositionTableTableOrderingComposer,
          $$ReadingPositionTableTableAnnotationComposer,
          $$ReadingPositionTableTableCreateCompanionBuilder,
          $$ReadingPositionTableTableUpdateCompanionBuilder,
          (
            ReadingPositionRow,
            BaseReferences<
              _$UserDatabase,
              $ReadingPositionTableTable,
              ReadingPositionRow
            >,
          ),
          ReadingPositionRow,
          PrefetchHooks Function()
        > {
  $$ReadingPositionTableTableTableManager(
    _$UserDatabase db,
    $ReadingPositionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingPositionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingPositionTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReadingPositionTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mode = const Value.absent(),
                Value<String> ref = const Value.absent(),
                Value<String> verseKey = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingPositionTableCompanion(
                mode: mode,
                ref: ref,
                verseKey: verseKey,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mode,
                required String ref,
                required String verseKey,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReadingPositionTableCompanion.insert(
                mode: mode,
                ref: ref,
                verseKey: verseKey,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingPositionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $ReadingPositionTableTable,
      ReadingPositionRow,
      $$ReadingPositionTableTableFilterComposer,
      $$ReadingPositionTableTableOrderingComposer,
      $$ReadingPositionTableTableAnnotationComposer,
      $$ReadingPositionTableTableCreateCompanionBuilder,
      $$ReadingPositionTableTableUpdateCompanionBuilder,
      (
        ReadingPositionRow,
        BaseReferences<
          _$UserDatabase,
          $ReadingPositionTableTable,
          ReadingPositionRow
        >,
      ),
      ReadingPositionRow,
      PrefetchHooks Function()
    >;

class $UserDatabaseManager {
  final _$UserDatabase _db;
  $UserDatabaseManager(this._db);
  $$BookmarkTableTableTableManager get bookmarkTable =>
      $$BookmarkTableTableTableManager(_db, _db.bookmarkTable);
  $$ReadingPositionTableTableTableManager get readingPositionTable =>
      $$ReadingPositionTableTableTableManager(_db, _db.readingPositionTable);
}
