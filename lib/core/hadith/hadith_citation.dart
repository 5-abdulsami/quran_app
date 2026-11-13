// Text placed in the share sheet for a hadith.
//
// Like a verse, a shared hadith ALWAYS carries its reference and a link to its
// source, so whoever receives it can check the wording, the chain and the
// grading for themselves. A translation from another publisher is credited by
// name, as its terms require.

/// Joins the parts with blank lines and ends with the citation and link:
/// "…\n\n…\n\nSahih al-Bukhari 1 · https://sunnah.com/bukhari:1".
///
/// [translationSource] is added as "(HadeethEnc.com)" after the citation
/// when it is not the site the link already names.
String hadithPayload({
  required String translation,
  required String citation,
  required Uri source,
  String? arabic,
  String? translationSource,
}) {
  final credit = translationSource == null || translationSource == source.host
      ? ''
      : ' ($translationSource)';
  return [?arabic, translation, '$citation$credit · $source'].join('\n\n');
}
