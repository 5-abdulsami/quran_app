import 'package:flutter/material.dart';

import '../../core/quran/bismillah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/quran_text.dart';

/// The standalone basmalah shown under a surah header.
///
/// Rendered only where `Surah.rendersHeaderBismillah` is true (never for
/// al-Fatihah, whose basmalah is ayah 1, nor for at-Tawbah, which has none).
/// The text is the code-point constant from core/quran/bismillah.dart.
class BismillahHeader extends StatelessWidget {
  const BismillahHeader({required this.fontSize, super.key});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.quranColors;
    return Semantics(
      label: AppLocalizations.of(context).basmalahSemantics,
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: colors.ornament.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colors.sourceBackground,
            border: Border.all(color: colors.ornament.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(11),
          ),
          child: QuranText(
            basmalah,
            fontSize: fontSize,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
