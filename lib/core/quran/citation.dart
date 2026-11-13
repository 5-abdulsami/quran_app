// Text placed on the clipboard or in the share sheet for a verse.
//
// As in islamic-platform/src/ui/verse-actions.tsx, the payload ALWAYS includes
// the reference. Someone pasting a verse into a family group chat should be
// pasting something the next person can verify — a bare quote with no
// reference is how misattribution starts.

import 'references.dart';

/// Joins the chosen parts with blank lines and ends with the citation,
/// e.g. "…\n\n…\n\nQur'an 2:255 (Surah Al-Baqara)".
String versePayload({
  required int surah,
  required int ayah,
  required String surahName,
  String? arabic,
  List<String> translations = const [],
}) => passagePayload(
  surah: surah,
  fromAyah: ayah,
  toAyah: ayah,
  surahName: surahName,
  arabic: arabic,
  translations: translations,
);

/// [versePayload] for consecutive verses, ending with e.g.
/// "Qur'an 94:5–6 (Surah Ash-Sharh)".
String passagePayload({
  required int surah,
  required int fromAyah,
  required int toAyah,
  required String surahName,
  String? arabic,
  List<String> translations = const [],
}) => [
  ?arabic,
  ...translations,
  formatQuranPassageCitation(surah, fromAyah, toAyah, surahName),
].join('\n\n');
