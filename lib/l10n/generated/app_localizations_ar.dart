// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'فهرس الإسلام: القرآن';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSurahs => 'السور';

  @override
  String get navJuz => 'الأجزاء';

  @override
  String get navSearch => 'بحث';

  @override
  String get navBookmarks => 'المحفوظات';

  @override
  String get navSaved => 'المحفوظات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get search => 'بحث';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get close => 'إغلاق';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ';

  @override
  String get share => 'مشاركة';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get delete => 'حذف';

  @override
  String get undo => 'تراجع';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get goHome => 'الذهاب إلى الرئيسية';

  @override
  String get notFound => 'تعذّر العثور على هذه الصفحة.';

  @override
  String get genericError => 'حدث خطأ.';

  @override
  String get quranTitle => 'القرآن الكريم';

  @override
  String get surah => 'سورة';

  @override
  String get surahs => 'السور';

  @override
  String get juz => 'الجزء';

  @override
  String get page => 'الصفحة';

  @override
  String get hizb => 'الحزب';

  @override
  String get ruku => 'الركوع';

  @override
  String get manzil => 'المنزل';

  @override
  String get verse => 'آية';

  @override
  String get ayah => 'آية';

  @override
  String get translation => 'الترجمة';

  @override
  String get translations => 'الترجمات';

  @override
  String get makkah => 'مكية';

  @override
  String get madinah => 'مدنية';

  @override
  String get makki => 'مكية';

  @override
  String get madani => 'مدنية';

  @override
  String versesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آية',
      many: '$count آية',
      few: '$count آيات',
      two: 'آيتان',
      one: 'آية واحدة',
      zero: 'لا آيات',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'ابحث في القرآن…';

  @override
  String get noTranslationSelected => 'لم تُختر ترجمة';

  @override
  String get selectTranslation => 'اختر ترجمة';

  @override
  String get showArabic => 'إظهار العربية';

  @override
  String get showTranslation => 'إظهار الترجمة';

  @override
  String get arabicOnly => 'العربية فقط';

  @override
  String get fontSizeArabic => 'حجم النص العربي';

  @override
  String get fontSizeTranslation => 'حجم نص الترجمة';

  @override
  String get preview => 'معاينة';

  @override
  String get copyVerse => 'نسخ الآية';

  @override
  String get bookmarkVerse => 'حفظ هذه الآية';

  @override
  String get sajdahRecommended => 'سجدة مستحبة';

  @override
  String get sajdahObligatory => 'سجدة واجبة';

  @override
  String translatedBy(String name) {
    return 'ترجمة: $name';
  }

  @override
  String juzNumber(int number) {
    return 'الجزء $number';
  }

  @override
  String hizbNumber(int number) {
    return 'الحزب $number';
  }

  @override
  String pageNumber(int number) {
    return 'الصفحة $number';
  }

  @override
  String continuingSurah(String name, int ayah) {
    return 'تتمة سورة $name من الآية $ayah';
  }

  @override
  String verseSemantics(String surah, int ayah) {
    return 'سورة $surah، الآية $ayah';
  }

  @override
  String surahSemantics(int number, String name) {
    return 'السورة $number، $name';
  }

  @override
  String get basmalahSemantics => 'البسملة';

  @override
  String get continueReading => 'متابعة القراءة';

  @override
  String get continueReadingEmpty => 'ابدأ القراءة وسيُحفظ موضعك هنا.';

  @override
  String get goToVerse => 'الانتقال إلى آية';

  @override
  String get goToVerseHint => 'مثل 2:255 أو يس أو الجزء 30';

  @override
  String get goToAyah => 'الانتقال إلى آية';

  @override
  String ayahNumberRange(int max) {
    return 'رقم الآية (1–$max)';
  }

  @override
  String get invalidReference => 'هذا المرجع غير موجود في القرآن.';

  @override
  String get quickAccess => 'وصول سريع';

  @override
  String get ayatAlKursi => 'آية الكرسي';

  @override
  String get sort => 'ترتيب';

  @override
  String get recentBookmarks => 'أحدث المحفوظات';

  @override
  String get readBySurah => 'القراءة حسب السورة';

  @override
  String get readByJuz => 'القراءة حسب الجزء';

  @override
  String get previousJuz => 'الجزء السابق';

  @override
  String get nextJuz => 'الجزء التالي';

  @override
  String get previousSurah => 'السورة السابقة';

  @override
  String get nextSurah => 'السورة التالية';

  @override
  String progressRead(int percent) {
    return 'قُرئ $percent%';
  }

  @override
  String get filterSurahs => 'ابحث بالرقم أو الاسم';

  @override
  String get filterAll => 'الكل';

  @override
  String get copyArabic => 'نسخ النص العربي';

  @override
  String get copyTranslation => 'نسخ الترجمة';

  @override
  String get copyBoth => 'نسخ النص والترجمة';

  @override
  String get copyWithBasmalah => 'النسخ مع البسملة';

  @override
  String get copyVerseKey => 'نسخ رقم الآية';

  @override
  String get openDetail => 'تفاصيل الآية';

  @override
  String get readInContext => 'القراءة في السياق';

  @override
  String get removeBookmark => 'إزالة من المحفوظات';

  @override
  String get bookmarkAdded => 'حُفظت الآية';

  @override
  String get bookmarkRemoved => 'أُزيلت من المحفوظات';

  @override
  String get verseActions => 'خيارات الآية';

  @override
  String get searchTry => 'جرّب';

  @override
  String get goTo => 'انتقال إلى';

  @override
  String get versesSection => 'الآيات';

  @override
  String noResults(String query) {
    return 'لم تُطابق أي آية «$query».';
  }

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آية',
      many: '$count آية',
      few: '$count آيات',
      two: 'آيتان',
      one: 'آية واحدة',
      zero: 'لا آيات',
    );
    return '$_temp0';
  }

  @override
  String get recentSearches => 'عمليات البحث الأخيرة';

  @override
  String get clear => 'مسح';

  @override
  String get scopeArabic => 'العربية';

  @override
  String get scopeTranslation => 'الترجمة';

  @override
  String get scopeBoth => 'كلاهما';

  @override
  String get anySurah => 'أي سورة';

  @override
  String get anyJuz => 'أي جزء';

  @override
  String get loadMore => 'عرض المزيد';

  @override
  String get bookmarksEmpty => 'لا محفوظات بعد. اضغط مطولاً على آية لحفظها.';

  @override
  String get sortNewest => 'الأحدث أولاً';

  @override
  String get sortMushaf => 'ترتيب المصحف';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get note => 'ملاحظة';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSepia => 'بني فاتح';

  @override
  String get language => 'اللغة';

  @override
  String get reading => 'القراءة';

  @override
  String get keepScreenAwake => 'إبقاء الشاشة مضاءة أثناء القراءة';

  @override
  String get showMarkers => 'إظهار علامات الجزء والحزب والصفحة';

  @override
  String get manageTranslations => 'اختيار الترجمات وترتيبها';

  @override
  String get yourData => 'بياناتك';

  @override
  String get resetProgress => 'إعادة ضبط تقدم القراءة';

  @override
  String get resetProgressConfirm =>
      'سيؤدي هذا إلى مسح كل مواضع القراءة المحفوظة. تبقى المحفوظات كما هي.';

  @override
  String get progressReset => 'مُسح تقدم القراءة';

  @override
  String get exportBookmarks => 'تصدير المحفوظات';

  @override
  String get importBookmarks => 'استيراد المحفوظات';

  @override
  String importedBookmarks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استُوردت $count آية',
      many: 'استُوردت $count آية',
      few: 'استُوردت $count آيات',
      two: 'استُوردت آيتان',
      one: 'استُوردت آية واحدة',
      zero: 'لم تُستورد محفوظات',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'هذا الملف ليس ملف محفوظات صالحاً.';

  @override
  String get installed => 'المثبتة';

  @override
  String get availableToDownload => 'متاحة للتنزيل';

  @override
  String get bundled => 'مضمّنة';

  @override
  String get download => 'تنزيل';

  @override
  String get downloading => 'جارٍ التنزيل…';

  @override
  String get downloadFailed => 'فشل التنزيل. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get loadEditionsFailed =>
      'تعذّر تحميل قائمة الترجمات. تحقق من الاتصال.';

  @override
  String get translationOrderHint =>
      'تظهر الترجمات المختارة في القارئ بهذا الترتيب. اسحب لإعادة الترتيب.';

  @override
  String get atLeastOneTranslation =>
      'أبقِ ترجمة واحدة على الأقل، أو استخدم وضع العربية فقط.';

  @override
  String get aboutSources => 'حول التطبيق والمصادر';

  @override
  String get arabicText => 'النص العربي';

  @override
  String get font => 'الخط';

  @override
  String get fontCredit =>
      'خطوط المصحف: Scheherazade New وLateef وHarmattan من SIL Global؛ وAmiri وAmiri Quran من The Amiri Project Authors؛ وNoto Naskh Arabic وNoto Sans Arabic من The Noto Project Authors. وكلها مرخّصة برخصة SIL Open Font License 1.1.';

  @override
  String get quranFont => 'خط المصحف';

  @override
  String get viewLicences => 'عرض التراخيص';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get dataVersion => 'إصدار البيانات';

  @override
  String get aboutBody =>
      'يُعرض النص القرآني كما ورد من مصدره تماماً، بالرسم العثماني، ولا يعدّله هذا التطبيق أبداً. والترجمات من عمل المترجمين المذكورين أدناه.';

  @override
  String get preparingQuran => 'جارٍ تجهيز القرآن للقراءة دون اتصال…';

  @override
  String get dbErrorTitle => 'تعذّر فتح قاعدة بيانات القرآن';

  @override
  String get dbErrorBody =>
      'محفوظاتك مخزنة بشكل منفصل وهي آمنة. حاول مرة أخرى، أو استعد قاعدة بيانات القرآن من حزمة التطبيق.';

  @override
  String get restoreDatabase => 'استعادة قاعدة بيانات القرآن';
}
