// Port of the cases in islamic-platform/tests/unit/text.test.ts that cover the
// ported functions, plus mobile-specific search cases.
//
// The same functions run at build time and at query time, so a change here
// changes search behaviour — hence the specificity.

import 'package:flutter_test/flutter_test.dart' hide collapseWhitespace;
import 'package:quran_app/core/text/arabic_digits.dart';
import 'package:quran_app/core/text/normalize.dart';
import 'package:quran_app/core/text/search_terms.dart';

import '../../helpers/test_databases.dart';

String ch(List<int> codes) => String.fromCharCodes(codes);

void main() {
  nfkcFastPathTests();

  group('stripArabicDiacritics', () {
    test('removes harakat while preserving letters', () {
      // "الرَّحمَٰن" -> "الرحمن"
      expect(stripArabicDiacritics('الرَّحمَٰن'), 'الرحمن');
    });

    test('removes tatweel', () {
      expect(stripArabicDiacritics('مــحمد'), 'محمد');
    });

    test('leaves Latin text untouched', () {
      expect(stripArabicDiacritics('hello world'), 'hello world');
    });
  });

  group('foldArabicLetters', () {
    test('folds every alef variant to bare alef', () {
      for (final variant in ['آ', 'أ', 'إ', 'ٱ']) {
        expect(foldArabicLetters(variant), 'ا');
      }
    });

    test('folds Urdu yeh and barree yeh to Arabic yeh', () {
      expect(foldArabicLetters('ی'), 'ي');
      expect(foldArabicLetters('ے'), 'ي');
    });

    test('folds Urdu keheh to Arabic kaf', () {
      // The single most common reason an Urdu-typed query misses Arabic text.
      expect(foldArabicLetters('ک'), 'ك');
    });

    test('folds teh marbuta to heh', () {
      expect(foldArabicLetters('ة'), 'ه');
    });
  });

  group('hasArabicScript', () {
    test('detects Arabic script', () {
      expect(hasArabicScript('قرآن'), isTrue);
    });

    test('does not fire on Latin text', () {
      expect(hasArabicScript('quran'), isFalse);
    });
  });

  group('detectScript', () {
    test('detects Urdu by its distinctive letters', () {
      expect(detectScript('کیا نیند'), DetectedScript.urdu);
    });

    test('detects Arabic', () {
      expect(detectScript('ما حكم الوضوء'), DetectedScript.arabic);
    });

    test('detects Roman Urdu from marker words', () {
      expect(
        detectScript('kya neend se wuzu toot jata hai'),
        DetectedScript.romanUrdu,
      );
    });

    test('detects Roman Urdu in a short query with one marker', () {
      expect(detectScript('namaz ka waqt'), DetectedScript.romanUrdu);
    });

    test('does not misclassify ordinary English as Roman Urdu', () {
      expect(
        detectScript('what is the main ruling on music in islam'),
        DetectedScript.latin,
      );
    });

    test('treats empty input as Latin', () {
      expect(detectScript(''), DetectedScript.latin);
    });
  });

  group('normalizeForSearch', () {
    test('lowercases and collapses whitespace', () {
      expect(
        normalizeForSearch('  What   BREAKS   Wudu?  '),
        'what breaks wudu',
      );
    });

    test('preserves the colon so verse references survive', () {
      expect(normalizeForSearch('quran 2:255'), 'quran 2:255');
    });

    test('strips punctuation to spaces', () {
      expect(
        normalizeForSearch('wudu, prayer; fasting!'),
        'wudu prayer fasting',
      );
    });

    test('strips zero-width and bidi control characters', () {
      // 'wu' ZERO WIDTH SPACE 'du' RIGHT-TO-LEFT OVERRIDE
      final input = 'wu${ch(const [0x200B])}du${ch(const [0x202E])}';
      expect(normalizeForSearch(input), 'wudu');
    });

    test('produces the same output for diacritised and bare Arabic', () {
      expect(normalizeForSearch('الرَّحمَٰن'), normalizeForSearch('الرحمن'));
    });
  });

  group('truncate', () {
    test('leaves short strings alone', () {
      expect(truncate('short', 20), 'short');
    });

    test('cuts on a word boundary and appends an ellipsis', () {
      final result = truncate(
        'the quick brown fox jumps over the lazy dog',
        20,
      );
      expect(result.endsWith('…'), isTrue);
      expect(result.length, lessThanOrEqualTo(21));
      expect(result, isNot(contains('jum…')));
    });

    test('collapses whitespace before measuring', () {
      expect(truncate('a   b', 10), 'a b');
    });
  });

  group('collapseWhitespace', () {
    test('collapses runs of whitespace including newlines', () {
      expect(collapseWhitespace('a\n\n  b\tc '), 'a b c');
    });
  });

  group('sanitizeSourceText', () {
    final bom = ch(const [0xfeff]);
    final zeroWidth = ch(const [0x200b]);
    final harakaFatha = ch(const [0x064e]);
    final alef = ch(const [0x0627]);

    test('strips a leading byte-order mark', () {
      // AlQuran.cloud ships verse 1:1 with exactly this.
      expect(sanitizeSourceText(bom + alef), alef);
    });

    test('strips zero-width characters anywhere in the string', () {
      expect(sanitizeSourceText(alef + zeroWidth + alef), alef + alef);
    });

    test('preserves harakat', () {
      // The licences require diacritics to be preserved verbatim, so the
      // sanitiser must be narrower than the search fold.
      final vowelled = alef + harakaFatha;
      expect(sanitizeSourceText(vowelled), vowelled);
    });

    test('leaves ordinary text untouched apart from trimming', () {
      expect(sanitizeSourceText('  hello world  '), 'hello world');
    });

    test('reduces a string of only invisible characters to empty', () {
      // So the build's empty-text validation rejects it.
      expect(sanitizeSourceText(bom + zeroWidth), '');
    });
  });

  group('arabic digits', () {
    test('renders Arabic-Indic digits', () {
      expect(toArabicIndicDigits(255), '٢٥٥');
    });

    test('converts Arabic-Indic and Persian digits to ASCII', () {
      expect(toAsciiDigits('٢:٢٥٥'), '2:255');
      expect(toAsciiDigits('۲:۲۵۵'), '2:255');
      expect(toAsciiDigits('juz ٣٠'), 'juz 30');
    });

    test('end-of-ayah marker is U+06DD followed by the digits', () {
      expect(endOfAyahMarker(7).runes.toList(), [0x06DD, 0x0667]);
    });
  });

  group('search against the bundled corpus', () {
    late Map<String, String> arabic;
    late Map<String, String> english;

    setUpAll(() async {
      final db = await openBundledContentDb();
      arabic = {
        for (final r
            in await db
                .customSelect('SELECT verse_key, text_search FROM ayah')
                .get())
          r.read<String>('verse_key'): r.read<String>('text_search'),
      };
      english = {
        for (final r
            in await db
                .customSelect(
                  'SELECT a.verse_key, t.text_search FROM translation t '
                  "JOIN ayah a ON a.id = t.ayah_id WHERE t.edition_id = 'en.sahih'",
                )
                .get())
          r.read<String>('verse_key'): r.read<String>('text_search'),
      };
      await db.close();
    });

    test('unvoweled "الحمد لله" matches 1:2', () {
      expect(arabic['1:2'], contains(normalizeForSearch('الحمد لله')));
    });

    test('"رحمن" matches ٱلرَّحْمَٰنِ', () {
      expect(arabic['1:3'], contains(normalizeForSearch('رحمن')));
      expect(normalizeForSearch('ٱلرَّحْمَٰنِ'), 'الرحمن');
    });

    test('"mercy" prefix-matches en.sahih "Mercy" and "merciful"', () {
      final term = searchTermsFor('mercy').single;
      expect(term.match, TermMatch.wordPrefix);
      // 1:1 "...the Entirely Merciful, the Especially Merciful."
      expect(term.matches(english['1:1']!), isTrue);
      // A verse with the noun itself, e.g. 6:12 "...decreed upon Himself mercy".
      expect(term.matches(english['6:12']!), isTrue);
      expect(english['6:12'], contains('mercy'));
    });
  });

  group('searchTermsFor', () {
    test('Arabic terms match anywhere in a word', () {
      final terms = searchTermsFor('الحمد لله');
      expect(terms.map((t) => t.match), everyElement(TermMatch.substring));
      expect(terms.map((t) => t.text), ['الحمد', 'لله']);
    });

    test('Latin terms are lowercased, stemmed and prefix-matched', () {
      expect(searchTermsFor('Believers Patience'), const [
        SearchTerm('believer', TermMatch.wordPrefix),
        SearchTerm('patience', TermMatch.wordPrefix),
      ]);
    });

    test('a word prefix does not match mid-word', () {
      const term = SearchTerm('pray', TermMatch.wordPrefix);
      expect(term.matches('and they prayed'), isTrue);
      expect(term.matches('spray'), isFalse);
    });

    test('duplicates and empty input collapse', () {
      expect(searchTermsFor('patience patience'), hasLength(1));
      expect(searchTermsFor('  ,; '), isEmpty);
    });

    test('light stemming', () {
      expect(latinStem('mercy'), 'merc');
      expect(latinStem('mercies'), 'merc');
      expect(latinStem('prayers'), 'prayer');
      expect(latinStem('witness'), 'witness');
      expect(latinStem('day'), 'day');
    });
  });
}

