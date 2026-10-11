import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/quran/attribution.dart';
import '../../core/quran/references.dart';
import '../../data/quran_repository.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/translation_edition.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../ui/l10n_labels.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/async_value_view.dart';
import '../../ui/widgets/attribution_text.dart';
import '../../ui/widgets/quran_text.dart';
import '../reader/verse_actions.dart';
import '../settings/settings_controller.dart';

/// One verse with EVERY installed translation: a reader who opens a single
/// verse is usually there to compare (as on the web's verse page). The
/// reader's chosen translations come first.
final ayahDetailProvider = FutureProvider.autoDispose.family<Ayah?, String>((
  ref,
  verseKey,
) async {
  final selected = ref.watch(
    settingsControllerProvider.select((s) => s.translationIds),
  );
  final installed = await ref.watch(editionsProvider.future);
  final ids = [
    ...selected,
    for (final e in installed)
      if (!selected.contains(e.id)) e.id,
  ];
  return ref.watch(quranRepositoryProvider).ayah(verseKey, translationIds: ids);
});

class AyahDetailScreen extends ConsumerWidget {
  const AyahDetailScreen({required this.surah, required this.ayah, super.key});

  final int surah;
  final int ayah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final verseKey = '$surah:$ayah';
    final detail = ref.watch(ayahDetailProvider(verseKey));
    final meta = ref.watch(surahsProvider).value?.elementAtOrNull(surah - 1);
    final bookmarked =
        ref.watch(bookmarkedKeysProvider).value?.contains(verseKey) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(meta == null ? verseKey : '${meta.nameSimple} · $verseKey'),
        actions: [
          IconButton(
            tooltip: bookmarked ? l10n.removeBookmark : l10n.bookmarkVerse,
            isSelected: bookmarked,
            icon: const Icon(Icons.bookmark_border),
            selectedIcon: const Icon(Icons.bookmark),
            onPressed: () =>
                ref.read(bookmarkRepositoryProvider).toggle(verseKey),
          ),
          if (detail.value case final loaded? when meta != null)
            IconButton(
              tooltip: l10n.verseActions,
              icon: const Icon(Icons.share_outlined),
              onPressed: () => showVerseActions(
                context,
                ayah: loaded,
                surah: meta,
                showOpenDetail: false,
                showReadInContext: true,
              ),
            ),
        ],
      ),
      body: AsyncValueView(
        value: detail,
        onRetry: () => ref.invalidate(ayahDetailProvider(verseKey)),
        data: (loaded) => loaded == null
            ? ErrorMessage(message: l10n.notFound)
            : _AyahDetailBody(ayah: loaded),
      ),
    );
  }
}

class _AyahDetailBody extends ConsumerWidget {
  const _AyahDetailBody({required this.ayah});

  final Ayah ayah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.quranColors;
    final fontSize = ref.watch(
      settingsControllerProvider.select((s) => s.arabicFontSize),
    );
    final editions = {
      for (final e
          in ref.watch(editionsProvider).value ?? const <TranslationEdition>[])
        e.id: e,
    };
    final previous = QuranRepository.verseKeyFor(ayah.id - 1);
    final next = QuranRepository.verseKeyFor(ayah.id + 1);

    Widget fact(String label, Object value) => Chip(
      label: Text('$label $value'),
      visualDensity: VisualDensity.compact,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: colors.sourceBackground,
            border: Border.all(color: colors.sourceBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: QuranText(
            ayah.displayText,
            fontSize: fontSize * 1.15,
            ayahNumber: ayah.ayahNumber,
            selectable: true,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            fact(l10n.juz, ayah.juz),
            fact(l10n.hizb, ayah.hizb),
            fact(l10n.page, ayah.page),
            fact(l10n.manzil, ayah.manzil),
            fact(l10n.ruku, ayah.ruku),
            if (ayah.sajdahType case final sajdah?)
              Chip(
                label: Text(l10n.sajdah(sajdah)),
                backgroundColor: theme.colorScheme.primaryContainer,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(l10n.translations, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (ayah.translations.isEmpty)
          Text(l10n.noTranslationSelected)
        else
          for (final translation in ayah.translations)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Directionality(
                    textDirection: translation.isRtl
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          translation.text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                          ),
                        ),
                        if (editions[translation.editionId]
                            case final edition?) ...[
                          const SizedBox(height: 8),
                          AttributionText(
                            creditLine(
                              translatorName: edition.translator,
                              sourceName: edition.name,
                              attribution: edition.attribution,
                              translatedBy: l10n.translatedBy,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => context.push(
            AppRoutes.surah(ayah.surahNumber, ayah: ayah.ayahNumber),
          ),
          icon: const Icon(Icons.menu_book_outlined),
          label: Text(l10n.readInContext),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (previous != null)
              OutlinedButton.icon(
                onPressed: () => _open(context, previous),
                icon: const Icon(Icons.arrow_back),
                label: Text(previous),
              ),
            const Spacer(),
            if (next != null)
              OutlinedButton.icon(
                onPressed: () => _open(context, next),
                icon: const Icon(Icons.arrow_forward),
                iconAlignment: IconAlignment.end,
                label: Text(next),
              ),
          ],
        ),
      ],
    );
  }

  static void _open(BuildContext context, String verseKey) {
    final parsed = parseVerseKey(verseKey)!;
    context.pushReplacement(AppRoutes.ayah(parsed.surah, parsed.ayah));
  }
}
