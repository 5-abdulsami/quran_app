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

/// English language names for AlQuran.cloud edition codes.
const Map<String, String> _englishNames = {
  'am': 'Amharic',
  'ar': 'Arabic',
  'az': 'Azerbaijani',
  'ba': 'Bosnian', // AlQuran.cloud files Bosnian editions under "ba".
  'ber': 'Amazigh',
  'bg': 'Bulgarian',
  'bn': 'Bengali',
  'bs': 'Bosnian',
  'cs': 'Czech',
  'de': 'German',
  'dv': 'Divehi',
  'en': 'English',
  'es': 'Spanish',
  'fa': 'Persian',
  'fr': 'French',
  'ha': 'Hausa',
  'hi': 'Hindi',
  'id': 'Indonesian',
  'it': 'Italian',
  'ja': 'Japanese',
  'ko': 'Korean',
  'ku': 'Kurdish',
  'ml': 'Malayalam',
  'ms': 'Malay',
  'nl': 'Dutch',
  'no': 'Norwegian',
  'pl': 'Polish',
  'ps': 'Pashto',
  'pt': 'Portuguese',
  'ro': 'Romanian',
  'ru': 'Russian',
  'sd': 'Sindhi',
  'si': 'Sinhala',
  'so': 'Somali',
  'sq': 'Albanian',
  'sv': 'Swedish',
  'sw': 'Swahili',
  'ta': 'Tamil',
  'tg': 'Tajik',
  'th': 'Thai',
  'tr': 'Turkish',
  'tt': 'Tatar',
  'ug': 'Uyghur',
  'uk': 'Ukrainian',
  'ur': 'Urdu',
  'uz': 'Uzbek',
  'zh': 'Chinese',
};

String languageEnglishName(String code) =>
    _englishNames[code.toLowerCase()] ?? code.toUpperCase();

/// Languages listed first when choosing translations.
const preferredTranslationLanguages = ['ur', 'en', 'ar'];
