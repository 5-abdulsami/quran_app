import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerLicenses();

  final prefs = await SharedPreferences.getInstance();
  runApp(AppBootstrap(prefs: prefs));
}

/// Adds the bundled fonts' OFL licences to Flutter's licence page.
void registerLicenses() {
  const fonts = {
    'Scheherazade New (font)': 'assets/fonts/OFL-scheherazade-new.txt',
    'Amiri Quran (font)': 'assets/fonts/OFL-amiri-quran.txt',
  };
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: name, value: asset) in fonts.entries) {
      yield LicenseEntryWithLineBreaks([
        name,
      ], await rootBundle.loadString(asset));
    }
  });
}
