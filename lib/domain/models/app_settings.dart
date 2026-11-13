import 'package:meta/meta.dart';

import '../daily/daily_content.dart';
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
    this.arabicFontSize = 30,
    this.translationFontSize = 18,
    this.showTranslation = true,
    this.showMarkers = true,
    this.keepScreenAwake = false,
    this.translationIds = const ['ur.jalandhry'],
    this.recitationMode = RecitationMode.arabic,
    this.reciterId = Reciters.defaultArabicId,
    this.urduReciterId = Reciters.defaultUrduId,
    this.showDailyCard = true,
    this.dailyContentMode = DailyContentMode.both,
    this.showHadithArabic = false,
    this.hijriAdjustment = 0,
  });

  /// How far the Hijri date may be moved to match local moon sighting.
  static const int maxHijriAdjustment = 2;

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

  /// The Ayah / Hadith of the Day card on the home screen.
  final bool showDailyCard;
  final DailyContentMode dailyContentMode;

  /// The hadith's Arabic matn above its translation. Off by default: most
  /// readers read the translation, and the card stays short.
  final bool showHadithArabic;

  /// Days added to the calculated Hijri date, -[maxHijriAdjustment] to
  /// +[maxHijriAdjustment], so it matches the local moon sighting.
  final int hijriAdjustment;

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
    bool? showDailyCard,
    DailyContentMode? dailyContentMode,
    bool? showHadithArabic,
    int? hijriAdjustment,
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
    showDailyCard: showDailyCard ?? this.showDailyCard,
    dailyContentMode: dailyContentMode ?? this.dailyContentMode,
    showHadithArabic: showHadithArabic ?? this.showHadithArabic,
    hijriAdjustment: hijriAdjustment ?? this.hijriAdjustment,
  );
}
