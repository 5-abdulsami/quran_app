import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// The app's one loading indicator: the launch screen's orbiting arc, in the
/// theme's accent colour, so every wait looks like part of the same app.
///
/// - Indeterminate (no [value]): a comet-tailed arc circles a faint ring,
///   its length gently breathing. It fades in only after [delay], so loads
///   that finish quickly never flash a spinner.
/// - Determinate ([value] 0–1, e.g. a download): a rounded arc that eases
///   to each new value instead of jumping. Shown at once.
/// - With "reduce motion" on, the arc holds still.
class AppLoader extends StatefulWidget {
  const AppLoader({
    this.value,
    this.size = 32,
    this.delay = const Duration(milliseconds: 250),
    this.color,
    super.key,
  });

  /// Compact, for a list row or an icon button. Shown at once: the wait was
  /// started by a tap, so feedback should be immediate.
  const AppLoader.small({this.value, this.color, super.key})
    : size = 22,
      delay = Duration.zero;

  /// Progress 0–1, or null while the total is unknown.
  final double? value;
  final double size;
  final Duration delay;

  /// Defaults to the theme's primary colour.
  final Color? color;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late bool _visible = widget.delay == Duration.zero || widget.value != null;
  Timer? _reveal;

  @override
  void initState() {
    super.initState();
    if (!_visible) {
      _reveal = Timer(widget.delay, () => setState(() => _visible = true));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSpin();
  }

  @override
  void didUpdateWidget(AppLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSpin();
  }

  /// Spins only while indeterminate and motion is allowed.
  void _syncSpin() {
    final still =
        widget.value != null || MediaQuery.disableAnimationsOf(context);
    if (still) {
      _spin.stop();
    } else if (!_spin.isAnimating) {
      _spin.repeat();
    }
  }

  @override
  void dispose() {
    _reveal?.cancel();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final stroke = (widget.size / 11).clamp(2.0, 3.5);
    final value = widget.value;
    final label = AppLocalizations.of(context).loading;

    final Widget arc = value == null
        ? AnimatedBuilder(
            animation: _spin,
            builder: (context, _) {
              final t = _spin.value;
              return CustomPaint(
                painter: OrbitArcPainter(
                  color: color,
                  angle: t * 2 * math.pi - math.pi / 2,
                  // Breathes between a third and a half of the ring.
                  sweep: math.pi * (0.85 + 0.25 * math.sin(t * 2 * math.pi)),
                  strokeWidth: stroke,
                  fadingTail: true,
                ),
              );
            },
          )
        : TweenAnimationBuilder<double>(
            tween: Tween(end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) => CustomPaint(
              painter: OrbitArcPainter(
                color: color,
                angle: -math.pi / 2,
                sweep: 2 * math.pi * progress,
                strokeWidth: stroke,
              ),
            ),
          );

    return Semantics(
      label: label,
      value: value == null ? null : '${(value * 100).round()}%',
      child: RepaintBoundary(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox.square(dimension: widget.size, child: arc),
        ),
      ),
    );
  }
}

/// An arc travelling around a faint ring. Shared by [AppLoader] and the
/// launch screen, so both draw the same shape.
class OrbitArcPainter extends CustomPainter {
  const OrbitArcPainter({
    required this.color,
    required this.angle,
    required this.sweep,
    required this.strokeWidth,
    this.fadingTail = false,
    this.trackWidth,
    this.trackOpacity = 0.16,
  });

  final Color color;

  /// Where the arc starts, in radians (0 is three o'clock).
  final double angle;
  final double sweep;
  final double strokeWidth;

  /// Fades the arc towards its start, like a comet's tail.
  final bool fadingTail;

  /// The ring's stroke; defaults to half the arc's.
  final double? trackWidth;
  final double trackOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final radius = rect.shortestSide / 2;
    canvas.drawCircle(
      rect.center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackWidth ?? strokeWidth / 2
        ..color = color.withValues(alpha: trackOpacity),
    );
    if (sweep <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    if (fadingTail) {
      paint.shader = SweepGradient(
        endAngle: sweep,
        colors: [color.withValues(alpha: 0), color],
        transform: GradientRotation(angle),
      ).createShader(rect);
    } else {
      paint.color = color;
    }
    canvas.drawArc(rect, angle, sweep, false, paint);
  }

  @override
  bool shouldRepaint(OrbitArcPainter oldDelegate) =>
      oldDelegate.angle != angle ||
      oldDelegate.sweep != sweep ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
