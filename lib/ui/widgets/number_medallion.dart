import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A number inside an eight-pointed star: two overlapping squares, the
/// geometric motif used to mark divisions in printed mushafs.
class NumberMedallion extends StatelessWidget {
  const NumberMedallion(this.number, {this.size = 40, super.key});

  final int number;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = context.quranColors.ornament;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StarPainter(color),
        child: Center(
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: size * (number > 99 ? 0.28 : 0.32),
            ),
            textScaler: TextScaler.noScaling,
          ),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = size.center(Offset.zero);
    final side = size.shortestSide * 0.68;
    final square = Rect.fromCenter(center: center, width: side, height: side);

    canvas
      ..drawRect(square, paint)
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(math.pi / 4)
      ..translate(-center.dx, -center.dy)
      ..drawRect(square, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => oldDelegate.color != color;
}
