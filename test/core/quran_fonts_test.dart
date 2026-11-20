import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/domain/models/app_settings.dart';
import 'package:quran_app/ui/theme/quran_typography.dart';

import '../helpers/font_cmap.dart';
import '../helpers/test_databases.dart';

/// Every selectable Quran font must render every character of the text it is
/// paired with — a font missing a single Quranic mark would silently drop it.
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  /// family -> asset path, from the `fonts:` section of pubspec.yaml.
  final declared = {
    for (final m in RegExp(
      r'- family: (\w+)\s+fonts:\s+- asset: (\S+)',
    ).allMatches(pubspec))
      m.group(1)!: m.group(2)!,
  };

  /// Every code point each script's fonts must draw: the verses, the
  /// basmalah and the surah names (also shown in the Quran font).
  late Map<QuranScript, Set<int>> codePoints;

  setUpAll(() async {
    final db = await openBundledContentDb();
    Future<Set<int>> read(String column) async {
      final rows = await db
          .customSelect(
            'SELECT $column t FROM ayah UNION ALL SELECT name_arabic FROM surah',
          )
          .get();
      return {for (final r in rows) ...r.read<String>('t').runes}..remove(0x20);
    }

    codePoints = {
      QuranScript.uthmani: await read('text_uthmani'),
      QuranScript.indopak: await read('text_indopak'),
      QuranScript.qpcNastaleeq: await read('text_qpc_nastaleeq'),
    };
    await db.close();
  });

  test('every QuranFont has exactly one spec; KFGQPC is the default', () {
    expect(QuranFonts.all.map((s) => s.font).toSet(), QuranFont.values.toSet());
    expect(QuranFonts.all, hasLength(QuranFont.values.length));
    expect(QuranFonts.standard.font, QuranFont.kfgqpcNastaleeq);
    expect(QuranFonts.standard.script, QuranScript.qpcNastaleeq);
    expect(const AppSettings().quranFont, QuranFont.kfgqpcNastaleeq);
    // One font per Indo-Pak text.
    expect(
      QuranFonts.of(QuranFont.indoPakNastaleeq).script,
      QuranScript.indopak,
    );
    expect(
      QuranFonts.all
          .where((s) => s.script == QuranScript.uthmani)
          .map((s) => s.label),
      ['Scheherazade New', 'Noto Naskh Arabic', 'Lateef'],
    );
  });

  for (final spec in QuranFonts.all) {
    test('${spec.label} is bundled, licensed and covers the Quran text', () {
      final asset = declared[spec.family];
      expect(asset, isNotNull, reason: '${spec.family} not in pubspec.yaml');
      expect(File(spec.licenceAsset).existsSync(), isTrue);
      expect(pubspec, contains(spec.licenceAsset));
      expect(File(spec.licenceAsset).readAsStringSync(), switch (spec.script) {
        QuranScript.qpcNastaleeq => contains(
          'King Fahd Glorious Quran Printing Complex',
        ),
        QuranScript.indopak => contains('QURANWBW.COM'),
        QuranScript.uthmani => contains('SIL Open Font License'),
      });

      final missing = codePoints[spec.script]!.difference(
        fontCodePoints(asset!),
      );
      expect(
        missing.map((c) => 'U+${c.toRadixString(16).toUpperCase()}'),
        isEmpty,
      );
    });
  }

  test('the support fonts ship with their licences', () {
    for (final (_, asset) in supportFontLicences) {
      expect(pubspec, contains(asset));
      expect(File(asset).readAsStringSync(), contains('SIL Open Font License'));
    }
  });

  test('the ornament font has U+06DD and the Arabic-Indic digits', () {
    final glyphs = fontCodePoints(declared[QuranTypography.ornamentFamily]!);
    expect(
      glyphs,
      containsAll([0x06DD, for (var d = 0; d < 10; d++) 0x0660 + d]),
    );
  });
}
