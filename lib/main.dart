import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/bootstrap/app_bootstrap.dart';
import 'ui/theme/quran_typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerLicenses();
  await _initBackgroundAudio();

  final prefs = await SharedPreferences.getInstance();
  runApp(AppBootstrap(prefs: prefs));
}

/// Lets recitation keep playing in the background, with media controls in
/// the notification and on the lock screen.
Future<void> _initBackgroundAudio() async {
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.samionyx.quran_app.recitation',
      androidNotificationChannelName: 'Recitation',
      androidNotificationIcon: 'drawable/ic_stat_recitation',
      androidNotificationOngoing: true,
    );
  } on Object catch (error, stack) {
    // Platforms without the plugin still run; only background audio is lost.
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack, library: 'audio'),
    );
  }
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
