import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/quran/bismillah.dart';
import '../../domain/models/app_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/keyboard.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/quran_text.dart';
import '../settings/settings_controller.dart';

/// Asks for an ayah number in 1..[max]; null when cancelled.
Future<int?> showGoToAyahDialog(BuildContext context, {required int max}) =>
    showDialog<int>(
      context: context,
      builder: (_) => _GoToAyahDialog(max: max),
    );

class _GoToAyahDialog extends StatefulWidget {
  const _GoToAyahDialog({required this.max});
  final int max;

  @override
  State<_GoToAyahDialog> createState() => _GoToAyahDialogState();
}

class _GoToAyahDialogState extends State<_GoToAyahDialog> {
  final _controller = TextEditingController();
  int? get _value {
    final value = int.tryParse(_controller.text);
    return value != null && value >= 1 && value <= widget.max ? value : null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_value case final value?) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.goToAyah),
      content: TextField(
        onTapOutside: dismissKeyboard,
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: l10n.ayahNumberRange(widget.max),
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _value == null ? null : _submit,
          child: Text(l10n.goTo),
        ),
      ],
    );
  }
}

/// Arabic and translation size sliders with a live preview.
Future<void> showTextSizeSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextSizeControls(),
        ),
      ),
    );

/// Shared by the reader's sheet and the Settings screen.
class TextSizeControls extends ConsumerWidget {
  const TextSizeControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.preview, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        // The preview sits in its own framed area, clear of the sliders.
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: context.quranColors.sourceBackground,
            border: Border.all(color: context.quranColors.sourceBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuranText(
                basmalah,
                fontSize: settings.arabicFontSize,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.fontSizeTranslation,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: settings.translationFontSize,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SizeSlider(
          label: l10n.fontSizeArabic,
          value: settings.arabicFontSize,
          min: AppSettings.minArabicFontSize,
          max: AppSettings.maxArabicFontSize,
          onChanged: controller.setArabicFontSize,
        ),
        _SizeSlider(
          label: l10n.fontSizeTranslation,
          value: settings.translationFontSize,
          min: AppSettings.minTranslationFontSize,
          max: AppSettings.maxTranslationFontSize,
          onChanged: controller.setTranslationFontSize,
        ),
      ],
    );
  }
}

class _SizeSlider extends StatelessWidget {
  const _SizeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label · ${value.round()}'),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: (max - min).round(),
        label: '${value.round()}',
        semanticFormatterCallback: (v) => '$label ${v.round()}',
        onChanged: onChanged,
      ),
    ],
  );
}

/// Keeps the screen on while a reader is open, when the setting asks for it.
mixin KeepAwakeWhileReading<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  @override
  void initState() {
    super.initState();
    if (ref.read(settingsControllerProvider).keepScreenAwake) {
      WakelockPlus.enable().ignore();
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable().ignore();
    super.dispose();
  }
}
