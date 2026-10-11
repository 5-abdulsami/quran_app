import 'package:flutter/material.dart';

// Phase 1 placeholder; implemented in a later phase.
class AyahDetailScreen extends StatelessWidget {
  const AyahDetailScreen({required this.surah, required this.ayah, super.key});

  final int surah;
  final int ayah;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('$surah:$ayah')),
    body: const SizedBox.shrink(),
  );
}
