// Renders the app icon and splash artwork to assets/icon/.
//
// Usage (from quran_app/):
//   flutter test tool/icon/generate_icon_test.dart --update-goldens
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// The mark itself is StarMarkPainter (lib/ui/widgets/star_mark.dart), the
// same drawing the loading screen animates.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/ui/widgets/star_mark.dart';

const _green = StarMarkPainter.brandGreen;
const _gold = StarMarkPainter.brandGold;

Future<void> _render(
  WidgetTester tester,
  String file,
  StarMarkPainter painter, {
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
  testWidgets(
    'app icon',
    (tester) => _render(
      tester,
      'icon.png',
      const StarMarkPainter(
        starColor: _gold,
        innerColor: _green,
        scale: 0.62,
        background: _green,
      ),
    ),
  );

  // Adaptive-icon foreground: the star inside Android's safe zone.
  testWidgets(
    'adaptive foreground',
    (tester) => _render(
      tester,
      'icon_foreground.png',
      const StarMarkPainter(starColor: _gold, innerColor: _green, scale: 0.42),
    ),
  );

  // Splash logo, also used for Android 12's splash icon.
  testWidgets(
    'splash logo',
    (tester) => _render(
      tester,
      'splash.png',
      const StarMarkPainter(starColor: _gold, innerColor: _green, scale: 0.5),
    ),
  );
}
