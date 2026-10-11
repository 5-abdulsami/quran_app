// Builds assets/db/quran.db from AlQuran.cloud.
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
import 'package:quran_app/core/quran/references.dart';
import 'package:quran_app/core/text/normalize.dart';

import 'src/alquran_cloud.dart';
import 'src/expected_structure.dart';

/// Translations shipped inside the app, in default display order.
const bundledTranslations = ['en.sahih', 'ur.jalandhry'];

/// Bump when the content schema changes.
const contentSchemaVersion = 1;

Future<void> main() async {
  final root = Directory.current;
  if (!File(p.join(root.path, 'pubspec.yaml')).existsSync()) {
    stderr.writeln('Run this from the quran_app directory.');
    exitCode = 2;
    return;
  }

  final client = AlQuranCloudClient(
    cacheDir: Directory(p.join(root.path, 'tool', 'cache')),
  );

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

    final corpus = Corpus.sanitised(surahs, arabic, translations);

    final errors = <String>[
      ...corpus.validateStructure(),
      ...corpus.validateJuzAgainstMeta(meta),
      ...corpus.validateTranslations(),
      ...corpus.crossCheckBismillah(),
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
  Corpus._(this.surahs, this.ayahs, this.translations);

  factory Corpus.sanitised(
    List<CloudSurah> surahs,
    CloudQuran arabic,
    List<CloudQuran> translations,
  ) => Corpus._(surahs, arabic.ayahs.map(SourceAyah.new).toList(), {
    for (final t in translations)
      t.edition: t.ayahs.map(SourceAyah.new).toList(),
  });

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
        '${a.raw.verseKey}|${a.text}|${a.raw.juz}|${a.raw.page}|'
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
    return hash.toUnsigned(64).toRadixString(16).padLeft(16, '0');
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
      ..writeln('  data version:  $dataVersion')
      ..writeln(
        '  wrote:         ${dbFile.path} (${sizeMb.toStringAsFixed(1)} MB)',
      );
  }
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
