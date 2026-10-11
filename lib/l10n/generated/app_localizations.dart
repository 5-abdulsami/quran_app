import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'IslamIndex Quran'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSurahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get navSurahs;

  /// No description provided for @navJuz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get navJuz;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get navBookmarks;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to the homepage'**
  String get goHome;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'We could not find that page.'**
  String get notFound;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get genericError;

  /// No description provided for @quranTitle.
  ///
  /// In en, this message translates to:
  /// **'The Quran'**
  String get quranTitle;

  /// No description provided for @surah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surah;

  /// No description provided for @surahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahs;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @hizb.
  ///
  /// In en, this message translates to:
  /// **'Hizb'**
  String get hizb;

  /// No description provided for @ruku.
  ///
  /// In en, this message translates to:
  /// **'Ruku'**
  String get ruku;

  /// No description provided for @manzil.
  ///
  /// In en, this message translates to:
  /// **'Manzil'**
  String get manzil;

  /// No description provided for @verse.
  ///
  /// In en, this message translates to:
  /// **'Verse'**
  String get verse;

  /// No description provided for @ayah.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get ayah;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @translations.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translations;

  /// No description provided for @makkah.
  ///
  /// In en, this message translates to:
  /// **'Revealed in Makkah'**
  String get makkah;

  /// No description provided for @madinah.
  ///
  /// In en, this message translates to:
  /// **'Revealed in Madinah'**
  String get madinah;

  /// No description provided for @makki.
  ///
  /// In en, this message translates to:
  /// **'Makki'**
  String get makki;

  /// No description provided for @madani.
  ///
  /// In en, this message translates to:
  /// **'Madani'**
  String get madani;

  /// No description provided for @versesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 verse} other{{count} verses}}'**
  String versesCount(int count);

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search the Quran…'**
  String get searchPlaceholder;

  /// No description provided for @noTranslationSelected.
  ///
  /// In en, this message translates to:
  /// **'No translation selected'**
  String get noTranslationSelected;

  /// No description provided for @selectTranslation.
  ///
  /// In en, this message translates to:
  /// **'Choose a translation'**
  String get selectTranslation;

  /// No description provided for @showArabic.
  ///
  /// In en, this message translates to:
  /// **'Show Arabic'**
  String get showArabic;

  /// No description provided for @showTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show translation'**
  String get showTranslation;

  /// No description provided for @arabicOnly.
  ///
  /// In en, this message translates to:
  /// **'Arabic only'**
  String get arabicOnly;

  /// No description provided for @fontSizeArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic text size'**
  String get fontSizeArabic;

  /// No description provided for @fontSizeTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation text size'**
  String get fontSizeTranslation;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @copyVerse.
  ///
  /// In en, this message translates to:
  /// **'Copy verse'**
  String get copyVerse;

  /// No description provided for @bookmarkVerse.
  ///
  /// In en, this message translates to:
  /// **'Bookmark this verse'**
  String get bookmarkVerse;

  /// No description provided for @sajdahRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended prostration'**
  String get sajdahRecommended;

  /// No description provided for @sajdahObligatory.
  ///
  /// In en, this message translates to:
  /// **'Obligatory prostration'**
  String get sajdahObligatory;

  /// No description provided for @translatedBy.
  ///
  /// In en, this message translates to:
  /// **'Translated by {name}'**
  String translatedBy(String name);

  /// No description provided for @juzNumber.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String juzNumber(int number);

  /// No description provided for @hizbNumber.
  ///
  /// In en, this message translates to:
  /// **'Hizb {number}'**
  String hizbNumber(int number);

  /// No description provided for @pageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String pageNumber(int number);

  /// No description provided for @continuingSurah.
  ///
  /// In en, this message translates to:
  /// **'Continuing Surah {name} from ayah {ayah}'**
  String continuingSurah(String name, int ayah);

  /// No description provided for @verseSemantics.
  ///
  /// In en, this message translates to:
  /// **'Surah {surah}, verse {ayah}'**
  String verseSemantics(String surah, int ayah);

  /// No description provided for @surahSemantics.
  ///
  /// In en, this message translates to:
  /// **'Surah {number}, {name}'**
  String surahSemantics(int number, String name);

  /// No description provided for @basmalahSemantics.
  ///
  /// In en, this message translates to:
  /// **'Bismillah'**
  String get basmalahSemantics;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continueReading;

  /// No description provided for @continueReadingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start reading and your place will be kept here.'**
  String get continueReadingEmpty;

  /// No description provided for @goToVerse.
  ///
  /// In en, this message translates to:
  /// **'Go to verse'**
  String get goToVerse;

  /// No description provided for @goToVerseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2:255, Yaseen, juz 30'**
  String get goToVerseHint;

  /// No description provided for @goToAyah.
  ///
  /// In en, this message translates to:
  /// **'Go to ayah'**
  String get goToAyah;

  /// No description provided for @ayahNumberRange.
  ///
  /// In en, this message translates to:
  /// **'Ayah number (1–{max})'**
  String ayahNumberRange(int max);

  /// No description provided for @invalidReference.
  ///
  /// In en, this message translates to:
  /// **'That reference does not exist in the Quran.'**
  String get invalidReference;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get quickAccess;

  /// No description provided for @ayatAlKursi.
  ///
  /// In en, this message translates to:
  /// **'Ayat al-Kursi'**
  String get ayatAlKursi;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @recentBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Recent bookmarks'**
  String get recentBookmarks;

  /// No description provided for @readBySurah.
  ///
  /// In en, this message translates to:
  /// **'Read by surah'**
  String get readBySurah;

  /// No description provided for @readByJuz.
  ///
  /// In en, this message translates to:
  /// **'Read by juz'**
  String get readByJuz;

  /// No description provided for @previousJuz.
  ///
  /// In en, this message translates to:
  /// **'Previous juz'**
  String get previousJuz;

  /// No description provided for @nextJuz.
  ///
  /// In en, this message translates to:
  /// **'Next juz'**
  String get nextJuz;

  /// No description provided for @previousSurah.
  ///
  /// In en, this message translates to:
  /// **'Previous surah'**
  String get previousSurah;

  /// No description provided for @nextSurah.
  ///
  /// In en, this message translates to:
  /// **'Next surah'**
  String get nextSurah;

  /// No description provided for @progressRead.
  ///
  /// In en, this message translates to:
  /// **'{percent}% read'**
  String progressRead(int percent);

  /// No description provided for @filterSurahs.
  ///
  /// In en, this message translates to:
  /// **'Filter by number or name'**
  String get filterSurahs;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @copyArabic.
  ///
  /// In en, this message translates to:
  /// **'Copy Arabic'**
  String get copyArabic;

  /// No description provided for @copyTranslation.
  ///
  /// In en, this message translates to:
  /// **'Copy translation'**
  String get copyTranslation;

  /// No description provided for @copyBoth.
  ///
  /// In en, this message translates to:
  /// **'Copy Arabic and translation'**
  String get copyBoth;

  /// No description provided for @copyWithBasmalah.
  ///
  /// In en, this message translates to:
  /// **'Copy with basmalah'**
  String get copyWithBasmalah;

  /// No description provided for @copyVerseKey.
  ///
  /// In en, this message translates to:
  /// **'Copy verse key'**
  String get copyVerseKey;

  /// No description provided for @openDetail.
  ///
  /// In en, this message translates to:
  /// **'Open verse details'**
  String get openDetail;

  /// No description provided for @readInContext.
  ///
  /// In en, this message translates to:
  /// **'Read in context'**
  String get readInContext;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @bookmarkAdded.
  ///
  /// In en, this message translates to:
  /// **'Bookmark saved'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark removed'**
  String get bookmarkRemoved;

  /// No description provided for @verseActions.
  ///
  /// In en, this message translates to:
  /// **'Verse actions'**
  String get verseActions;

  /// No description provided for @searchTry.
  ///
  /// In en, this message translates to:
  /// **'Try'**
  String get searchTry;

  /// No description provided for @goTo.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get goTo;

  /// No description provided for @versesSection.
  ///
  /// In en, this message translates to:
  /// **'Verses'**
  String get versesSection;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No verses matched “{query}”.'**
  String noResults(String query);

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 verse} other{{count} verses}}'**
  String resultsCount(int count);

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @scopeArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get scopeArabic;

  /// No description provided for @scopeTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get scopeTranslation;

  /// No description provided for @scopeBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get scopeBoth;

  /// No description provided for @anySurah.
  ///
  /// In en, this message translates to:
  /// **'Any surah'**
  String get anySurah;

  /// No description provided for @anyJuz.
  ///
  /// In en, this message translates to:
  /// **'Any juz'**
  String get anyJuz;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @bookmarksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Long-press a verse to bookmark it.'**
  String get bookmarksEmpty;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewest;

  /// No description provided for @sortMushaf.
  ///
  /// In en, this message translates to:
  /// **'Mushaf order'**
  String get sortMushaf;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match system'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get themeSepia;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @keepScreenAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep screen awake while reading'**
  String get keepScreenAwake;

  /// No description provided for @showMarkers.
  ///
  /// In en, this message translates to:
  /// **'Show juz, hizb and page markers'**
  String get showMarkers;

  /// No description provided for @manageTranslations.
  ///
  /// In en, this message translates to:
  /// **'Choose and order translations'**
  String get manageTranslations;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get yourData;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset reading progress'**
  String get resetProgress;

  /// No description provided for @resetProgressConfirm.
  ///
  /// In en, this message translates to:
  /// **'This clears every saved reading position. Bookmarks are kept.'**
  String get resetProgressConfirm;

  /// No description provided for @progressReset.
  ///
  /// In en, this message translates to:
  /// **'Reading progress cleared'**
  String get progressReset;

  /// No description provided for @exportBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Export bookmarks'**
  String get exportBookmarks;

  /// No description provided for @importBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Import bookmarks'**
  String get importBookmarks;

  /// No description provided for @importedBookmarks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 bookmark} other{Imported {count} bookmarks}}'**
  String importedBookmarks(int count);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'That file is not a valid bookmarks export.'**
  String get importFailed;

  /// No description provided for @installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installed;

  /// No description provided for @availableToDownload.
  ///
  /// In en, this message translates to:
  /// **'Available to download'**
  String get availableToDownload;

  /// No description provided for @bundled.
  ///
  /// In en, this message translates to:
  /// **'Bundled'**
  String get bundled;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get downloading;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection and try again.'**
  String get downloadFailed;

  /// No description provided for @loadEditionsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the list of translations. Check your connection.'**
  String get loadEditionsFailed;

  /// No description provided for @translationOrderHint.
  ///
  /// In en, this message translates to:
  /// **'Checked translations are shown in the reader, in this order. Drag to reorder.'**
  String get translationOrderHint;

  /// No description provided for @atLeastOneTranslation.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one translation selected, or use Arabic only mode.'**
  String get atLeastOneTranslation;

  /// No description provided for @aboutSources.
  ///
  /// In en, this message translates to:
  /// **'About & Sources'**
  String get aboutSources;

  /// No description provided for @arabicText.
  ///
  /// In en, this message translates to:
  /// **'Arabic text'**
  String get arabicText;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @fontCredit.
  ///
  /// In en, this message translates to:
  /// **'Amiri Quran by The Amiri Project Authors, licensed under the SIL Open Font License 1.1.'**
  String get fontCredit;

  /// No description provided for @viewLicences.
  ///
  /// In en, this message translates to:
  /// **'View licences'**
  String get viewLicences;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @dataVersion.
  ///
  /// In en, this message translates to:
  /// **'Data version'**
  String get dataVersion;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'The Quranic text is shown exactly as supplied by its source, in Uthmani orthography, and is never edited by this app. Translations are the work of the translators named below.'**
  String get aboutBody;

  /// No description provided for @preparingQuran.
  ///
  /// In en, this message translates to:
  /// **'Preparing the Quran for offline reading…'**
  String get preparingQuran;

  /// No description provided for @dbErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'The Quran database could not be opened'**
  String get dbErrorTitle;

  /// No description provided for @dbErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Your bookmarks are stored separately and are safe. Try again, or restore the Quran database from the app package.'**
  String get dbErrorBody;

  /// No description provided for @restoreDatabase.
  ///
  /// In en, this message translates to:
  /// **'Restore the Quran database'**
  String get restoreDatabase;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
