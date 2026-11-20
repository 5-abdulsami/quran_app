import 'package:flutter/material.dart';

import '../../core/text/arabic_digits.dart';
import '../../core/text/highlight.dart';
import '../../core/text/search_terms.dart';
import '../../domain/models/ayah.dart';
import '../theme/app_theme.dart';
import '../theme/quran_typography.dart';

/// The one way Quranic text is put on screen.
///
/// Verses and the basmalah are given as [QuranText.ayah] and
/// [QuranText.basmalah], which show the text the chosen font is drawn for
/// (Indo-Pak or Uthmani; see [QuranScript]), so no screen can pair a font with
/// the wrong text.
///
/// Always right-to-left, always the chosen Quran font with the Arabic locale,
/// always start-aligned (ragged on the left, never justified: justification
/// without kashida support pulls words apart), with leading generous enough
/// that no mark is clipped. The text itself is rendered exactly as given; search
/// highlights only change the background of whole original words.
class QuranText extends StatelessWidget {
  /// A verse, with its end-of-verse number unless [showNumber] is false.
  ///
  /// [highlightTerms] highlights the words matching a search.
  const QuranText.ayah(
    Ayah this.ayah, {
    required this.fontSize,
    this.showNumber = true,
    this.selectable = false,
    this.textAlign = TextAlign.start,
    this.semanticsLabel,
    this.highlightTerms = const [],
    this.maxLines,
    super.key,
  });

  /// The basmalah, as shown above a surah.
  const QuranText.basmalah({
    required this.fontSize,
    this.textAlign = TextAlign.center,
    this.semanticsLabel,
    super.key,
  }) : ayah = null,
       showNumber = false,
       selectable = false,
       highlightTerms = const [],
       maxLines = null;

  /// The verse to show, or null for the basmalah.
  final Ayah? ayah;
  final double fontSize;

  /// Whether the Uthmani verse is followed by its ornament (U+06DD +
  /// Arabic-Indic digits). The Indo-Pak texts always keep their own verse
  /// numbers: the waqf signs drawn above them are part of the verse.
  final bool showNumber;

  /// Selectable text, for the ayah detail screen.
  final bool selectable;
  final TextAlign textAlign;
  final String? semanticsLabel;

  /// Search terms whose matching words are highlighted.
  final List<SearchTerm> highlightTerms;

  /// Truncates with an ellipsis, for search snippets.
  final int? maxLines;

  /// Key of the inner text widget, for tests asserting style and direction.
  static const textKey = ValueKey('quran-text');

  @override
  Widget build(BuildContext context) {
    final colors = context.quranColors;
    final font = QuranTypography.fontOf(context);
    final style = QuranTypography.style(
      font: font,
      fontSize: fontSize,
      color: colors.quranText,
    );
    final ayah = this.ayah;
    final text = ayah == null
        ? font.script.basmalahText
        : font.script.verseText(ayah);
    final ayahNumber =
        ayah != null && showNumber && !font.script.hasOwnVerseEnds
        ? ayah.ayahNumber
        : null;
    final highlights = highlightRanges(text, highlightTerms);
    final span = TextSpan(
      children: [
        // The verse itself, as one span (split only for highlights).
        TextSpan(
          children: [
            for (final (segment, highlighted) in splitHighlights(
              text,
              highlights,
            ))
              TextSpan(
                text: segment,
                style: highlighted
                    ? TextStyle(backgroundColor: colors.highlight)
                    : null,
              ),
          ],
        ),
        if (ayahNumber case final number?) ...[
          TextSpan(
            // A no-break space keeps the ornament on the verse's last line.
            text: '\u{00A0}${endOfAyahMarker(number)}',
            style: TextStyle(
              color: colors.ornament,
              fontFamily: QuranTypography.ornamentFamily,
            ),
          ),
          // The QPC Nastaleeq signs that sit on the verse-end circle.
          if (font.script.verseEndSigns(ayah!) case final signs
              when signs.isNotEmpty)
            TextSpan(text: signs),
        ],
      ],
    );

    final child = selectable
        ? SelectableText.rich(
            span,
            key: textKey,
            style: style,
            textAlign: textAlign,
            textDirection: TextDirection.rtl,
          )
        : Text.rich(
            span,
            key: textKey,
            style: style,
            textAlign: textAlign,
            textDirection: TextDirection.rtl,
            locale: QuranTypography.locale,
            semanticsLabel: semanticsLabel,
            maxLines: maxLines,
            overflow: maxLines == null ? null : TextOverflow.ellipsis,
          );

    // The Arabic locale travels on the text style (see QuranTypography.style),
    // so no per-verse Localizations scope is needed: lists stay light.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}
