import 'package:flutter/material.dart';

// Phase 1 placeholder; implemented in a later phase.
class JuzReaderScreen extends StatelessWidget {
  const JuzReaderScreen({required this.juz, this.initialVerseKey, super.key});

  final int juz;
  final String? initialVerseKey;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('$juz')),
    body: const SizedBox.shrink(),
  );
}
