import 'package:flutter/material.dart';

/// Typography for Quranic text.
///
/// Every piece of Quranic text in the app goes through [QuranTypography.style],
/// so the family, locale and line height can never drift between screens.
abstract final class QuranTypography {
  /// The bundled Amiri Quran family (see pubspec.yaml). Never fetched.
  static const String fontFamily = 'AmiriQuran';

  /// Arabic locale, so the shaper picks Arabic forms and features.
  static const Locale locale = Locale('ar');

  /// Line height for Quranic text.
  ///
  /// Matches the web app's `.quran-text { line-height: 2.5 }`: Amiri Quran's
  /// annotation marks extend well above and below the baseline, and at
  /// anything tighter the marks of consecutive lines collide.
  static const double lineHeight = 2.5;

  /// The style for Quranic text at [fontSize].
  static TextStyle style({required double fontSize, required Color color}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        height: lineHeight,
        color: color,
        locale: locale,
        // Even leading keeps marks clear of both the line above and below.
        leadingDistribution: TextLeadingDistribution.even,
      );
}

/// Typography for translations.
abstract final class TranslationTypography {
  /// Generous leading, as on the web (`leading-[1.8]`).
  static const double lineHeight = 1.7;
}
