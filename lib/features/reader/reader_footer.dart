import 'package:flutter/material.dart';

/// Previous / next navigation at the end of a reader (surah or juz).
class ReaderFooter extends StatelessWidget {
  const ReaderFooter({
    this.previousLabel,
    this.onPrevious,
    this.nextLabel,
    this.onNext,
    this.attribution,
    super.key,
  });

  final String? previousLabel;
  final VoidCallback? onPrevious;
  final String? nextLabel;
  final VoidCallback? onNext;

  /// Licence-required credits for the translations on screen.
  final List<String>? attribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in attribution ?? const <String>[])
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (onPrevious != null && previousLabel != null)
                Flexible(
                  child: OutlinedButton.icon(
                    onPressed: onPrevious,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(
                      previousLabel!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              const Spacer(),
              if (onNext != null && nextLabel != null)
                Flexible(
                  child: FilledButton.tonalIcon(
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward),
                    iconAlignment: IconAlignment.end,
                    label: Text(nextLabel!, overflow: TextOverflow.ellipsis),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
