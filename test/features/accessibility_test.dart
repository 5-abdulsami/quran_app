import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

/// Every main screen meets Flutter's accessibility guidelines: 48 dp touch
/// targets, labelled tap targets, and WCAG AA text contrast, in light and dark.
void main() {
  const screens = [
    '/',
    '/surahs',
    '/juz',
    '/search',
    '/bookmarks',
    '/surah/2',
    '/juz/30',
    '/settings',
    '/about',
  ];

  for (final theme in ['light', 'dark', 'sepia']) {
    for (final location in screens) {
      testWidgets('$location ($theme) meets accessibility guidelines', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final app = await TestApp.pump(
          tester,
          location: location,
          prefs: {'settings.theme': theme},
        );
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await app.dispose(tester);
        semantics.dispose();
      });
    }
  }

  testWidgets('large text (200%) lays out without overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final location in ['/', '/surahs', '/juz', '/surah/1', '/settings']) {
      final app = await TestApp.pump(tester, location: location);
      // A RenderFlex overflow would have been reported as an exception.
      expect(tester.takeException(), isNull, reason: location);
      await app.dispose(tester);
    }
  });
}
