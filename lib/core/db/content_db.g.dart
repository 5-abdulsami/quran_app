// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_db.dart';

// ignore_for_file: type=lint
class $SurahTableTable extends SurahTable
    with TableInfo<$SurahTableTable, SurahRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameArabicMeta = const VerificationMeta(
    'nameArabic',
  );
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
    'name_arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameSimpleMeta = const VerificationMeta(
    'nameSimple',
  );
  @override
  late final GeneratedColumn<String> nameSimple = GeneratedColumn<String>(
    'name_simple',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameTranslatedMeta = const VerificationMeta(
    'nameTranslated',
  );
  @override
  late final GeneratedColumn<String> nameTranslated = GeneratedColumn<String>(
    'name_translated',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revelationPlaceMeta = const VerificationMeta(
    'revelationPlace',
  );
  @override
  late final GeneratedColumn<String> revelationPlace = GeneratedColumn<String>(
    'revelation_place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revelationOrderMeta = const VerificationMeta(
    'revelationOrder',
  );
  @override
  late final GeneratedColumn<int> revelationOrder = GeneratedColumn<int>(
    'revelation_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ayahCountMeta = const VerificationMeta(
    'ayahCount',
  );
  @override
  late final GeneratedColumn<int> ayahCount = GeneratedColumn<int>(
    'ayah_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bismillahPreMeta = const VerificationMeta(
    'bismillahPre',
  );
  @override
  late final GeneratedColumn<bool> bismillahPre = GeneratedColumn<bool>(
    'bismillah_pre',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bismillah_pre" IN (0, 1))',
    ),
  );
  static const VerificationMeta _pageStartMeta = const VerificationMeta(
    'pageStart',
  );
  @override
  late final GeneratedColumn<int> pageStart = GeneratedColumn<int>(
    'page_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageEndMeta = const VerificationMeta(
    'pageEnd',
  );
  @override
  late final GeneratedColumn<int> pageEnd = GeneratedColumn<int>(
    'page_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    number,
    nameArabic,
    nameSimple,
    nameTranslated,
    revelationPlace,
    revelationOrder,
    ayahCount,
    bismillahPre,
    pageStart,
    pageEnd,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surah';
  @override
  VerificationContext validateIntegrity(
    Insertable<SurahRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
        _nameArabicMeta,
        nameArabic.isAcceptableOrUnknown(data['name_arabic']!, _nameArabicMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('name_simple')) {
      context.handle(
        _nameSimpleMeta,
        nameSimple.isAcceptableOrUnknown(data['name_simple']!, _nameSimpleMeta),
      );
    } else if (isInserting) {
      context.missing(_nameSimpleMeta);
    }
    if (data.containsKey('name_translated')) {
      context.handle(
        _nameTranslatedMeta,
        nameTranslated.isAcceptableOrUnknown(
          data['name_translated']!,
          _nameTranslatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameTranslatedMeta);
    }
    if (data.containsKey('revelation_place')) {
      context.handle(
        _revelationPlaceMeta,
        revelationPlace.isAcceptableOrUnknown(
          data['revelation_place']!,
          _revelationPlaceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revelationPlaceMeta);
    }
    if (data.containsKey('revelation_order')) {
      context.handle(
        _revelationOrderMeta,
        revelationOrder.isAcceptableOrUnknown(
          data['revelation_order']!,
          _revelationOrderMeta,
        ),
      );
    }
    if (data.containsKey('ayah_count')) {
      context.handle(
        _ayahCountMeta,
        ayahCount.isAcceptableOrUnknown(data['ayah_count']!, _ayahCountMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahCountMeta);
    }
    if (data.containsKey('bismillah_pre')) {
      context.handle(
        _bismillahPreMeta,
        bismillahPre.isAcceptableOrUnknown(
          data['bismillah_pre']!,
          _bismillahPreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bismillahPreMeta);
    }
    if (data.containsKey('page_start')) {
      context.handle(
        _pageStartMeta,
        pageStart.isAcceptableOrUnknown(data['page_start']!, _pageStartMeta),
      );
    } else if (isInserting) {
      context.missing(_pageStartMeta);
    }
    if (data.containsKey('page_end')) {
      context.handle(
        _pageEndMeta,
        pageEnd.isAcceptableOrUnknown(data['page_end']!, _pageEndMeta),
      );
    } else if (isInserting) {
      context.missing(_pageEndMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  SurahRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurahRow(
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      nameArabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_arabic'],
      )!,
      nameSimple: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_simple'],
      )!,
      nameTranslated: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_translated'],
      )!,
      revelationPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revelation_place'],
      )!,
      revelationOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revelation_order'],
      ),
      ayahCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_count'],
      )!,
      bismillahPre: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bismillah_pre'],
      )!,
      pageStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_start'],
      )!,
      pageEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_end'],
      )!,
    );
  }

  @override
  $SurahTableTable createAlias(String alias) {
    return $SurahTableTable(attachedDatabase, alias);
  }
}

class SurahRow extends DataClass implements Insertable<SurahRow> {
  final int number;
  final String nameArabic;
  final String nameSimple;
  final String nameTranslated;

  /// 'makkah' | 'madinah'
  final String revelationPlace;

  /// Not published by AlQuran.cloud, so null rather than guessed.
  final int? revelationOrder;
  final int ayahCount;

