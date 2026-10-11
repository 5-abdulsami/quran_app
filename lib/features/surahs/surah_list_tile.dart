import 'package:flutter/material.dart';

import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/l10n_labels.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/theme/quran_typography.dart';
import '../../ui/widgets/number_medallion.dart';

/// One row of the surah index (also used in search results).
///
/// The Arabic name is the plain name in Amiri Quran, not a calligraphic glyph:
/// at list size the calligraphy is an illegible smudge (as the web notes).
class SurahListTile extends StatelessWidget {
  const SurahListTile({required this.surah, required this.onTap, super.key});

  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: NumberMedallion(surah.number),
      title: Text(
        surah.nameSimple,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        [
          surah.nameTranslated,
          l10n.revelationShort(surah.revelationPlace),
          l10n.versesCount(surah.ayahCount),
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: Text(
          surah.nameArabic,
          textDirection: TextDirection.rtl,
          locale: QuranTypography.locale,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: TextStyle(
            fontFamily: QuranTypography.fontFamily,
            fontSize: 22,
            height: 1.6,
            color: context.quranColors.quranText,
          ),
        ),
      ),
    );
  }
}
