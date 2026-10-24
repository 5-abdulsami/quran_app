import 'package:meta/meta.dart';

/// What the player recites for each verse.
enum RecitationMode {
  /// The Arabic recitation only.
  arabic,

  /// The Urdu translation only.
  urdu,

  /// Each verse in Arabic, then its Urdu translation.
  arabicThenUrdu;

  bool get includesArabic => this != urdu;
  bool get includesUrdu => this != arabic;
}

/// A recitation on EveryAyah.com: one MP3 per verse, named SSSAAA.mp3 under
/// [folder]. Verse files never include the basmalah; it is 001001.mp3.
@immutable
class Reciter {
  const Reciter({
    required this.id,
    required this.name,
    required this.folder,
    required this.language,
  });

  /// Stable id, stored in settings and used as the download folder name.
  final String id;

  /// Display name (a proper name, not localized).
  final String name;

  /// Path under https://everyayah.com/data/.
  final String folder;

  /// 'ar' for a recitation, 'ur' for an Urdu translation.
  final String language;
}

/// The recitations the app offers. Each was checked to have every verse.
abstract final class Reciters {
  static const arabic = [
    Reciter(
      id: 'alafasy',
      name: 'Mishary Rashid Alafasy',
      folder: 'Alafasy_128kbps',
      language: 'ar',
    ),
    Reciter(
      id: 'husary',
      name: 'Mahmoud Khalil Al-Husary',
      folder: 'Husary_128kbps',
      language: 'ar',
    ),
    Reciter(
      id: 'minshawi',
      name: 'Mohamed Siddiq Al-Minshawi',
      folder: 'Minshawy_Murattal_128kbps',
      language: 'ar',
    ),
    Reciter(
      id: 'abdulbasit',
      name: 'Abdul Basit Abdul Samad',
      folder: 'Abdul_Basit_Murattal_192kbps',
      language: 'ar',
    ),
    Reciter(
      id: 'sudais',
      name: 'Abdur-Rahman As-Sudais',
      folder: 'Abdurrahmaan_As-Sudais_192kbps',
      language: 'ar',
    ),
    Reciter(
      id: 'shuraim',
      name: 'Saud Ash-Shuraim',
      folder: 'Saood_ash-Shuraym_128kbps',
      language: 'ar',
    ),
    Reciter(
      id: 'muaiqly',
      name: 'Maher Al-Muaiqly',
      folder: 'MaherAlMuaiqly128kbps',
      language: 'ar',
    ),
  ];

  static const urdu = [
    Reciter(
      id: 'ur.shamshad',
      name: 'Shamshad Ali Khan',
      folder: 'translations/urdu_shamshad_ali_khan_46kbps',
      language: 'ur',
    ),
  ];

  static const defaultArabicId = 'alafasy';
  static const defaultUrduId = 'ur.shamshad';

  /// The Arabic reciter with [id], or the default for an unknown id.
  static Reciter arabicById(String id) =>
      arabic.firstWhere((r) => r.id == id, orElse: () => arabic.first);

  /// The Urdu reciter with [id], or the default for an unknown id.
  static Reciter urduById(String id) =>
      urdu.firstWhere((r) => r.id == id, orElse: () => urdu.first);
}
