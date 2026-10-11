/// Language names in their own script, so each is recognisable whatever the
/// UI language. Unknown codes fall back to the code itself.
const Map<String, String> _endonyms = {
  'en': 'English',
  'ur': 'اردو',
  'ar': 'العربية',
  'fa': 'فارسی',
  'tr': 'Türkçe',
  'id': 'Bahasa Indonesia',
  'ms': 'Bahasa Melayu',
  'bn': 'বাংলা',
  'hi': 'हिन्दी',
  'fr': 'Français',
  'de': 'Deutsch',
  'es': 'Español',
  'ru': 'Русский',
  'zh': '中文',
};

String languageEndonym(String code) =>
    _endonyms[code.toLowerCase()] ?? code.toUpperCase();
