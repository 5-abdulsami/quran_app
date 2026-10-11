import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/quran/references.dart';
import '../../domain/models/bookmark.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../reader/reader_footer.dart';
import '../reader/reader_providers.dart';
import '../reader/reader_scaffold.dart';

/// Reads one juz in mushaf order across surah boundaries, with the same ayah
/// tile and actions as the surah reader.
class JuzReaderScreen extends ConsumerWidget {
  const JuzReaderScreen({required this.juz, this.initialVerseKey, super.key});

  final int juz;

  /// Open at (and highlight) this verse; otherwise resume the saved position.
  final String? initialVerseKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(juzsProvider).value?.elementAtOrNull(juz - 1);

    return ReaderScaffold(
      title: name == null
          ? l10n.juzNumber(juz)
          : '${l10n.juzNumber(juz)} · ${name.nameTransliterated}',
      content: ref.watch(juzContentProvider(juz)),
      mode: ReadingMode.juz,
      ref: juz,
      initialVerseKey: initialVerseKey,
      menuActions: [
        // Switch to the surah reader at the verse currently on screen.
        ReaderMenuAction(l10n.readBySurah, (item) {
          if (item == null) return;
          context.pushReplacement(
            AppRoutes.surah(item.ayah.surahNumber, ayah: item.ayah.ayahNumber),
          );
        }),
      ],
      footerBuilder: (attribution) => ReaderFooter(
        attribution: attribution,
        previousLabel: juz > 1 ? l10n.juzNumber(juz - 1) : null,
        onPrevious: juz > 1
            ? () => context.pushReplacement(AppRoutes.juz(juz - 1))
            : null,
        nextLabel: juz < juzCount ? l10n.juzNumber(juz + 1) : null,
        onNext: juz < juzCount
            ? () => context.pushReplacement(AppRoutes.juz(juz + 1))
            : null,
      ),
    );
  }
}
