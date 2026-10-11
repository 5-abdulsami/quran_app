import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/translation_download_service.dart';
import '../../providers.dart';
import 'settings_controller.dart';

/// Translations AlQuran.cloud offers. Fetched only when the reader opens the
/// translations screen: the app makes no other network calls.
final availableEditionsProvider =
    FutureProvider.autoDispose<List<AvailableEdition>>(
      (ref) => ref.watch(translationDownloadServiceProvider).fetchAvailable(),
    );

/// The state of one download.
sealed class DownloadStatus {
  const DownloadStatus();
}

/// In progress; [progress] is 0..1, or null when the size is unknown.
final class Downloading extends DownloadStatus {
  const Downloading(this.progress);
  final double? progress;
}

final class DownloadFailed extends DownloadStatus {
  const DownloadFailed();
}

/// Downloads and deletions of optional translations, by edition id.
class TranslationDownloads extends Notifier<Map<String, DownloadStatus>> {
  @override
  Map<String, DownloadStatus> build() => const {};

  /// Replaces (or with null, clears) one edition's status. State maps are
  /// never mutated in place.
  void _set(String id, DownloadStatus? status) => state = {
    for (final entry in state.entries)
      if (entry.key != id) entry.key: entry.value,
    id: ?status,
  };

  /// Downloads [edition], validates it, and shows it in the reader. A failure
  /// is reported on the row and never affects the rest of the app.
  Future<void> download(AvailableEdition edition) async {
    if (state[edition.id] is Downloading) return;
    _set(edition.id, const Downloading(null));
    try {
      await ref
          .read(translationDownloadServiceProvider)
          .download(
            edition,
            onProgress: (progress) => _set(edition.id, Downloading(progress)),
          );
      ref.invalidate(editionsProvider);
      final settings = ref.read(settingsControllerProvider);
      if (!settings.translationIds.contains(edition.id)) {
        await ref.read(settingsControllerProvider.notifier).setTranslationIds([
          ...settings.translationIds,
          edition.id,
        ]);
      }
      _set(edition.id, null);
    } on Object {
      _set(edition.id, const DownloadFailed());
    }
  }

  /// Deletes a downloaded edition (bundled ones cannot be deleted).
  Future<void> delete(String editionId) async {
    await ref.read(translationDownloadServiceProvider).delete(editionId);
    final ids = ref.read(settingsControllerProvider).translationIds;
    await ref
        .read(settingsControllerProvider.notifier)
        .setTranslationIds(ids.where((id) => id != editionId).toList());
    ref.invalidate(editionsProvider);
  }
}

final translationDownloadsProvider =
    NotifierProvider<TranslationDownloads, Map<String, DownloadStatus>>(
      TranslationDownloads.new,
    );
