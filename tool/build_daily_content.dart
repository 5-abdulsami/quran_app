// Builds assets/daily/daily_content.json: the Ayah / Hadith of the Day.
//
// Usage (from the quran_app directory):
//   dart run tool/build_daily_content.dart [path/to/HadithTable.sql]
//
// Inputs:
//   - tool/daily/curation.json: the hand-picked references (see its notes);
//   - sunnah.com's HadithTable dump (default: ./HadithTable.sql), the source
//     of every hadith's Arabic text and English translation;
//   - tool/daily/translations/*.json: further translations, each file one
//     language from one named source (e.g. hadeethenc_ur.json, written by
//     tool/fetch_hadeethenc.dart).
//
// Ayat are stored as references only; their text and translations come from
// the bundled Quran database at runtime, so the reader's chosen translation
// applies and there is one source of Quranic text in the app.
//
// Every check below must pass, or nothing is written and every problem is
// listed. A hadith is accepted only if it is in Sahih al-Bukhari or Sahih
// Muslim, sunnah.com grades it Sahih, its matn is marked, and its English is
// short and free of translator's cross-references.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:quran_app/core/quran/references.dart';
import 'package:quran_app/data/daily_catalogue_codec.dart';
import 'package:quran_app/domain/daily/daily_content.dart';
import 'package:quran_app/domain/models/hadith.dart';

import 'src/sunnah_hadith.dart';

const _curationPath = 'tool/daily/curation.json';
const _translationsDir = 'tool/daily/translations';
const _outputPath = 'assets/daily/daily_content.json';
const _defaultDumpPath = 'HadithTable.sql';

/// Short enough to read at a glance on a phone.
const maxEnglishLength = 450;

/// A passage of at most this many verses.
const maxAyahsPerEntry = 5;

/// Credited under every hadith translation taken from the dump.
const sunnahSource = 'sunnah.com';

/// Translator's notes the dump embeds in some English texts.
final _translatorNote = RegExp(
  r'\((see|See) (Hadith|hadith)|Vol\.|Fath-al-Bari',
);

Future<void> main(List<String> args) async {
  if (!File('pubspec.yaml').existsSync()) {
    stderr.writeln('Run this from the quran_app directory.');
    exitCode = 64;
    return;
  }
  final dumpPath = args.isNotEmpty ? args.first : _defaultDumpPath;
  final dump = File(dumpPath);
  if (!dump.existsSync()) {
    stderr.writeln('HadithTable dump not found at $dumpPath.');
    exitCode = 66;
    return;
  }

  final curation = jsonDecode(File(_curationPath).readAsStringSync());
  final rows = readSunnahDump(
    await dump.readAsString(),
    collections: {for (final c in HadithCollection.values) c.id},
  );
  stdout.writeln('Read ${rows.length} hadith from $dumpPath.');

  final translationsDir = Directory(_translationsDir);
  final translationFiles = translationsDir.existsSync()
      ? (translationsDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path)))
      : const <File>[];

  final builder = DailyContentBuilder(rows);
  final catalogue = builder.build(
    curation as Map<String, Object?>,
    translations: [
      for (final file in translationFiles)
        jsonDecode(file.readAsStringSync()) as Map<String, Object?>,
    ],
  );
  if (builder.errors.isNotEmpty) {
    stderr
      ..writeln('Daily content NOT written: ${builder.errors.length} problems')
      ..writeAll(builder.errors.map((e) => '  - $e'), '\n')
      ..writeln();
    exitCode = 1;
    return;
  }

  final output = File(_outputPath);
  await output.parent.create(recursive: true);
  await output.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(DailyCatalogueCodec.encode(catalogue))}\n',
  );
  stdout.writeln(
    'Wrote ${p.normalize(_outputPath)}: ${catalogue.ayahs.length} ayah '
    'passages, ${catalogue.hadiths.length} hadith.',
  );
}

/// Turns the curation file into a validated [DailyCatalogue], collecting
/// every problem in [errors] instead of stopping at the first.
class DailyContentBuilder {
  DailyContentBuilder(this._rows);

  final Map<String, SunnahHadithRow> _rows;
  final List<String> errors = [];
  final Set<String> _seen = {};

