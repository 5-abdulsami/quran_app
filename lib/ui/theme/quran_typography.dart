import 'package:flutter/material.dart';

import '../../domain/models/app_settings.dart';

/// One bundled Quran font: what the reader picks in Settings.
@immutable
class QuranFontSpec {
  const QuranFontSpec({
    required this.font,
    required this.family,
    required this.label,
    required this.licenceAsset,
    this.scale = 1,
  });

  final QuranFont font;

  /// The family declared in pubspec.yaml.
  final String family;

  /// The font's own name, shown as-is in every UI language.
  final String label;

  /// Its OFL licence, shown on the licence page.
  final String licenceAsset;

  /// Brings fonts with a small design size up to the others, so a chosen
  /// text size looks the same whichever font is selected.
  final double scale;
}

/// Every bundled Quran font. All are under the SIL Open Font License, never
/// fetched at runtime, and cover every code point of the Uthmani text.
abstract final class QuranFonts {
  static const all = [
    QuranFontSpec(
      font: QuranFont.scheherazadeNew,
      family: 'ScheherazadeNew',
      label: 'Scheherazade New',
      licenceAsset: 'assets/fonts/OFL-scheherazade-new.txt',
    ),
    QuranFontSpec(
      font: QuranFont.amiriQuran,
      family: 'AmiriQuran',
      label: 'Amiri Quran',
      licenceAsset: 'assets/fonts/OFL-amiri-quran.txt',
    ),
    QuranFontSpec(
      font: QuranFont.amiri,
      family: 'Amiri',
      label: 'Amiri',
      licenceAsset: 'assets/fonts/OFL-amiri.txt',
    ),
    QuranFontSpec(
      font: QuranFont.notoNaskhArabic,
      family: 'NotoNaskhArabic',
      label: 'Noto Naskh Arabic',
      licenceAsset: 'assets/fonts/OFL-noto-naskh-arabic.txt',
      scale: 0.92,
    ),
    QuranFontSpec(
      font: QuranFont.notoSansArabic,
      family: 'NotoSansArabic',
      label: 'Noto Sans Arabic',
      licenceAsset: 'assets/fonts/OFL-noto-sans-arabic.txt',
      scale: 0.9,
    ),
    QuranFontSpec(
      font: QuranFont.lateef,
      family: 'Lateef',
      label: 'Lateef',
      licenceAsset: 'assets/fonts/OFL-lateef.txt',
      scale: 1.25,
    ),
    QuranFontSpec(
      font: QuranFont.harmattan,
      family: 'Harmattan',
      label: 'Harmattan',
      licenceAsset: 'assets/fonts/OFL-harmattan.txt',
      scale: 1.1,
    ),
  ];

  static QuranFontSpec of(QuranFont font) =>
      all.firstWhere((spec) => spec.font == font);

  /// The default (the first entry): SIL's Scheherazade New, very legible with
  /// full Quranic mark support.
  static QuranFontSpec get standard => all.first;
}

/// Typography for Quranic text.
///
/// Every piece of Quranic text in the app goes through [QuranTypography.style]
/// with the font from [QuranTypography.fontOf], so the family, size, locale
/// and line height can never drift between screens.
abstract final class QuranTypography {
  /// The end-of-ayah ornament (U+06DD + digits) is always drawn with Amiri
  /// Quran, which composes the number inside the ornament; most other fonts
  /// leave the digits beside an empty ornament.
  static const String ornamentFamily = 'AmiriQuran';

  /// Arabic locale, so the shaper picks Arabic forms and features.
  static const Locale locale = Locale('ar');

  /// Line height for Quranic text.
  ///
  /// Matches the web app's `.quran-text { line-height: 2.5 }`: Quranic
  /// annotation marks extend well above and below the baseline, and at
  /// anything tighter the marks of consecutive lines collide.
  static const double lineHeight = 2.5;

  /// The font chosen in Settings, provided by [QuranFontScope].
  static QuranFontSpec fontOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<QuranFontScope>()?.font ??
      QuranFonts.standard;

  /// The style for Quranic text at [fontSize] in [font].
  static TextStyle style({
    required QuranFontSpec font,
    required double fontSize,
    required Color color,
  }) => TextStyle(
    fontFamily: font.family,
    fontSize: fontSize * font.scale,
    height: lineHeight,
    color: color,
    locale: locale,
    // Even leading keeps marks clear of both the line above and below.
    leadingDistribution: TextLeadingDistribution.even,
  );
}

/// Makes the reader's chosen Quran font available to every Quran text widget.
class QuranFontScope extends InheritedWidget {
  const QuranFontScope({required this.font, required super.child, super.key});

  final QuranFontSpec font;

  @override
  bool updateShouldNotify(QuranFontScope oldWidget) => oldWidget.font != font;
}

/// Typography for translations.
abstract final class TranslationTypography {
  /// Generous leading, as on the web (`leading-[1.8]`).
  static const double lineHeight = 1.7;
}
