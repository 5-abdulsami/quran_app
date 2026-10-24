import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../ui/toast.dart';
import 'recitation_controller.dart';

/// The mini player: what is being recited, with previous / play-pause / next
/// / stop. Takes no space while nothing is loaded.
///
/// Also reports playback failures, so mount exactly one per screen; see
/// [RecitationPlayerBarScope].
class RecitationPlayerBar extends ConsumerWidget {
  const RecitationPlayerBar({this.onOpen, this.safeBottom = false, super.key});

  /// Tapping the title (e.g. to open the verse being recited).
  final void Function(String verseKey)? onOpen;

  /// Pads for the system navigation area (when nothing below does).
  final bool safeBottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(recitationControllerProvider.select((s) => s.failures), (
      previous,
      next,
    ) {
      if (previous != null && next > previous) {
        ScaffoldMessenger.of(
          context,
        ).showToast(AppLocalizations.of(context).audioPlayFailed);
      }
    });

    final state = ref.watch(recitationControllerProvider);
    final track = state.current;
    if (track == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(recitationControllerProvider.notifier);
    final subtitle = [
      track.reciter.name,
      if (track.reciter.language == 'ur') l10n.modeUrdu,
    ].join(' · ');

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        bottom: safeBottom,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<double>(
              stream: controller.trackProgress,
              builder: (context, snapshot) => LinearProgressIndicator(
                value: state.buffering ? null : (snapshot.data ?? 0),
                minHeight: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onOpen == null
                          ? null
                          : () => onOpen!(track.verseKey),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${track.surah.nameSimple} · ${track.verseKey}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.previousVerse,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: controller.previousVerse,
                  ),
                  IconButton(
                    tooltip: state.playing ? l10n.pause : l10n.play,
                    icon: Icon(state.playing ? Icons.pause : Icons.play_arrow),
                    onPressed: controller.togglePlay,
                  ),
                  IconButton(
                    tooltip: l10n.nextVerse,
                    icon: const Icon(Icons.skip_next),
                    onPressed: controller.nextVerse,
                  ),
                  IconButton(
                    tooltip: l10n.stopPlayback,
                    icon: const Icon(Icons.close),
                    onPressed: controller.stop,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Marks a subtree whose screen already shows a [RecitationPlayerBar] (the
/// tab shell), so screens nested inside it do not add a second one.
class RecitationPlayerBarScope extends InheritedWidget {
  const RecitationPlayerBarScope({required super.child, super.key});

  static bool isProvided(BuildContext context) =>
      context.getInheritedWidgetOfExactType<RecitationPlayerBarScope>() != null;

  @override
  bool updateShouldNotify(RecitationPlayerBarScope oldWidget) => false;
}
