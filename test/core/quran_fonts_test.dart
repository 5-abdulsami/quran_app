import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/domain/models/app_settings.dart';
import 'package:quran_app/ui/theme/quran_typography.dart';

import '../helpers/font_cmap.dart';
import '../helpers/test_databases.dart';

/// Every selectable Quran font must render every character of the Uthmani
/// text — a font missing a single Quranic mark would silently drop it.
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  /// family -> asset path, from the `fonts:` section of pubspec.yaml.
  final declared = {
    for (final m in RegExp(
      r'- family: (\w+)\s+fonts:\s+- asset: (\S+)',
    ).allMatches(pubspec))
      m.group(1)!: m.group(2)!,
  };

  late Set<int> quranCodePoints;

  setUpAll(() async {
    final db = await openBundledContentDb();
    final rows = await db
        .customSelect(
          'SELECT text_uthmani t FROM ayah UNION ALL SELECT name_arabic FROM surah',
        )
        .get();
    await db.close();
    quranCodePoints = {for (final r in rows) ...r.read<String>('t').runes}
      ..remove(0x20);
  });

  test('every QuranFont has exactly one spec', () {
    expect(QuranFonts.all.map((s) => s.font).toSet(), QuranFont.values.toSet());
    expect(QuranFonts.all, hasLength(QuranFont.values.length));
    expect(QuranFonts.standard.font, QuranFont.scheherazadeNew);
  });

  for (final spec in QuranFonts.all) {
    test('${spec.label} is bundled, licensed and covers the Quran text', () {
      final asset = declared[spec.family];
      expect(asset, isNotNull, reason: '${spec.family} not in pubspec.yaml');
      expect(File(spec.licenceAsset).existsSync(), isTrue);
      expect(pubspec, contains(spec.licenceAsset));
      expect(
        File(spec.licenceAsset).readAsStringSync(),
        contains('SIL Open Font License'),
      );

      final missing = quranCodePoints.difference(fontCodePoints(asset!));
      expect(
        missing.map((c) => 'U+${c.toRadixString(16).toUpperCase()}'),
        isEmpty,
      );
    });
  }

  test('the ornament font has U+06DD and the Arabic-Indic digits', () {
    final glyphs = fontCodePoints(declared[QuranTypography.ornamentFamily]!);
    expect(
      glyphs,
      containsAll([0x06DD, for (var d = 0; d < 10; d++) 0x0660 + d]),
    );
  });
}
