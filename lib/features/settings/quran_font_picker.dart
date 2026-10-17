import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran/bismillah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/theme/quran_typography.dart';
import '../../ui/widgets/quran_text.dart';
import 'settings_controller.dart';

/// Lets the reader pick a Quran font by seeing it: every font previews the
/// basmalah in its own face.
Future<void> showQuranFontPicker(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (context, scrollController) =>
            _QuranFontList(scrollController: scrollController),
      ),
    );

class _QuranFontList extends ConsumerWidget {
  const _QuranFontList({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selected = ref.watch(
      settingsControllerProvider.select((s) => s.quranFont),
    );

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Text(l10n.quranFont, style: theme.textTheme.titleLarge),
        ),
        for (final spec in QuranFonts.all)
          _FontOption(
            spec: spec,
            selected: spec.font == selected,
            onTap: () {
              ref
                  .read(settingsControllerProvider.notifier)
                  .setQuranFont(spec.font);
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }
}

class _FontOption extends StatelessWidget {
  const _FontOption({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final QuranFontSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        spec.label,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle, color: scheme.primary),
                  ],
                ),
                // The preview is drawn in this option's own font.
                QuranFontScope(
                  font: spec,
                  child: QuranText(basmalah, fontSize: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
