// Structural facts the downloaded data is validated against.

/// The first ayah of each juz, 1 → 30. The data's own `juz` field must agree.
const List<String> expectedJuzStarts = [
  '1:1', '2:142', '2:253', '3:93', '4:24', '4:148', '5:82', '6:111', //
  '7:88', '8:41', '9:93', '11:6', '12:53', '15:1', '17:1', '18:75', '21:1',
  '23:1', '25:21', '27:56', '29:46', '33:31', '36:28', '39:32', '41:47',
  '46:1', '51:31', '58:1', '67:1', '78:1',
];

/// Traditional juz names, 1 → 30: (Arabic, transliteration).
///
/// Labels only, taken from the traditional naming; boundaries always come from
/// the data.
const List<(String, String)> juzNames = [
  ('الم', 'Alif Lam Mim'),
  ('سيقول', 'Sayaqul'),
  ('تلك الرسل', 'Tilka r-Rusul'),
  ('لن تنالوا', 'Lan Tanalu'),
  ('والمحصنات', 'Wal-Muhsanat'),
  ('لا يحب الله', 'La Yuhibbullah'),
  ('وإذا سمعوا', "Wa Idha Sami'u"),
  ('ولو أننا', 'Wa Law Annana'),
  ('قال الملأ', "Qala l-Mala'"),
  ('واعلموا', "Wa'lamu"),
  ('يعتذرون', "Ya'tadhirun"),
  ('وما من دابة', 'Wa Ma Min Dabbah'),
  ('وما أبرئ', "Wa Ma Ubarri'u"),
  ('ربما', 'Rubama'),
  ('سبحان الذي', 'Subhana lladhi'),
  ('قال ألم', 'Qala Alam'),
  ('اقترب', 'Iqtaraba'),
  ('قد أفلح', 'Qad Aflaha'),
  ('وقال الذين', 'Wa Qala lladhina'),
  ('أمن خلق', 'Amman Khalaqa'),
  ('اتل ما أوحي', 'Utlu Ma Uhiya'),
  ('ومن يقنت', 'Wa Man Yaqnut'),
  ('وما لي', 'Wa Mali'),
  ('فمن أظلم', 'Fa Man Azlam'),
  ('إليه يرد', 'Ilayhi Yuraddu'),
  ('حم', 'Ha Mim'),
  ('قال فما خطبكم', 'Qala Fama Khatbukum'),
  ('قد سمع الله', "Qad Sami' Allah"),
  ('تبارك الذي', 'Tabaraka lladhi'),
  ('عم', "'Amma"),
];

/// Mushaf pages in the source's page numbering.
const int expectedPageCount = 604;
