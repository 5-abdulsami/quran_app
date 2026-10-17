import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/bootstrap/app_bootstrap.dart';
import 'ui/theme/quran_typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerLicenses();

  final prefs = await SharedPreferences.getInstance();
  runApp(AppBootstrap(prefs: prefs));
}

/// Adds the bundled fonts' OFL licences to Flutter's licence page.
void registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final font in QuranFonts.all) {
      yield LicenseEntryWithLineBreaks([
        '${font.label} (font)',
      ], await rootBundle.loadString(font.licenceAsset));
    }
  });
}
