# IslamIndex Quran

An offline-first Quran reader for Android and iOS, built with Flutter. It is a
standalone port of the Quran reader in the IslamIndex web app
(`../islamic-platform`). That web app remains the reference for behaviour, but
this app never contacts its server or database.

- The complete Quran (Uthmani script, AlQuran.cloud `quran-uthmani`) with
  Saheeh International (English) and Fateh Muhammad Jalandhry (Urdu) bundled.
- It works fully offline. The only network use is optionally downloading
  more translations.
- Read by surah or by juz, go to any verse, search Arabic and translations,
  keep bookmarks, and resume reading where you stopped.
- Light, dark and sepia themes. The UI is in English, Urdu or Arabic, and
  the Urdu and Arabic UIs are right-to-left.

## Setup

Requires Flutter 3.38.4 / Dart 3.10.

```sh
flutter pub get
flutter run
```

The Quran database (`assets/db/quran.db`) is committed, so the app runs
without any build step. To rebuild it from the source:

```sh
dart run tool/build_quran_db.dart
```

The first run downloads the editions once into `tool/cache/` (git-ignored).
Later runs are offline and deterministic. The script validates the whole
corpus and writes nothing if any check fails (see "Data pipeline" below).

Other maintenance commands:

```sh
# Regenerate drift code (JIT mode is needed because sqlite3 uses build hooks)
dart run build_runner build --force-jit --delete-conflicting-outputs

# Regenerate localisations from lib/l10n/*.arb
flutter gen-l10n

# Fail if any source file contains an invisible / bidi-control character
dart run tool/check_invisible_chars.dart

# Re-render the icon artwork, then the platform icons and splash screens
flutter test tool/icon/generate_icon_test.dart --update-goldens
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Tests

```sh
flutter test                    # unit + widget tests (host)
flutter test integration_test   # end-to-end, needs a device or emulator
```

The unit and widget tests run against a private copy of the real bundled
database, so the shipped asset can never be modified by a test.

## Release builds

```sh
flutter build apk --release
flutter build ipa               # macOS only
```

Android release signing reads `android/key.properties` (never committed):

```properties
storeFile=/path/to/upload-keystore.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

Without that file, release builds are signed with the debug key so that they
still build locally. R8 shrinking is enabled, with keep rules for SQLite in
`android/app/proguard-rules.pro`.

App identifiers:
- Android: `com.samionyx.quran_app`.
- iOS: `com.samionyx.quranApp`, because iOS bundle identifiers cannot contain
  underscores.
