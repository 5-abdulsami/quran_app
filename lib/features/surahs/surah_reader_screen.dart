import 'package:flutter/material.dart';


// Phase 1 placeholder; implemented in a later phase.
class SurahReaderScreen extends StatelessWidget {
  const SurahReaderScreen({required this.surah, this.initialAyah, super.key});

  final int surah;
  final int? initialAyah;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('$surah')),
    body: const SizedBox.shrink(),
  );
}
