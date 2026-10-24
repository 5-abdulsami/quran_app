import 'package:flutter/widgets.dart';

/// A pointed mihrab arch filling [box]: straight sides up to the springing
/// line, then two gently curved sides meeting at a point, closed by a sill.
///
/// The one shape behind the app's mark and every [NumberMedallion], so the
/// icon, the loading screen and the surah and juz lists read as one family.
Path mihrabArch(Rect box, {double spring = 0.44}) {
  final Rect(:left, :top, :right, :bottom, :width) = box;
  final cx = box.center.dx;
  final springY = top + box.height * spring;
  final rise = springY - top;
  return Path()
    ..moveTo(left, bottom)
    ..lineTo(left, springY)
    ..cubicTo(
      left,
      springY - rise * 0.58,
      cx - width * 0.14,
      top + rise * 0.22,
      cx,
      top,
    )
    ..cubicTo(
      cx + width * 0.14,
      top + rise * 0.22,
      right,
      springY - rise * 0.58,
      right,
      springY,
    )
    ..lineTo(right, bottom)
    ..close();
}

/// The app's mark: an open mushaf resting inside a mihrab arch.
///
/// Geometric, with no imagery of living beings. The same painter draws the
/// launcher icon (tool/icon/generate_icon_test.dart) and the loading screen.
class MihrabMarkPainter extends CustomPainter {
  const MihrabMarkPainter({
    required this.color,
    this.scale = 1,
    this.background,
  });

  /// The arch and the book.
  final Color color;

  /// Size of the mark relative to the canvas.
  final double scale;

  /// Fills the whole canvas first when set (the opaque app icon).
  final Color? background;

  static const brandGreen = Color(0xFF1F6650);
  static const brandGold = Color(0xFFD9B76A);

  @override
  void paint(Canvas canvas, Size size) {
    if (background case final color?) {
      canvas.drawRect(Offset.zero & size, Paint()..color = color);
    }
    final m = size.shortestSide * scale;
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    // The arch, as a band whose stroke stays inside the mark's bounds.
    final band = m * 0.07;
    final arch = Rect.fromCenter(
      center: center,
      width: m * 0.66,
      height: m * 0.94,
    ).deflate(band / 2);
    canvas.drawPath(
      mihrabArch(arch),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = band
        ..strokeJoin = StrokeJoin.miter
        ..strokeMiterLimit = 8,
    );

    // The open book: two pages rising from a shared spine above the sill.
    final bookWidth = arch.width * 0.74;
    final bookHeight = m * 0.21;
    final spineX = center.dx;
    final spineY = arch.bottom - band / 2 - m * 0.075;
    final gap = m * 0.014;
    for (final side in const [-1.0, 1.0]) {
      final inner = spineX + side * gap;
      final outer = spineX + side * bookWidth / 2;
      final mid = spineX + side * bookWidth / 4;
      canvas.drawPath(
        Path()
          ..moveTo(inner, spineY)
          ..quadraticBezierTo(
            mid,
            spineY + bookHeight * 0.06,
            outer,
            spineY - bookHeight * 0.22,
          )
          ..lineTo(outer, spineY - bookHeight)
          ..quadraticBezierTo(
            mid,
            spineY - bookHeight * 1.12,
            inner,
            spineY - bookHeight * 0.82,
          )
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MihrabMarkPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.scale != scale ||
      oldDelegate.background != background;
}
