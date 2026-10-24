import 'package:meta/meta.dart';

import 'reciter.dart';

/// The reader's appearance choice.
enum AppThemeMode { system, light, dark, sepia }

/// The bundled fonts for Quranic text. Each one covers every code point the
/// Uthmani text uses (checked by test/core/quran_fonts_test.dart).
enum QuranFont {
  scheherazadeNew,
  amiriQuran,
  amiri,
  notoNaskhArabic,
  notoSansArabic,
  lateef,
  harmattan,
}

/// The UI languages the app ships. `null` in [AppSettings.languageCode] means
/// "follow the device".
abstract final class AppLanguages {
  static const List<String> supported = ['en', 'ur', 'ar'];
}

/// Every user preference, immutable. Persisted by `SettingsRepository`.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.quranFont = QuranFont.scheherazadeNew,
    this.languageCode,
    this.arabicFontSize = 28,
    this.translationFontSize = 16,
    this.showTranslation = true,
    this.showMarkers = true,
    this.keepScreenAwake = false,
    this.translationIds = const ['en.sahih'],
    this.recitationMode = RecitationMode.arabic,
    this.reciterId = Reciters.defaultArabicId,
    this.urduReciterId = Reciters.defaultUrduId,
  });

  static const double minArabicFontSize = 20;
  static const double maxArabicFontSize = 44;
  static const double minTranslationFontSize = 13;
  static const double maxTranslationFontSize = 26;

  final AppThemeMode themeMode;

  /// Font for Quranic text (Scheherazade New by default).
  final QuranFont quranFont;

  /// One of [AppLanguages.supported], or null to follow the device.
  final String? languageCode;

  final double arabicFontSize;
  final double translationFontSize;

  /// False is "Arabic only" mode.
  final bool showTranslation;

  /// Juz / hizb / page markers in the readers.
  final bool showMarkers;

  final bool keepScreenAwake;

  /// Selected translation editions, in display order.
  final List<String> translationIds;

  /// What the audio player recites: Arabic, Urdu, or both per verse.
  final RecitationMode recitationMode;

  /// The Arabic reciter ([Reciters.arabic]) and the Urdu translation
  /// recording ([Reciters.urdu]).
  final String reciterId;
  final String urduReciterId;

  Reciter get reciter => Reciters.arabicById(reciterId);
  Reciter get urduReciter => Reciters.urduById(urduReciterId);

  /// The recordings [recitationMode] plays, in order.
  List<Reciter> get activeReciters => [
    if (recitationMode.includesArabic) reciter,
    if (recitationMode.includesUrdu) urduReciter,
  ];

  /// The editions actually rendered: none in Arabic-only mode.
  List<String> get visibleTranslationIds =>
      showTranslation ? translationIds : const [];

  AppSettings copyWith({
    AppThemeMode? themeMode,
    QuranFont? quranFont,
    String? Function()? languageCode,
    double? arabicFontSize,
    double? translationFontSize,
    bool? showTranslation,
    bool? showMarkers,
    bool? keepScreenAwake,
    List<String>? translationIds,
    RecitationMode? recitationMode,
    String? reciterId,
    String? urduReciterId,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    quranFont: quranFont ?? this.quranFont,
    languageCode: languageCode != null ? languageCode() : this.languageCode,
    arabicFontSize: arabicFontSize ?? this.arabicFontSize,
    translationFontSize: translationFontSize ?? this.translationFontSize,
    showTranslation: showTranslation ?? this.showTranslation,
    showMarkers: showMarkers ?? this.showMarkers,
    keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
    translationIds: translationIds ?? this.translationIds,
    recitationMode: recitationMode ?? this.recitationMode,
    reciterId: reciterId ?? this.reciterId,
    urduReciterId: urduReciterId ?? this.urduReciterId,
  );
}
