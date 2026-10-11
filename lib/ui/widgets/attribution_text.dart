import 'package:flutter/material.dart';

/// A licence-required credit line.
///
/// Credits are English sentences that may embed an Arabic-script name
/// ("Fateh Muhammad Jalandhry, translated by جالندہری. …"). Laid out with a
/// right-to-left base direction — under an Urdu translation or in the Urdu
/// and Arabic UIs — the bidi algorithm reorders the sentence and garbles it,
/// so credits are always left-to-right.
class AttributionText extends StatelessWidget {
  const AttributionText(this.text, {this.selectable = false, super.key});

  final String text;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: double.infinity,
        child: selectable
            ? SelectableText(text, style: style)
            : Text(text, style: style),
      ),
    );
  }
}
