import 'package:flutter/material.dart';

import '../../core/text/highlight.dart';
import '../../core/text/search_terms.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/widgets/highlighted_text.dart';
import '../../ui/widgets/quran_text.dart';

/// One verse in the search results: reference, Arabic (displayText, never the
/// folded search text) and the first translation, with matches highlighted.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    required this.ayah,
    required this.surah,
    required this.terms,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final Ayah ayah;
  final Surah surah;
  final List<SearchTerm> terms;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  static Key keyFor(String verseKey) => ValueKey('result-$verseKey');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translation = ayah.translations.firstOrNull;

    return Semantics(
      button: true,
      label: AppLocalizations.of(
        context,
      ).verseSemantics(surah.nameSimple, ayah.ayahNumber),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${surah.nameSimple} · ${ayah.verseKey}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              QuranText(
                ayah.displayText,
                fontSize: 22,
                maxLines: 2,
                highlights: highlightRanges(ayah.displayText, terms),
              ),
              if (translation != null)
                HighlightedText(
                  translation.text,
                  highlights: highlightRanges(translation.text, terms),
                  maxLines: 3,
                  textDirection: translation.isRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  locale: Locale(translation.language),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
