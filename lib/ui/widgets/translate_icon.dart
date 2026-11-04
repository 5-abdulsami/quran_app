import 'package:flutter/material.dart';

/// The translation icon: an Urdu "ع" with a Latin "A", laid out like Material's
/// translate icon (whose 文 glyph is Chinese). Sized and coloured by the
/// surrounding [IconTheme], like an [Icon].
class TranslateIcon extends StatelessWidget {
  const TranslateIcon({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = theme.size ?? 24;
    final color = this.color ?? theme.color;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Fixed placement (not mirrored), like the Material icon.
          Positioned(
            left: -size * 0.02,
            top: -size * 0.24,
            child: Text(
              'ع',
              textDirection: TextDirection.rtl,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: size * 0.78,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: color,
              ),
            ),
          ),
          Positioned(
            right: size * 0.02,
            bottom: 0,
            child: Text(
              'A',
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: size * 0.6,
                fontWeight: FontWeight.w700,
                height: 1,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
