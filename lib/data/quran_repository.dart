import 'package:drift/drift.dart';

import '../core/db/content_db.dart';
import '../core/quran/bismillah.dart';
import '../core/quran/references.dart';
import '../domain/models/ayah.dart';
import '../domain/models/juz.dart';
import '../domain/models/surah.dart';
import '../domain/models/translation_edition.dart';

/// The Quran read model.
///
/// This is the ONLY place database rows become [Ayah] models, and therefore the
/// only place `presentVerse` is called (as `toAyahView` is in the web app's
/// service.ts). Every consumer — surah reader, juz reader, ayah detail, search,
/// bookmarks, copy and share — gets the same answer without remembering to ask.
class QuranRepository {
  QuranRepository(this._db);

  final ContentDatabase _db;

  // Surahs and juz never change at runtime, so they are read once.
  late final Future<List<Surah>> _surahs = _loadSurahs();
  late final Future<List<Juz>> _juzs = _loadJuzs();

  /// All 114 surahs in mushaf order.
  Future<List<Surah>> surahs() => _surahs;

  /// One surah, or null for a number outside 1..114.
  Future<Surah?> surah(int number) async {
    if (ayahCount(number) == null) return null;
    return (await _surahs)[number - 1];
  }

  /// All 30 juz in order.
  Future<List<Juz>> juzs() => _juzs;

  /// Every installed translation (bundled and downloaded).
  Future<List<TranslationEdition>> editions() async {
    final rows =
        await (_db.select(_db.translationEditionTable)..orderBy([
              (t) => OrderingTerm.desc(t.bundled),
              (t) => OrderingTerm.asc(t.name),
            ]))
            .get();
    return rows.map(_toEdition).toList();
  }

  /// Every value in the content database's `meta` table.
  Future<Map<String, String>> meta() async => {
    for (final row in await _db.select(_db.metaTable).get()) row.key: row.value,
  };

  /// The ayat of one surah, with [translationIds] in that order.
  Future<List<Ayah>> surahAyahs(
    int surah, {
    List<String> translationIds = const [],
  }) => _ayahs(
    (t) => t.surahNumber.equals(surah),
    translationIds: translationIds,
  );

  /// The ayat of one juz, in mushaf order across surah boundaries.
  Future<List<Ayah>> juzAyahs(
    int juz, {
    List<String> translationIds = const [],
  }) => _ayahs((t) => t.juz.equals(juz), translationIds: translationIds);

  /// Specific ayat by mushaf-wide id, returned in the order requested.
  Future<List<Ayah>> ayahsByIds(
    List<int> ids, {
    List<String> translationIds = const [],
  }) async {
    if (ids.isEmpty) return const [];
    final byId = {
      for (final ayah in await _ayahs(
        (t) => t.id.isIn(ids),
        translationIds: translationIds,
      ))
        ayah.id: ayah,
    };
    return [for (final id in ids) ?byId[id]];
  }

  /// One ayah by "surah:ayah" key, or null when the key does not exist.
  Future<Ayah?> ayah(
    String verseKey, {
    List<String> translationIds = const [],
  }) async {
    if (parseVerseKey(verseKey) == null) return null;
    final rows = await _ayahs(
      (t) => t.verseKey.equals(verseKey),
      translationIds: translationIds,
    );
    return rows.firstOrNull;
  }

  /// Mushaf-wide id of a verse key (1..6236), computed from AYAH_COUNTS.
  static int? ayahIdFor(String verseKey) {
    final parsed = parseVerseKey(verseKey);
    if (parsed == null) return null;
    var id = parsed.ayah;
    for (var s = 1; s < parsed.surah; s++) {
      id += ayahCounts[s - 1];
    }
    return id;
  }

  // ---------------------------------------------------------------------------

