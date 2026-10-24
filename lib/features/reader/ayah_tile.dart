import 'package:flutter/material.dart';

import '../../domain/models/ayah.dart';
import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/l10n_labels.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/theme/quran_typography.dart';
import '../../ui/widgets/quran_text.dart';

/// Whether a verse is the one being recited.
enum AyahRecitation { idle, playing, paused }

/// One verse: the same widget in the surah reader, the juz reader and search.
///
/// Layout choices that matter for Arabic (as in the web's ayah-row.tsx):
///   - the Arabic is its own right-to-left block, never inline with Latin
///     text, so the bidi algorithm has nothing to get wrong;
///   - it is left ragged rather than justified;
///   - line height is generous, since marks extend well above and below the
///     baseline.
class AyahTile extends StatelessWidget {
  const AyahTile({
    required this.ayah,
    required this.surah,
    required this.arabicFontSize,
    required this.translationFontSize,
    required this.onActions,
    this.onOpenDetail,
    this.showJuz = false,
    this.showHizb = false,
    this.showPage = false,
    this.editionNames = const {},
    this.highlighted = false,
    this.bookmarked = false,
    this.onPlay,
    this.recitation = AyahRecitation.idle,
    super.key,
  });

  final Ayah ayah;
  final Surah surah;
  final double arabicFontSize;
  final double translationFontSize;

  /// Opens the verse-actions sheet (long-press or the ⋯ button).
  final VoidCallback onActions;

  /// Tapping the verse-key chip.
  final VoidCallback? onOpenDetail;

  /// Markers, printed only where the value changes from the previous ayah.
  final bool showJuz;
  final bool showHizb;
  final bool showPage;

  /// Edition id → display name; names are shown when there are several
  /// translations, so the reader can tell them apart.
  final Map<String, String> editionNames;

  /// Briefly true for the verse the reader just navigated to.
  final bool highlighted;
  final bool bookmarked;

  /// Starts (or, for the verse being recited, pauses and resumes) recitation.
  /// No play button when null.
  final VoidCallback? onPlay;
  final AyahRecitation recitation;

  /// Stable key for a verse's tile, used by tests and scrolling.
  static Key keyFor(String verseKey) => ValueKey('ayah-$verseKey');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.quranColors;

    final markers = [
      if (showJuz) l10n.juzNumber(ayah.juz),
      if (showHizb) l10n.hizbNumber(ayah.hizb),
      if (showPage) l10n.pageNumber(ayah.page),
    ];

    return Semantics(
      container: true,
      label: l10n.verseSemantics(surah.nameSimple, ayah.ayahNumber),
      child: InkWell(
        onLongPress: onActions,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          color: highlighted || recitation != AyahRecitation.idle
              ? colors.highlight
              : Colors.transparent,
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ActionChip(
                    label: Text(ayah.verseKey),
                    onPressed: onOpenDetail,
                    tooltip: l10n.openDetail,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (markers.isNotEmpty)
                          Text(
                            markers.join(' · '),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.marker,
                            ),
                          ),
                        if (ayah.sajdahType case final sajdah?)
                          _SajdahBadge(label: l10n.sajdah(sajdah)),
                      ],
                    ),
                  ),
                  if (bookmarked)
                    Icon(
                      Icons.bookmark,
                      size: 20,
                      color: theme.colorScheme.primary,
                      semanticLabel: l10n.bookmarkVerse,
                    ),
                  if (onPlay case final onPlay?)
                    IconButton(
                      icon: Icon(
                        recitation == AyahRecitation.playing
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                      ),
                      tooltip: recitation == AyahRecitation.playing
                          ? l10n.pause
                          : l10n.playFromHere,
                      onPressed: onPlay,
                    ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    tooltip: l10n.verseActions,
                    onPressed: onActions,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: QuranText(
                  ayah.displayText,
                  fontSize: arabicFontSize,
                  ayahNumber: ayah.ayahNumber,
                ),
              ),
              for (final translation in ayah.translations)
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 12, end: 12),
                  child: _TranslationText(
                    translation: translation,
                    fontSize: translationFontSize,
                    editionName: ayah.translations.length > 1
                        ? editionNames[translation.editionId]
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranslationText extends StatelessWidget {
  const _TranslationText({
    required this.translation,
    required this.fontSize,
    this.editionName,
  });

  final AyahTranslation translation;
  final double fontSize;
  final String? editionName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final direction = translation.isRtl ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(
      textDirection: direction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (editionName case final name?)
            Text(
              name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          Text(
            translation.text,
            locale: Locale(translation.language),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: fontSize,
              height: TranslationTypography.lineHeight,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _SajdahBadge extends StatelessWidget {
  const _SajdahBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: scheme.onPrimaryContainer),
      ),
    );
  }
}
