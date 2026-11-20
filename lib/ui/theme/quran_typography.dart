import 'package:flutter/material.dart';

import '../../core/quran/bismillah.dart';
import '../../core/quran/indopak.dart';
import '../../core/quran/qpc_nastaleeq.dart';
import '../../core/quran/verse_end.dart';
import '../../core/text/arabic_digits.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/ayah.dart';

/// The Quran texts the app carries. Each font is designed for one of them and
/// must only ever be given that one: a font drawing another text's marks
/// would put wrong signs on the page.
enum QuranScript {
  /// The King Fahd Complex's Indo-Pak (Nastaleeq) text.
  qpcNastaleeq,

  /// The Indo-Pak (Nastaleeq) text of QuranWBW / Quran.com.
  indopak,

  /// The Uthmani (Madinah) text.
  uthmani,
}

/// The text each script shows. The single place a font is matched to its
/// text: every screen goes through these.
extension QuranScriptText on QuranScript {
  /// Whether the text draws each verse's number itself. Only the IndoPak
  /// Nastaleeq text does (its verse-end glyphs are single code points); the
  /// others are followed by the Amiri Quran ornament.
  ///
  /// The QPC Nastaleeq text does end with its number, but KFGQPC Nastaleeq
  /// circles the digits only under the Arabic script, and Flutter shapes
  /// Arabic-Indic digits as script-neutral, so they would show as bare
  /// digits. Its number is therefore drawn as the ornament, with the text's
  /// own verse-end signs (waqf, ruku, sajdah) placed above it.
  bool get hasOwnVerseEnds => this == QuranScript.indopak;

  /// The basmalah shown above a surah.
  String get basmalahText => switch (this) {
    QuranScript.qpcNastaleeq => qpcNastaleeqBasmalah,
    QuranScript.indopak => indopakBasmalah,
    QuranScript.uthmani => basmalah,
  };

  /// [ayah] as shown, before any ornament: the IndoPak Nastaleeq text with
  /// its verse-end glyph kept on the verse's last line, the QPC Nastaleeq text
  /// without its closing number word, the Uthmani text without the basmalah
  /// its surah header already shows.
  String verseText(Ayah ayah) => switch (this) {
    QuranScript.qpcNastaleeq => ayah.textQpcNastaleeq.substring(
      0,
      ayah.textQpcNastaleeq.lastIndexOf(' '),
    ),
    QuranScript.indopak => keepVerseEndOnLine(ayah.textIndopak),
    QuranScript.uthmani => ayah.displayText,
  };

  /// The signs the text places on [ayah]'s verse-end circle (waqf, ruku,
  /// sajdah), drawn after the ornament so they sit above it. Only the QPC
  /// Nastaleeq text has them; usually empty.
  String verseEndSigns(Ayah ayah) {
    if (this != QuranScript.qpcNastaleeq) return '';
    final text = ayah.textQpcNastaleeq;
    return text
        .substring(text.lastIndexOf(' ') + 1)
        .substring(toArabicIndicDigits(ayah.ayahNumber).length);
  }
}

/// One bundled Quran font: what the reader picks in Settings.
@immutable
class QuranFontSpec {
  const QuranFontSpec({
    required this.font,
    required this.family,
    required this.label,
    required this.script,
    required this.licenceAsset,
    this.scale = 1,
  });

  final QuranFont font;

  /// The family declared in pubspec.yaml.
  final String family;

  /// The font's own name, shown as-is in every UI language.
  final String label;

  /// The text this font is drawn for.
  final QuranScript script;

  /// Its licence, shown on the licence page.
  final String licenceAsset;

  /// Brings fonts with a small design size up to the others, so a chosen
  /// text size looks the same whichever font is selected.
  final double scale;
}

/// Every Quran font the reader can pick, all bundled and never fetched.
abstract final class QuranFonts {
  static const all = [
    QuranFontSpec(
      font: QuranFont.kfgqpcNastaleeq,
      family: 'KFGQPCNastaleeq',
      label: 'KFGQPC Nastaleeq',
      script: QuranScript.qpcNastaleeq,
      licenceAsset: 'assets/fonts/LICENSE-kfgqpc-nastaleeq.txt',
    ),
    QuranFontSpec(
      font: QuranFont.indoPakNastaleeq,
      family: 'IndoPakNastaleeq',
      label: 'IndoPak Nastaleeq',
      script: QuranScript.indopak,
      licenceAsset: 'assets/fonts/LICENSE-indopak-nastaleeq.txt',
    ),
    QuranFontSpec(
      font: QuranFont.scheherazadeNew,
      family: 'ScheherazadeNew',
      label: 'Scheherazade New',
      script: QuranScript.uthmani,
      licenceAsset: 'assets/fonts/OFL-scheherazade-new.txt',
    ),
    QuranFontSpec(
      font: QuranFont.notoNaskhArabic,
      family: 'NotoNaskhArabic',
      label: 'Noto Naskh Arabic',
      script: QuranScript.uthmani,
      licenceAsset: 'assets/fonts/OFL-noto-naskh-arabic.txt',
      scale: 0.92,
    ),
    QuranFontSpec(
      font: QuranFont.lateef,
      family: 'Lateef',
      label: 'Lateef',
      script: QuranScript.uthmani,
      licenceAsset: 'assets/fonts/OFL-lateef.txt',
      scale: 1.25,
    ),
  ];

  static QuranFontSpec of(QuranFont font) =>
      all.firstWhere((spec) => spec.font == font);

  /// The default (the first entry): KFGQPC Nastaleeq, the King Fahd Complex's
  /// Indo-Pak script, the one most of the app's readers learned from.
  static QuranFontSpec get standard => all.first;
}

/// Bundled fonts that are not Quran-font choices but still ship, with their
/// licences: (name, licence asset).
const supportFontLicences = [
  ('Amiri Quran', 'assets/fonts/OFL-amiri-quran.txt'),
  ('Amiri', 'assets/fonts/OFL-amiri.txt'),
];

/// Typography for Quranic text.
///
/// Every piece of Quranic text in the app goes through [QuranTypography.style]
/// with the font from [QuranTypography.fontOf], so the family, size, locale
/// and line height can never drift between screens.
abstract final class QuranTypography {
  /// The Uthmani end-of-ayah ornament (U+06DD + digits) is always drawn with
  /// Amiri Quran, which composes the number inside the ornament; most other
  /// fonts leave the digits beside an empty ornament. (The Indo-Pak text
  /// carries its own verse-end glyphs.)
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

  /// Arabic-script translations (Urdu, Persian...) read smaller than Latin
  /// text at the same size, and need more room for their marks.
  static const double rtlScale = 1.15;
  static const double rtlLineHeight = 2;
}
