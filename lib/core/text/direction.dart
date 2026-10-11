// Extends `directionFor` from islamic-platform/src/lib/text.ts, which returns
// 'rtl' for 'ar' and 'ur'. Translations can be in any language, so every
// right-to-left script language AlQuran.cloud offers is covered.

const Set<String> _rtlLanguages = {
  'ar', 'ur', 'fa', 'he', 'ps', 'sd', 'ug', 'dv', 'ku', 'ckb', 'yi', //
};

/// 'rtl' or 'ltr' for a translation edition.
///
/// The provider's own `direction` wins when it states one; otherwise the
/// language decides.
String textDirectionFor(String language, {String? reported}) {
  if (reported == 'rtl' || reported == 'ltr') return reported!;
  return _rtlLanguages.contains(language.toLowerCase()) ? 'rtl' : 'ltr';
}
