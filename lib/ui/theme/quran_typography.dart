import 'package:flutter/material.dart';

import '../../domain/models/app_settings.dart';

/// Typography for Quranic text.
///
/// Every piece of Quranic text in the app goes through [QuranTypography.style]
/// with the family from [QuranTypography.familyOf], so the font, locale and
/// line height can never drift between screens.
abstract final class QuranTypography {
  /// SIL's Scheherazade New: full coverage of the Quranic marks in the
  /// Uthmani (Tanzil) text, very legible. The default.
  static const String scheherazadeFamily = 'ScheherazadeNew';

  /// Amiri Quran, the alternative.
  static const String amiriFamily = 'AmiriQuran';

  /// The end-of-ayah ornament (U+06DD + digits) is always drawn with Amiri
  /// Quran, which composes the number inside the ornament; Scheherazade New
  /// leaves the digits beside an empty ornament.
  static const String ornamentFamily = amiriFamily;

  /// Arabic locale, so the shaper picks Arabic forms and features.
  static const Locale locale = Locale('ar');

  /// Line height for Quranic text.
  ///
  /// Matches the web app's `.quran-text { line-height: 2.5 }`: Quranic
  /// annotation marks extend well above and below the baseline, and at
  /// anything tighter the marks of consecutive lines collide.
  static const double lineHeight = 2.5;

  /// The bundled family for a [QuranFont] choice. Fonts are never fetched.
  static String familyFor(QuranFont font) => switch (font) {
    QuranFont.scheherazadeNew => scheherazadeFamily,
    QuranFont.amiriQuran => amiriFamily,
  };

  /// The family chosen in Settings, provided by [QuranFontScope].
  static String familyOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<QuranFontScope>()?.family ??
      scheherazadeFamily;

  /// The style for Quranic text at [fontSize].
  static TextStyle style({
    required String family,
    required double fontSize,
    required Color color,
  }) => TextStyle(
    fontFamily: family,
    fontSize: fontSize,
    height: lineHeight,
    color: color,
    locale: locale,
    // Even leading keeps marks clear of both the line above and below.
    leadingDistribution: TextLeadingDistribution.even,
  );
}

/// Makes the reader's chosen Quran font available to every [QuranText].
class QuranFontScope extends InheritedWidget {
  const QuranFontScope({required this.family, required super.child, super.key});

  final String family;

  @override
  bool updateShouldNotify(QuranFontScope oldWidget) =>
      oldWidget.family != family;
}

/// Typography for translations.
abstract final class TranslationTypography {
  /// Generous leading, as on the web (`leading-[1.8]`).
  static const double lineHeight = 1.7;
}
