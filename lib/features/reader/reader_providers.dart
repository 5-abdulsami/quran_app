import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/bookmark.dart';
import '../../domain/models/translation_edition.dart';
import '../../providers.dart';
import '../settings/settings_controller.dart';
import 'reader_items.dart';

/// The translations currently shown, re-read when the selection changes.
final _visibleTranslationIdsProvider = Provider<List<String>>(
  (ref) => ref.watch(
    settingsControllerProvider.select((s) => s.visibleTranslationIds),
  ),
);

/// Everything the surah reader renders for surah `n`.
final surahContentProvider = FutureProvider.autoDispose
    .family<ReaderContent, int>((ref, number) async {
      final ids = ref.watch(_visibleTranslationIdsProvider);
      final repo = ref.watch(quranRepositoryProvider);
      final surah = (await repo.surah(number))!;
      return buildSurahContent(
        surah,
        await repo.surahAyahs(number, translationIds: ids),
      );
    });

/// Everything the juz reader renders for juz `n`.
final juzContentProvider = FutureProvider.autoDispose
    .family<ReaderContent, int>((ref, number) async {
      final ids = ref.watch(_visibleTranslationIdsProvider);
      final repo = ref.watch(quranRepositoryProvider);
      return buildJuzContent(
        await repo.surahs(),
        await repo.juzAyahs(number, translationIds: ids),
      );
    });

/// The saved position for one surah or juz (read once when a reader opens).
final savedPositionProvider = FutureProvider.autoDispose
    .family<ReadingPosition?, (ReadingMode, int)>(
      (ref, key) =>
          ref.watch(readingPositionRepositoryProvider).position(key.$1, key.$2),
    );

/// Licence-required credits for the translations on screen.
final visibleAttributionsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final ids = ref.watch(_visibleTranslationIdsProvider);
  final editions = {
    for (final TranslationEdition e in await ref.watch(editionsProvider.future))
      e.id: e,
  };
  return [for (final id in ids) ?editions[id]?.attribution];
});
