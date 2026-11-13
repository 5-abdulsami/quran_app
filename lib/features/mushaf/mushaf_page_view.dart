import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/text/arabic_digits.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/theme/quran_typography.dart';
import '../reader/surah_header.dart';
import '../settings/settings_controller.dart';
import 'mushaf_providers.dart';

/// One mushaf page: a sheet of paper with the surah and juz at its head,
/// each surah opening (name and basmalah) where it begins, the Arabic text
/// flowing verse after verse, and the page number at its foot.
class MushafPageView extends ConsumerWidget {
  const MushafPageView({
    required this.page,
    required this.onAyahTap,
    this.markedVerseKey,
    super.key,
  });

  final int page;
  final void Function(Ayah ayah, Surah surah) onAyahTap;

  /// Tinted: the verse being recited, or the one the reader was sent to.
  final String? markedVerseKey;

  /// Keeps the list steady while a page loads: about one screen of text.
  static const placeholderHeight = 640.0;

  static Key keyFor(int page) => ValueKey('mushaf-page-$page');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(mushafPageProvider(page)).value;
    final colors = context.quranColors;
    final fontSize = ref.watch(
      settingsControllerProvider.select((s) => s.arabicFontSize),
    );

    return Padding(
      key: keyFor(page),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.sourceBackground,
          border: Border.all(color: colors.sourceBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: data == null
            ? const SizedBox(height: placeholderHeight, width: double.infinity)
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PageHead(page: data),
                    for (final section in data.sections) ...[
                      // The reader's own surah opening, with its basmalah.
                      if (section.startsSurah)
                        SurahHeader(
                          surah: section.surah,
                          arabicFontSize: fontSize,
                        ),
                      _MushafText(
                        section: section,
                        fontSize: fontSize,
                        markedVerseKey: markedVerseKey,
                        onAyahTap: onAyahTap,
                      ),
                    ],
                    const SizedBox(height: 4),
                    _PageFoot(number: data.number),
                  ],
                ),
              ),
      ),
    );
  }
}

/// The surah name(s) on the start side, the juz on the end side.
class _PageHead extends StatelessWidget {
  const _PageHead({required this.page});

  final MushafPage page;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: context.quranColors.marker);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              page.sections.map((s) => s.surah.nameSimple).join(' · '),
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(l10n.juzNumber(page.juz), style: style),
        ],
      ),
    );
  }
}

/// The page number, centred, in Arabic-Indic digits as printed.
class _PageFoot extends StatelessWidget {
  const _PageFoot({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.pageNumber(number),
      excludeSemantics: true,
      child: Text(
        toArabicIndicDigits(number),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.quranColors.marker,
          fontFamily: QuranTypography.ornamentFamily,
          fontSize: 15,
        ),
      ),
    );
  }
}

/// A section's ayat as one flowing block of right-to-left text, each verse
/// followed by its end-of-ayah ornament. Every verse is tappable; the text
/// as a whole stays selectable (the screen wraps it in a SelectionArea).
class _MushafText extends StatefulWidget {
  const _MushafText({
    required this.section,
    required this.fontSize,
    required this.onAyahTap,
    this.markedVerseKey,
  });

  final MushafSection section;
  final double fontSize;
  final String? markedVerseKey;
  final void Function(Ayah ayah, Surah surah) onAyahTap;

  @override
  State<_MushafText> createState() => _MushafTextState();
}

class _MushafTextState extends State<_MushafText> {
  final _taps = <int, TapGestureRecognizer>{};

  TapGestureRecognizer _tapFor(Ayah ayah) =>
      _taps.putIfAbsent(ayah.id, TapGestureRecognizer.new)
        ..onTap = () => widget.onAyahTap(ayah, widget.section.surah);

  @override
  void dispose() {
    for (final tap in _taps.values) {
      tap.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.quranColors;
    final style = QuranTypography.style(
      font: QuranTypography.fontOf(context),
      fontSize: widget.fontSize,
      color: colors.quranText,
    );
    final ornament = TextStyle(
      color: colors.ornament,
      fontFamily: QuranTypography.ornamentFamily,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(
          children: [
            for (final ayah in widget.section.ayahs) ...[
              TextSpan(
                text: ayah.displayText,
                recognizer: _tapFor(ayah),
                style: ayah.verseKey == widget.markedVerseKey
                    ? TextStyle(backgroundColor: colors.highlight)
                    : null,
              ),
              // A no-break space keeps the ornament on its verse's line.
              TextSpan(
                text: '\u00A0${endOfAyahMarker(ayah.ayahNumber)} ',
                style: ornament,
              ),
            ],
          ],
        ),
        style: style,
        textAlign: TextAlign.start,
        textDirection: TextDirection.rtl,
        locale: QuranTypography.locale,
      ),
    );
  }
}
