// Builds assets/db/quran.db from AlQuran.cloud (Uthmani text, translations,
// structure), Quran.com (the IndoPak Nastaleeq text) and QUL (the QPC
// Nastaleeq text, from tool/sources/).
//
// Usage (from the quran_app directory):
//   dart run tool/build_quran_db.dart
//
// Mirrors islamic-platform/src/modules/ingestion/quran-sync.ts:
//   - text is sanitised BEFORE it is validated, so a verse consisting only of
//     a BOM fails the empty-text check instead of slipping through;
//   - a surah whose ayah count is wrong is a data-integrity failure;
//   - the Arabic is stored verbatim (no NFC/NFKC, no diacritic stripping);
//     folding happens only in the separate, never-displayed `text_search`.
//
// Any validation failure aborts the build with every error listed. Nothing is
// written unless the whole corpus passes.

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:quran_app/core/db/content_db.dart';
import 'package:quran_app/core/quran/attribution.dart';
import 'package:quran_app/core/quran/bismillah.dart';
import 'package:quran_app/core/quran/indopak.dart';
import 'package:quran_app/core/quran/qpc_nastaleeq.dart';
import 'package:quran_app/core/quran/references.dart';
import 'package:quran_app/core/text/arabic_digits.dart';
import 'package:quran_app/core/text/normalize.dart';

import 'src/alquran_cloud.dart';
import 'src/expected_structure.dart';
import 'src/qul_qpc_nastaleeq.dart';
import 'src/quran_com.dart';

/// Translations shipped inside the app, in default display order.
const bundledTranslations = ['en.sahih', 'ur.jalandhry'];

/// Bump when the content schema changes.
const contentSchemaVersion = 3;

Future<void> main() async {
  final root = Directory.current;
  if (!File(p.join(root.path, 'pubspec.yaml')).existsSync()) {
    stderr.writeln('Run this from the quran_app directory.');
    exitCode = 2;
    return;
  }

  final cacheDir = Directory(p.join(root.path, 'tool', 'cache'));
  final client = AlQuranCloudClient(cacheDir: cacheDir);
  final quranCom = QuranComClient(cacheDir: cacheDir);

  try {
    stdout.writeln('Loading source data (cached in tool/cache/)…');
    final surahs = await client.surahs();
    final meta = await client.meta();
    final arabic = await client.quran(arabicEdition);
    final editions = await client.translationEditions();
    final translations = [
      for (final id in bundledTranslations)
        await client.quran(
          id,
          reportedDirection: editions[id]?['direction'] as String?,
        ),
    ];

    final indopak = await quranCom.indopak();
    final qpcNastaleeq = loadQpcNastaleeq(
      File(p.join(root.path, qpcNastaleeqSourcePath)),
    );

    final corpus = Corpus.sanitised(
      surahs,
      arabic,
      translations,
      indopak,
      qpcNastaleeq,
    );

    final errors = <String>[
      ...corpus.validateStructure(),
      ...corpus.validateJuzAgainstMeta(meta),
      ...corpus.validateTranslations(),
      ...corpus.crossCheckBismillah(),
      ...corpus.validateIndopak(),
      ...corpus.validateQpcNastaleeq(),
    ];
    if (errors.isNotEmpty) {
      stderr.writeln('\nVALIDATION FAILED (${errors.length} errors):');
      for (final error in errors) {
        stderr.writeln('  - $error');
      }
      stderr.writeln('Nothing was written.');
      exitCode = 1;
      return;
    }

    final dbFile = File(p.join(root.path, 'assets', 'db', 'quran.db'));
    final dataVersion = corpus.dataVersion();
    await writeDatabase(corpus, dbFile, dataVersion);
    writeManifest(File(p.join(root.path, 'assets', 'db', 'manifest.json')), {
      'schemaVersion': contentSchemaVersion,
      'dataVersion': dataVersion,
    });

    corpus.printSummary(dbFile, dataVersion);
  } finally {
    client.close();
    quranCom.close();
  }
}

/// One ayah after sanitising, with its structural fields.
class SourceAyah {
  SourceAyah(this.raw) : text = sanitizeSourceText(raw.text);

  final CloudAyah raw;

