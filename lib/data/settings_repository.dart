import 'package:shared_preferences/shared_preferences.dart';

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
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_theme, settings.themeMode.name);
    await _prefs.setString(_quranFont, settings.quranFont.name);
    final language = settings.languageCode;
    if (language == null) {
      await _prefs.remove(_language);
    } else {
      await _prefs.setString(_language, language);
    }
    await _prefs.setDouble(_arabicSize, settings.arabicFontSize);
    await _prefs.setDouble(_translationSize, settings.translationFontSize);
    await _prefs.setBool(_showTranslation, settings.showTranslation);
    await _prefs.setBool(_showMarkers, settings.showMarkers);
    await _prefs.setBool(_keepAwake, settings.keepScreenAwake);
    await _prefs.setStringList(_translations, settings.translationIds);
    await _prefs.setString(_recitationMode, settings.recitationMode.name);
    await _prefs.setString(_reciter, settings.reciterId);
    await _prefs.setString(_urduReciter, settings.urduReciterId);
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
