import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/daily/daily_content.dart';
import '../../domain/models/app_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/l10n_labels.dart';
import '../settings/settings_controller.dart';
import 'daily_providers.dart';

/// The Settings rows for the home screen's Ayah / Hadith of the Day.
class DailyCardSettings extends ConsumerWidget {
  const DailyCardSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final enabled = settings.showDailyCard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.wb_twilight_outlined),
          title: Text(l10n.dailyCardShow),
          subtitle: Text(l10n.dailyContentHint),
          value: enabled,
          onChanged: (show) => controller.setShowDailyCard(show: show),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: SegmentedButton<DailyContentMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: DailyContentMode.both,
                label: Text(l10n.dailyContentBoth),
              ),
              ButtonSegment(
                value: DailyContentMode.ayahOnly,
                label: Text(l10n.ayah),
              ),
              ButtonSegment(
                value: DailyContentMode.hadithOnly,
                label: Text(l10n.hadith),
              ),
            ],
            selected: {settings.dailyContentMode},
            onSelectionChanged: enabled
                ? (s) => controller.setDailyContentMode(s.single)
                : null,
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.format_quote_outlined),
          title: Text(l10n.hadithArabicSetting),
          value: settings.showHadithArabic,
          onChanged: enabled && settings.dailyContentMode.includesHadith
              ? (show) => controller.setShowHadithArabic(show: show)
              : null,
        ),
        const _HijriAdjustmentTile(),
      ],
    );
  }
}

/// Moves the Hijri date a day or two to match the local moon sighting,
/// previewing the resulting date.
class _HijriAdjustmentTile extends ConsumerWidget {
  const _HijriAdjustmentTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final adjustment = ref.watch(
      settingsControllerProvider.select((s) => s.hijriAdjustment),
    );
    final hijri = ref.watch(dailyDateProvider.select((d) => d.hijri));
    final controller = ref.read(settingsControllerProvider.notifier);
    const max = AppSettings.maxHijriAdjustment;
    final value = switch (adjustment) {
      0 => l10n.hijriAdjustmentNone,
      > 0 => '+$adjustment',
      _ => '−${-adjustment}',
    };

    return ListTile(
      leading: const Icon(Icons.nightlight_outlined),
      title: Text(l10n.hijriAdjustment),
      subtitle: Text('${l10n.hijri(hijri)}\n${l10n.hijriAdjustmentHint}'),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.decrease,
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: adjustment > -max
                ? () => controller.setHijriAdjustment(adjustment - 1)
                : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 24),
            child: Text(
              adjustment == 0 ? '0' : value,
              key: const ValueKey('hijri-adjustment-value'),
              textAlign: TextAlign.center,
              semanticsLabel: value,
            ),
          ),
          IconButton(
            tooltip: l10n.increase,
            icon: const Icon(Icons.add_circle_outline),
            onPressed: adjustment < max
                ? () => controller.setHijriAdjustment(adjustment + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
