import 'package:flutter/material.dart';

import '../../core/text/arabic_digits.dart';
import '../../core/text/highlight.dart';
import '../theme/app_theme.dart';
import '../theme/quran_typography.dart';

/// The one way Quranic text is put on screen.
///
/// Always right-to-left, always Amiri Quran with the Arabic locale, always
/// start-aligned (ragged on the left, never justified: justification without
/// kashida support pulls words apart), with leading generous enough that no
/// mark is clipped. The text itself is rendered exactly as given; search
/// highlights only change the background of whole original words.
class QuranText extends StatelessWidget {
  const QuranText(
    this.text, {
    required this.fontSize,
    this.ayahNumber,
    this.selectable = false,
    this.textAlign = TextAlign.start,
    this.semanticsLabel,
    this.highlights = const [],
    this.maxLines,
    super.key,
  });

  /// The text to show, unmodified (an ayah's `displayText`, or the basmalah).
  final String text;
  final double fontSize;

  /// When set, the end-of-ayah ornament (U+06DD + Arabic-Indic digits) is
  /// appended after the verse.
  final int? ayahNumber;

  /// Selectable text, for the ayah detail screen.
  final bool selectable;
  final TextAlign textAlign;
  final String? semanticsLabel;

  /// Ranges of [text] to highlight (search matches).
  final List<TextSlice> highlights;

  /// Truncates with an ellipsis, for search snippets.
  final int? maxLines;

  /// Key of the inner text widget, for tests asserting style and direction.
  static const textKey = ValueKey('quran-text');

  @override
  Widget build(BuildContext context) {
    final colors = context.quranColors;
    final style = QuranTypography.style(
      family: QuranTypography.familyOf(context),
      fontSize: fontSize,
      color: colors.quranText,
    );
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
        if (ayahNumber case final number?)
          TextSpan(
            // A no-break space keeps the ornament on the verse's last line.
            text: '\u{00A0}${endOfAyahMarker(number)}',
            style: TextStyle(
              color: colors.ornament,
              fontFamily: QuranTypography.ornamentFamily,
            ),
          ),
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Localizations.override(
        context: context,
        locale: QuranTypography.locale,
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
