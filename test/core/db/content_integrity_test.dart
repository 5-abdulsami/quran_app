import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/db/content_db.dart';
import 'package:quran_app/core/quran/references.dart';

import '../../helpers/test_databases.dart';

/// Integrity of the bundled content database.
///
/// The build script already refuses to write a database that fails these
/// checks; they are repeated here against the committed file, so a hand-edited
/// or truncated asset can never ship.
void main() {
  late ContentDatabase db;

  setUpAll(() async => db = await openBundledContentDb());
  tearDownAll(() => db.close());

  Future<List<Map<String, Object?>>> rows(String sql) async =>
      (await db.customSelect(sql).get()).map((r) => r.data).toList();

  test('has 114 surahs and 6236 ayahs', () async {
    expect((await rows('SELECT COUNT(*) c FROM surah')).single['c'], 114);
    expect((await rows('SELECT COUNT(*) c FROM ayah')).single['c'], 6236);
  });

  test('every surah has the ayah count from AYAH_COUNTS', () async {
    final counts = await rows(
      'SELECT surah_number s, COUNT(*) c, MIN(ayah_number) lo, '
      'MAX(ayah_number) hi FROM ayah GROUP BY surah_number ORDER BY s',
    );
    expect(counts, hasLength(114));
    for (final row in counts) {
      final surah = row['s']! as int;
      expect(row['c'], ayahCount(surah), reason: 'surah $surah');
      expect(row['lo'], 1);
      expect(row['hi'], ayahCount(surah));
    }
    final listed = await rows('SELECT number, ayah_count FROM surah');
    for (final row in listed) {
      expect(row['ayah_count'], ayahCount(row['number']! as int));
    }
  });

  test('ayah ids run 1..6236 in mushaf order', () async {
    final ordered = await rows(
      'SELECT id FROM ayah ORDER BY surah_number, ayah_number',
    );
    for (var i = 0; i < ordered.length; i++) {
      expect(ordered[i]['id'], i + 1);
    }
  });

  test('no Arabic text is empty or carries invisible characters', () async {
    final bad = await rows(
      "SELECT verse_key FROM ayah WHERE TRIM(text_uthmani) = '' "
      "OR text_uthmani LIKE '%' || char(65279) || '%' "
      "OR text_uthmani LIKE '%' || char(8203) || '%'",
    );
    expect(bad, isEmpty);
  });

  test('bismillah_pre is false exactly for surahs 1 and 9', () async {
    final noBasmalah = await rows(
      'SELECT number FROM surah WHERE bismillah_pre = 0 ORDER BY number',
    );
    expect(noBasmalah.map((r) => r['number']), [1, 9]);
  });

  test('each bundled translation has one non-empty row per ayah', () async {
    final editions = await rows(
      'SELECT id, direction FROM translation_edition WHERE bundled = 1',
    );
    expect(
      editions.map((e) => e['id']),
      containsAll(['en.sahih', 'ur.jalandhry']),
    );
    for (final edition in editions) {
      final counts = await rows(
        "SELECT COUNT(*) c, SUM(TRIM(text) = '') empty FROM translation "
        "WHERE edition_id = '${edition['id']}'",
      );
      expect(counts.single['c'], 6236, reason: '${edition['id']}');
      expect(counts.single['empty'], 0, reason: '${edition['id']}');
    }
    final urdu = editions.firstWhere((e) => e['id'] == 'ur.jalandhry');
    expect(urdu['direction'], 'rtl');
  });

  test('juz boundaries match the expected first verses', () async {
    const expected = [
      '1:1', '2:142', '2:253', '3:93', '4:24', '4:148', '5:82', '6:111', //
      '7:88', '8:41', '9:93', '11:6', '12:53', '15:1', '17:1', '18:75',
      '21:1', '23:1', '25:21', '27:56', '29:46', '33:31', '36:28', '39:32',
      '41:47', '46:1', '51:31', '58:1', '67:1', '78:1',
    ];
    final juz = await rows(
      'SELECT number, first_verse_key FROM juz ORDER BY number',
    );
    expect(juz.map((r) => r['first_verse_key']), expected);

    // The ayah table's own juz field agrees, and each juz ends where the next begins.
    for (var j = 1; j <= 30; j++) {
      final first = await rows(
        'SELECT verse_key FROM ayah WHERE juz = $j ORDER BY id LIMIT 1',
      );
      expect(first.single['verse_key'], expected[j - 1], reason: 'juz $j');
    }
    final last = await rows('SELECT last_verse_key FROM juz WHERE number = 30');
    expect(last.single['last_verse_key'], '114:6');
  });

  test('juz covers 1..30 and pages cover 1..604 without gaps', () async {
    final juz = await rows('SELECT DISTINCT juz FROM ayah ORDER BY juz');
    expect(juz.map((r) => r['juz']), List.generate(30, (i) => i + 1));
    final pages = await rows('SELECT DISTINCT page FROM ayah ORDER BY page');
    expect(pages.map((r) => r['page']), List.generate(604, (i) => i + 1));
  });

  test('sajdah types use the web wording keys only', () async {
    final types = await rows(
      'SELECT DISTINCT sajdah_type t FROM ayah WHERE sajdah_type IS NOT NULL',
    );
    expect(types.map((r) => r['t']).toSet(), {'recommended', 'obligatory'});
  });

  test('meta matches the shipped manifest', () async {
    final manifest =
        jsonDecode(File('assets/db/manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(await db.metaValue(MetaKeys.dataVersion), manifest['dataVersion']);
    expect(
      await db.metaValue(MetaKeys.schemaVersion),
      '${manifest['schemaVersion']}',
    );
    expect(await db.metaValue(MetaKeys.arabicEdition), 'quran-uthmani');
  });
}
