import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran/attribution.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/surah.dart';
import '../../domain/models/translation_edition.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../ui/theme/quran_typography.dart';
import '../../ui/toast.dart';
import '../../ui/widgets/app_loader.dart';
import '../../ui/widgets/attribution_text.dart';
import '../audio/recitation_controller.dart';
import '../reader/verse_actions.dart';
import '../settings/settings_controller.dart';

/// What a tap on a verse in the mushaf opens: its translations, and the
/// everyday actions. Everything else (copy, share, detail) is one tap further,
/// in the same actions sheet the readers use.
Future<void> showMushafAyahSheet(
  BuildContext context, {
  required Ayah ayah,
  required Surah surah,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _MushafAyahSheet(ayah: ayah, surah: surah, host: context),
);

/// The verse with the reader's chosen translations (the mushaf shows none).
final _translatedAyahProvider = FutureProvider.autoDispose
    .family<Ayah?, String>((ref, verseKey) {
      final ids = ref.watch(
        settingsControllerProvider.select((s) => s.translationIds),
      );
      return ref
          .watch(quranRepositoryProvider)
          .ayah(verseKey, translationIds: ids);
    });

class _MushafAyahSheet extends ConsumerWidget {
  const _MushafAyahSheet({
    required this.ayah,
    required this.surah,
    required this.host,
  });

  final Ayah ayah;
  final Surah surah;

  /// The screen underneath: still mounted after this sheet closes, so the
  /// actions sheet opens from it.
  final BuildContext host;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final translated = ref.watch(_translatedAyahProvider(ayah.verseKey)).value;
    final editions = {
      for (final e
          in ref.watch(editionsProvider).value ?? const <TranslationEdition>[])
        e.id: e,
    };
    final fontSize = ref.watch(
      settingsControllerProvider.select((s) => s.translationFontSize),
    );
    final bookmarked =
        ref.watch(bookmarkedKeysProvider).value?.contains(ayah.verseKey) ??
        false;
    final messenger = ScaffoldMessenger.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${surah.nameSimple} · ${ayah.verseKey}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (translated == null)
                  const Center(child: AppLoader())
                else if (translated.translations.isEmpty)
                  Text(l10n.noTranslationSelected)
                else
                  for (final t in translated.translations) ...[
                    Directionality(
                      textDirection: t.isRtl
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: Text(
                        t.text,
                        locale: Locale(t.language),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: t.isRtl
                              ? fontSize * TranslationTypography.rtlScale
                              : fontSize,
                          height: t.isRtl
                              ? TranslationTypography.rtlLineHeight
                              : TranslationTypography.lineHeight,
                        ),
                      ),
                    ),
                    if (editions[t.editionId] case final edition?)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
                        child: AttributionText(
                          creditLine(
                            translatorName: edition.translator,
                            sourceName: edition.name,
                            attribution: edition.attribution,
                            translatedBy: l10n.translatedBy,
                          ),
                        ),
                      ),
                  ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref
                            .read(recitationControllerProvider.notifier)
                            .playSurah(surah, fromAyah: ayah.ayahNumber);
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.playFromHere),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final added = await ref
                            .read(bookmarkRepositoryProvider)
                            .toggle(ayah.verseKey);
                        messenger.showToast(
                          added ? l10n.bookmarkAdded : l10n.bookmarkRemoved,
                        );
                      },
                      icon: Icon(
                        bookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_add_outlined,
                      ),
                      label: Text(
                        bookmarked ? l10n.removeBookmark : l10n.bookmarkVerse,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: translated == null
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              showVerseActions(
                                host,
                                ayah: translated,
                                surah: surah,
                                showReadInContext: true,
                              );
                            },
                      icon: const Icon(Icons.more_horiz),
                      label: Text(l10n.verseActions),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
