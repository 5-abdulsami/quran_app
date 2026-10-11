// Port of the attribution logic in
// islamic-platform/src/modules/ingestion/adapters/alquran-cloud.ts and the
// `creditLine` helper in islamic-platform/src/app/quran/[surah]/[ayah]/page.tsx.
//
// Licence position, from https://alquran.cloud/terms-and-conditions (as
// recorded by the web app's adapter):
//   - free reproduction, embedding, storage and display for non-commercial use;
//   - commercial use permitted with respectful acknowledgement of the source;
//   - Arabic text curation is credited to Tanzil.net and Quran Academy;
//   - translations must credit the translator by name;
//   - text must keep its diacritics and Uthmani orthography and must not be
//     commingled with non-Quranic material in a way that could be mistaken for
//     the Quran itself;
//   - callers are asked to cache aggressively rather than re-request.

/// The reference Arabic text edition. Uthmani orthography, Tanzil-curated.
const String arabicEdition = 'quran-uthmani';

/// Base URL of the AlQuran.cloud API. No credentials required.
const String alQuranCloudApiBase = 'https://api.alquran.cloud/v1';

/// Required credit for the Arabic text. (`ATTRIBUTION_ARABIC` in the original.)
const String attributionArabic =
    'Quranic text via AlQuran.cloud. Text curation: Tanzil.net and Quran '
    'Academy. Uthmani orthography preserved.';

/// Required credit for a translation edition.
///
/// AlQuran.cloud often reports the same string as both the English name and
/// the edition name, and the reader already sees "Translated by X" near this
/// line. Repeating it reads like a bug, so the duplicate is collapsed.
String attributionForTranslation({
  required String name,
  required String englishName,
}) {
  final translator = name.trim();
  final title = englishName.trim();
  final credit = translator.isNotEmpty && translator != title
      ? '$title, translated by $translator'
      : title;
  return '$credit. Supplied by AlQuran.cloud.';
}

/// Builds the one-line credit under a translation.
///
/// Attribution text is contractually required, so it is never dropped or
/// reworded. The translator credit in front of it is ours, and is omitted when
/// it would only repeat what the attribution says.
String creditLine({
  required String? translatorName,
  required String sourceName,
  required String? attribution,
  required String Function(String name) translatedBy,
}) {
  final name = translatorName ?? sourceName;
  final credit = translatorName != null
      ? translatedBy(translatorName)
      : sourceName;

  if (attribution == null) return credit;
  if (name.isNotEmpty &&
      attribution.toLowerCase().contains(name.toLowerCase())) {
    return attribution;
  }
  return '$credit · $attribution';
}
