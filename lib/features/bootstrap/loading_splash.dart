import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../ui/widgets/mihrab_mark.dart';

/// The in-app loading screen.
///
/// It continues the native launch screen (same background, same gold mark) so
/// start-up reads as one motion: the mark breathes inside a slowly orbiting
/// arc while the app name rises in. The "preparing" line appears only when
/// loading is genuinely slow (the first launch, while the Quran is installed).
/// With "reduce motion" on, everything is still.
class LoadingSplash extends StatefulWidget {
  const LoadingSplash({super.key});

  /// Background shared with the native splash (flutter_native_splash.yaml).
  static const lightBackground = MihrabMarkPainter.brandGreen;
  static const darkBackground = Color(0xFF151412);

  @override
  State<LoadingSplash> createState() => _LoadingSplashState();
}

class _LoadingSplashState extends State<LoadingSplash>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  late final Timer _slowTimer;
  bool _slow = false;

  static const _cream = Color(0xFFF6EFDD);

  @override
  void initState() {
    super.initState();
    _slowTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the system's "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _slowTimer.cancel();
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark
        ? LoadingSplash.darkBackground
        : LoadingSplash.lightBackground;
    final rise = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
    );

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 168,
              child: AnimatedBuilder(
                animation: _loop,
                builder: (context, _) {
                  final phase = _loop.value * 2 * math.pi;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size.square(168),
                        painter: _OrbitPainter(angle: phase),
                      ),
                      Transform.scale(
                        // A slow breath: 1.0 → 1.04 → 1.0.
                        scale: 1 + 0.02 * (1 - math.cos(phase)),
                        child: const CustomPaint(
                          size: Size.square(120),
                          painter: MihrabMarkPainter(
                            color: MihrabMarkPainter.brandGold,
                            scale: 0.8,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: rise,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(rise),
                child: Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _cream,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedOpacity(
              opacity: _slow ? 0.8 : 0,
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.preparingQuran,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: _cream),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A thin gold arc circling the mark, fading towards its tail.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.angle});

  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(6);
    const sweep = math.pi * 0.6;

    // The faint full ring the arc travels along.
    canvas.drawCircle(
      rect.center,
      arcRect.width / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = MihrabMarkPainter.brandGold.withValues(alpha: 0.18),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: sweep,
        colors: [
          MihrabMarkPainter.brandGold.withValues(alpha: 0),
          MihrabMarkPainter.brandGold,
        ],
        transform: GradientRotation(angle),
      ).createShader(arcRect);
    canvas.drawArc(arcRect, angle, sweep, false, paint);
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) => oldDelegate.angle != angle;
}
