import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_settings.dart';
import '../../domain/models/reciter.dart';
import '../../providers.dart';

/// Holds the current [AppSettings] and persists every change.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> _update(AppSettings next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  Future<void> setQuranFont(QuranFont font) =>
      _update(state.copyWith(quranFont: font));

  Future<void> setLanguage(String? code) =>
      _update(state.copyWith(languageCode: () => code));

  Future<void> setArabicFontSize(double size) => _update(
    state.copyWith(
      arabicFontSize: size.clamp(
        AppSettings.minArabicFontSize,
        AppSettings.maxArabicFontSize,
      ),
    ),
  );

  Future<void> setTranslationFontSize(double size) => _update(
    state.copyWith(
      translationFontSize: size.clamp(
        AppSettings.minTranslationFontSize,
        AppSettings.maxTranslationFontSize,
      ),
    ),
  );

  Future<void> setShowTranslation({required bool show}) =>
      _update(state.copyWith(showTranslation: show));

  Future<void> setShowMarkers({required bool show}) =>
      _update(state.copyWith(showMarkers: show));

  Future<void> setKeepScreenAwake({required bool keepAwake}) =>
      _update(state.copyWith(keepScreenAwake: keepAwake));

  Future<void> setRecitationMode(RecitationMode mode) =>
      _update(state.copyWith(recitationMode: mode));

  Future<void> setReciter(Reciter reciter) => _update(
    reciter.language == 'ur'
        ? state.copyWith(urduReciterId: reciter.id)
        : state.copyWith(reciterId: reciter.id),
  );

  /// Replaces the ordered list of selected translation editions.
  Future<void> setTranslationIds(List<String> ids) =>
      _update(state.copyWith(translationIds: List.unmodifiable(ids)));
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