/// The NFKC fast path in normalizeForSearch must never change a result.
void nfkcFastPathTests() {
  group('NFKC fast path', () {
    test('agrees with full NFKC on the cases it must hand to NFKC', () {
      final cases = [
        ch(const [0x06D5, 0x0654]), // ae + hamza above composes to U+06C0
        ch(const [0x06C1, 0x0654]), // heh goal + hamza above -> U+06C2
        ch(const [0x06D2, 0x0654]), // yeh barree + hamza above -> U+06D3
        ch(const [0x0675]), // high hamza alef: compatibility decomposition
        ch(const [0x0627, 0x0653]), // alef + maddah composes to U+0622
        ch(const [0x064A, 0x0654]), // yeh + hamza above composes to U+0626
        ch(const [0xFEFB]), // lam-alef presentation form
        ch(const [0xFDF2]), // "Allah" ligature
        'wu${ch(const [0x00A0])}du', // no-break space
        'ﬁne', // Latin ligature
        'Ｑｕｒａｎ', // full-width
        'Allah’s',
      ];
      for (final input in cases) {
        expect(
          normalizeForSearch(input),
          normalizeForSearchWithFullNfkc(input),
          reason: input.runes.map((r) => r.toRadixString(16)).join(' '),
        );
      }
    });

    test('matches the stored search text for the whole corpus', () async {
      // The bundled text_search columns were produced with full NFKC.
      final db = await openBundledContentDb();
      final rows = [
        ...await db
            .customSelect('SELECT text_uthmani t, text_search s FROM ayah')
            .get(),
        ...await db
            .customSelect('SELECT text t, text_search s FROM translation')
            .get(),
      ];
      await db.close();
      expect(rows.length, 6236 * 3);
      for (final r in rows) {
        expect(normalizeForSearch(r.read<String>('t')), r.read<String>('s'));
      }
    });

    test('agrees with full NFKC on a sample of verses', () async {
      final db = await openBundledContentDb();
      final rows = await db
          .customSelect('SELECT text_uthmani t FROM ayah WHERE id % 97 = 0')
          .get();
      await db.close();
      for (final r in rows) {
        final text = r.read<String>('t');
        expect(normalizeForSearch(text), normalizeForSearchWithFullNfkc(text));
      }
    });
  });
}
