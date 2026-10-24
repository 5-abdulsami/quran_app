import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../domain/models/surah.dart';
import '../../domain/recitation_queue.dart';
import '../../providers.dart';
import '../settings/settings_controller.dart';

/// What the recitation player is doing.
@immutable
class RecitationState {
  const RecitationState({
    this.queue = const [],
    this.index,
    this.playing = false,
    this.buffering = false,
    this.failures = 0,
  });

  final List<RecitationTrack> queue;
  final int? index;
  final bool playing;
  final bool buffering;

  /// Counts playback failures, so listeners can react to each new one.
  final int failures;

  RecitationTrack? get current => switch (index) {
    final i? when i < queue.length => queue[i],
    _ => null,
  };

  /// Whether anything is loaded (playing or paused).
  bool get active => current != null;

  RecitationState copyWith({
    int? index,
    bool? playing,
    bool? buffering,
    int? failures,
  }) => RecitationState(
    queue: queue,
    index: index ?? this.index,
    playing: playing ?? this.playing,
    buffering: buffering ?? this.buffering,
    failures: failures ?? this.failures,
  );
}

/// Plays verses: streamed, or from downloads when present, with lock-screen
/// and notification controls.
///
/// The [AudioPlayer] is created on first use, so screens (and tests) that
/// never play anything never touch the audio plugins.
class RecitationController extends Notifier<RecitationState> {
  AudioPlayer? _player;
  final _subscriptions = <StreamSubscription<Object?>>[];

  @override
  RecitationState build() {
    ref.onDispose(() {
      for (final s in _subscriptions) {
        s.cancel();
      }
      _player?.dispose();
    });
    return const RecitationState();
  }

  AudioPlayer _ensurePlayer() {
    if (_player case final player?) return player;
    final player = _player = AudioPlayer();
    _subscriptions
      ..add(
        player.playerStateStream.listen((s) {
          if (s.processingState == ProcessingState.completed) {
            // The end of the queue: clear the player away.
            unawaited(stop());
            return;
          }
          state = state.copyWith(
            playing: s.playing,
            buffering:
                s.processingState == ProcessingState.loading ||
                s.processingState == ProcessingState.buffering,
          );
        }),
      )
      ..add(
        player.currentIndexStream.listen((i) {
          if (i != null && state.active) state = state.copyWith(index: i);
        }),
      )
      ..add(player.errorStream.listen((_) => _fail()));
    return player;
  }

  /// Progress through the current track, 0..1.
  Stream<double> get trackProgress {
    final player = _player;
    if (player == null) return Stream.value(0);
    return player.positionStream.map((position) {
      final total = player.duration?.inMilliseconds ?? 0;
      return total <= 0
          ? 0
          : (position.inMilliseconds / total).clamp(0, 1).toDouble();
    });
  }

  /// Recites [verses] in order, per the user's recitation settings.
  Future<void> playVerses(List<(Surah, int)> verses) async {
    if (verses.isEmpty) return;
    final settings = ref.read(settingsControllerProvider);
    final store = ref.read(recitationAudioStoreProvider);
    final queue = buildRecitationQueue(
      verses,
      mode: settings.recitationMode,
      arabic: settings.reciter,
      urdu: settings.urduReciter,
    );
    state = RecitationState(
      queue: queue,
      index: 0,
      buffering: true,
      failures: state.failures,
    );
    try {
      final player = _ensurePlayer();
      await player.setAudioSources([
        for (final (i, track) in queue.indexed)
          AudioSource.uri(
            store.sourceFor(track),
            tag: MediaItem(
              // Unique per position: the same file can recur (the basmalah).
              id: '$i:${track.reciter.id}/${track.fileName}',
              title: '${track.surah.nameSimple} ${track.verseKey}',
              artist: track.reciter.name,
              album: track.surah.nameSimple,
            ),
          ),
      ]);
      unawaited(player.play());
    } on PlayerInterruptedException {
      // A newer request replaced this one.
    } on Object {
      _fail();
    }
  }

  /// Recites [surah] from [fromAyah] to its end.
  Future<void> playSurah(Surah surah, {int fromAyah = 1}) => playVerses([
    for (var a = fromAyah; a <= surah.ayahCount; a++) (surah, a),
  ]);

  void _fail() {
    // A failed load is reported both by the call and by errorStream.
    if (!state.active) return;
    final failures = state.failures + 1;
    unawaited(_player?.stop());
    state = RecitationState(failures: failures);
  }

  Future<void> togglePlay() async {
    final player = _player;
    if (player == null || !state.active) return;
    if (player.playing) {
      await player.pause();
    } else {
      unawaited(player.play());
    }
  }

  /// Jumps to the next verse (past its basmalah and Urdu tracks).
  Future<void> nextVerse() async {
    final i = state.index;
    if (i == null) return;
    final key = state.queue[i].verseKey;
    final next = state.queue.indexWhere((t) => t.verseKey != key, i);
    if (next != -1) await _player?.seek(Duration.zero, index: next);
  }

  /// Restarts the current verse, or goes to the previous one when already at
  /// the start of it.
  Future<void> previousVerse() async {
    final player = _player;
    final i = state.index;
    if (player == null || i == null) return;
    final queue = state.queue;
    var start = i;
    while (start > 0 && queue[start - 1].verseKey == queue[i].verseKey) {
      start--;
    }
    final atStart = i == start && player.position < const Duration(seconds: 2);
    if (atStart && start > 0) {
      var previous = start - 1;
      while (previous > 0 &&
          queue[previous - 1].verseKey == queue[start - 1].verseKey) {
        previous--;
      }
      start = previous;
    }
    await player.seek(Duration.zero, index: start);
  }

  Future<void> stop() async {
    state = RecitationState(failures: state.failures);
    await _player?.stop();
  }
}

final recitationControllerProvider =
    NotifierProvider<RecitationController, RecitationState>(
      RecitationController.new,
    );
