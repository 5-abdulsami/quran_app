import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/reciter.dart';
import '../../domain/models/surah.dart';
import '../../domain/recitation_queue.dart';
import '../../providers.dart';
import '../settings/settings_controller.dart';

/// Names of the files downloaded for a reciter (by id). Invalidated by
/// [AudioDownloadsController] after every change.
final downloadedAudioProvider = FutureProvider.family<Set<String>, String>((
  ref,
  reciterId,
) {
  final reciter = [
    ...Reciters.arabic,
    ...Reciters.urdu,
  ].firstWhere((r) => r.id == reciterId);
  return ref.watch(recitationAudioStoreProvider).downloadedFiles(reciter);
});

/// Space used by all downloaded recitations, in bytes.
final audioBytesUsedProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(recitationAudioStoreProvider).bytesUsed(),
);

/// Surah numbers whose audio is fully downloaded for every recording the
/// current recitation mode plays.
final downloadedSurahsProvider = Provider<Set<int>>((ref) {
  final reciters = ref.watch(settingsControllerProvider).activeReciters;
  final surahs = ref.watch(surahsProvider).value ?? const <Surah>[];
  final files = [
    for (final r in reciters) ref.watch(downloadedAudioProvider(r.id)).value,
  ];
  if (files.any((f) => f == null)) return const {};
  return {
    for (final surah in surahs)
      if (files.every((f) => surahFileNames(surah).every(f!.contains)))
        surah.number,
  };
});

/// Surah downloads in progress: surah number → progress 0..1.
class AudioDownloadsController extends Notifier<Map<int, double>> {
  final _cancelled = <int>{};

  @override
  Map<int, double> build() => const {};

  void _set(int surah, double? progress) => state = {
    for (final e in state.entries)
      if (e.key != surah) e.key: e.value,
    surah: ?progress,
  };

  /// Downloads [surah] for every recording the current mode plays. Returns
  /// false when it failed (a cancelled download is not a failure).
  Future<bool> download(Surah surah) async {
    if (state.containsKey(surah.number)) return true;
    final reciters = ref.read(settingsControllerProvider).activeReciters;
    final store = ref.read(recitationAudioStoreProvider);
    _cancelled.remove(surah.number);
    _set(surah.number, 0);
    try {
      for (final (i, reciter) in reciters.indexed) {
        await store.downloadSurah(
          reciter,
          surah,
          isCancelled: () => _cancelled.contains(surah.number),
          onProgress: (done, total) =>
              _set(surah.number, (i + done / total) / reciters.length),
        );
      }
      return true;
    } on Object {
      return false;
    } finally {
      _set(surah.number, null);
      _refresh(reciters);
    }
  }

  void cancel(int surah) => _cancelled.add(surah);

  /// Removes [surah]'s audio for the recordings the current mode plays.
  Future<void> delete(Surah surah) async {
    final reciters = ref.read(settingsControllerProvider).activeReciters;
    final store = ref.read(recitationAudioStoreProvider);
    for (final reciter in reciters) {
      await store.deleteSurah(reciter, surah);
    }
    _refresh(reciters);
  }

  Future<void> deleteAll() async {
    await ref.read(recitationAudioStoreProvider).deleteAll();
    _refresh([...Reciters.arabic, ...Reciters.urdu]);
  }

  void _refresh(List<Reciter> reciters) {
    for (final r in reciters) {
      ref.invalidate(downloadedAudioProvider(r.id));
    }
    ref.invalidate(audioBytesUsedProvider);
  }
}

final audioDownloadsProvider =
    NotifierProvider<AudioDownloadsController, Map<int, double>>(
      AudioDownloadsController.new,
    );
