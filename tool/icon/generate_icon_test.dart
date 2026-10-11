// Renders the app icon and splash artwork to assets/icon/.
//
// Usage (from quran_app/):
//   flutter test tool/icon/generate_icon_test.dart --update-goldens
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// The mark is an eight-pointed star (two overlapping squares, the rub el hizb
// motif that marks divisions in printed mushafs): geometric, with no imagery
// of living beings, in the app's deep green and a muted gold.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _green = Color(0xFF1F6650);
const _gold = Color(0xFFD9B76A);

class _StarMark extends CustomPainter {
  const _StarMark({required this.scale, this.background});

  /// Size of the star relative to the canvas.
  final double scale;
  final Color? background;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    if (background case final color?) {
      canvas.drawRect(Offset.zero & size, Paint()..color = color);
    }
    final side = size.shortestSide * scale / math.sqrt2;
    final square = Rect.fromCenter(center: center, width: side, height: side);
    final gold = Paint()..color = _gold;

    // Two overlapping squares, the second turned 45°.
    canvas.drawRect(square, gold);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(math.pi / 4)
      ..translate(-center.dx, -center.dy)
      ..drawRect(square, gold)
      ..restore();

    // An inner disc and ring give the star depth at small sizes.
    canvas
      ..drawCircle(center, side * 0.36, Paint()..color = _green)
      ..drawCircle(
        center,
        side * 0.24,
        Paint()
          ..color = _gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = side * 0.05,
      );
  }

  @override
  bool shouldRepaint(_StarMark oldDelegate) => false;
}

Future<void> _render(
  WidgetTester tester,
  String file,
  _StarMark painter, {
  double size = 1024,
}) async {
  tester.view
    ..physicalSize = Size(size, size)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(painter: painter),
        ),
      ),
    ),
  );
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('../../assets/icon/$file'),
  );
}

void main() {
  testWidgets('app icon', (tester) => _render(
    tester,
    'icon.png',
    const _StarMark(scale: 0.62, background: _green),
  ));

  // Adaptive-icon foreground: the star inside Android's safe zone.
  testWidgets('adaptive foreground', (tester) => _render(
    tester,
    'icon_foreground.png',
    const _StarMark(scale: 0.42),
  ));

  // Splash logo, also used for Android 12's splash icon.
  testWidgets('splash logo', (tester) => _render(
    tester,
    'splash.png',
    const _StarMark(scale: 0.5),
  ));
}
