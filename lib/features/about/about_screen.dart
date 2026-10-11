import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

// Phase 1 placeholder; implemented in a later phase.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).aboutSources)),
    body: const SizedBox.shrink(),
  );
}