  /// sanitizeSourceText(raw.text): the only change ever made to the text.
  final String text;
}

/// The full downloaded corpus, sanitised and ready to validate.
class Corpus {
  Corpus._(
    this.surahs,
    this.ayahs,
    this.translations,
    this.indopakSource,
    this.qpcNastaleeq,
  );

  factory Corpus.sanitised(
    List<CloudSurah> surahs,
    CloudQuran arabic,
    List<CloudQuran> translations,
    Map<String, String> indopak,
    Map<String, String> qpcNastaleeq,
  ) => Corpus._(
    surahs,
    arabic.ayahs.map(SourceAyah.new).toList(),
    {
      for (final t in translations)
        t.edition: t.ayahs.map(SourceAyah.new).toList(),
    },
    {
      for (final MapEntry(:key, :value) in indopak.entries)
        key: sanitizeSourceText(value),
    },
    qpcNastaleeq,
  );

  /// The QPC Nastaleeq text by verse key, stored exactly as QUL supplied it
  /// (words joined; see tool/src/qul_qpc_nastaleeq.dart).
  final Map<String, String> qpcNastaleeq;

  /// The Indo-Pak text by verse key, as Quran.com supplied it (sanitised).
  final Map<String, String> indopakSource;

  /// The Indo-Pak text as stored: the source, except al-Fatihah's verse-end
  /// circles are renumbered (see [indopakFor]).
  late final Map<String, String> indopak = {
    for (final MapEntry(:key, :value) in indopakSource.entries)
      key: indopakFor(key, value),
  };

  final List<CloudSurah> surahs;
  final List<SourceAyah> ayahs;
  final Map<CloudEdition, List<SourceAyah>> translations;

  // --------------------------------------------------------------------------
  // Validation
  // --------------------------------------------------------------------------

  List<String> validateStructure() {
    final errors = <String>[];

    if (surahs.length != surahCount) {
      errors.add('expected $surahCount surahs, got ${surahs.length}');
    }
    if (ayahs.length != totalAyahCount) {
      errors.add('expected $totalAyahCount ayahs, got ${ayahs.length}');
    }

    // Per-surah counts against AYAH_COUNTS and the surah list.
    for (var s = 1; s <= surahCount; s++) {
      final actual = ayahs.where((a) => a.raw.surahNumber == s).length;
      if (actual != ayahCount(s)) {
        errors.add('surah $s: expected ${ayahCount(s)} ayat, got $actual');
      }
      final listed = surahs.where((x) => x.number == s).firstOrNull;
      if (listed == null) {
        errors.add('surah $s missing from the surah list');
      } else if (listed.numberOfAyahs != ayahCount(s)) {
        errors.add('surah $s: list says ${listed.numberOfAyahs} ayat');
      }
    }

    // Order, numbering and non-empty text.
    for (var i = 0; i < ayahs.length; i++) {
      final a = ayahs[i];
      if (a.raw.number != i + 1) {
        errors.add(
          '${a.raw.verseKey}: global number ${a.raw.number} != ${i + 1}',
        );
      }
      if (!isValidVerseKey(a.raw.surahNumber, a.raw.numberInSurah)) {
        errors.add('${a.raw.verseKey}: impossible verse key');
      }
      if (a.text.isEmpty) errors.add('${a.raw.verseKey}: empty Arabic text');
      if (a.raw.hizbQuarter < 1 || a.raw.hizbQuarter > 240) {
        errors.add('${a.raw.verseKey}: hizbQuarter ${a.raw.hizbQuarter}');
      }
    }

    errors
      ..addAll(_validateSequence('juz', (a) => a.juz, 1, juzCount))
      ..addAll(_validateSequence('page', (a) => a.page, 1, expectedPageCount));

    // First ayah of each juz, from the data's own juz field.
    for (var juz = 1; juz <= juzCount; juz++) {
      final first = ayahs.where((a) => a.raw.juz == juz).firstOrNull;
      final expected = expectedJuzStarts[juz - 1];
      if (first?.raw.verseKey != expected) {
        errors.add(
          'juz $juz starts at ${first?.raw.verseKey}, expected $expected',
        );
      }
    }
    return errors;
  }

