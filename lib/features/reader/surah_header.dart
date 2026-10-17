import 'package:flutter/material.dart';

import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/l10n_labels.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/theme/quran_typography.dart';
import 'bismillah_header.dart';

/// A surah's opening, laid out as on the web app.
///
/// The Arabic name leads, centred, the way it does at the head of a printed
/// chapter, with the Latin name and counts beneath it. It is set as real text,
/// not an ornamental surah-title glyph font: those decorative calligraphy
/// fonts stay hard to read at any size, and real text is selectable and read
/// correctly by screen readers.
class SurahHeader extends StatelessWidget {
  const SurahHeader({
    required this.surah,
    required this.arabicFontSize,
    super.key,
  });

  final Surah surah;
  final double arabicFontSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.quranColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.sourceBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.sourceBorder),
            ),
            child: Semantics(
              header: true,
              label: l10n.surahSemantics(surah.number, surah.nameSimple),
              excludeSemantics: true,
              child: Column(
                children: [
                  Text(
                    surah.nameArabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    locale: QuranTypography.locale,
                    style: TextStyle(
                      fontFamily: QuranTypography.fontOf(context).family,
                      fontSize: arabicFontSize * 1.15,
                      // Room for the marks below the name (e.g. a kasra).
                      height: 2.3,
                      leadingDistribution: TextLeadingDistribution.even,
                      color: colors.quranText,
                    ),
                  ),
                  Text(
                    '${surah.number}. ${surah.nameSimple}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      surah.nameTranslated,
                      l10n.versesCount(surah.ayahCount),
                      l10n.revelation(surah.revelationPlace),
                    ].join(' · '),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (surah.rendersHeaderBismillah) ...[
            const SizedBox(height: 8),
            BismillahHeader(fontSize: arabicFontSize),
          ],
        ],
      ),
    );
  }
}

/// Opens a juz that begins mid-surah. Never followed by a basmalah.
class ContinuingSurahCard extends StatelessWidget {
  const ContinuingSurahCard({
    required this.surah,
    required this.fromAyah,
    super.key,
  });

  final Surah surah;
  final int fromAyah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          AppLocalizations.of(
            context,
          ).continuingSurah(surah.nameSimple, fromAyah),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
