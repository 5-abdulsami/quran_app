import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

// Phase 1 placeholder; implemented in a later phase.
class SurahIndexScreen extends StatelessWidget {
  const SurahIndexScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).surahs)),
    body: const SizedBox.shrink(),
  );
}
