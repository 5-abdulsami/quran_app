import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/bookmark.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../reader/reader_controls.dart';
import '../reader/reader_footer.dart';
import '../reader/reader_providers.dart';
import '../reader/reader_scaffold.dart';

/// Reads one surah from start to finish (mirrors the web's /quran/[surah]).
class SurahReaderScreen extends ConsumerWidget {
  const SurahReaderScreen({required this.surah, this.initialAyah, super.key});

  final int surah;

  /// Open at this ayah and highlight it; otherwise resume where the reader
  /// stopped in this surah.
  final int? initialAyah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final surahs = ref.watch(surahsProvider).value;
    // Surah n is at index n - 1, so its neighbours are at n - 2 and n.
    final current = surahs?.elementAtOrNull(surah - 1);
    final previous = surah > 1 ? surahs?.elementAtOrNull(surah - 2) : null;
    final next = surahs?.elementAtOrNull(surah);

    return ReaderScaffold(
      title: current?.nameSimple ?? '',
      content: ref.watch(surahContentProvider(surah)),
      mode: ReadingMode.surah,
      ref: surah,
      initialVerseKey: initialAyah == null ? null : '$surah:$initialAyah',
      extraActions: (reader) => [
        if (current != null)
          IconButton(
            tooltip: l10n.goToAyah,
            icon: const Icon(Icons.pin_outlined),
            onPressed: () async {
              final ayah = await showGoToAyahDialog(
                context,
                max: current.ayahCount,
              );
              if (ayah != null) {
                reader.currentState?.jumpToVerse('$surah:$ayah');
              }
            },
          ),
      ],
      menuActions: [
        // Switch to the juz reader at the verse currently on screen.
        ReaderMenuAction(l10n.readByJuz, (item) {
          if (item == null) return;
          context.pushReplacement(
            AppRoutes.juz(item.ayah.juz, verseKey: item.ayah.verseKey),
          );
        }),
      ],
      footerBuilder: (attribution) => ReaderFooter(
        attribution: attribution,
        previousLabel: previous?.nameSimple,
        onPrevious: previous == null
            ? null
            : () => context.pushReplacement(AppRoutes.surah(previous.number)),
        nextLabel: next?.nameSimple,
        onNext: next == null
            ? null
            : () => context.pushReplacement(AppRoutes.surah(next.number)),
      ),
    );
  }
}