- Minimum versions: Android 7.0 (API 24, Flutter 3.38's minimum) and iOS 13.

## Architecture

```
lib/
  main.dart, app.dart, router.dart, providers.dart
  core/                 pure Dart, no Flutter imports
    quran/              bismillah, references, attribution, citation
    text/               normalisation, search terms, highlighting, digits
    db/                 drift schemas (content + user) and the bootstrap
  data/                 repositories; QuranRepository is the ONLY place rows
                        become Ayah models and the only caller of presentVerse
  domain/               immutable models and the surah filter
  features/             home, surahs, juz, reader, ayah_detail, search,
                        bookmarks, settings, about, bootstrap
  ui/                   theme, shared widgets (QuranText, AttributionText, …)
  l10n/                 ARB files (en, ur, ar) and generated localisations
tool/
  build_quran_db.dart   builds and validates assets/db/quran.db
  check_invisible_chars.dart
  icon/                 icon and splash artwork generator
```

**Two databases.** The Quran content (`quran.db`) is copied from the assets
on first launch, and copied again whenever an app update ships new data (the
data version in `assets/db/manifest.json` changes). Bookmarks and reading
positions live in a separate `user.db`, so replacing the content can never
touch user data. Downloaded translations are kept as validated JSON outside
the content database and re-imported after a content upgrade.

**State and navigation.** Riverpod providers sit on top of the repositories.
go_router provides deep-linkable routes:

| Route | Screen |
|---|---|
| `/` | Home |
| `/surahs` | Surah index |
| `/surah/:n` (`?ayah=N`) | Surah reader |
| `/juz` | Juz index |
| `/juz/:n` (`?verse=2:150`) | Juz reader |
| `/ayah/:surah/:ayah` | Ayah detail |
| `/search?q=` | Search |
| `/bookmarks` | Bookmarks |
| `/settings` | Settings |
| `/settings/translations` | Translations |
| `/about` | About & Sources |

Impossible references, such as `/surah/115` or `/ayah/2/300`, show a
not-found screen.

## Ported files

Every port names its TypeScript origin at the top of the file and keeps the
original's explanatory comments, so the two can be kept in sync.

| Dart | TypeScript origin (`islamic-platform/`) |
|---|---|
| `lib/core/quran/bismillah.dart` | `src/modules/quran/bismillah.ts` |
| `lib/core/quran/references.dart` | `src/lib/references.ts` (Quran half) |
| `lib/core/text/normalize.dart` | `src/lib/text.ts` |
| `lib/core/text/direction.dart` | `directionFor` in `src/lib/text.ts` |
| `lib/core/quran/attribution.dart` | `src/modules/ingestion/adapters/alquran-cloud.ts` (attribution) and `creditLine` in `src/app/quran/[surah]/[ayah]/page.tsx` |
| `lib/core/quran/citation.dart` | the copy payload in `src/ui/verse-actions.tsx` |
| `lib/data/quran_repository.dart` (`_toAyah`) | `toAyahView` in `src/modules/quran/service.ts` |
| `lib/core/db/content_db.dart` | `src/db/schema/quran.ts` |
| `tool/build_quran_db.dart` | `src/modules/ingestion/quran-sync.ts` and the field mapping in `alquran-cloud.ts` |
| `lib/features/reader/ayah_tile.dart` | `src/ui/ayah-row.tsx` |
| `lib/features/reader/surah_header.dart` | the header in `src/app/quran/[surah]/page.tsx` |
| `lib/l10n/app_{en,ur,ar}.arb` | `src/lib/i18n/dictionaries/{en,ur,ar}.ts` |
| `test/core/quran/bismillah_test.dart` | `tests/unit/bismillah.test.ts` |
| `test/core/quran/references_test.dart` | `tests/unit/references.test.ts` (Quran cases) |
| `test/core/text/normalize_test.dart` | `tests/unit/text.test.ts` (ported functions) |

## Accuracy safeguards

- **Verbatim text.** The Arabic is stored exactly as the source supplies it.
  The only change is `sanitizeSourceText`, which removes the BOM that
  AlQuran.cloud places on 1:1. Folding for search lives in separate
  `text_search` columns that are never displayed.
- **The basmalah** is never removed from the stored text. `presentVerse`
  separates it from the display text of ayah 1 only where the header shows
  it. That is 112 surahs: not al-Fatihah (where it is ayah 1) and not
  at-Tawbah. Both orthographic variants (surahs 95 and 97) are handled, and
  27:30 is never touched. A corpus test checks every surah, and architecture
  tests check that `presentVerse` has one caller and that no other code
  special-cases surah 1 or 9.
- **Build-time validation:** 114 surahs and 6236 ayat; per-surah counts; no
  empty text; complete translations; juz starts against a fixed table and
  the provider's `/meta`; juz 1–30 and pages 1–604 with no gaps; and the
  bismillah cross-check.
- **References are never clamped.** 2:300 and 115:1 resolve to nothing.
- **Citations travel with the text.** Copied and shared text always ends
  with the citation, e.g. "Qur'an 2:255 (Surah Al-Baqara)".
- **Attribution.** The Arabic text and every translator are credited on
  About & Sources and under the translations in each reader.

## Data pipeline

`tool/build_quran_db.dart` fetches `/surah`, `/meta`, `/edition` and
`/quran/{edition}` for `quran-uthmani`, `en.sahih` and `ur.jalandhry`. It
sanitises before it validates, and it computes a deterministic data version
from the content. It then writes `assets/db/quran.db` and
`assets/db/manifest.json`.

The content schema mirrors the web app's:
- `surah`
- `ayah` (with `juz`, `hizb`, `rub_el_hizb`, `ruku`, `manzil`, `page`, `sajdah_type`)
- `translation_edition`
- `translation`
- `juz`
- `meta`

## Known limitations

- **No revelation-order sort.** AlQuran.cloud does not publish revelation
  order, and, like the web adapter, the app leaves it absent rather than
  guessing.
- **Search** is lexical (word-prefix for Latin text, in-word matching for
  Arabic) with a light English stem. It is not morphological, so Arabic
  roots and broken plurals are not expanded.
- **iOS** was not built or run locally: the development machine runs
  Windows. The iOS project is configured (iOS 13, icons, launch screen) but
  needs a macOS build to verify.
- **Arabic fallback in the Latin UI font.** Arabic typed into the search
  field, and Urdu translations, use the device's system Arabic fonts (as
  every Android and iOS device ships them). Only Quranic text uses the
  bundled Amiri Quran.
- **Out of scope for v1:** audio, tafsir, a page-image mushaf,
  word-by-word translation, widgets and sync. The schema and routing leave
  room for them.

## Licences

- Quranic text and translations: AlQuran.cloud terms
  (https://alquran.cloud/terms-and-conditions). Credits are shown in the app.
- Amiri Quran font: SIL Open Font License 1.1
  (`assets/fonts/OFL-amiri-quran.txt`), shown on the licence page.
