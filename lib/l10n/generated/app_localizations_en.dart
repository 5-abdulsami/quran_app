// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IslamIndex Quran';

  @override
  String get navHome => 'Home';

  @override
  String get navSurahs => 'Surahs';

  @override
  String get navJuz => 'Juz';

  @override
  String get navSearch => 'Search';

  @override
  String get navBookmarks => 'Bookmarks';

  @override
  String get navSaved => 'Saved';

  @override
  String get settings => 'Settings';

  @override
  String get search => 'Search';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get share => 'Share';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get seeAll => 'See all';

  @override
  String get loading => 'Loading…';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get reset => 'Reset';

  @override
  String get tryAgain => 'Try again';

  @override
  String get goHome => 'Go to the homepage';

  @override
  String get notFound => 'We could not find that page.';

  @override
  String get genericError => 'Something went wrong.';

  @override
  String get quranTitle => 'The Quran';

  @override
  String get surah => 'Surah';

  @override
  String get surahs => 'Surahs';

  @override
  String get juz => 'Juz';

  @override
  String get page => 'Page';

  @override
  String get hizb => 'Hizb';

  @override
  String get ruku => 'Ruku';

  @override
  String get manzil => 'Manzil';

  @override
  String get verse => 'Verse';

  @override
  String get ayah => 'Ayah';

  @override
  String get translation => 'Translation';

  @override
  String get translations => 'Translations';

  @override
  String get makkah => 'Revealed in Makkah';

  @override
  String get madinah => 'Revealed in Madinah';

  @override
  String get makki => 'Makki';

  @override
  String get madani => 'Madani';

  @override
  String versesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses',
      one: '1 verse',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Search the Quran…';

  @override
  String get noTranslationSelected => 'No translation selected';

  @override
  String get selectTranslation => 'Choose a translation';

  @override
  String get showArabic => 'Show Arabic';

  @override
  String get showTranslation => 'Show translation';

  @override
  String get arabicOnly => 'Arabic only';

  @override
  String get fontSizeArabic => 'Arabic text size';

  @override
  String get fontSizeTranslation => 'Translation text size';

  @override
  String get preview => 'Preview';

  @override
  String get copyVerse => 'Copy verse';

  @override
  String get bookmarkVerse => 'Bookmark this verse';

  @override
  String get sajdahRecommended => 'Recommended prostration';

  @override
  String get sajdahObligatory => 'Obligatory prostration';

  @override
  String translatedBy(String name) {
    return 'Translated by $name';
  }

  @override
  String juzNumber(int number) {
    return 'Juz $number';
  }

  @override
  String hizbNumber(int number) {
    return 'Hizb $number';
  }

  @override
  String pageNumber(int number) {
    return 'Page $number';
  }

  @override
  String continuingSurah(String name, int ayah) {
    return 'Continuing Surah $name from ayah $ayah';
  }

  @override
  String verseSemantics(String surah, int ayah) {
    return 'Surah $surah, verse $ayah';
  }

  @override
  String surahSemantics(int number, String name) {
    return 'Surah $number, $name';
  }

  @override
  String get basmalahSemantics => 'Bismillah';

  @override
  String get continueReading => 'Continue reading';

  @override
  String get continueReadingEmpty =>
      'Start reading and your place will be kept here.';

  @override
  String get goToVerse => 'Go to verse';

  @override
  String get goToVerseHint => 'e.g. 2:255, Yaseen, juz 30';

  @override
  String get goToAyah => 'Go to ayah';

  @override
  String ayahNumberRange(int max) {
    return 'Ayah number (1–$max)';
  }

  @override
  String get invalidReference => 'That reference does not exist in the Quran.';

  @override
  String get quickAccess => 'Quick access';

  @override
  String get ayatAlKursi => 'Ayat al-Kursi';

  @override
  String get sort => 'Sort';

  @override
  String get recentBookmarks => 'Recent bookmarks';

  @override
  String get readBySurah => 'Read by surah';

  @override
  String get readByJuz => 'Read by juz';

  @override
  String get previousJuz => 'Previous juz';

  @override
  String get nextJuz => 'Next juz';

  @override
  String get previousSurah => 'Previous surah';

  @override
  String get nextSurah => 'Next surah';

  @override
  String progressRead(int percent) {
    return '$percent% read';
  }

  @override
  String get filterSurahs => 'Filter by number or name';

  @override
  String get filterAll => 'All';

  @override
  String get copyArabic => 'Copy Arabic';

  @override
  String get copyTranslation => 'Copy translation';

  @override
  String get copyBoth => 'Copy Arabic and translation';

  @override
  String get copyWithBasmalah => 'Copy with basmalah';

  @override
  String get copyVerseKey => 'Copy verse key';

  @override
  String get openDetail => 'Open verse details';

  @override
  String get readInContext => 'Read in context';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get bookmarkAdded => 'Bookmark saved';

  @override
  String get bookmarkRemoved => 'Bookmark removed';

  @override
  String get verseActions => 'Verse actions';

  @override
  String get searchTry => 'Try';

  @override
  String get goTo => 'Go to';

  @override
  String get versesSection => 'Verses';

  @override
  String noResults(String query) {
    return 'No verses matched “$query”.';
  }

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses',
      one: '1 verse',
    );
    return '$_temp0';
  }

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get clear => 'Clear';

  @override
  String get scopeArabic => 'Arabic';

  @override
  String get scopeTranslation => 'Translation';

  @override
  String get scopeBoth => 'Both';

  @override
  String get anySurah => 'Any surah';

  @override
  String get anyJuz => 'Any juz';

  @override
  String get loadMore => 'Load more';

  @override
  String get bookmarksEmpty =>
      'No bookmarks yet. Long-press a verse to bookmark it.';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortMushaf => 'Mushaf order';

  @override
  String get addNote => 'Add note';

  @override
  String get editNote => 'Edit note';

  @override
  String get note => 'Note';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get language => 'Language';

  @override
  String get reading => 'Reading';

  @override
  String get keepScreenAwake => 'Keep screen awake while reading';

  @override
  String get showMarkers => 'Show juz, hizb and page markers';

  @override
  String get manageTranslations => 'Choose and order translations';

  @override
  String get yourData => 'Your data';

  @override
  String get resetProgress => 'Reset reading progress';

  @override
  String get resetProgressConfirm =>
      'This clears every saved reading position. Bookmarks are kept.';

  @override
  String get progressReset => 'Reading progress cleared';

  @override
  String get exportBookmarks => 'Export bookmarks';

  @override
  String get importBookmarks => 'Import bookmarks';

  @override
  String importedBookmarks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count bookmarks',
      one: 'Imported 1 bookmark',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'That file is not a valid bookmarks export.';

  @override
  String get installed => 'Installed';

  @override
  String get availableToDownload => 'Available to download';

  @override
  String get bundled => 'Bundled';

  @override
  String get download => 'Download';

  @override
  String get downloading => 'Downloading…';

  @override
  String get downloadFailed =>
      'Download failed. Check your connection and try again.';

  @override
  String get loadEditionsFailed =>
      'Could not load the list of translations. Check your connection.';

  @override
  String get translationOrderHint =>
      'Checked translations are shown in the reader, in this order. Drag to reorder.';

  @override
  String get atLeastOneTranslation =>
      'Keep at least one translation selected, or use Arabic only mode.';

  @override
  String get aboutSources => 'About & Sources';

  @override
  String get arabicText => 'Arabic text';

  @override
  String get font => 'Font';

  @override
  String get fontCredit =>
      'Quran fonts: Scheherazade New, Lateef and Harmattan by SIL Global; Amiri and Amiri Quran by The Amiri Project Authors; Noto Naskh Arabic and Noto Sans Arabic by The Noto Project Authors. All under the SIL Open Font License 1.1.';

  @override
  String get quranFont => 'Quran font';

  @override
  String get viewLicences => 'View licences';

  @override
  String get appVersion => 'App version';

  @override
  String get dataVersion => 'Data version';

  @override
  String get aboutBody =>
      'The Quranic text is shown exactly as supplied by its source, in Uthmani orthography, and is never edited by this app. Translations are the work of the translators named below.';

  @override
  String get preparingQuran => 'Preparing the Quran for offline reading…';

  @override
  String get dbErrorTitle => 'The Quran database could not be opened';

  @override
  String get dbErrorBody =>
      'Your bookmarks are stored separately and are safe. Try again, or restore the Quran database from the app package.';

  @override
  String get restoreDatabase => 'Restore the Quran database';
}
