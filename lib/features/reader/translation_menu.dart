import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/translation_edition.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../ui/language_names.dart';
import '../settings/settings_controller.dart';

/// The readers' translation picker: "Arabic only", or any combination of the
/// installed translations (English, Urdu and any downloaded ones).
class TranslationMenuButton extends ConsumerWidget {
  const TranslationMenuButton({super.key});

  /// Menu value for "Arabic only" (edition ids never take this form).
  static const _arabicOnly = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final editions =
        ref.watch(editionsProvider).value ?? const <TranslationEdition>[];
    final shown = settings.visibleTranslationIds;

    return PopupMenuButton<String>(
      tooltip: l10n.selectTranslation,
      icon: Icon(
        Icons.translate,
        color: shown.isEmpty ? null : Theme.of(context).colorScheme.primary,
      ),
      onSelected: (id) => _select(ref, id),
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: _arabicOnly,
          checked: shown.isEmpty,
          child: Text(l10n.arabicOnly),
        ),
        const PopupMenuDivider(),
        for (final edition in editions)
          CheckedPopupMenuItem(
            value: edition.id,
            checked: shown.contains(edition.id),
            child: _EditionLabel(edition),
          ),
      ],
    );
  }

  /// Toggles one translation; choosing "Arabic only", or unticking the last
  /// translation, hides translations altogether.
  Future<void> _select(WidgetRef ref, String id) async {
    final controller = ref.read(settingsControllerProvider.notifier);
    final settings = ref.read(settingsControllerProvider);
    final ids = settings.translationIds;

    if (id == _arabicOnly) {
      await controller.setShowTranslation(show: false);
      return;
    }
    if (!settings.showTranslation) {
      // Coming back from Arabic only: show exactly what was picked.
      await controller.setTranslationIds([id]);
      await controller.setShowTranslation(show: true);
      return;
    }
    if (!ids.contains(id)) {
      await controller.setTranslationIds([...ids, id]);
    } else if (ids.length == 1) {
      await controller.setShowTranslation(show: false);
    } else {
      await controller.setTranslationIds(ids.where((e) => e != id).toList());
    }
  }
}

class _EditionLabel extends StatelessWidget {
  const _EditionLabel(this.edition);

  final TranslationEdition edition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageEndonym(edition.language)),
        Text(
          edition.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
