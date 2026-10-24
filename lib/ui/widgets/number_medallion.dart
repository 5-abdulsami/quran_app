import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'mihrab_mark.dart';

/// A number framed by the app's mihrab arch, with a faint inner line as in
/// the double-ruled frames of printed mushafs.
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
        painter: _ArchPainter(color),
        child: Align(
          // Optically centred in the arch's body, below the pointed crown.
          alignment: const Alignment(0, 0.3),
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: size * (number > 99 ? 0.26 : 0.31),
            ),
            textScaler: TextScaler.noScaling,
          ),
        ),
      ),
    );
  }
}

class _ArchPainter extends CustomPainter {
  _ArchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final outer = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: s * 0.72,
      height: s * 0.94,
    );
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas
      ..drawPath(
        mihrabArch(outer),
        Paint()..color = color.withValues(alpha: 0.08),
      )
      ..drawPath(mihrabArch(outer), stroke)
      ..drawPath(
        mihrabArch(outer.deflate(s * 0.07)),
        stroke
          ..strokeWidth = 0.6
          ..color = color.withValues(alpha: 0.6),
      );
  }

  @override
  bool shouldRepaint(_ArchPainter oldDelegate) => oldDelegate.color != color;
}
