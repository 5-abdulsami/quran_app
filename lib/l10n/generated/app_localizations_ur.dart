// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'اسلام انڈیکس قرآن';

  @override
  String get navHome => 'صفحۂ اول';

  @override
  String get navSurahs => 'سورتیں';

  @override
  String get navJuz => 'پارے';

  @override
  String get navSearch => 'تلاش';

  @override
  String get navBookmarks => 'محفوظ شدہ';

  @override
  String get navSaved => 'محفوظ';

  @override
  String get settings => 'ترتیبات';

  @override
  String get search => 'تلاش';

  @override
  String get cancel => 'منسوخ';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get close => 'بند کریں';

  @override
  String get copy => 'نقل کریں';

  @override
  String get copied => 'نقل ہو گیا';

  @override
  String get share => 'شیئر کریں';

  @override
  String get back => 'واپس';

  @override
  String get next => 'اگلا';

  @override
  String get previous => 'پچھلا';

  @override
  String get seeAll => 'سب دیکھیں';

  @override
  String get loading => 'لوڈ ہو رہا ہے…';

  @override
  String get delete => 'حذف کریں';

  @override
  String get undo => 'واپس لیں';

  @override
  String get reset => 'ری سیٹ';

  @override
  String get tryAgain => 'دوبارہ کوشش کریں';

  @override
  String get goHome => 'صفحۂ اول پر جائیں';

  @override
  String get notFound => 'یہ صفحہ نہیں مل سکا۔';

  @override
  String get genericError => 'کچھ خرابی ہو گئی۔';

  @override
  String get quranTitle => 'قرآن مجید';

  @override
  String get surah => 'سورت';

  @override
  String get surahs => 'سورتیں';

  @override
  String get juz => 'پارہ';

  @override
  String get page => 'صفحہ';

  @override
  String get hizb => 'حزب';

  @override
  String get ruku => 'رکوع';

  @override
  String get manzil => 'منزل';

  @override
  String get verse => 'آیت';

  @override
  String get ayah => 'آیت';

  @override
  String get translation => 'ترجمہ';

  @override
  String get translations => 'تراجم';

  @override
  String get makkah => 'مکی';

  @override
  String get madinah => 'مدنی';

  @override
  String get makki => 'مکی';

  @override
  String get madani => 'مدنی';

  @override
  String versesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آیات',
      one: '1 آیت',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'قرآن میں تلاش کریں…';

  @override
  String get noTranslationSelected => 'کوئی ترجمہ منتخب نہیں';

  @override
  String get selectTranslation => 'ترجمہ منتخب کریں';

  @override
  String get showArabic => 'عربی دکھائیں';

  @override
  String get showTranslation => 'ترجمہ دکھائیں';

  @override
  String get arabicOnly => 'صرف عربی';

  @override
  String get fontSizeArabic => 'عربی متن کا سائز';

  @override
  String get fontSizeTranslation => 'ترجمے کا سائز';

  @override
  String get preview => 'نمونہ';

  @override
  String get copyVerse => 'آیت نقل کریں';

  @override
  String get bookmarkVerse => 'یہ آیت محفوظ کریں';

  @override
  String get sajdahRecommended => 'مستحب سجدہ';

  @override
  String get sajdahObligatory => 'واجب سجدہ';

  @override
  String translatedBy(String name) {
    return 'ترجمہ: $name';
  }

  @override
  String juzNumber(int number) {
    return 'پارہ $number';
  }

  @override
  String hizbNumber(int number) {
    return 'حزب $number';
  }

  @override
  String pageNumber(int number) {
    return 'صفحہ $number';
  }

  @override
  String continuingSurah(String name, int ayah) {
    return 'سورۂ $name کا تسلسل، آیت $ayah سے';
  }

  @override
  String verseSemantics(String surah, int ayah) {
    return 'سورۂ $surah، آیت $ayah';
  }

  @override
  String surahSemantics(int number, String name) {
    return 'سورت $number، $name';
  }

  @override
  String get basmalahSemantics => 'بسم اللہ';

  @override
  String get continueReading => 'پڑھنا جاری رکھیں';

  @override
  String get continueReadingEmpty =>
      'پڑھنا شروع کریں، آپ کا مقام یہاں محفوظ رہے گا۔';

  @override
  String get goToVerse => 'آیت پر جائیں';

  @override
  String get goToVerseHint => 'مثلاً 2:255، یٰسین، پارہ 30';

  @override
  String get goToAyah => 'آیت پر جائیں';

  @override
  String ayahNumberRange(int max) {
    return 'آیت نمبر (1–$max)';
  }

  @override
  String get invalidReference => 'یہ حوالہ قرآن میں موجود نہیں۔';

  @override
  String get quickAccess => 'فوری رسائی';

  @override
  String get ayatAlKursi => 'آیت الکرسی';

  @override
  String get sort => 'ترتیب';

  @override
  String get recentBookmarks => 'حالیہ محفوظ شدہ';

  @override
  String get readBySurah => 'سورت کے مطابق پڑھیں';

  @override
  String get readByJuz => 'پارے کے مطابق پڑھیں';

  @override
  String get previousJuz => 'پچھلا پارہ';

  @override
  String get nextJuz => 'اگلا پارہ';

  @override
  String get previousSurah => 'پچھلی سورت';

  @override
  String get nextSurah => 'اگلی سورت';

  @override
  String progressRead(int percent) {
    return '$percent% پڑھا گیا';
  }

  @override
  String get filterSurahs => 'نمبر یا نام سے تلاش کریں';

  @override
  String get filterAll => 'تمام';

  @override
  String get copyArabic => 'عربی نقل کریں';

  @override
  String get copyTranslation => 'ترجمہ نقل کریں';

  @override
  String get copyBoth => 'عربی اور ترجمہ نقل کریں';

  @override
  String get copyWithBasmalah => 'بسم اللہ کے ساتھ نقل کریں';

  @override
  String get copyVerseKey => 'آیت کا حوالہ نقل کریں';

  @override
  String get openDetail => 'آیت کی تفصیل';

  @override
  String get readInContext => 'سیاق میں پڑھیں';

  @override
  String get removeBookmark => 'محفوظ شدہ سے ہٹائیں';

  @override
  String get bookmarkAdded => 'آیت محفوظ ہو گئی';

  @override
  String get bookmarkRemoved => 'محفوظ شدہ سے ہٹا دی گئی';

  @override
  String get verseActions => 'آیت کے اختیارات';

  @override
  String get searchTry => 'آزمائیں';

  @override
  String get goTo => 'جائیں';

  @override
  String get versesSection => 'آیات';

  @override
  String noResults(String query) {
    return '“$query” سے کوئی آیت نہیں ملی۔';
  }

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آیات',
      one: '1 آیت',
    );
    return '$_temp0';
  }

  @override
  String get recentSearches => 'حالیہ تلاشیں';

  @override
  String get clear => 'صاف کریں';

  @override
  String get scopeArabic => 'عربی';

  @override
  String get scopeTranslation => 'ترجمہ';

  @override
  String get scopeBoth => 'دونوں';

  @override
  String get anySurah => 'کوئی بھی سورت';

  @override
  String get anyJuz => 'کوئی بھی پارہ';

  @override
  String get loadMore => 'مزید دکھائیں';

  @override
  String get bookmarksEmpty =>
      'ابھی کوئی آیت محفوظ نہیں۔ کسی آیت کو دیر تک دبا کر محفوظ کریں۔';

  @override
  String get sortNewest => 'تازہ ترین پہلے';

  @override
  String get sortMushaf => 'مصحف کی ترتیب';

  @override
  String get addNote => 'نوٹ شامل کریں';

  @override
  String get editNote => 'نوٹ میں ترمیم';

  @override
  String get note => 'نوٹ';

  @override
  String get appearance => 'ظاہری شکل';

  @override
  String get themeSystem => 'سسٹم کے مطابق';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تاریک';

  @override
  String get themeSepia => 'سیپیا';

  @override
  String get language => 'زبان';

  @override
  String get reading => 'مطالعہ';

  @override
  String get keepScreenAwake => 'پڑھتے وقت اسکرین روشن رکھیں';

  @override
  String get showMarkers => 'پارہ، حزب اور صفحہ کے نشانات دکھائیں';

  @override
  String get manageTranslations => 'تراجم منتخب اور مرتب کریں';

  @override
  String get yourData => 'آپ کا ڈیٹا';

  @override
  String get resetProgress => 'مطالعے کی پیش رفت ری سیٹ کریں';

  @override
  String get resetProgressConfirm =>
      'اس سے مطالعے کے تمام محفوظ مقامات صاف ہو جائیں گے۔ محفوظ شدہ آیات برقرار رہیں گی۔';

  @override
  String get progressReset => 'مطالعے کی پیش رفت صاف ہو گئی';

  @override
  String get exportBookmarks => 'محفوظ شدہ آیات برآمد کریں';

  @override
  String get importBookmarks => 'محفوظ شدہ آیات درآمد کریں';

  @override
  String importedBookmarks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آیات درآمد ہوئیں',
      one: '1 آیت درآمد ہوئی',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'یہ فائل درست برآمد شدہ فائل نہیں۔';

  @override
  String get installed => 'نصب شدہ';

  @override
  String get availableToDownload => 'ڈاؤن لوڈ کے لیے دستیاب';

  @override
  String get bundled => 'ساتھ شامل';

  @override
  String get download => 'ڈاؤن لوڈ';

  @override
  String get downloading => 'ڈاؤن لوڈ ہو رہا ہے…';

  @override
  String get downloadFailed =>
      'ڈاؤن لوڈ ناکام ہوا۔ کنکشن چیک کر کے دوبارہ کوشش کریں۔';

  @override
  String get loadEditionsFailed =>
      'تراجم کی فہرست لوڈ نہیں ہو سکی۔ کنکشن چیک کریں۔';

  @override
  String get translationOrderHint =>
      'منتخب تراجم اسی ترتیب سے دکھائے جاتے ہیں۔ ترتیب بدلنے کے لیے گھسیٹیں۔';

  @override
  String get atLeastOneTranslation =>
      'کم از کم ایک ترجمہ منتخب رکھیں، یا صرف عربی موڈ استعمال کریں۔';

  @override
  String get aboutSources => 'تعارف و مآخذ';

  @override
  String get arabicText => 'عربی متن';

  @override
  String get font => 'فونٹ';

  @override
  String get fontCredit =>
      'Amiri Quran از The Amiri Project Authors، SIL Open Font License 1.1 کے تحت۔';

  @override
  String get viewLicences => 'لائسنس دیکھیں';

  @override
  String get appVersion => 'ایپ ورژن';

  @override
  String get dataVersion => 'ڈیٹا ورژن';

  @override
  String get aboutBody =>
      'قرآنی متن بالکل اسی طرح دکھایا جاتا ہے جیسے ماخذ نے فراہم کیا، رسمِ عثمانی میں، اور یہ ایپ اس میں کبھی کوئی ترمیم نہیں کرتی۔ تراجم نیچے درج مترجمین کا کام ہیں۔';

  @override
  String get preparingQuran =>
      'قرآن کو آف لائن مطالعے کے لیے تیار کیا جا رہا ہے…';

  @override
  String get dbErrorTitle => 'قرآن کا ڈیٹا بیس نہیں کھل سکا';

  @override
  String get dbErrorBody =>
      'آپ کی محفوظ شدہ آیات الگ محفوظ ہیں۔ دوبارہ کوشش کریں، یا ایپ سے قرآن کا ڈیٹا بیس بحال کریں۔';

  @override
  String get restoreDatabase => 'قرآن کا ڈیٹا بیس بحال کریں';
}