  Future<List<Ayah>> _ayahs(
    Expression<bool> Function($AyahTableTable t) where, {
    required List<String> translationIds,
  }) async {
    final rows =
        await (_db.select(_db.ayahTable)
              ..where(where)
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();
    if (rows.isEmpty) return const [];

    final surahs = await _surahs;
    final translations = await _translationsFor(
      rows.map((r) => r.id).toList(),
      translationIds,
    );
    return [
      for (final row in rows)
        _toAyah(
          row,
          bismillahPre: surahs[row.surahNumber - 1].bismillahPre,
          translations: translations[row.id] ?? const [],
        ),
    ];
  }

  /// Translations for [ayahIds], grouped by ayah, in [editionIds] order.
  Future<Map<int, List<AyahTranslation>>> _translationsFor(
    List<int> ayahIds,
    List<String> editionIds,
  ) async {
    if (editionIds.isEmpty) return const {};
    final installed = {for (final e in await editions()) e.id: e};
    final wanted = editionIds.where(installed.containsKey).toList();
    if (wanted.isEmpty) return const {};

    // Ayah ids of a surah or juz are contiguous, so a range beats a long IN.
    final first = ayahIds.reduce((a, b) => a < b ? a : b);
    final last = ayahIds.reduce((a, b) => a > b ? a : b);
    final contiguous = last - first + 1 == ayahIds.length;
    final query = _db.select(_db.translationTable)
      ..where(
        (t) =>
            t.editionId.isIn(wanted) &
            (contiguous
                ? t.ayahId.isBetweenValues(first, last)
                : t.ayahId.isIn(ayahIds)),
      );

    final byAyah = <int, Map<String, TranslationRow>>{};
    for (final row in await query.get()) {
      (byAyah[row.ayahId] ??= {})[row.editionId] = row;
    }
    return {
      for (final MapEntry(key: ayahId, value: rows) in byAyah.entries)
        ayahId: [
          for (final id in wanted)
            if (rows[id] case final row?)
              AyahTranslation(
                editionId: id,
                text: row.body,
                language: installed[id]!.language,
                isRtl: installed[id]!.isRtl,
              ),
        ],
    };
  }

  /// The single call site of `presentVerse` in the app.
  Ayah _toAyah(
    AyahRow row, {
    required bool bismillahPre,
    required List<AyahTranslation> translations,
  }) {
    final presented = presentVerse(
      surahNumber: row.surahNumber,
      ayahNumber: row.ayahNumber,
      text: row.textUthmani,
      bismillahPre: bismillahPre,
    );
    return Ayah(
      id: row.id,
      surahNumber: row.surahNumber,
      ayahNumber: row.ayahNumber,
      textUthmani: row.textUthmani,
      displayText: presented.text,
      leadingBismillah: presented.bismillah,
      bismillahPre: bismillahPre,
      juz: row.juz,
      hizb: row.hizb,
      rubElHizb: row.rubElHizb,
      ruku: row.ruku,
      manzil: row.manzil,
      page: row.page,
      sajdahType: switch (row.sajdahType) {
        'obligatory' => SajdahType.obligatory,
        'recommended' => SajdahType.recommended,
        _ => null,
      },
      translations: translations,
    );
  }

  Future<List<Surah>> _loadSurahs() async {
    final rows = await (_db.select(
      _db.surahTable,
    )..orderBy([(t) => OrderingTerm.asc(t.number)])).get();
    return [
      for (final r in rows)
        Surah(
          number: r.number,
          nameArabic: r.nameArabic,
          nameSimple: r.nameSimple,
          nameTranslated: r.nameTranslated,
          revelationPlace: r.revelationPlace == 'makkah'
              ? RevelationPlace.makkah
              : RevelationPlace.madinah,
          revelationOrder: r.revelationOrder,
          ayahCount: r.ayahCount,
          bismillahPre: r.bismillahPre,
          pageStart: r.pageStart,
          pageEnd: r.pageEnd,
        ),
    ];
  }

  Future<List<Juz>> _loadJuzs() async {
    final rows = await (_db.select(
      _db.juzTable,
    )..orderBy([(t) => OrderingTerm.asc(t.number)])).get();
    final spans = await _db
        .customSelect(
          'SELECT juz, surah_number FROM ayah GROUP BY juz, surah_number '
          'ORDER BY juz, surah_number',
        )
        .get();
    final surahsByJuz = <int, List<int>>{};
    for (final span in spans) {
      (surahsByJuz[span.read<int>('juz')] ??= []).add(
        span.read<int>('surah_number'),
      );
    }
    return [
      for (final r in rows)
        Juz(
          number: r.number,
          firstVerseKey: r.firstVerseKey,
          lastVerseKey: r.lastVerseKey,
          firstAyahId: ayahIdFor(r.firstVerseKey)!,
          lastAyahId: ayahIdFor(r.lastVerseKey)!,
          nameArabic: r.nameArabic,
          nameTransliterated: r.nameTransliterated,
          surahNumbers: surahsByJuz[r.number] ?? const [],
        ),
    ];
  }

  static TranslationEdition _toEdition(TranslationEditionRow r) =>
      TranslationEdition(
        id: r.id,
        language: r.language,
        name: r.name,
        translator: r.translator,
        isRtl: r.direction == 'rtl',
        attribution: r.attribution,
        bundled: r.bundled,
      );
}