  /// A field must start at [min], never decrease, never skip, and end at [max].
  List<String> _validateSequence(
    String label,
    int Function(CloudAyah) field,
    int min,
    int max,
  ) {
    final errors = <String>[];
    var previous = min;
    for (final a in ayahs) {
      final value = field(a.raw);
      if (value != previous && value != previous + 1) {
        errors.add(
          '$label jumps from $previous to $value at ${a.raw.verseKey}',
        );
      }
      previous = value;
    }
    if (field(ayahs.first.raw) != min) {
      errors.add('$label does not start at $min');
    }
    if (previous != max) errors.add('$label ends at $previous, expected $max');
    return errors;
  }

  /// Cross-checks the juz table against the provider's own `/meta` structure.
  List<String> validateJuzAgainstMeta(Map<String, dynamic> meta) {
    final refs =
        ((meta['juzs'] as Map<String, dynamic>)['references'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    if (refs.length != juzCount) {
      return ['meta lists ${refs.length} juz, expected $juzCount'];
    }
    return [
      for (var i = 0; i < juzCount; i++)
        if ('${refs[i]['surah']}:${refs[i]['ayah']}' != expectedJuzStarts[i])
          'meta juz ${i + 1} starts at ${refs[i]['surah']}:${refs[i]['ayah']}',
    ];
  }

  /// Every bundled translation has exactly one non-empty row per ayah.
  List<String> validateTranslations() {
    final errors = <String>[];
    for (final MapEntry(key: edition, value: rows) in translations.entries) {
      final id = edition.identifier;
      if (rows.length != totalAyahCount) {
        errors.add('$id: ${rows.length} rows, expected $totalAyahCount');
        continue;
      }
      for (var i = 0; i < rows.length; i++) {
        if (rows[i].raw.verseKey != ayahs[i].raw.verseKey) {
          errors.add('$id: row ${i + 1} is ${rows[i].raw.verseKey}');
        }
        if (rows[i].text.isEmpty) {
          errors.add('$id: empty text at ${rows[i].raw.verseKey}');
        }
      }
    }
    return errors;
  }

  /// Runs the Dart bismillah port over the whole corpus.
  List<String> crossCheckBismillah() {
    final errors = <String>[];
    var separatedCount = 0;

    for (final a in ayahs) {
      final surah = a.raw.surahNumber;
      final ayah = a.raw.numberInSurah;
      final presented = presentVerse(
        surahNumber: surah,
        ayahNumber: ayah,
        text: a.text,
        bismillahPre: bismillahPreFor(surah),
      );
      final key = a.raw.verseKey;

      if (presented.text.trim().isEmpty) errors.add('$key: empty displayText');

      if (presented.separated) {
        separatedCount++;
        final rebuilt = collapseWhitespace(
          '${presented.bismillah} ${presented.text}',
        );
        if (rebuilt != collapseWhitespace(a.text)) {
          errors.add('$key: bismillah split is not lossless');
        }
      } else if (ayah == 1 &&
          shouldRenderHeaderBismillah(
            surah,
            bismillahPre: bismillahPreFor(surah),
          )) {
        errors.add('$key: header renders basmalah but ayah 1 did not separate');
      }
    }

    if (separatedCount != 112) {
      errors.add('expected 112 separated ayat, got $separatedCount');
    }

    // 1:1 IS the basmalah; 9:1 has none; 27:30 quotes it mid-surah.
    for (final key in ['1:1', '9:1', '27:30']) {
      final a = ayahs.firstWhere((x) => x.raw.verseKey == key);
      final presented = presentVerse(
        surahNumber: a.raw.surahNumber,
        ayahNumber: a.raw.numberInSurah,
        text: a.text,
        bismillahPre: bismillahPreFor(a.raw.surahNumber),
      );
      if (presented.separated || presented.text != a.text) {
        errors.add('$key must be shown unchanged');
      }
    }

    // Surahs 95 and 97 carry the shadda-on-ba variant the port must handle.
    for (final surah in [95, 97]) {
      final first = ayahs.firstWhere(
        (x) => x.raw.surahNumber == surah && x.raw.numberInSurah == 1,
      );
      if (!first.text.startsWith(String.fromCharCodes([0x0628, 0x0651]))) {
        errors.add(
          '$surah:1 no longer has the shadda variant; review bismillah.dart',
        );
      }
    }
    return errors;
  }

  /// The Indo-Pak text has exactly one verse per Uthmani verse, each ending
  /// with the verse-end glyph for its own number, and no basmalah prefix.
  List<String> validateIndopak() {
    final errors = <String>[];
    final keys = ayahs.map((a) => a.raw.verseKey).toList();
    if (indopakSource.length != totalAyahCount ||
        indopakSource.keys.join(',') != keys.join(',')) {
      return ['indopak: verses differ from the Uthmani text'];
    }
    final foldedBasmalah = stripArabicDiacritics(indopakBasmalah);
    for (final a in ayahs) {
      final key = a.raw.verseKey;
      final text = indopak[key]!;
      if (stripArabicDiacritics(text).trim().length < 2) {
        errors.add('$key: empty indopak text');
      }
      // Exactly one verse-end glyph, at the very end (22:77 alone places its
      // rounded zero after it), showing this verse's own number.
      final runes = text.runes.toList();
      final ends = [
        for (var i = 0; i < runes.length; i++)
          if (indopakVerseEndNumber(runes[i]) != null) i,
      ];
      if (ends.length != 1) {
        errors.add('$key: ${ends.length} indopak verse-end glyphs');
        continue;
      }
      final code = runes[ends.single];
      final after = runes.sublist(ends.single + 1);
      if (!(after.isEmpty ||
          (key == '22:77' && after.length == 1 && after.single == 0x06DF))) {
        errors.add('$key: text after the indopak verse-end glyph');
      }
      if (indopakVerseEndNumber(code) != a.raw.numberInSurah) {
        errors.add(
          '$key: indopak verse end shows ${indopakVerseEndNumber(code)}',
        );
      }
      if (indopakSajdahVerseEnds.contains(code) != (a.raw.sajdahType != null)) {
        errors.add('$key: indopak sajdah sign disagrees with the data');
      }
      // The header shows the basmalah on its own; no verse may repeat it.
      if (a.raw.numberInSurah == 1 &&
          a.raw.surahNumber != 1 &&
          stripArabicDiacritics(text).startsWith(foldedBasmalah)) {
        errors.add('$key: indopak verse starts with the basmalah');
      }
    }
    if (indopak['1:1'] != '$indopakBasmalah \u{06DF}${indopakVerseEnd(1)}') {
      errors.add('1:1: indopak text is not the expected basmalah');
    }
    return errors;
  }

  /// The QPC Nastaleeq text has exactly one verse per Uthmani verse, each
  /// ending with its own number (plus only the signs drawn above it), and no
  /// basmalah prefix.
  List<String> validateQpcNastaleeq() {
    final keys = ayahs.map((a) => a.raw.verseKey).toList();
    if (qpcNastaleeq.length != totalAyahCount ||
        qpcNastaleeq.keys.join(',') != keys.join(',')) {
      return ['qpc nastaleeq: verses differ from the Uthmani text'];
    }
    final errors = <String>[];
    final foldedBasmalah = stripArabicDiacritics(qpcNastaleeqBasmalah);
    for (final a in ayahs) {
      final key = a.raw.verseKey;
      final text = qpcNastaleeq[key]!;
      if (text != sanitizeSourceText(text) || text.contains('\u00A0')) {
        errors.add('$key: qpc nastaleeq text has invisible characters');
      }
      final space = text.lastIndexOf(' ');
      if (space < 1) {
        errors.add('$key: qpc nastaleeq verse has no number');
        continue;
      }
      // The last word: this verse's number, then only verse-end signs.
      final end = text.substring(space + 1);
      final digits = toArabicIndicDigits(a.raw.numberInSurah);
      final signs = end.substring(end.startsWith(digits) ? digits.length : 0);
      if (!end.startsWith(digits) || !signs.runes.every(isQpcNastaleeqSign)) {
        errors.add('$key: qpc nastaleeq verse ends with "$end"');
      }
      // Nor may a number or a verse-end sign appear anywhere else.
      final body = text.substring(0, space);
      if (RegExp('[\u0660-\u0669]').hasMatch(body)) {
        errors.add('$key: digits inside the qpc nastaleeq verse');
      }
      // 22:77 is not a sajdah in the Hanafi Indo-Pak mushaf this text follows.
      final sajdah = signs.runes.any(qpcNastaleeqSajdahSigns.contains);
      if (sajdah != (a.raw.sajdahType != null && key != '22:77')) {
        errors.add('$key: qpc nastaleeq sajdah sign disagrees with the data');
      }
      if (a.raw.numberInSurah == 1 &&
          a.raw.surahNumber != 1 &&
          stripArabicDiacritics(text).startsWith(foldedBasmalah)) {
        errors.add('$key: qpc nastaleeq verse starts with the basmalah');
      }
    }
    if (qpcNastaleeq['1:1'] !=
        '$qpcNastaleeqBasmalah ${toArabicIndicDigits(1)}') {
      errors.add('1:1: qpc nastaleeq text is not the expected basmalah');
    }
    return errors;
  }

  // --------------------------------------------------------------------------
  // Derived data
  // --------------------------------------------------------------------------

  /// A deterministic fingerprint of everything stored (FNV-1a, 64-bit).
  String dataVersion() {
    var hash = 0xcbf29ce484222325;
    void add(String value) {
      for (final unit in utf8.encode(value)) {
        hash ^= unit;
        hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
      }
    }

    for (final a in ayahs) {
      add(
        '${a.raw.verseKey}|${a.text}|${indopak[a.raw.verseKey]}|'
        '${qpcNastaleeq[a.raw.verseKey]}|'
        '${a.raw.juz}|${a.raw.page}|'
        '${a.raw.hizbQuarter}|${a.raw.ruku}|${a.raw.manzil}|${a.raw.sajdahType}',
      );
    }
    for (final MapEntry(key: edition, value: rows) in translations.entries) {
      add(
        '${edition.identifier}|${edition.language}|${edition.direction}|'
        '${edition.attribution}',
      );
      for (final row in rows) {
        add(row.text);
      }
    }
    add('schema:$contentSchemaVersion');
    return BigInt.from(hash).toUnsigned(64).toRadixString(16).padLeft(16, '0');
  }

  void printSummary(File dbFile, String dataVersion) {
    final sizeMb = dbFile.lengthSync() / (1024 * 1024);
    stdout
      ..writeln('\nAll validations passed.')
      ..writeln('  surahs:        ${surahs.length}')
      ..writeln('  ayahs:         ${ayahs.length}')
      ..writeln(
        '  translations:  ${translations.keys.map((e) => e.identifier).join(', ')}',
      )
      ..writeln('  juz / pages:   $juzCount / $expectedPageCount')
      ..writeln('  bismillah:     112 separated; 1:1, 9:1, 27:30 unchanged')
      ..writeln('  indopak:       ${indopak.length} verses, verse ends checked')
      ..writeln(
        '  qpc nastaleeq: ${qpcNastaleeq.length} verses, verse ends checked',
      )
      ..writeln('  data version:  $dataVersion')
      ..writeln(
        '  wrote:         ${dbFile.path} (${sizeMb.toStringAsFixed(1)} MB)',
      );
  }
}

/// The stored Indo-Pak verse for [key].
///
/// The source numbers al-Fatihah as some Indo-Pak mushafs do (the basmalah
/// unnumbered, then 1..5, then 7), which would contradict the verse keys,
/// recitation and bookmarks used everywhere else in the app. So al-Fatihah's
/// seven verse-end circles are replaced with the plain circles for 1..7.
/// Nothing else in any verse is changed.
String indopakFor(String key, String source) {
  if (!key.startsWith('1:')) return source;
  final runes = source.runes.toList();
  if (!(runes.last == 0xF61E || indopakVerseEndNumber(runes.last) != null)) {
    throw SourceDataException('$key: unexpected indopak verse end');
  }
  return String.fromCharCodes(runes.take(runes.length - 1)) +
      indopakVerseEnd(int.parse(key.substring(2)));
}

/// `bismillahPre: s.number !== 1 && s.number !== 9`, exactly as the web adapter.
bool bismillahPreFor(int surah) => surah != 1 && surah != 9;

Future<void> writeDatabase(Corpus corpus, File file, String dataVersion) async {
  file.parent.createSync(recursive: true);
  if (file.existsSync()) file.deleteSync();

  final db = ContentDatabase(NativeDatabase(file));
  try {
    await db.batch((batch) {
      for (final s in corpus.surahs) {
        final pages = corpus.ayahs
            .where((a) => a.raw.surahNumber == s.number)
            .map((a) => a.raw.page);
        batch.insert(
          db.surahTable,
          SurahTableCompanion.insert(
            number: Value(s.number),
            nameArabic: sanitizeSourceText(s.name),
            nameSimple: sanitizeSourceText(s.englishName),
            nameTranslated: sanitizeSourceText(s.englishNameTranslation),
            revelationPlace: s.revelationPlace,
            ayahCount: s.numberOfAyahs,
            bismillahPre: bismillahPreFor(s.number),
            pageStart: pages.reduce((a, b) => a < b ? a : b),
            pageEnd: pages.reduce((a, b) => a > b ? a : b),
          ),
        );
      }

      for (final a in corpus.ayahs) {
        batch.insert(
          db.ayahTable,
          AyahTableCompanion.insert(
            id: Value(a.raw.number),
            surahNumber: a.raw.surahNumber,
            ayahNumber: a.raw.numberInSurah,
            verseKey: a.raw.verseKey,
            // Stored verbatim. Folding happens only in textSearch.
            textUthmani: a.text,
            textIndopak: corpus.indopak[a.raw.verseKey]!,
            textQpcNastaleeq: corpus.qpcNastaleeq[a.raw.verseKey]!,
            textSearch: normalizeForSearch(a.text),
            juz: a.raw.juz,
            hizb: a.raw.hizb,
            rubElHizb: a.raw.hizbQuarter,
            ruku: a.raw.ruku,
            manzil: a.raw.manzil,
            page: a.raw.page,
            sajdahType: Value(a.raw.sajdahType),
          ),
        );
      }

      for (final MapEntry(key: edition, value: rows)
          in corpus.translations.entries) {
        batch.insert(
          db.translationEditionTable,
          TranslationEditionTableCompanion.insert(
            id: edition.identifier,
            language: edition.language,
            name: edition.englishName,
            translator: edition.name,
            direction: edition.direction,
            attribution: edition.attribution,
            bundled: true,
          ),
        );
        for (var i = 0; i < rows.length; i++) {
          batch.insert(
            db.translationTable,
            TranslationTableCompanion.insert(
              editionId: edition.identifier,
              ayahId: corpus.ayahs[i].raw.number,
              body: rows[i].text,
              textSearch: normalizeForSearch(rows[i].text),
            ),
          );
        }
      }

      for (var juz = 1; juz <= juzCount; juz++) {
        final inJuz = corpus.ayahs.where((a) => a.raw.juz == juz);
        final (arabicName, transliteration) = juzNames[juz - 1];
        batch.insert(
          db.juzTable,
          JuzTableCompanion.insert(
            number: Value(juz),
            firstVerseKey: inJuz.first.raw.verseKey,
            lastVerseKey: inJuz.last.raw.verseKey,
            nameArabic: arabicName,
            nameTransliterated: transliteration,
          ),
        );
      }

      final meta = {
        MetaKeys.schemaVersion: '$contentSchemaVersion',
        MetaKeys.dataVersion: dataVersion,
        MetaKeys.buildDate: DateTime.now().toUtc().toIso8601String(),
        MetaKeys.arabicEdition: arabicEdition,
        MetaKeys.translationEditions: bundledTranslations.join(','),
        MetaKeys.source: alQuranCloudApiBase,
      };
      for (final entry in meta.entries) {
        batch.insert(
          db.metaTable,
          MetaTableCompanion.insert(key: entry.key, value: entry.value),
        );
      }
    });

    await db.customStatement('VACUUM');
  } finally {
    await db.close();
  }
}

void writeManifest(File file, Map<String, Object> manifest) {
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
  );
}
