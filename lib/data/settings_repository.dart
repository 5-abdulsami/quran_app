import 'package:shared_preferences/shared_preferences.dart';

import '../domain/daily/daily_content.dart';
import '../domain/models/app_settings.dart';
import '../domain/models/reciter.dart';

/// Reads and writes [AppSettings] in SharedPreferences.
///
/// Every value is read defensively: a missing or malformed key falls back to
/// the default rather than failing app start.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _theme = 'settings.theme';
  static const _quranFont = 'settings.quranFont';
  static const _language = 'settings.language';
  static const _arabicSize = 'settings.arabicFontSize';
  static const _translationSize = 'settings.translationFontSize';
  static const _showTranslation = 'settings.showTranslation';
  static const _showMarkers = 'settings.showMarkers';
  static const _keepAwake = 'settings.keepScreenAwake';
  static const _translations = 'settings.translationIds';
  static const _recitationMode = 'settings.recitationMode';
  static const _reciter = 'settings.reciter';
  static const _urduReciter = 'settings.urduReciter';
  static const _showDailyCard = 'settings.daily.show';
  static const _dailyContentMode = 'settings.daily.content';
  static const _showHadithArabic = 'settings.daily.hadithArabic';
  static const _hijriAdjustment = 'settings.hijriAdjustment';
  static const _recentSearches = 'search.recent';

  static const int maxRecentSearches = 10;

  AppSettings load() {
    const defaults = AppSettings();
    final language = _prefs.getString(_language);
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (m) => m.name == _prefs.getString(_theme),
        orElse: () => defaults.themeMode,
      ),
      quranFont: QuranFont.values.firstWhere(
        (f) => f.name == _prefs.getString(_quranFont),
        orElse: () => defaults.quranFont,
      ),
      languageCode: AppLanguages.supported.contains(language) ? language : null,
      arabicFontSize: (_prefs.getDouble(_arabicSize) ?? defaults.arabicFontSize)
          .clamp(AppSettings.minArabicFontSize, AppSettings.maxArabicFontSize),
      translationFontSize:
          (_prefs.getDouble(_translationSize) ?? defaults.translationFontSize)
              .clamp(
                AppSettings.minTranslationFontSize,
                AppSettings.maxTranslationFontSize,
              ),
      showTranslation:
          _prefs.getBool(_showTranslation) ?? defaults.showTranslation,
      showMarkers: _prefs.getBool(_showMarkers) ?? defaults.showMarkers,
      keepScreenAwake: _prefs.getBool(_keepAwake) ?? defaults.keepScreenAwake,
      translationIds:
          _prefs.getStringList(_translations) ?? defaults.translationIds,
      recitationMode: RecitationMode.values.firstWhere(
        (m) => m.name == _prefs.getString(_recitationMode),
        orElse: () => defaults.recitationMode,
      ),
      // Unknown ids (a reciter since removed) fall back to the default.
      reciterId: Reciters.arabicById(
        _prefs.getString(_reciter) ?? defaults.reciterId,
      ).id,
      urduReciterId: Reciters.urduById(
        _prefs.getString(_urduReciter) ?? defaults.urduReciterId,
      ).id,
      showDailyCard: _prefs.getBool(_showDailyCard) ?? defaults.showDailyCard,
      dailyContentMode: DailyContentMode.values.firstWhere(
        (m) => m.name == _prefs.getString(_dailyContentMode),
        orElse: () => defaults.dailyContentMode,
      ),
      showHadithArabic:
          _prefs.getBool(_showHadithArabic) ?? defaults.showHadithArabic,
      hijriAdjustment:
          (_prefs.getInt(_hijriAdjustment) ?? defaults.hijriAdjustment).clamp(
            -AppSettings.maxHijriAdjustment,
            AppSettings.maxHijriAdjustment,
          ),
    );
  }

  /// Persists [settings]. With [previous], only the values that differ are
  /// written: a slider drag then costs one write per step, not one per
  /// setting.
  Future<void> save(AppSettings settings, {AppSettings? previous}) async {
    bool changed<T>(T Function(AppSettings s) value) =>
        previous == null || value(previous) != value(settings);

    if (changed((s) => s.themeMode)) {
      await _prefs.setString(_theme, settings.themeMode.name);
    }
    if (changed((s) => s.quranFont)) {
      await _prefs.setString(_quranFont, settings.quranFont.name);
    }
    if (changed((s) => s.languageCode)) {
      final language = settings.languageCode;
      if (language == null) {
        await _prefs.remove(_language);
      } else {
        await _prefs.setString(_language, language);
      }
    }
    if (changed((s) => s.arabicFontSize)) {
      await _prefs.setDouble(_arabicSize, settings.arabicFontSize);
    }
    if (changed((s) => s.translationFontSize)) {
      await _prefs.setDouble(_translationSize, settings.translationFontSize);
    }
    if (changed((s) => s.showTranslation)) {
      await _prefs.setBool(_showTranslation, settings.showTranslation);
    }
    if (changed((s) => s.showMarkers)) {
      await _prefs.setBool(_showMarkers, settings.showMarkers);
    }
    if (changed((s) => s.keepScreenAwake)) {
      await _prefs.setBool(_keepAwake, settings.keepScreenAwake);
    }
    // Lists compare by identity; copyWith keeps the same list when unchanged.
    if (changed((s) => s.translationIds)) {
      await _prefs.setStringList(_translations, settings.translationIds);
    }
    if (changed((s) => s.recitationMode)) {
      await _prefs.setString(_recitationMode, settings.recitationMode.name);
    }
    if (changed((s) => s.reciterId)) {
      await _prefs.setString(_reciter, settings.reciterId);
    }
    if (changed((s) => s.urduReciterId)) {
      await _prefs.setString(_urduReciter, settings.urduReciterId);
    }
    if (changed((s) => s.showDailyCard)) {
      await _prefs.setBool(_showDailyCard, settings.showDailyCard);
    }
    if (changed((s) => s.dailyContentMode)) {
      await _prefs.setString(_dailyContentMode, settings.dailyContentMode.name);
    }
    if (changed((s) => s.showHadithArabic)) {
      await _prefs.setBool(_showHadithArabic, settings.showHadithArabic);
    }
    if (changed((s) => s.hijriAdjustment)) {
      await _prefs.setInt(_hijriAdjustment, settings.hijriAdjustment);
    }
  }

  /// Most recent first.
  List<String> recentSearches() =>
      _prefs.getStringList(_recentSearches) ?? const [];

  Future<List<String>> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return recentSearches();
    final updated = [
      trimmed,
      ...recentSearches().where((q) => q != trimmed),
    ].take(maxRecentSearches).toList();
    await _prefs.setStringList(_recentSearches, updated);
    return updated;
  }

  Future<void> clearRecentSearches() => _prefs.remove(_recentSearches);
}
