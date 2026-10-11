import '../domain/models/ayah.dart';
import '../domain/models/surah.dart';
import '../l10n/generated/app_localizations.dart';

/// Localised labels for domain values, shared by every screen.
extension DomainLabels on AppLocalizations {
  /// "Revealed in Makkah" / "Revealed in Madinah" (the web's wording).
  String revelation(RevelationPlace place) =>
      place == RevelationPlace.makkah ? makkah : madinah;

  /// "Makki" / "Madani", for compact chips.
  String revelationShort(RevelationPlace place) =>
      place == RevelationPlace.makkah ? makki : madani;

  /// "Recommended prostration" / "Obligatory prostration".
  String sajdah(SajdahType type) =>
      type == SajdahType.obligatory ? sajdahObligatory : sajdahRecommended;
}
