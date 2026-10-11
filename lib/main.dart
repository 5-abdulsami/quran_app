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

/// Adds the bundled font's OFL licence to Flutter's licence page.
void registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString(
      'assets/fonts/OFL-amiri-quran.txt',
    );
    yield LicenseEntryWithLineBreaks(const ['Amiri Quran (font)'], text);
  });
}
