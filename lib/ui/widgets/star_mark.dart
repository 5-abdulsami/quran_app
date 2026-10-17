import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The app's mark: an eight-pointed star (two overlapping squares, the rub el
/// hizb motif that marks divisions in printed mushafs) with an inner ring.
///
/// Geometric, with no imagery of living beings. The same painter draws the
/// launcher icon (tool/icon/generate_icon_test.dart) and the loading screen.
class StarMarkPainter extends CustomPainter {
  const StarMarkPainter({
    required this.starColor,
    required this.innerColor,
    this.scale = 1,
    this.background,
  });

  /// The star and ring.
  final Color starColor;

  /// The disc inside the star (normally the background colour).
  final Color innerColor;

  /// Size of the star relative to the canvas.
  final double scale;

  /// Fills the whole canvas first when set (the opaque app icon).
  final Color? background;

  static const brandGreen = Color(0xFF1F6650);
  static const brandGold = Color(0xFFD9B76A);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    if (background case final color?) {
      canvas.drawRect(Offset.zero & size, Paint()..color = color);
    }
    final side = size.shortestSide * scale / math.sqrt2;
    final square = Rect.fromCenter(center: center, width: side, height: side);
    final star = Paint()
      ..color = starColor
      ..isAntiAlias = true;

    // Two overlapping squares, the second turned 45°.
    canvas.drawRect(square, star);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(math.pi / 4)
      ..translate(-center.dx, -center.dy)
      ..drawRect(square, star)
      ..restore();

    // An inner disc and ring give the star depth at small sizes.
    canvas
      ..drawCircle(center, side * 0.36, Paint()..color = innerColor)
      ..drawCircle(
        center,
        side * 0.24,
        Paint()
          ..color = starColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = side * 0.05,
      );
  }

  @override
  bool shouldRepaint(StarMarkPainter oldDelegate) =>
      oldDelegate.starColor != starColor ||
      oldDelegate.innerColor != innerColor ||
      oldDelegate.scale != scale ||
      oldDelegate.background != background;
}