  DailyCatalogue build(
    Map<String, Object?> curation, {
    List<Map<String, Object?>> translations = const [],
  }) {
    final overrides = _translations(translations);
    final ayahs = <DailyAyahEntry>[];
    final hadiths = <DailyHadithEntry>[];

    void addAll(Object? list, DailyOccasion? occasion, {required bool ayah}) {
      for (final ref in _strings(list)) {
        if (!_seen.add(ref)) {
          errors.add('$ref is listed more than once');
          continue;
        }
        if (ayah) {
          if (_ayah(ref, occasion) case final entry?) ayahs.add(entry);
        } else {
          if (_hadith(ref, occasion, overrides[ref] ?? const [])
              case final entry?) {
            hadiths.add(entry);
          }
        }
      }
    }

    addAll(curation['ayahs'], null, ayah: true);
    addAll(curation['hadiths'], null, ayah: false);
    final occasions = curation['occasions'];
    if (occasions is Map<String, Object?>) {
      for (final MapEntry(key: name, value: lists) in occasions.entries) {
        final occasion = DailyOccasion.values
            .where((o) => o.name == name)
            .firstOrNull;
        if (occasion == null || lists is! Map<String, Object?>) {
          errors.add('Unknown occasion "$name"');
          continue;
        }
        addAll(lists['ayahs'], occasion, ayah: true);
        addAll(lists['hadiths'], occasion, ayah: false);
      }
    }
    for (final ref in overrides.keys) {
      if (!_seen.contains(ref)) errors.add('Translation for unlisted $ref');
    }
    if (ayahs.isEmpty || hadiths.isEmpty) {
      errors.add('Both an ayah and a hadith rotation are required');
    }
    return DailyCatalogue(ayahs: ayahs, hadiths: hadiths);
  }

  static final _ayahRef = RegExp(r'^(\d{1,3}):(\d{1,3})(?:-(\d{1,3}))?$');

  DailyAyahEntry? _ayah(String ref, DailyOccasion? occasion) {
    final match = _ayahRef.firstMatch(ref);
    if (match == null) {
      errors.add('"$ref" is not an ayah reference like 2:153 or 94:5-6');
      return null;
    }
    final surah = int.parse(match.group(1)!);
    final from = int.parse(match.group(2)!);
    final to = int.parse(match.group(3) ?? match.group(2)!);
    if (!isValidVerseKey(surah, from) || !isValidVerseKey(surah, to)) {
      errors.add('$ref does not exist in the mushaf');
      return null;
    }
    if (to < from || to - from + 1 > maxAyahsPerEntry) {
      errors.add('$ref must be 1–$maxAyahsPerEntry ayat in order');
      return null;
    }
    return DailyAyahEntry(
      surah: surah,
      fromAyah: from,
      toAyah: to,
      occasion: occasion,
    );
  }

  DailyHadithEntry? _hadith(
    String ref,
    DailyOccasion? occasion,
    List<HadithTranslation> extraTranslations,
  ) {
    final parts = ref.split(':');
    final collection = parts.length == 2
        ? HadithCollection.byId(parts.first)
        : null;
    final number = parts.last;
    if (collection == null) {
      errors.add('$ref: only Bukhari and Muslim are allowed');
      return null;
    }
    final row = _rows[ref];
    if (row == null) {
      errors.add('$ref is not in the dump');
      return null;
    }
    final problems = <String>[];
    if (row.englishGrade.trim() != 'Sahih') {
      problems.add('graded "${row.englishGrade}", not Sahih');
    }
    final english = cleanEnglishText(row.englishText);
    if (english.isEmpty) problems.add('no English text');
    if (english.length > maxEnglishLength) {
      problems.add('English is ${english.length} characters');
    }
    if (_translatorNote.hasMatch(english)) {
      problems.add("English carries a translator's note");
    }
    final arabic = arabicMatn(row.arabicText);
    if (arabic == null) problems.add('no matn marked in the Arabic');
    if (problems.isNotEmpty) {
      errors.add('$ref: ${problems.join('; ')}');
      return null;
    }
    return DailyHadithEntry(
      hadith: Hadith(
        collection: collection,
        number: number,
        arabic: arabic!,
        translations: [
          HadithTranslation(
            language: 'en',
            text: english,
            source: sunnahSource,
          ),
          ...extraTranslations,
        ],
      ),
      occasion: occasion,
    );
  }

  /// Translation files, each
  /// `{"source": "...", "language": "ur", "hadiths": {"bukhari:1": {"text": "..."}}}`.
  Map<String, List<HadithTranslation>> _translations(
    List<Map<String, Object?>> files,
  ) {
    final result = <String, List<HadithTranslation>>{};
    for (final file in files) {
      final source = file['source'];
      final language = file['language'];
      final hadiths = file['hadiths'];
      if (source is! String ||
          source.trim().isEmpty ||
          language is! String ||
          hadiths is! Map<String, Object?>) {
        errors.add('A translation file needs source, language and hadiths');
        continue;
      }
      if (language == 'en') {
        errors.add('$source: English comes from the dump');
        continue;
      }
      for (final MapEntry(key: ref, value: entry) in hadiths.entries) {
        final text = entry is Map ? entry['text'] : null;
        if (text is! String || text.trim().isEmpty) {
          errors.add('$source: $ref has no text');
          continue;
        }
        final existing = result[ref] ??= [];
        if (existing.any((t) => t.language == language)) {
          errors.add('$ref has two "$language" translations');
          continue;
        }
        existing.add(
          HadithTranslation(
            language: language,
            text: text.trim(),
            source: source.trim(),
          ),
        );
      }
    }
    return result;
  }

  List<String> _strings(Object? list) {
    if (list == null) return const [];
    if (list is! List || list.any((e) => e is! String)) {
      errors.add('Expected a list of references, got $list');
      return const [];
    }
    return list.cast<String>();
  }
}
