import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/l10n/generated/app_localizations.dart';
import 'package:quran_app/ui/widgets/app_loader.dart';

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

double _opacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(
      find.descendant(
        of: find.byType(AppLoader),
        matching: find.byType(AnimatedOpacity),
      ),
    )
    .opacity;

OrbitArcPainter _painter(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(
              find.descendant(
                of: find.byType(AppLoader),
                matching: find.byType(CustomPaint),
              ),
            )
            .painter!
        as OrbitArcPainter;

void main() {
  testWidgets('a quick load never flashes the loader', (tester) async {
    await tester.pumpWidget(_host(const AppLoader()));
    expect(_opacity(tester), 0);

    // Still hidden just before the delay...
    await tester.pump(const Duration(milliseconds: 200));
    expect(_opacity(tester), 0);

    // ...and fades in after it.
    await tester.pump(const Duration(milliseconds: 100));
    expect(_opacity(tester), 1);

    // Disposed early: no timer is left behind.
    await tester.pumpWidget(_host(const SizedBox()));
  });

  testWidgets('the indeterminate arc turns and breathes', (tester) async {
    await tester.pumpWidget(_host(const AppLoader.small()));
    final first = _painter(tester);
    await tester.pump(const Duration(milliseconds: 350));
    final later = _painter(tester);
    expect(later.angle, isNot(first.angle));
    expect(later.sweep, isNot(first.sweep));
    expect(later.fadingTail, isTrue);
    await tester.pumpWidget(_host(const SizedBox()));
  });

  testWidgets('reduce motion holds the arc still', (tester) async {
    await tester.pumpWidget(_host(const AppLoader.small(), reduceMotion: true));
    final first = _painter(tester).angle;
    await tester.pump(const Duration(milliseconds: 500));
    expect(_painter(tester).angle, first);
  });

  testWidgets('progress is shown at once and eases between values', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const AppLoader.small(value: 0.2)));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
    expect(_painter(tester).sweep, closeTo(0.2 * 2 * 3.14159, 0.01));

    await tester.pumpWidget(_host(const AppLoader.small(value: 0.8)));
    await tester.pump(const Duration(milliseconds: 100));
    final midway = _painter(tester).sweep;
    expect(midway, greaterThan(0.2 * 2 * 3.14159));
    expect(midway, lessThan(0.8 * 2 * 3.14159));
    await tester.pumpAndSettle();
    expect(_painter(tester).sweep, closeTo(0.8 * 2 * 3.14159, 0.01));
  });

  testWidgets('announces itself to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const AppLoader.small(value: 0.5)));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Loading…'), findsOneWidget);
    handle.dispose();
  });
}
