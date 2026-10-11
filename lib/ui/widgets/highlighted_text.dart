import 'package:flutter/material.dart';

import '../../core/text/highlight.dart';
import '../theme/app_theme.dart';

/// Plain (non-Quranic) text, e.g. a translation, with search matches marked.
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.text, {
    required this.highlights,
    this.style,
    this.maxLines,
    this.textDirection,
    this.locale,
    super.key,
  });

  final String text;
  final List<TextSlice> highlights;
  final TextStyle? style;
  final int? maxLines;
  final TextDirection? textDirection;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final highlight = context.quranColors.highlight;
    return Text.rich(
      TextSpan(
        children: [
          for (final (segment, highlighted) in splitHighlights(
            text,
            highlights,
          ))
            TextSpan(
              text: segment,
              style: highlighted
                  ? TextStyle(
                      backgroundColor: highlight,
                      fontWeight: FontWeight.w600,
                    )
                  : null,
            ),
        ],
      ),
      style: style,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textDirection: textDirection,
      locale: locale,
    );
  }
}
