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
  // Independent, so started together: the first frame waits for the slower,
  // not for both in turn.
  final (_, prefs) = await (
    _initBackgroundAudio(),
    SharedPreferences.getInstance(),
  ).wait;
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

/// Adds the bundled fonts' licences to Flutter's licence page.
void registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (label, asset) in [
      for (final font in QuranFonts.all) (font.label, font.licenceAsset),
      ...supportFontLicences,
    ]) {
      yield LicenseEntryWithLineBreaks([
        '$label (font)',
      ], await rootBundle.loadString(asset));
    }
  });
}