  /// `number != 1 && number != 9`: a structural fact about the mushaf.
  final bool bismillahPre;
  final int pageStart;
  final int pageEnd;
  const SurahRow({
    required this.number,
    required this.nameArabic,
    required this.nameSimple,
    required this.nameTranslated,
    required this.revelationPlace,
    this.revelationOrder,
    required this.ayahCount,
    required this.bismillahPre,
    required this.pageStart,
    required this.pageEnd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['name_simple'] = Variable<String>(nameSimple);
    map['name_translated'] = Variable<String>(nameTranslated);
    map['revelation_place'] = Variable<String>(revelationPlace);
    if (!nullToAbsent || revelationOrder != null) {
      map['revelation_order'] = Variable<int>(revelationOrder);
    }
    map['ayah_count'] = Variable<int>(ayahCount);
    map['bismillah_pre'] = Variable<bool>(bismillahPre);
    map['page_start'] = Variable<int>(pageStart);
    map['page_end'] = Variable<int>(pageEnd);
    return map;
  }

  SurahTableCompanion toCompanion(bool nullToAbsent) {
    return SurahTableCompanion(
      number: Value(number),
      nameArabic: Value(nameArabic),
      nameSimple: Value(nameSimple),
      nameTranslated: Value(nameTranslated),
      revelationPlace: Value(revelationPlace),
      revelationOrder: revelationOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(revelationOrder),
      ayahCount: Value(ayahCount),
      bismillahPre: Value(bismillahPre),
      pageStart: Value(pageStart),
      pageEnd: Value(pageEnd),
    );
  }

  factory SurahRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurahRow(
      number: serializer.fromJson<int>(json['number']),
      nameArabic: serializer.fromJson<String>(json['nameArabic']),
      nameSimple: serializer.fromJson<String>(json['nameSimple']),
      nameTranslated: serializer.fromJson<String>(json['nameTranslated']),
      revelationPlace: serializer.fromJson<String>(json['revelationPlace']),
      revelationOrder: serializer.fromJson<int?>(json['revelationOrder']),
      ayahCount: serializer.fromJson<int>(json['ayahCount']),
      bismillahPre: serializer.fromJson<bool>(json['bismillahPre']),
      pageStart: serializer.fromJson<int>(json['pageStart']),
      pageEnd: serializer.fromJson<int>(json['pageEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'nameArabic': serializer.toJson<String>(nameArabic),
      'nameSimple': serializer.toJson<String>(nameSimple),
      'nameTranslated': serializer.toJson<String>(nameTranslated),
      'revelationPlace': serializer.toJson<String>(revelationPlace),
      'revelationOrder': serializer.toJson<int?>(revelationOrder),
      'ayahCount': serializer.toJson<int>(ayahCount),
      'bismillahPre': serializer.toJson<bool>(bismillahPre),
      'pageStart': serializer.toJson<int>(pageStart),
      'pageEnd': serializer.toJson<int>(pageEnd),
    };
  }

  SurahRow copyWith({
    int? number,
    String? nameArabic,
    String? nameSimple,
    String? nameTranslated,
    String? revelationPlace,
    Value<int?> revelationOrder = const Value.absent(),
    int? ayahCount,
    bool? bismillahPre,
    int? pageStart,
    int? pageEnd,
  }) => SurahRow(
    number: number ?? this.number,
    nameArabic: nameArabic ?? this.nameArabic,
    nameSimple: nameSimple ?? this.nameSimple,
    nameTranslated: nameTranslated ?? this.nameTranslated,
    revelationPlace: revelationPlace ?? this.revelationPlace,
    revelationOrder: revelationOrder.present
        ? revelationOrder.value
        : this.revelationOrder,
    ayahCount: ayahCount ?? this.ayahCount,
    bismillahPre: bismillahPre ?? this.bismillahPre,
    pageStart: pageStart ?? this.pageStart,
    pageEnd: pageEnd ?? this.pageEnd,
  );
  SurahRow copyWithCompanion(SurahTableCompanion data) {
    return SurahRow(
      number: data.number.present ? data.number.value : this.number,
      nameArabic: data.nameArabic.present
          ? data.nameArabic.value
          : this.nameArabic,
      nameSimple: data.nameSimple.present
          ? data.nameSimple.value
          : this.nameSimple,
      nameTranslated: data.nameTranslated.present
          ? data.nameTranslated.value
          : this.nameTranslated,
      revelationPlace: data.revelationPlace.present
          ? data.revelationPlace.value
          : this.revelationPlace,
      revelationOrder: data.revelationOrder.present
          ? data.revelationOrder.value
          : this.revelationOrder,
      ayahCount: data.ayahCount.present ? data.ayahCount.value : this.ayahCount,
      bismillahPre: data.bismillahPre.present
          ? data.bismillahPre.value
          : this.bismillahPre,
      pageStart: data.pageStart.present ? data.pageStart.value : this.pageStart,
      pageEnd: data.pageEnd.present ? data.pageEnd.value : this.pageEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurahRow(')
          ..write('number: $number, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameSimple: $nameSimple, ')
          ..write('nameTranslated: $nameTranslated, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('revelationOrder: $revelationOrder, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('bismillahPre: $bismillahPre, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    number,
    nameArabic,
    nameSimple,
    nameTranslated,
    revelationPlace,
    revelationOrder,
    ayahCount,
    bismillahPre,
    pageStart,
    pageEnd,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurahRow &&
          other.number == this.number &&
          other.nameArabic == this.nameArabic &&
          other.nameSimple == this.nameSimple &&
          other.nameTranslated == this.nameTranslated &&
          other.revelationPlace == this.revelationPlace &&
          other.revelationOrder == this.revelationOrder &&
          other.ayahCount == this.ayahCount &&
          other.bismillahPre == this.bismillahPre &&
          other.pageStart == this.pageStart &&
          other.pageEnd == this.pageEnd);
}

class SurahTableCompanion extends UpdateCompanion<SurahRow> {
  final Value<int> number;
  final Value<String> nameArabic;
  final Value<String> nameSimple;
  final Value<String> nameTranslated;
  final Value<String> revelationPlace;
  final Value<int?> revelationOrder;
  final Value<int> ayahCount;
  final Value<bool> bismillahPre;
  final Value<int> pageStart;
  final Value<int> pageEnd;
  const SurahTableCompanion({
    this.number = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.nameSimple = const Value.absent(),
    this.nameTranslated = const Value.absent(),
    this.revelationPlace = const Value.absent(),
    this.revelationOrder = const Value.absent(),
    this.ayahCount = const Value.absent(),
    this.bismillahPre = const Value.absent(),
    this.pageStart = const Value.absent(),
    this.pageEnd = const Value.absent(),
  });
  SurahTableCompanion.insert({
    this.number = const Value.absent(),
    required String nameArabic,
    required String nameSimple,
    required String nameTranslated,
    required String revelationPlace,
    this.revelationOrder = const Value.absent(),
    required int ayahCount,
    required bool bismillahPre,
    required int pageStart,
    required int pageEnd,
  }) : nameArabic = Value(nameArabic),
       nameSimple = Value(nameSimple),
       nameTranslated = Value(nameTranslated),
       revelationPlace = Value(revelationPlace),
       ayahCount = Value(ayahCount),
       bismillahPre = Value(bismillahPre),
       pageStart = Value(pageStart),
       pageEnd = Value(pageEnd);
  static Insertable<SurahRow> custom({
    Expression<int>? number,
    Expression<String>? nameArabic,
    Expression<String>? nameSimple,
    Expression<String>? nameTranslated,
    Expression<String>? revelationPlace,
    Expression<int>? revelationOrder,
    Expression<int>? ayahCount,
    Expression<bool>? bismillahPre,
    Expression<int>? pageStart,
    Expression<int>? pageEnd,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (nameSimple != null) 'name_simple': nameSimple,
      if (nameTranslated != null) 'name_translated': nameTranslated,
      if (revelationPlace != null) 'revelation_place': revelationPlace,
      if (revelationOrder != null) 'revelation_order': revelationOrder,
      if (ayahCount != null) 'ayah_count': ayahCount,
      if (bismillahPre != null) 'bismillah_pre': bismillahPre,
      if (pageStart != null) 'page_start': pageStart,
      if (pageEnd != null) 'page_end': pageEnd,
    });
  }

  SurahTableCompanion copyWith({
    Value<int>? number,
    Value<String>? nameArabic,
    Value<String>? nameSimple,
    Value<String>? nameTranslated,
    Value<String>? revelationPlace,
    Value<int?>? revelationOrder,
    Value<int>? ayahCount,
    Value<bool>? bismillahPre,
    Value<int>? pageStart,
    Value<int>? pageEnd,
  }) {
    return SurahTableCompanion(
      number: number ?? this.number,
      nameArabic: nameArabic ?? this.nameArabic,
      nameSimple: nameSimple ?? this.nameSimple,
      nameTranslated: nameTranslated ?? this.nameTranslated,
      revelationPlace: revelationPlace ?? this.revelationPlace,
      revelationOrder: revelationOrder ?? this.revelationOrder,
      ayahCount: ayahCount ?? this.ayahCount,
      bismillahPre: bismillahPre ?? this.bismillahPre,
      pageStart: pageStart ?? this.pageStart,
      pageEnd: pageEnd ?? this.pageEnd,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (nameSimple.present) {
      map['name_simple'] = Variable<String>(nameSimple.value);
    }
    if (nameTranslated.present) {
      map['name_translated'] = Variable<String>(nameTranslated.value);
    }
    if (revelationPlace.present) {
      map['revelation_place'] = Variable<String>(revelationPlace.value);
    }
    if (revelationOrder.present) {
      map['revelation_order'] = Variable<int>(revelationOrder.value);
    }
    if (ayahCount.present) {
      map['ayah_count'] = Variable<int>(ayahCount.value);
    }
    if (bismillahPre.present) {
      map['bismillah_pre'] = Variable<bool>(bismillahPre.value);
    }
    if (pageStart.present) {
      map['page_start'] = Variable<int>(pageStart.value);
    }
    if (pageEnd.present) {
      map['page_end'] = Variable<int>(pageEnd.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahTableCompanion(')
          ..write('number: $number, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameSimple: $nameSimple, ')
          ..write('nameTranslated: $nameTranslated, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('revelationOrder: $revelationOrder, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('bismillahPre: $bismillahPre, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd')
          ..write(')'))
        .toString();
  }
}

class $AyahTableTable extends AyahTable
    with TableInfo<$AyahTableTable, AyahRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES surah (number)',
    ),
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _textUthmaniMeta = const VerificationMeta(
    'textUthmani',
  );
  @override
  late final GeneratedColumn<String> textUthmani = GeneratedColumn<String>(
    'text_uthmani',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textSearchMeta = const VerificationMeta(
    'textSearch',
  );
  @override
  late final GeneratedColumn<String> textSearch = GeneratedColumn<String>(
    'text_search',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _juzMeta = const VerificationMeta('juz');
  @override
  late final GeneratedColumn<int> juz = GeneratedColumn<int>(
    'juz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hizbMeta = const VerificationMeta('hizb');
  @override
  late final GeneratedColumn<int> hizb = GeneratedColumn<int>(
    'hizb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rubElHizbMeta = const VerificationMeta(
    'rubElHizb',
  );
  @override
  late final GeneratedColumn<int> rubElHizb = GeneratedColumn<int>(
    'rub_el_hizb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rukuMeta = const VerificationMeta('ruku');
  @override
  late final GeneratedColumn<int> ruku = GeneratedColumn<int>(
    'ruku',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manzilMeta = const VerificationMeta('manzil');
  @override
  late final GeneratedColumn<int> manzil = GeneratedColumn<int>(
    'manzil',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sajdahTypeMeta = const VerificationMeta(
    'sajdahType',
  );
  @override
  late final GeneratedColumn<String> sajdahType = GeneratedColumn<String>(
    'sajdah_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surahNumber,
    ayahNumber,
    verseKey,
    textUthmani,
    textSearch,
    juz,
    hizb,
    rubElHizb,
    ruku,
    manzil,
    page,
    sajdahType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayah';
  @override
  VerificationContext validateIntegrity(
    Insertable<AyahRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('verse_key')) {
      context.handle(
        _verseKeyMeta,
        verseKey.isAcceptableOrUnknown(data['verse_key']!, _verseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_verseKeyMeta);
    }
    if (data.containsKey('text_uthmani')) {
      context.handle(
        _textUthmaniMeta,
        textUthmani.isAcceptableOrUnknown(
          data['text_uthmani']!,
          _textUthmaniMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textUthmaniMeta);
    }
    if (data.containsKey('text_search')) {
      context.handle(
        _textSearchMeta,
        textSearch.isAcceptableOrUnknown(data['text_search']!, _textSearchMeta),
      );
    } else if (isInserting) {
      context.missing(_textSearchMeta);
    }
    if (data.containsKey('juz')) {
      context.handle(
        _juzMeta,
        juz.isAcceptableOrUnknown(data['juz']!, _juzMeta),
      );
    } else if (isInserting) {
      context.missing(_juzMeta);
    }
    if (data.containsKey('hizb')) {
      context.handle(
        _hizbMeta,
        hizb.isAcceptableOrUnknown(data['hizb']!, _hizbMeta),
      );
    } else if (isInserting) {
      context.missing(_hizbMeta);
    }
    if (data.containsKey('rub_el_hizb')) {
      context.handle(
        _rubElHizbMeta,
        rubElHizb.isAcceptableOrUnknown(data['rub_el_hizb']!, _rubElHizbMeta),
      );
    } else if (isInserting) {
      context.missing(_rubElHizbMeta);
    }
    if (data.containsKey('ruku')) {
      context.handle(
        _rukuMeta,
        ruku.isAcceptableOrUnknown(data['ruku']!, _rukuMeta),
      );
    } else if (isInserting) {
      context.missing(_rukuMeta);
    }
    if (data.containsKey('manzil')) {
      context.handle(
        _manzilMeta,
        manzil.isAcceptableOrUnknown(data['manzil']!, _manzilMeta),
      );
    } else if (isInserting) {
      context.missing(_manzilMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('sajdah_type')) {
      context.handle(
        _sajdahTypeMeta,
        sajdahType.isAcceptableOrUnknown(data['sajdah_type']!, _sajdahTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AyahRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      verseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verse_key'],
      )!,
      textUthmani: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_uthmani'],
      )!,
      textSearch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_search'],
      )!,
      juz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz'],
      )!,
      hizb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hizb'],
      )!,
      rubElHizb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rub_el_hizb'],
      )!,
      ruku: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ruku'],
      )!,
      manzil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manzil'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      sajdahType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sajdah_type'],
      ),
    );
  }

  @override
  $AyahTableTable createAlias(String alias) {
    return $AyahTableTable(attachedDatabase, alias);
  }
}

class AyahRow extends DataClass implements Insertable<AyahRow> {
  /// Mushaf-wide index, 1..6236.
  final int id;
  final int surahNumber;
  final int ayahNumber;

  /// "2:255" — the canonical citation key.
  final String verseKey;

  /// The verse exactly as the source supplied it (after sanitizeSourceText).
  /// Never modified and never normalised.
  final String textUthmani;

  /// normalizeForSearch(textUthmani); used only for matching, never rendered.
  final String textSearch;
  final int juz;
  final int hizb;
  final int rubElHizb;
  final int ruku;
  final int manzil;
  final int page;

  /// null | 'recommended' | 'obligatory'
  final String? sajdahType;
  const AyahRow({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.verseKey,
    required this.textUthmani,
    required this.textSearch,
    required this.juz,
    required this.hizb,
    required this.rubElHizb,
    required this.ruku,
    required this.manzil,
    required this.page,
    this.sajdahType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['verse_key'] = Variable<String>(verseKey);
    map['text_uthmani'] = Variable<String>(textUthmani);
    map['text_search'] = Variable<String>(textSearch);
    map['juz'] = Variable<int>(juz);
    map['hizb'] = Variable<int>(hizb);
    map['rub_el_hizb'] = Variable<int>(rubElHizb);
    map['ruku'] = Variable<int>(ruku);
    map['manzil'] = Variable<int>(manzil);
    map['page'] = Variable<int>(page);
    if (!nullToAbsent || sajdahType != null) {
      map['sajdah_type'] = Variable<String>(sajdahType);
    }
    return map;
  }

  AyahTableCompanion toCompanion(bool nullToAbsent) {
    return AyahTableCompanion(
      id: Value(id),
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      verseKey: Value(verseKey),
      textUthmani: Value(textUthmani),
      textSearch: Value(textSearch),
      juz: Value(juz),
      hizb: Value(hizb),
      rubElHizb: Value(rubElHizb),
      ruku: Value(ruku),
      manzil: Value(manzil),
      page: Value(page),
      sajdahType: sajdahType == null && nullToAbsent
          ? const Value.absent()
          : Value(sajdahType),
    );
  }

  factory AyahRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahRow(
      id: serializer.fromJson<int>(json['id']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      verseKey: serializer.fromJson<String>(json['verseKey']),
      textUthmani: serializer.fromJson<String>(json['textUthmani']),
      textSearch: serializer.fromJson<String>(json['textSearch']),
      juz: serializer.fromJson<int>(json['juz']),
      hizb: serializer.fromJson<int>(json['hizb']),
      rubElHizb: serializer.fromJson<int>(json['rubElHizb']),
      ruku: serializer.fromJson<int>(json['ruku']),
      manzil: serializer.fromJson<int>(json['manzil']),
      page: serializer.fromJson<int>(json['page']),
      sajdahType: serializer.fromJson<String?>(json['sajdahType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'verseKey': serializer.toJson<String>(verseKey),
      'textUthmani': serializer.toJson<String>(textUthmani),
      'textSearch': serializer.toJson<String>(textSearch),
      'juz': serializer.toJson<int>(juz),
      'hizb': serializer.toJson<int>(hizb),
      'rubElHizb': serializer.toJson<int>(rubElHizb),
      'ruku': serializer.toJson<int>(ruku),
      'manzil': serializer.toJson<int>(manzil),
      'page': serializer.toJson<int>(page),
      'sajdahType': serializer.toJson<String?>(sajdahType),
    };
  }

  AyahRow copyWith({
    int? id,
    int? surahNumber,
    int? ayahNumber,
    String? verseKey,
    String? textUthmani,
    String? textSearch,
    int? juz,
    int? hizb,
    int? rubElHizb,
    int? ruku,
    int? manzil,
    int? page,
    Value<String?> sajdahType = const Value.absent(),
  }) => AyahRow(
    id: id ?? this.id,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    verseKey: verseKey ?? this.verseKey,
    textUthmani: textUthmani ?? this.textUthmani,
    textSearch: textSearch ?? this.textSearch,
    juz: juz ?? this.juz,
    hizb: hizb ?? this.hizb,
    rubElHizb: rubElHizb ?? this.rubElHizb,
    ruku: ruku ?? this.ruku,
    manzil: manzil ?? this.manzil,
    page: page ?? this.page,
    sajdahType: sajdahType.present ? sajdahType.value : this.sajdahType,
  );
  AyahRow copyWithCompanion(AyahTableCompanion data) {
    return AyahRow(
      id: data.id.present ? data.id.value : this.id,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      verseKey: data.verseKey.present ? data.verseKey.value : this.verseKey,
      textUthmani: data.textUthmani.present
          ? data.textUthmani.value
          : this.textUthmani,
      textSearch: data.textSearch.present
          ? data.textSearch.value
          : this.textSearch,
      juz: data.juz.present ? data.juz.value : this.juz,
      hizb: data.hizb.present ? data.hizb.value : this.hizb,
      rubElHizb: data.rubElHizb.present ? data.rubElHizb.value : this.rubElHizb,
      ruku: data.ruku.present ? data.ruku.value : this.ruku,
      manzil: data.manzil.present ? data.manzil.value : this.manzil,
      page: data.page.present ? data.page.value : this.page,
      sajdahType: data.sajdahType.present
          ? data.sajdahType.value
          : this.sajdahType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahRow(')
          ..write('id: $id, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('verseKey: $verseKey, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('textSearch: $textSearch, ')
          ..write('juz: $juz, ')
          ..write('hizb: $hizb, ')
          ..write('rubElHizb: $rubElHizb, ')
          ..write('ruku: $ruku, ')
          ..write('manzil: $manzil, ')
          ..write('page: $page, ')
          ..write('sajdahType: $sajdahType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    surahNumber,
    ayahNumber,
    verseKey,
    textUthmani,
    textSearch,
    juz,
    hizb,
    rubElHizb,
    ruku,
    manzil,
    page,
    sajdahType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahRow &&
          other.id == this.id &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.verseKey == this.verseKey &&
          other.textUthmani == this.textUthmani &&
          other.textSearch == this.textSearch &&
          other.juz == this.juz &&
          other.hizb == this.hizb &&
          other.rubElHizb == this.rubElHizb &&
          other.ruku == this.ruku &&
          other.manzil == this.manzil &&
          other.page == this.page &&
          other.sajdahType == this.sajdahType);
}

class AyahTableCompanion extends UpdateCompanion<AyahRow> {
  final Value<int> id;
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<String> verseKey;
  final Value<String> textUthmani;
  final Value<String> textSearch;
  final Value<int> juz;
  final Value<int> hizb;
  final Value<int> rubElHizb;
  final Value<int> ruku;
  final Value<int> manzil;
  final Value<int> page;
  final Value<String?> sajdahType;
  const AyahTableCompanion({
    this.id = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.verseKey = const Value.absent(),
    this.textUthmani = const Value.absent(),
    this.textSearch = const Value.absent(),
    this.juz = const Value.absent(),
    this.hizb = const Value.absent(),
    this.rubElHizb = const Value.absent(),
    this.ruku = const Value.absent(),
    this.manzil = const Value.absent(),
    this.page = const Value.absent(),
    this.sajdahType = const Value.absent(),
  });
  AyahTableCompanion.insert({
    this.id = const Value.absent(),
    required int surahNumber,
    required int ayahNumber,
    required String verseKey,
    required String textUthmani,
    required String textSearch,
    required int juz,
    required int hizb,
    required int rubElHizb,
    required int ruku,
    required int manzil,
    required int page,
    this.sajdahType = const Value.absent(),
  }) : surahNumber = Value(surahNumber),
       ayahNumber = Value(ayahNumber),
       verseKey = Value(verseKey),
       textUthmani = Value(textUthmani),
       textSearch = Value(textSearch),
       juz = Value(juz),
       hizb = Value(hizb),
       rubElHizb = Value(rubElHizb),
       ruku = Value(ruku),
       manzil = Value(manzil),
       page = Value(page);
  static Insertable<AyahRow> custom({
    Expression<int>? id,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<String>? verseKey,
    Expression<String>? textUthmani,
    Expression<String>? textSearch,
    Expression<int>? juz,
    Expression<int>? hizb,
    Expression<int>? rubElHizb,
    Expression<int>? ruku,
    Expression<int>? manzil,
    Expression<int>? page,
    Expression<String>? sajdahType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (verseKey != null) 'verse_key': verseKey,
      if (textUthmani != null) 'text_uthmani': textUthmani,
      if (textSearch != null) 'text_search': textSearch,
      if (juz != null) 'juz': juz,
      if (hizb != null) 'hizb': hizb,
      if (rubElHizb != null) 'rub_el_hizb': rubElHizb,
      if (ruku != null) 'ruku': ruku,
      if (manzil != null) 'manzil': manzil,
      if (page != null) 'page': page,
      if (sajdahType != null) 'sajdah_type': sajdahType,
    });
  }

  AyahTableCompanion copyWith({
    Value<int>? id,
    Value<int>? surahNumber,
    Value<int>? ayahNumber,
    Value<String>? verseKey,
    Value<String>? textUthmani,
    Value<String>? textSearch,
    Value<int>? juz,
    Value<int>? hizb,
    Value<int>? rubElHizb,
    Value<int>? ruku,
    Value<int>? manzil,
    Value<int>? page,
    Value<String?>? sajdahType,
  }) {
    return AyahTableCompanion(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      verseKey: verseKey ?? this.verseKey,
      textUthmani: textUthmani ?? this.textUthmani,
      textSearch: textSearch ?? this.textSearch,
      juz: juz ?? this.juz,
      hizb: hizb ?? this.hizb,
      rubElHizb: rubElHizb ?? this.rubElHizb,
      ruku: ruku ?? this.ruku,
      manzil: manzil ?? this.manzil,
      page: page ?? this.page,
      sajdahType: sajdahType ?? this.sajdahType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (verseKey.present) {
      map['verse_key'] = Variable<String>(verseKey.value);
    }
    if (textUthmani.present) {
      map['text_uthmani'] = Variable<String>(textUthmani.value);
    }
    if (textSearch.present) {
      map['text_search'] = Variable<String>(textSearch.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    if (hizb.present) {
      map['hizb'] = Variable<int>(hizb.value);
    }
    if (rubElHizb.present) {
      map['rub_el_hizb'] = Variable<int>(rubElHizb.value);
    }
    if (ruku.present) {
      map['ruku'] = Variable<int>(ruku.value);
    }
    if (manzil.present) {
      map['manzil'] = Variable<int>(manzil.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (sajdahType.present) {
      map['sajdah_type'] = Variable<String>(sajdahType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahTableCompanion(')
          ..write('id: $id, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('verseKey: $verseKey, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('textSearch: $textSearch, ')
          ..write('juz: $juz, ')
          ..write('hizb: $hizb, ')
          ..write('rubElHizb: $rubElHizb, ')
          ..write('ruku: $ruku, ')
          ..write('manzil: $manzil, ')
          ..write('page: $page, ')
          ..write('sajdahType: $sajdahType')
          ..write(')'))
        .toString();
  }
}

class $TranslationEditionTableTable extends TranslationEditionTable
    with TableInfo<$TranslationEditionTableTable, TranslationEditionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationEditionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translatorMeta = const VerificationMeta(
    'translator',
  );
  @override
  late final GeneratedColumn<String> translator = GeneratedColumn<String>(
    'translator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attributionMeta = const VerificationMeta(
    'attribution',
  );
  @override
  late final GeneratedColumn<String> attribution = GeneratedColumn<String>(
    'attribution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bundledMeta = const VerificationMeta(
    'bundled',
  );
  @override
  late final GeneratedColumn<bool> bundled = GeneratedColumn<bool>(
    'bundled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bundled" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    language,
    name,
    translator,
    direction,
    attribution,
    bundled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translation_edition';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranslationEditionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('translator')) {
      context.handle(
        _translatorMeta,
        translator.isAcceptableOrUnknown(data['translator']!, _translatorMeta),
      );
    } else if (isInserting) {
      context.missing(_translatorMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('attribution')) {
      context.handle(
        _attributionMeta,
        attribution.isAcceptableOrUnknown(
          data['attribution']!,
          _attributionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attributionMeta);
    }
    if (data.containsKey('bundled')) {
      context.handle(
        _bundledMeta,
        bundled.isAcceptableOrUnknown(data['bundled']!, _bundledMeta),
      );
    } else if (isInserting) {
      context.missing(_bundledMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranslationEditionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationEditionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      translator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translator'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      attribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribution'],
      )!,
      bundled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bundled'],
      )!,
    );
  }

  @override
  $TranslationEditionTableTable createAlias(String alias) {
    return $TranslationEditionTableTable(attachedDatabase, alias);
  }
}

class TranslationEditionRow extends DataClass
    implements Insertable<TranslationEditionRow> {
  /// AlQuran.cloud identifier, e.g. 'en.sahih'.
  final String id;
  final String language;

  /// Edition title (AlQuran.cloud `englishName`).
  final String name;

  /// Translator credit (AlQuran.cloud `name`).
  final String translator;

  /// 'ltr' | 'rtl'
  final String direction;

  /// Licence-required credit, from attributionForTranslation.
  final String attribution;

  /// Shipped with the app (cannot be deleted) vs downloaded at runtime.
  final bool bundled;
  const TranslationEditionRow({
    required this.id,
    required this.language,
    required this.name,
    required this.translator,
    required this.direction,
    required this.attribution,
    required this.bundled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['language'] = Variable<String>(language);
    map['name'] = Variable<String>(name);
    map['translator'] = Variable<String>(translator);
    map['direction'] = Variable<String>(direction);
    map['attribution'] = Variable<String>(attribution);
    map['bundled'] = Variable<bool>(bundled);
    return map;
  }

  TranslationEditionTableCompanion toCompanion(bool nullToAbsent) {
    return TranslationEditionTableCompanion(
      id: Value(id),
      language: Value(language),
      name: Value(name),
      translator: Value(translator),
      direction: Value(direction),
      attribution: Value(attribution),
      bundled: Value(bundled),
    );
  }

  factory TranslationEditionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationEditionRow(
      id: serializer.fromJson<String>(json['id']),
      language: serializer.fromJson<String>(json['language']),
      name: serializer.fromJson<String>(json['name']),
      translator: serializer.fromJson<String>(json['translator']),
      direction: serializer.fromJson<String>(json['direction']),
      attribution: serializer.fromJson<String>(json['attribution']),
      bundled: serializer.fromJson<bool>(json['bundled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'language': serializer.toJson<String>(language),
      'name': serializer.toJson<String>(name),
      'translator': serializer.toJson<String>(translator),
      'direction': serializer.toJson<String>(direction),
      'attribution': serializer.toJson<String>(attribution),
      'bundled': serializer.toJson<bool>(bundled),
    };
  }

  TranslationEditionRow copyWith({
    String? id,
    String? language,
    String? name,
    String? translator,
    String? direction,
    String? attribution,
    bool? bundled,
  }) => TranslationEditionRow(
    id: id ?? this.id,
    language: language ?? this.language,
    name: name ?? this.name,
    translator: translator ?? this.translator,
    direction: direction ?? this.direction,
    attribution: attribution ?? this.attribution,
    bundled: bundled ?? this.bundled,
  );
  TranslationEditionRow copyWithCompanion(
    TranslationEditionTableCompanion data,
  ) {
    return TranslationEditionRow(
      id: data.id.present ? data.id.value : this.id,
      language: data.language.present ? data.language.value : this.language,
      name: data.name.present ? data.name.value : this.name,
      translator: data.translator.present
          ? data.translator.value
          : this.translator,
      direction: data.direction.present ? data.direction.value : this.direction,
      attribution: data.attribution.present
          ? data.attribution.value
          : this.attribution,
      bundled: data.bundled.present ? data.bundled.value : this.bundled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationEditionRow(')
          ..write('id: $id, ')
          ..write('language: $language, ')
          ..write('name: $name, ')
          ..write('translator: $translator, ')
          ..write('direction: $direction, ')
          ..write('attribution: $attribution, ')
          ..write('bundled: $bundled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    language,
    name,
    translator,
    direction,
    attribution,
    bundled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationEditionRow &&
          other.id == this.id &&
          other.language == this.language &&
          other.name == this.name &&
          other.translator == this.translator &&
          other.direction == this.direction &&
          other.attribution == this.attribution &&
          other.bundled == this.bundled);
}

class TranslationEditionTableCompanion
    extends UpdateCompanion<TranslationEditionRow> {
  final Value<String> id;
  final Value<String> language;
  final Value<String> name;
  final Value<String> translator;
  final Value<String> direction;
  final Value<String> attribution;
  final Value<bool> bundled;
  final Value<int> rowid;
  const TranslationEditionTableCompanion({
    this.id = const Value.absent(),
    this.language = const Value.absent(),
    this.name = const Value.absent(),
    this.translator = const Value.absent(),
    this.direction = const Value.absent(),
    this.attribution = const Value.absent(),
    this.bundled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranslationEditionTableCompanion.insert({
    required String id,
    required String language,
    required String name,
    required String translator,
    required String direction,
    required String attribution,
    required bool bundled,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       language = Value(language),
       name = Value(name),
       translator = Value(translator),
       direction = Value(direction),
       attribution = Value(attribution),
       bundled = Value(bundled);
  static Insertable<TranslationEditionRow> custom({
    Expression<String>? id,
    Expression<String>? language,
    Expression<String>? name,
    Expression<String>? translator,
    Expression<String>? direction,
    Expression<String>? attribution,
    Expression<bool>? bundled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (language != null) 'language': language,
      if (name != null) 'name': name,
      if (translator != null) 'translator': translator,
      if (direction != null) 'direction': direction,
      if (attribution != null) 'attribution': attribution,
      if (bundled != null) 'bundled': bundled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranslationEditionTableCompanion copyWith({
    Value<String>? id,
    Value<String>? language,
    Value<String>? name,
    Value<String>? translator,
    Value<String>? direction,
    Value<String>? attribution,
    Value<bool>? bundled,
    Value<int>? rowid,
  }) {
    return TranslationEditionTableCompanion(
      id: id ?? this.id,
      language: language ?? this.language,
      name: name ?? this.name,
      translator: translator ?? this.translator,
      direction: direction ?? this.direction,
      attribution: attribution ?? this.attribution,
      bundled: bundled ?? this.bundled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (translator.present) {
      map['translator'] = Variable<String>(translator.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (attribution.present) {
      map['attribution'] = Variable<String>(attribution.value);
    }
    if (bundled.present) {
      map['bundled'] = Variable<bool>(bundled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationEditionTableCompanion(')
          ..write('id: $id, ')
          ..write('language: $language, ')
          ..write('name: $name, ')
          ..write('translator: $translator, ')
          ..write('direction: $direction, ')
          ..write('attribution: $attribution, ')
          ..write('bundled: $bundled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranslationTableTable extends TranslationTable
    with TableInfo<$TranslationTableTable, TranslationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _editionIdMeta = const VerificationMeta(
    'editionId',
  );
  @override
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
    'edition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES translation_edition (id)',
    ),
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ayah (id)',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textSearchMeta = const VerificationMeta(
    'textSearch',
  );
  @override
  late final GeneratedColumn<String> textSearch = GeneratedColumn<String>(
    'text_search',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [editionId, ayahId, body, textSearch];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translation';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranslationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('edition_id')) {
      context.handle(
        _editionIdMeta,
        editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_editionIdMeta);
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['text']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('text_search')) {
      context.handle(
        _textSearchMeta,
        textSearch.isAcceptableOrUnknown(data['text_search']!, _textSearchMeta),
      );
    } else if (isInserting) {
      context.missing(_textSearchMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {editionId, ayahId};
  @override
  TranslationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationRow(
      editionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition_id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      textSearch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_search'],
      )!,
    );
  }

  @override
  $TranslationTableTable createAlias(String alias) {
    return $TranslationTableTable(attachedDatabase, alias);
  }
}

class TranslationRow extends DataClass implements Insertable<TranslationRow> {
  final String editionId;
  final int ayahId;

  /// The translation text (SQL column `text`; `text` is reserved in drift's
  /// table DSL, hence the getter name).
  final String body;

  /// normalizeForSearch(text); used only for matching, never rendered.
  final String textSearch;
  const TranslationRow({
    required this.editionId,
    required this.ayahId,
    required this.body,
    required this.textSearch,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['edition_id'] = Variable<String>(editionId);
    map['ayah_id'] = Variable<int>(ayahId);
    map['text'] = Variable<String>(body);
    map['text_search'] = Variable<String>(textSearch);
    return map;
  }

  TranslationTableCompanion toCompanion(bool nullToAbsent) {
    return TranslationTableCompanion(
      editionId: Value(editionId),
      ayahId: Value(ayahId),
      body: Value(body),
      textSearch: Value(textSearch),
    );
  }

  factory TranslationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationRow(
      editionId: serializer.fromJson<String>(json['editionId']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      body: serializer.fromJson<String>(json['body']),
      textSearch: serializer.fromJson<String>(json['textSearch']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'editionId': serializer.toJson<String>(editionId),
      'ayahId': serializer.toJson<int>(ayahId),
      'body': serializer.toJson<String>(body),
      'textSearch': serializer.toJson<String>(textSearch),
    };
  }

  TranslationRow copyWith({
    String? editionId,
    int? ayahId,
    String? body,
    String? textSearch,
  }) => TranslationRow(
    editionId: editionId ?? this.editionId,
    ayahId: ayahId ?? this.ayahId,
    body: body ?? this.body,
    textSearch: textSearch ?? this.textSearch,
  );
  TranslationRow copyWithCompanion(TranslationTableCompanion data) {
    return TranslationRow(
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      body: data.body.present ? data.body.value : this.body,
      textSearch: data.textSearch.present
          ? data.textSearch.value
          : this.textSearch,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationRow(')
          ..write('editionId: $editionId, ')
          ..write('ayahId: $ayahId, ')
          ..write('body: $body, ')
          ..write('textSearch: $textSearch')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(editionId, ayahId, body, textSearch);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationRow &&
          other.editionId == this.editionId &&
          other.ayahId == this.ayahId &&
          other.body == this.body &&
          other.textSearch == this.textSearch);
}

class TranslationTableCompanion extends UpdateCompanion<TranslationRow> {
  final Value<String> editionId;
  final Value<int> ayahId;
  final Value<String> body;
  final Value<String> textSearch;
  final Value<int> rowid;
  const TranslationTableCompanion({
    this.editionId = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.body = const Value.absent(),
    this.textSearch = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranslationTableCompanion.insert({
    required String editionId,
    required int ayahId,
    required String body,
    required String textSearch,
    this.rowid = const Value.absent(),
  }) : editionId = Value(editionId),
       ayahId = Value(ayahId),
       body = Value(body),
       textSearch = Value(textSearch);
  static Insertable<TranslationRow> custom({
    Expression<String>? editionId,
    Expression<int>? ayahId,
    Expression<String>? body,
    Expression<String>? textSearch,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (editionId != null) 'edition_id': editionId,
      if (ayahId != null) 'ayah_id': ayahId,
      if (body != null) 'text': body,
      if (textSearch != null) 'text_search': textSearch,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranslationTableCompanion copyWith({
    Value<String>? editionId,
    Value<int>? ayahId,
    Value<String>? body,
    Value<String>? textSearch,
    Value<int>? rowid,
  }) {
    return TranslationTableCompanion(
      editionId: editionId ?? this.editionId,
      ayahId: ayahId ?? this.ayahId,
      body: body ?? this.body,
      textSearch: textSearch ?? this.textSearch,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (body.present) {
      map['text'] = Variable<String>(body.value);
    }
    if (textSearch.present) {
      map['text_search'] = Variable<String>(textSearch.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationTableCompanion(')
          ..write('editionId: $editionId, ')
          ..write('ayahId: $ayahId, ')
          ..write('body: $body, ')
          ..write('textSearch: $textSearch, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JuzTableTable extends JuzTable with TableInfo<$JuzTableTable, JuzRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JuzTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstVerseKeyMeta = const VerificationMeta(
    'firstVerseKey',
  );
  @override
  late final GeneratedColumn<String> firstVerseKey = GeneratedColumn<String>(
    'first_verse_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastVerseKeyMeta = const VerificationMeta(
    'lastVerseKey',
  );
  @override
  late final GeneratedColumn<String> lastVerseKey = GeneratedColumn<String>(
    'last_verse_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArabicMeta = const VerificationMeta(
    'nameArabic',
  );
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
    'name_arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameTransliteratedMeta =
      const VerificationMeta('nameTransliterated');
  @override
  late final GeneratedColumn<String> nameTransliterated =
      GeneratedColumn<String>(
        'name_transliterated',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    number,
    firstVerseKey,
    lastVerseKey,
    nameArabic,
    nameTransliterated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'juz';
  @override
  VerificationContext validateIntegrity(
    Insertable<JuzRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('first_verse_key')) {
      context.handle(
        _firstVerseKeyMeta,
        firstVerseKey.isAcceptableOrUnknown(
          data['first_verse_key']!,
          _firstVerseKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstVerseKeyMeta);
    }
    if (data.containsKey('last_verse_key')) {
      context.handle(
        _lastVerseKeyMeta,
        lastVerseKey.isAcceptableOrUnknown(
          data['last_verse_key']!,
          _lastVerseKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastVerseKeyMeta);
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
        _nameArabicMeta,
        nameArabic.isAcceptableOrUnknown(data['name_arabic']!, _nameArabicMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('name_transliterated')) {
      context.handle(
        _nameTransliteratedMeta,
        nameTransliterated.isAcceptableOrUnknown(
          data['name_transliterated']!,
          _nameTransliteratedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameTransliteratedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  JuzRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JuzRow(
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      firstVerseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_verse_key'],
      )!,
      lastVerseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_verse_key'],
      )!,
      nameArabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_arabic'],
      )!,
      nameTransliterated: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_transliterated'],
      )!,
    );
  }

  @override
  $JuzTableTable createAlias(String alias) {
    return $JuzTableTable(attachedDatabase, alias);
  }
}

class JuzRow extends DataClass implements Insertable<JuzRow> {
  final int number;

  /// Boundaries are computed from the ayah data, never typed in.
  final String firstVerseKey;
  final String lastVerseKey;

  /// Traditional names. Labels only.
  final String nameArabic;
  final String nameTransliterated;
  const JuzRow({
    required this.number,
    required this.firstVerseKey,
    required this.lastVerseKey,
    required this.nameArabic,
    required this.nameTransliterated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['first_verse_key'] = Variable<String>(firstVerseKey);
    map['last_verse_key'] = Variable<String>(lastVerseKey);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['name_transliterated'] = Variable<String>(nameTransliterated);
    return map;
  }

  JuzTableCompanion toCompanion(bool nullToAbsent) {
    return JuzTableCompanion(
      number: Value(number),
      firstVerseKey: Value(firstVerseKey),
      lastVerseKey: Value(lastVerseKey),
      nameArabic: Value(nameArabic),
      nameTransliterated: Value(nameTransliterated),
    );
  }

  factory JuzRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JuzRow(
      number: serializer.fromJson<int>(json['number']),
      firstVerseKey: serializer.fromJson<String>(json['firstVerseKey']),
      lastVerseKey: serializer.fromJson<String>(json['lastVerseKey']),
      nameArabic: serializer.fromJson<String>(json['nameArabic']),
      nameTransliterated: serializer.fromJson<String>(
        json['nameTransliterated'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'firstVerseKey': serializer.toJson<String>(firstVerseKey),
      'lastVerseKey': serializer.toJson<String>(lastVerseKey),
      'nameArabic': serializer.toJson<String>(nameArabic),
      'nameTransliterated': serializer.toJson<String>(nameTransliterated),
    };
  }

  JuzRow copyWith({
    int? number,
    String? firstVerseKey,
    String? lastVerseKey,
    String? nameArabic,
    String? nameTransliterated,
  }) => JuzRow(
    number: number ?? this.number,
    firstVerseKey: firstVerseKey ?? this.firstVerseKey,
    lastVerseKey: lastVerseKey ?? this.lastVerseKey,
    nameArabic: nameArabic ?? this.nameArabic,
    nameTransliterated: nameTransliterated ?? this.nameTransliterated,
  );
  JuzRow copyWithCompanion(JuzTableCompanion data) {
    return JuzRow(
      number: data.number.present ? data.number.value : this.number,
      firstVerseKey: data.firstVerseKey.present
          ? data.firstVerseKey.value
          : this.firstVerseKey,
      lastVerseKey: data.lastVerseKey.present
          ? data.lastVerseKey.value
          : this.lastVerseKey,
      nameArabic: data.nameArabic.present
          ? data.nameArabic.value
          : this.nameArabic,
      nameTransliterated: data.nameTransliterated.present
          ? data.nameTransliterated.value
          : this.nameTransliterated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JuzRow(')
          ..write('number: $number, ')
          ..write('firstVerseKey: $firstVerseKey, ')
          ..write('lastVerseKey: $lastVerseKey, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameTransliterated: $nameTransliterated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    number,
    firstVerseKey,
    lastVerseKey,
    nameArabic,
    nameTransliterated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JuzRow &&
          other.number == this.number &&
          other.firstVerseKey == this.firstVerseKey &&
          other.lastVerseKey == this.lastVerseKey &&
          other.nameArabic == this.nameArabic &&
          other.nameTransliterated == this.nameTransliterated);
}

class JuzTableCompanion extends UpdateCompanion<JuzRow> {
  final Value<int> number;
  final Value<String> firstVerseKey;
  final Value<String> lastVerseKey;
  final Value<String> nameArabic;
  final Value<String> nameTransliterated;
  const JuzTableCompanion({
    this.number = const Value.absent(),
    this.firstVerseKey = const Value.absent(),
    this.lastVerseKey = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.nameTransliterated = const Value.absent(),
  });
  JuzTableCompanion.insert({
    this.number = const Value.absent(),
    required String firstVerseKey,
    required String lastVerseKey,
    required String nameArabic,
    required String nameTransliterated,
  }) : firstVerseKey = Value(firstVerseKey),
       lastVerseKey = Value(lastVerseKey),
       nameArabic = Value(nameArabic),
       nameTransliterated = Value(nameTransliterated);
  static Insertable<JuzRow> custom({
    Expression<int>? number,
    Expression<String>? firstVerseKey,
    Expression<String>? lastVerseKey,
    Expression<String>? nameArabic,
    Expression<String>? nameTransliterated,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (firstVerseKey != null) 'first_verse_key': firstVerseKey,
      if (lastVerseKey != null) 'last_verse_key': lastVerseKey,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (nameTransliterated != null) 'name_transliterated': nameTransliterated,
    });
  }

  JuzTableCompanion copyWith({
    Value<int>? number,
    Value<String>? firstVerseKey,
    Value<String>? lastVerseKey,
    Value<String>? nameArabic,
    Value<String>? nameTransliterated,
  }) {
    return JuzTableCompanion(
      number: number ?? this.number,
      firstVerseKey: firstVerseKey ?? this.firstVerseKey,
      lastVerseKey: lastVerseKey ?? this.lastVerseKey,
      nameArabic: nameArabic ?? this.nameArabic,
      nameTransliterated: nameTransliterated ?? this.nameTransliterated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (firstVerseKey.present) {
      map['first_verse_key'] = Variable<String>(firstVerseKey.value);
    }
    if (lastVerseKey.present) {
      map['last_verse_key'] = Variable<String>(lastVerseKey.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (nameTransliterated.present) {
      map['name_transliterated'] = Variable<String>(nameTransliterated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JuzTableCompanion(')
          ..write('number: $number, ')
          ..write('firstVerseKey: $firstVerseKey, ')
          ..write('lastVerseKey: $lastVerseKey, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameTransliterated: $nameTransliterated')
          ..write(')'))
        .toString();
  }
}

class $MetaTableTable extends MetaTable
    with TableInfo<$MetaTableTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetaTableTable createAlias(String alias) {
    return $MetaTableTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String key;
  final String value;
  const MetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaTableCompanion toCompanion(bool nullToAbsent) {
    return MetaTableCompanion(key: Value(key), value: Value(value));
  }

  factory MetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaRow copyWith({String? key, String? value}) =>
      MetaRow(key: key ?? this.key, value: value ?? this.value);
  MetaRow copyWithCompanion(MetaTableCompanion data) {
    return MetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow && other.key == this.key && other.value == this.value);
}

class MetaTableCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ContentDatabase extends GeneratedDatabase {
  _$ContentDatabase(QueryExecutor e) : super(e);
  $ContentDatabaseManager get managers => $ContentDatabaseManager(this);
  late final $SurahTableTable surahTable = $SurahTableTable(this);
  late final $AyahTableTable ayahTable = $AyahTableTable(this);
  late final $TranslationEditionTableTable translationEditionTable =
      $TranslationEditionTableTable(this);
  late final $TranslationTableTable translationTable = $TranslationTableTable(
    this,
  );
  late final $JuzTableTable juzTable = $JuzTableTable(this);
  late final $MetaTableTable metaTable = $MetaTableTable(this);
  late final Index ayahSurahAyahIdx = Index(
    'ayah_surah_ayah_idx',
    'CREATE INDEX ayah_surah_ayah_idx ON ayah (surah_number, ayah_number)',
  );
  late final Index ayahJuzIdx = Index(
    'ayah_juz_idx',
    'CREATE INDEX ayah_juz_idx ON ayah (juz)',
  );
  late final Index ayahPageIdx = Index(
    'ayah_page_idx',
    'CREATE INDEX ayah_page_idx ON ayah (page)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    surahTable,
    ayahTable,
    translationEditionTable,
    translationTable,
    juzTable,
    metaTable,
    ayahSurahAyahIdx,
    ayahJuzIdx,
    ayahPageIdx,
  ];
}

typedef $$SurahTableTableCreateCompanionBuilder =
    SurahTableCompanion Function({
      Value<int> number,
      required String nameArabic,
      required String nameSimple,
      required String nameTranslated,
      required String revelationPlace,
      Value<int?> revelationOrder,
      required int ayahCount,
      required bool bismillahPre,
      required int pageStart,
      required int pageEnd,
    });
typedef $$SurahTableTableUpdateCompanionBuilder =
    SurahTableCompanion Function({
      Value<int> number,
      Value<String> nameArabic,
      Value<String> nameSimple,
      Value<String> nameTranslated,
      Value<String> revelationPlace,
      Value<int?> revelationOrder,
      Value<int> ayahCount,
      Value<bool> bismillahPre,
      Value<int> pageStart,
      Value<int> pageEnd,
    });

final class $$SurahTableTableReferences
    extends BaseReferences<_$ContentDatabase, $SurahTableTable, SurahRow> {
  $$SurahTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AyahTableTable, List<AyahRow>>
  _ayahTableRefsTable(_$ContentDatabase db) => MultiTypedResultKey.fromTable(
    db.ayahTable,
    aliasName: $_aliasNameGenerator(
      db.surahTable.number,
      db.ayahTable.surahNumber,
    ),
  );

  $$AyahTableTableProcessedTableManager get ayahTableRefs {
    final manager = $$AyahTableTableTableManager($_db, $_db.ayahTable).filter(
      (f) => f.surahNumber.number.sqlEquals($_itemColumn<int>('number')!),
    );

    final cache = $_typedResult.readTableOrNull(_ayahTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SurahTableTableFilterComposer
    extends Composer<_$ContentDatabase, $SurahTableTable> {
  $$SurahTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameSimple => $composableBuilder(
    column: $table.nameSimple,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameTranslated => $composableBuilder(
    column: $table.nameTranslated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revelationOrder => $composableBuilder(
    column: $table.revelationOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahCount => $composableBuilder(
    column: $table.ayahCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bismillahPre => $composableBuilder(
    column: $table.bismillahPre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageStart => $composableBuilder(
    column: $table.pageStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageEnd => $composableBuilder(
    column: $table.pageEnd,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ayahTableRefs(
    Expression<bool> Function($$AyahTableTableFilterComposer f) f,
  ) {
    final $$AyahTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.number,
      referencedTable: $db.ayahTable,
      getReferencedColumn: (t) => t.surahNumber,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AyahTableTableFilterComposer(
            $db: $db,
            $table: $db.ayahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SurahTableTableOrderingComposer
    extends Composer<_$ContentDatabase, $SurahTableTable> {
  $$SurahTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameSimple => $composableBuilder(
    column: $table.nameSimple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameTranslated => $composableBuilder(
    column: $table.nameTranslated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revelationOrder => $composableBuilder(
    column: $table.revelationOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahCount => $composableBuilder(
    column: $table.ayahCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bismillahPre => $composableBuilder(
    column: $table.bismillahPre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageStart => $composableBuilder(
    column: $table.pageStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageEnd => $composableBuilder(
    column: $table.pageEnd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SurahTableTableAnnotationComposer
    extends Composer<_$ContentDatabase, $SurahTableTable> {
  $$SurahTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameSimple => $composableBuilder(
    column: $table.nameSimple,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameTranslated => $composableBuilder(
    column: $table.nameTranslated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revelationOrder => $composableBuilder(
    column: $table.revelationOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahCount =>
      $composableBuilder(column: $table.ayahCount, builder: (column) => column);

  GeneratedColumn<bool> get bismillahPre => $composableBuilder(
    column: $table.bismillahPre,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageStart =>
      $composableBuilder(column: $table.pageStart, builder: (column) => column);

  GeneratedColumn<int> get pageEnd =>
      $composableBuilder(column: $table.pageEnd, builder: (column) => column);

  Expression<T> ayahTableRefs<T extends Object>(
    Expression<T> Function($$AyahTableTableAnnotationComposer a) f,
  ) {
    final $$AyahTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.number,
      referencedTable: $db.ayahTable,
      getReferencedColumn: (t) => t.surahNumber,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AyahTableTableAnnotationComposer(
            $db: $db,
            $table: $db.ayahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SurahTableTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $SurahTableTable,
          SurahRow,
          $$SurahTableTableFilterComposer,
          $$SurahTableTableOrderingComposer,
          $$SurahTableTableAnnotationComposer,
          $$SurahTableTableCreateCompanionBuilder,
          $$SurahTableTableUpdateCompanionBuilder,
          (SurahRow, $$SurahTableTableReferences),
          SurahRow,
          PrefetchHooks Function({bool ayahTableRefs})
        > {
  $$SurahTableTableTableManager(_$ContentDatabase db, $SurahTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<String> nameArabic = const Value.absent(),
                Value<String> nameSimple = const Value.absent(),
                Value<String> nameTranslated = const Value.absent(),
                Value<String> revelationPlace = const Value.absent(),
                Value<int?> revelationOrder = const Value.absent(),
                Value<int> ayahCount = const Value.absent(),
                Value<bool> bismillahPre = const Value.absent(),
                Value<int> pageStart = const Value.absent(),
                Value<int> pageEnd = const Value.absent(),
              }) => SurahTableCompanion(
                number: number,
                nameArabic: nameArabic,
                nameSimple: nameSimple,
                nameTranslated: nameTranslated,
                revelationPlace: revelationPlace,
                revelationOrder: revelationOrder,
                ayahCount: ayahCount,
                bismillahPre: bismillahPre,
                pageStart: pageStart,
                pageEnd: pageEnd,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                required String nameArabic,
                required String nameSimple,
                required String nameTranslated,
                required String revelationPlace,
                Value<int?> revelationOrder = const Value.absent(),
                required int ayahCount,
                required bool bismillahPre,
                required int pageStart,
                required int pageEnd,
              }) => SurahTableCompanion.insert(
                number: number,
                nameArabic: nameArabic,
                nameSimple: nameSimple,
                nameTranslated: nameTranslated,
                revelationPlace: revelationPlace,
                revelationOrder: revelationOrder,
                ayahCount: ayahCount,
                bismillahPre: bismillahPre,
                pageStart: pageStart,
                pageEnd: pageEnd,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SurahTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ayahTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ayahTableRefs) db.ayahTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ayahTableRefs)
                    await $_getPrefetchedData<
                      SurahRow,
                      $SurahTableTable,
                      AyahRow
                    >(
                      currentTable: table,
                      referencedTable: $$SurahTableTableReferences
                          ._ayahTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SurahTableTableReferences(
                            db,
                            table,
                            p0,
                          ).ayahTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.surahNumber == item.number,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SurahTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $SurahTableTable,
      SurahRow,
      $$SurahTableTableFilterComposer,
      $$SurahTableTableOrderingComposer,
      $$SurahTableTableAnnotationComposer,
      $$SurahTableTableCreateCompanionBuilder,
      $$SurahTableTableUpdateCompanionBuilder,
      (SurahRow, $$SurahTableTableReferences),
      SurahRow,
      PrefetchHooks Function({bool ayahTableRefs})
    >;
typedef $$AyahTableTableCreateCompanionBuilder =
    AyahTableCompanion Function({
      Value<int> id,
      required int surahNumber,
      required int ayahNumber,
      required String verseKey,
      required String textUthmani,
      required String textSearch,
      required int juz,
      required int hizb,
      required int rubElHizb,
      required int ruku,
      required int manzil,
      required int page,
      Value<String?> sajdahType,
    });
typedef $$AyahTableTableUpdateCompanionBuilder =
    AyahTableCompanion Function({
      Value<int> id,
      Value<int> surahNumber,
      Value<int> ayahNumber,
      Value<String> verseKey,
      Value<String> textUthmani,
      Value<String> textSearch,
      Value<int> juz,
      Value<int> hizb,
      Value<int> rubElHizb,
      Value<int> ruku,
      Value<int> manzil,
      Value<int> page,
      Value<String?> sajdahType,
    });

final class $$AyahTableTableReferences
    extends BaseReferences<_$ContentDatabase, $AyahTableTable, AyahRow> {
  $$AyahTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SurahTableTable _surahNumberTable(_$ContentDatabase db) =>
      db.surahTable.createAlias(
        $_aliasNameGenerator(db.ayahTable.surahNumber, db.surahTable.number),
      );

  $$SurahTableTableProcessedTableManager get surahNumber {
    final $_column = $_itemColumn<int>('surah_number')!;

    final manager = $$SurahTableTableTableManager(
      $_db,
      $_db.surahTable,
    ).filter((f) => f.number.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_surahNumberTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TranslationTableTable, List<TranslationRow>>
  _translationTableRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.translationTable,
        aliasName: $_aliasNameGenerator(
          db.ayahTable.id,
          db.translationTable.ayahId,
        ),
      );

  $$TranslationTableTableProcessedTableManager get translationTableRefs {
    final manager = $$TranslationTableTableTableManager(
      $_db,
      $_db.translationTable,
    ).filter((f) => f.ayahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _translationTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AyahTableTableFilterComposer
    extends Composer<_$ContentDatabase, $AyahTableTable> {
  $$AyahTableTableFilterComposer({
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

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textSearch => $composableBuilder(
    column: $table.textSearch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hizb => $composableBuilder(
    column: $table.hizb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rubElHizb => $composableBuilder(
    column: $table.rubElHizb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ruku => $composableBuilder(
    column: $table.ruku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manzil => $composableBuilder(
    column: $table.manzil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sajdahType => $composableBuilder(
    column: $table.sajdahType,
    builder: (column) => ColumnFilters(column),
  );

  $$SurahTableTableFilterComposer get surahNumber {
    final $$SurahTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surahNumber,
      referencedTable: $db.surahTable,
      getReferencedColumn: (t) => t.number,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahTableTableFilterComposer(
            $db: $db,
            $table: $db.surahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> translationTableRefs(
    Expression<bool> Function($$TranslationTableTableFilterComposer f) f,
  ) {
    final $$TranslationTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.translationTable,
      getReferencedColumn: (t) => t.ayahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationTableTableFilterComposer(
            $db: $db,
            $table: $db.translationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AyahTableTableOrderingComposer
    extends Composer<_$ContentDatabase, $AyahTableTable> {
  $$AyahTableTableOrderingComposer({
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

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textSearch => $composableBuilder(
    column: $table.textSearch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hizb => $composableBuilder(
    column: $table.hizb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rubElHizb => $composableBuilder(
    column: $table.rubElHizb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruku => $composableBuilder(
    column: $table.ruku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manzil => $composableBuilder(
    column: $table.manzil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sajdahType => $composableBuilder(
    column: $table.sajdahType,
    builder: (column) => ColumnOrderings(column),
  );

  $$SurahTableTableOrderingComposer get surahNumber {
    final $$SurahTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surahNumber,
      referencedTable: $db.surahTable,
      getReferencedColumn: (t) => t.number,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahTableTableOrderingComposer(
            $db: $db,
            $table: $db.surahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AyahTableTableAnnotationComposer
    extends Composer<_$ContentDatabase, $AyahTableTable> {
  $$AyahTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verseKey =>
      $composableBuilder(column: $table.verseKey, builder: (column) => column);

  GeneratedColumn<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textSearch => $composableBuilder(
    column: $table.textSearch,
    builder: (column) => column,
  );

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  GeneratedColumn<int> get hizb =>
      $composableBuilder(column: $table.hizb, builder: (column) => column);

  GeneratedColumn<int> get rubElHizb =>
      $composableBuilder(column: $table.rubElHizb, builder: (column) => column);

  GeneratedColumn<int> get ruku =>
      $composableBuilder(column: $table.ruku, builder: (column) => column);

  GeneratedColumn<int> get manzil =>
      $composableBuilder(column: $table.manzil, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<String> get sajdahType => $composableBuilder(
    column: $table.sajdahType,
    builder: (column) => column,
  );

  $$SurahTableTableAnnotationComposer get surahNumber {
    final $$SurahTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surahNumber,
      referencedTable: $db.surahTable,
      getReferencedColumn: (t) => t.number,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurahTableTableAnnotationComposer(
            $db: $db,
            $table: $db.surahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> translationTableRefs<T extends Object>(
    Expression<T> Function($$TranslationTableTableAnnotationComposer a) f,
  ) {
    final $$TranslationTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.translationTable,
      getReferencedColumn: (t) => t.ayahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationTableTableAnnotationComposer(
            $db: $db,
            $table: $db.translationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AyahTableTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $AyahTableTable,
          AyahRow,
          $$AyahTableTableFilterComposer,
          $$AyahTableTableOrderingComposer,
          $$AyahTableTableAnnotationComposer,
          $$AyahTableTableCreateCompanionBuilder,
          $$AyahTableTableUpdateCompanionBuilder,
          (AyahRow, $$AyahTableTableReferences),
          AyahRow,
          PrefetchHooks Function({bool surahNumber, bool translationTableRefs})
        > {
  $$AyahTableTableTableManager(_$ContentDatabase db, $AyahTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<String> verseKey = const Value.absent(),
                Value<String> textUthmani = const Value.absent(),
                Value<String> textSearch = const Value.absent(),
                Value<int> juz = const Value.absent(),
                Value<int> hizb = const Value.absent(),
                Value<int> rubElHizb = const Value.absent(),
                Value<int> ruku = const Value.absent(),
                Value<int> manzil = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<String?> sajdahType = const Value.absent(),
              }) => AyahTableCompanion(
                id: id,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                verseKey: verseKey,
                textUthmani: textUthmani,
                textSearch: textSearch,
                juz: juz,
                hizb: hizb,
                rubElHizb: rubElHizb,
                ruku: ruku,
                manzil: manzil,
                page: page,
                sajdahType: sajdahType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahNumber,
                required int ayahNumber,
                required String verseKey,
                required String textUthmani,
                required String textSearch,
                required int juz,
                required int hizb,
                required int rubElHizb,
                required int ruku,
                required int manzil,
                required int page,
                Value<String?> sajdahType = const Value.absent(),
              }) => AyahTableCompanion.insert(
                id: id,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                verseKey: verseKey,
                textUthmani: textUthmani,
                textSearch: textSearch,
                juz: juz,
                hizb: hizb,
                rubElHizb: rubElHizb,
                ruku: ruku,
                manzil: manzil,
                page: page,
                sajdahType: sajdahType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AyahTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({surahNumber = false, translationTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (translationTableRefs) db.translationTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (surahNumber) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.surahNumber,
                                    referencedTable: $$AyahTableTableReferences
                                        ._surahNumberTable(db),
                                    referencedColumn: $$AyahTableTableReferences
                                        ._surahNumberTable(db)
                                        .number,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (translationTableRefs)
                        await $_getPrefetchedData<
                          AyahRow,
                          $AyahTableTable,
                          TranslationRow
                        >(
                          currentTable: table,
                          referencedTable: $$AyahTableTableReferences
                              ._translationTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AyahTableTableReferences(
                                db,
                                table,
                                p0,
                              ).translationTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ayahId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AyahTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $AyahTableTable,
      AyahRow,
      $$AyahTableTableFilterComposer,
      $$AyahTableTableOrderingComposer,
      $$AyahTableTableAnnotationComposer,
      $$AyahTableTableCreateCompanionBuilder,
      $$AyahTableTableUpdateCompanionBuilder,
      (AyahRow, $$AyahTableTableReferences),
      AyahRow,
      PrefetchHooks Function({bool surahNumber, bool translationTableRefs})
    >;
typedef $$TranslationEditionTableTableCreateCompanionBuilder =
    TranslationEditionTableCompanion Function({
      required String id,
      required String language,
      required String name,
      required String translator,
      required String direction,
      required String attribution,
      required bool bundled,
      Value<int> rowid,
    });
typedef $$TranslationEditionTableTableUpdateCompanionBuilder =
    TranslationEditionTableCompanion Function({
      Value<String> id,
      Value<String> language,
      Value<String> name,
      Value<String> translator,
      Value<String> direction,
      Value<String> attribution,
      Value<bool> bundled,
      Value<int> rowid,
    });

final class $$TranslationEditionTableTableReferences
    extends
        BaseReferences<
          _$ContentDatabase,
          $TranslationEditionTableTable,
          TranslationEditionRow
        > {
  $$TranslationEditionTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TranslationTableTable, List<TranslationRow>>
  _translationTableRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.translationTable,
        aliasName: $_aliasNameGenerator(
          db.translationEditionTable.id,
          db.translationTable.editionId,
        ),
      );

  $$TranslationTableTableProcessedTableManager get translationTableRefs {
    final manager = $$TranslationTableTableTableManager(
      $_db,
      $_db.translationTable,
    ).filter((f) => f.editionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _translationTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TranslationEditionTableTableFilterComposer
    extends Composer<_$ContentDatabase, $TranslationEditionTableTable> {
  $$TranslationEditionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translator => $composableBuilder(
    column: $table.translator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bundled => $composableBuilder(
    column: $table.bundled,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> translationTableRefs(
    Expression<bool> Function($$TranslationTableTableFilterComposer f) f,
  ) {
    final $$TranslationTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.translationTable,
      getReferencedColumn: (t) => t.editionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationTableTableFilterComposer(
            $db: $db,
            $table: $db.translationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TranslationEditionTableTableOrderingComposer
    extends Composer<_$ContentDatabase, $TranslationEditionTableTable> {
  $$TranslationEditionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translator => $composableBuilder(
    column: $table.translator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bundled => $composableBuilder(
    column: $table.bundled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranslationEditionTableTableAnnotationComposer
    extends Composer<_$ContentDatabase, $TranslationEditionTableTable> {
  $$TranslationEditionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get translator => $composableBuilder(
    column: $table.translator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bundled =>
      $composableBuilder(column: $table.bundled, builder: (column) => column);

  Expression<T> translationTableRefs<T extends Object>(
    Expression<T> Function($$TranslationTableTableAnnotationComposer a) f,
  ) {
    final $$TranslationTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.translationTable,
      getReferencedColumn: (t) => t.editionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationTableTableAnnotationComposer(
            $db: $db,
            $table: $db.translationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TranslationEditionTableTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $TranslationEditionTableTable,
          TranslationEditionRow,
          $$TranslationEditionTableTableFilterComposer,
          $$TranslationEditionTableTableOrderingComposer,
          $$TranslationEditionTableTableAnnotationComposer,
          $$TranslationEditionTableTableCreateCompanionBuilder,
          $$TranslationEditionTableTableUpdateCompanionBuilder,
          (TranslationEditionRow, $$TranslationEditionTableTableReferences),
          TranslationEditionRow,
          PrefetchHooks Function({bool translationTableRefs})
        > {
  $$TranslationEditionTableTableTableManager(
    _$ContentDatabase db,
    $TranslationEditionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationEditionTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TranslationEditionTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TranslationEditionTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> translator = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> attribution = const Value.absent(),
                Value<bool> bundled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationEditionTableCompanion(
                id: id,
                language: language,
                name: name,
                translator: translator,
                direction: direction,
                attribution: attribution,
                bundled: bundled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String language,
                required String name,
                required String translator,
                required String direction,
                required String attribution,
                required bool bundled,
                Value<int> rowid = const Value.absent(),
              }) => TranslationEditionTableCompanion.insert(
                id: id,
                language: language,
                name: name,
                translator: translator,
                direction: direction,
                attribution: attribution,
                bundled: bundled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TranslationEditionTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({translationTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (translationTableRefs) db.translationTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (translationTableRefs)
                    await $_getPrefetchedData<
                      TranslationEditionRow,
                      $TranslationEditionTableTable,
                      TranslationRow
                    >(
                      currentTable: table,
                      referencedTable: $$TranslationEditionTableTableReferences
                          ._translationTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TranslationEditionTableTableReferences(
                            db,
                            table,
                            p0,
                          ).translationTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.editionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TranslationEditionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $TranslationEditionTableTable,
      TranslationEditionRow,
      $$TranslationEditionTableTableFilterComposer,
      $$TranslationEditionTableTableOrderingComposer,
      $$TranslationEditionTableTableAnnotationComposer,
      $$TranslationEditionTableTableCreateCompanionBuilder,
      $$TranslationEditionTableTableUpdateCompanionBuilder,
      (TranslationEditionRow, $$TranslationEditionTableTableReferences),
      TranslationEditionRow,
      PrefetchHooks Function({bool translationTableRefs})
    >;
typedef $$TranslationTableTableCreateCompanionBuilder =
    TranslationTableCompanion Function({
      required String editionId,
      required int ayahId,
      required String body,
      required String textSearch,
      Value<int> rowid,
    });
typedef $$TranslationTableTableUpdateCompanionBuilder =
    TranslationTableCompanion Function({
      Value<String> editionId,
      Value<int> ayahId,
      Value<String> body,
      Value<String> textSearch,
      Value<int> rowid,
    });

final class $$TranslationTableTableReferences
    extends
        BaseReferences<
          _$ContentDatabase,
          $TranslationTableTable,
          TranslationRow
        > {
  $$TranslationTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TranslationEditionTableTable _editionIdTable(_$ContentDatabase db) =>
      db.translationEditionTable.createAlias(
        $_aliasNameGenerator(
          db.translationTable.editionId,
          db.translationEditionTable.id,
        ),
      );

  $$TranslationEditionTableTableProcessedTableManager get editionId {
    final $_column = $_itemColumn<String>('edition_id')!;

    final manager = $$TranslationEditionTableTableTableManager(
      $_db,
      $_db.translationEditionTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_editionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AyahTableTable _ayahIdTable(_$ContentDatabase db) =>
      db.ayahTable.createAlias(
        $_aliasNameGenerator(db.translationTable.ayahId, db.ayahTable.id),
      );

  $$AyahTableTableProcessedTableManager get ayahId {
    final $_column = $_itemColumn<int>('ayah_id')!;

    final manager = $$AyahTableTableTableManager(
      $_db,
      $_db.ayahTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ayahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TranslationTableTableFilterComposer
    extends Composer<_$ContentDatabase, $TranslationTableTable> {
  $$TranslationTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textSearch => $composableBuilder(
    column: $table.textSearch,
    builder: (column) => ColumnFilters(column),
  );

  $$TranslationEditionTableTableFilterComposer get editionId {
    final $$TranslationEditionTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.editionId,
          referencedTable: $db.translationEditionTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TranslationEditionTableTableFilterComposer(
                $db: $db,
                $table: $db.translationEditionTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$AyahTableTableFilterComposer get ayahId {
    final $$AyahTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayahTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AyahTableTableFilterComposer(
            $db: $db,
            $table: $db.ayahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranslationTableTableOrderingComposer
    extends Composer<_$ContentDatabase, $TranslationTableTable> {
  $$TranslationTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textSearch => $composableBuilder(
    column: $table.textSearch,
    builder: (column) => ColumnOrderings(column),
  );

  $$TranslationEditionTableTableOrderingComposer get editionId {
    final $$TranslationEditionTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.editionId,
          referencedTable: $db.translationEditionTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TranslationEditionTableTableOrderingComposer(
                $db: $db,
                $table: $db.translationEditionTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$AyahTableTableOrderingComposer get ayahId {
    final $$AyahTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayahTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AyahTableTableOrderingComposer(
            $db: $db,
            $table: $db.ayahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranslationTableTableAnnotationComposer
    extends Composer<_$ContentDatabase, $TranslationTableTable> {
  $$TranslationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get textSearch => $composableBuilder(
    column: $table.textSearch,
    builder: (column) => column,
  );

  $$TranslationEditionTableTableAnnotationComposer get editionId {
    final $$TranslationEditionTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.editionId,
          referencedTable: $db.translationEditionTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TranslationEditionTableTableAnnotationComposer(
                $db: $db,
                $table: $db.translationEditionTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$AyahTableTableAnnotationComposer get ayahId {
    final $$AyahTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayahTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AyahTableTableAnnotationComposer(
            $db: $db,
            $table: $db.ayahTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranslationTableTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $TranslationTableTable,
          TranslationRow,
          $$TranslationTableTableFilterComposer,
          $$TranslationTableTableOrderingComposer,
          $$TranslationTableTableAnnotationComposer,
          $$TranslationTableTableCreateCompanionBuilder,
          $$TranslationTableTableUpdateCompanionBuilder,
          (TranslationRow, $$TranslationTableTableReferences),
          TranslationRow,
          PrefetchHooks Function({bool editionId, bool ayahId})
        > {
  $$TranslationTableTableTableManager(
    _$ContentDatabase db,
    $TranslationTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranslationTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranslationTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> editionId = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> textSearch = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationTableCompanion(
                editionId: editionId,
                ayahId: ayahId,
                body: body,
                textSearch: textSearch,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String editionId,
                required int ayahId,
                required String body,
                required String textSearch,
                Value<int> rowid = const Value.absent(),
              }) => TranslationTableCompanion.insert(
                editionId: editionId,
                ayahId: ayahId,
                body: body,
                textSearch: textSearch,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TranslationTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({editionId = false, ayahId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (editionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.editionId,
                                referencedTable:
                                    $$TranslationTableTableReferences
                                        ._editionIdTable(db),
                                referencedColumn:
                                    $$TranslationTableTableReferences
                                        ._editionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (ayahId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ayahId,
                                referencedTable:
                                    $$TranslationTableTableReferences
                                        ._ayahIdTable(db),
                                referencedColumn:
                                    $$TranslationTableTableReferences
                                        ._ayahIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TranslationTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $TranslationTableTable,
      TranslationRow,
      $$TranslationTableTableFilterComposer,
      $$TranslationTableTableOrderingComposer,
      $$TranslationTableTableAnnotationComposer,
      $$TranslationTableTableCreateCompanionBuilder,
      $$TranslationTableTableUpdateCompanionBuilder,
      (TranslationRow, $$TranslationTableTableReferences),
      TranslationRow,
      PrefetchHooks Function({bool editionId, bool ayahId})
    >;
typedef $$JuzTableTableCreateCompanionBuilder =
    JuzTableCompanion Function({
      Value<int> number,
      required String firstVerseKey,
      required String lastVerseKey,
      required String nameArabic,
      required String nameTransliterated,
    });
typedef $$JuzTableTableUpdateCompanionBuilder =
    JuzTableCompanion Function({
      Value<int> number,
      Value<String> firstVerseKey,
      Value<String> lastVerseKey,
      Value<String> nameArabic,
      Value<String> nameTransliterated,
    });

class $$JuzTableTableFilterComposer
    extends Composer<_$ContentDatabase, $JuzTableTable> {
  $$JuzTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstVerseKey => $composableBuilder(
    column: $table.firstVerseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastVerseKey => $composableBuilder(
    column: $table.lastVerseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameTransliterated => $composableBuilder(
    column: $table.nameTransliterated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JuzTableTableOrderingComposer
    extends Composer<_$ContentDatabase, $JuzTableTable> {
  $$JuzTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstVerseKey => $composableBuilder(
    column: $table.firstVerseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastVerseKey => $composableBuilder(
    column: $table.lastVerseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameTransliterated => $composableBuilder(
    column: $table.nameTransliterated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JuzTableTableAnnotationComposer
    extends Composer<_$ContentDatabase, $JuzTableTable> {
  $$JuzTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get firstVerseKey => $composableBuilder(
    column: $table.firstVerseKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastVerseKey => $composableBuilder(
    column: $table.lastVerseKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameTransliterated => $composableBuilder(
    column: $table.nameTransliterated,
    builder: (column) => column,
  );
}

class $$JuzTableTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $JuzTableTable,
          JuzRow,
          $$JuzTableTableFilterComposer,
          $$JuzTableTableOrderingComposer,
          $$JuzTableTableAnnotationComposer,
          $$JuzTableTableCreateCompanionBuilder,
          $$JuzTableTableUpdateCompanionBuilder,
          (JuzRow, BaseReferences<_$ContentDatabase, $JuzTableTable, JuzRow>),
          JuzRow,
          PrefetchHooks Function()
        > {
  $$JuzTableTableTableManager(_$ContentDatabase db, $JuzTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JuzTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JuzTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JuzTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<String> firstVerseKey = const Value.absent(),
                Value<String> lastVerseKey = const Value.absent(),
                Value<String> nameArabic = const Value.absent(),
                Value<String> nameTransliterated = const Value.absent(),
              }) => JuzTableCompanion(
                number: number,
                firstVerseKey: firstVerseKey,
                lastVerseKey: lastVerseKey,
                nameArabic: nameArabic,
                nameTransliterated: nameTransliterated,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                required String firstVerseKey,
                required String lastVerseKey,
                required String nameArabic,
                required String nameTransliterated,
              }) => JuzTableCompanion.insert(
                number: number,
                firstVerseKey: firstVerseKey,
                lastVerseKey: lastVerseKey,
                nameArabic: nameArabic,
                nameTransliterated: nameTransliterated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JuzTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $JuzTableTable,
      JuzRow,
      $$JuzTableTableFilterComposer,
      $$JuzTableTableOrderingComposer,
      $$JuzTableTableAnnotationComposer,
      $$JuzTableTableCreateCompanionBuilder,
      $$JuzTableTableUpdateCompanionBuilder,
      (JuzRow, BaseReferences<_$ContentDatabase, $JuzTableTable, JuzRow>),
      JuzRow,
      PrefetchHooks Function()
    >;
typedef $$MetaTableTableCreateCompanionBuilder =
    MetaTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$MetaTableTableUpdateCompanionBuilder =
    MetaTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$MetaTableTableFilterComposer
    extends Composer<_$ContentDatabase, $MetaTableTable> {
  $$MetaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaTableTableOrderingComposer
    extends Composer<_$ContentDatabase, $MetaTableTable> {
  $$MetaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaTableTableAnnotationComposer
    extends Composer<_$ContentDatabase, $MetaTableTable> {
  $$MetaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaTableTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $MetaTableTable,
          MetaRow,
          $$MetaTableTableFilterComposer,
          $$MetaTableTableOrderingComposer,
          $$MetaTableTableAnnotationComposer,
          $$MetaTableTableCreateCompanionBuilder,
          $$MetaTableTableUpdateCompanionBuilder,
          (
            MetaRow,
            BaseReferences<_$ContentDatabase, $MetaTableTable, MetaRow>,
          ),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$MetaTableTableTableManager(_$ContentDatabase db, $MetaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaTableCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $MetaTableTable,
      MetaRow,
      $$MetaTableTableFilterComposer,
      $$MetaTableTableOrderingComposer,
      $$MetaTableTableAnnotationComposer,
      $$MetaTableTableCreateCompanionBuilder,
      $$MetaTableTableUpdateCompanionBuilder,
      (MetaRow, BaseReferences<_$ContentDatabase, $MetaTableTable, MetaRow>),
      MetaRow,
      PrefetchHooks Function()
    >;

class $ContentDatabaseManager {
  final _$ContentDatabase _db;
  $ContentDatabaseManager(this._db);
  $$SurahTableTableTableManager get surahTable =>
      $$SurahTableTableTableManager(_db, _db.surahTable);
  $$AyahTableTableTableManager get ayahTable =>
      $$AyahTableTableTableManager(_db, _db.ayahTable);
  $$TranslationEditionTableTableTableManager get translationEditionTable =>
      $$TranslationEditionTableTableTableManager(
        _db,
        _db.translationEditionTable,
      );
  $$TranslationTableTableTableManager get translationTable =>
      $$TranslationTableTableTableManager(_db, _db.translationTable);
  $$JuzTableTableTableManager get juzTable =>
      $$JuzTableTableTableManager(_db, _db.juzTable);
  $$MetaTableTableTableManager get metaTable =>
      $$MetaTableTableTableManager(_db, _db.metaTable);
}
