import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

// Phase 1 placeholder; implemented in a later phase.
class SearchScreen extends StatelessWidget {
  const SearchScreen({required this.initialQuery, super.key});

  final String initialQuery;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).search)),
    body: const SizedBox.shrink(),
  );
}
