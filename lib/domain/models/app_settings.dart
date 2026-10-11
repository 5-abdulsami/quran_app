import 'package:meta/meta.dart';

/// The reader's appearance choice.
enum AppThemeMode { system, light, dark, sepia }

/// The bundled font used for Quranic text.
enum QuranFont { scheherazadeNew, amiriQuran }

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
  );
}
