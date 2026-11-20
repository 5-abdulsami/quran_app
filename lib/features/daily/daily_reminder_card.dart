import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/hadith/hadith_citation.dart';
import '../../core/quran/attribution.dart';
import '../../core/quran/citation.dart';
import '../../core/quran/references.dart';
import '../../core/text/direction.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/translation_edition.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../ui/l10n_labels.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/theme/quran_typography.dart';
import '../../ui/toast.dart';
import '../../ui/widgets/attribution_text.dart';
import '../../ui/widgets/quran_text.dart';
import '../settings/settings_controller.dart';
import 'daily_providers.dart';

/// The home screen's Ayah / Hadith of the Day.
///
/// Renders nothing while loading, when turned off in Settings, or if the
/// day's entry cannot be loaded: it is a companion to the home screen, never
/// a reason for it to fail.
class DailyReminderCard extends ConsumerWidget {
  const DailyReminderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      settingsControllerProvider.select((s) => s.showDailyCard),
    );
    final reminder = enabled ? ref.watch(dailyReminderProvider).value : null;
    // Fades and grows in when the card first loads (or the day changes).
    // Changes inside a card, like showing the Arabic, animate on their own.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: child,
        ),
      ),
      child: switch (reminder) {
        null => const SizedBox(width: double.infinity),
        final DailyAyahReminder r => _AyahCard(reminder: r),
        final DailyHadithReminder r => _HadithCard(reminder: r),
      },
    );
  }
}

// --- Ayah ---------------------------------------------------------------------

class _AyahCard extends ConsumerWidget {
  const _AyahCard({required this.reminder});

  final DailyAyahReminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final arabicSize = ref.watch(
      settingsControllerProvider.select((s) => s.arabicFontSize),
    );
    final editions = {
      for (final e
          in ref.watch(editionsProvider).value ?? const <TranslationEdition>[])
        e.id: e,
    };
    final surah = reminder.surah;
    final ayahs = reminder.ayahs;
    final label = verseRangeLabel(
      surah.number,
      reminder.fromAyah,
      reminder.toAyah,
    );

    // One paragraph per translation edition, joining the passage's verses.
    final translations = <String, List<AyahTranslation>>{};
    for (final ayah in ayahs) {
      for (final t in ayah.translations) {
        (translations[t.editionId] ??= []).add(t);
      }
    }

    return _DailyCardFrame(
      key: const ValueKey('daily-ayah'),
      icon: Icons.auto_stories_outlined,
      title: l10n.ayahOfTheDay,
      onShare: () => SharePlus.instance.share(
        ShareParams(
          text: passagePayload(
            surah: surah.number,
            fromAyah: reminder.fromAyah,
            toAyah: reminder.toAyah,
            surahName: surah.nameSimple,
            arabic: ayahs.map((a) => a.displayText).join(' '),
            translations: [
              for (final parts in translations.values)
                parts.map((t) => t.text).join(' '),
            ],
          ),
          subject: "Qur'an $label",
        ),
      ),
      body: [
        _SourcePaper(
          child: Column(
            children: [
              for (final ayah in ayahs)
                QuranText.ayah(ayah, fontSize: arabicSize),
            ],
          ),
        ),
        for (final MapEntry(key: editionId, value: parts)
            in translations.entries) ...[
          const SizedBox(height: 12),
          _TranslationText(
            text: parts.map((t) => t.text).join(' '),
            language: parts.first.language,
            isRtl: parts.first.isRtl,
          ),
          if (editions[editionId] case final edition?) ...[
            const SizedBox(height: 4),
            AttributionText(
              creditLine(
                translatorName: edition.translator,
                sourceName: edition.name,
                attribution: edition.attribution,
                translatedBy: l10n.translatedBy,
              ),
            ),
          ],
        ],
      ],
      reference: Text(
        '${surah.nameSimple} · $label',
        style: _referenceStyle(context),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => context.push(
            AppRoutes.surah(surah.number, ayah: reminder.fromAyah),
          ),
          icon: const Icon(Icons.menu_book_outlined, size: 18),
          label: Text(l10n.readInContext),
        ),
      ],
    );
  }
}

// --- Hadith -------------------------------------------------------------------

class _HadithCard extends ConsumerWidget {
  const _HadithCard({required this.reminder});

  final DailyHadithReminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hadith = reminder.hadith;
    final (showArabic, arabicSize) = ref.watch(
      settingsControllerProvider.select(
        (s) => (s.showHadithArabic, s.arabicFontSize),
      ),
    );
    final translation = hadith.translationFor(
      _preferredLanguages(context, ref),
    );
    final messenger = ScaffoldMessenger.of(context);
    final launch = ref.read(externalLinkLauncherProvider);

    Future<void> openSource() async {
      final opened = await launch(hadith.sourceUrl).catchError((_) => false);
      if (!opened) messenger.showToast(l10n.openLinkFailed);
    }

    return _DailyCardFrame(
      key: const ValueKey('daily-hadith'),
      icon: Icons.format_quote_outlined,
      title: l10n.hadithOfTheDay,
      onShare: () => SharePlus.instance.share(
        ShareParams(
          text: hadithPayload(
            arabic: showArabic ? hadith.arabic : null,
            translation: translation.text,
            translationSource: translation.source,
            citation: hadith.citation,
            source: hadith.sourceUrl,
          ),
          subject: hadith.citation,
        ),
      ),
      body: [
        // The Arabic fades while the space for it eases open or closed, so
        // the translation glides instead of jumping.
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOutCubic,
          firstCurve: const Interval(0, 0.6, curve: Curves.easeOut),
          secondCurve: const Interval(0.4, 1, curve: Curves.easeIn),
          alignment: Alignment.topCenter,
          crossFadeState: showArabic
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SourcePaper(
              child: _HadithArabic(hadith.arabic, fontSize: arabicSize),
            ),
          ),
        ),
        _TranslationText(
          text: translation.text,
          language: translation.language,
          isRtl: textDirectionFor(translation.language) == 'rtl',
        ),
        const SizedBox(height: 4),
        AttributionText(translation.source),
      ],
      reference: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '${l10n.hadithCollection(hadith.collection)} ${hadith.number}',
              style: _referenceStyle(context),
            ),
          ),
          const SizedBox(width: 8),
          _GradeBadge(label: l10n.sahihGrade),
        ],
      ),
      actions: [
        TextButton(
          key: const ValueKey('daily-hadith-arabic-toggle'),
          onPressed: () => ref
              .read(settingsControllerProvider.notifier)
              .setShowHadithArabic(show: !showArabic),
          child: Text(showArabic ? l10n.hideArabic : l10n.showArabic),
        ),
        TextButton.icon(
          onPressed: openSource,
          icon: const Icon(Icons.open_in_new, size: 18),
          label: Text(l10n.verifySource),
        ),
      ],
    );
  }

  /// The languages of the reader's chosen Quran translations (so the hadith
  /// reads in the same language as the daily ayah), then the UI language,
  /// then English (which every hadith has).
  static List<String> _preferredLanguages(BuildContext context, WidgetRef ref) {
    final editions = {
      for (final e
          in ref.watch(editionsProvider).value ?? const <TranslationEdition>[])
        e.id: e.language,
    };
    final selected = ref.watch(
      settingsControllerProvider.select((s) => s.translationIds),
    );
    return [
      for (final id in selected) ?editions[id],
      Localizations.localeOf(context).languageCode,
      'en',
    ];
  }
}

/// A hadith's Arabic matn. Not Quranic text, so it never uses the Quran font
/// or the end-of-ayah ornament: it is set in Amiri, a classic naskh.
class _HadithArabic extends StatelessWidget {
  const _HadithArabic(this.text, {required this.fontSize});

  static const _family = 'Amiri';

  /// Amiri reads larger than the Quran fonts at the same size.
  static const _scale = 0.8;

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Text(
      text,
      key: const ValueKey('daily-hadith-arabic'),
      textDirection: TextDirection.rtl,
      locale: QuranTypography.locale,
      style: TextStyle(
        fontFamily: _family,
        fontSize: fontSize * _scale,
        height: 2,
        color: context.quranColors.quranText,
        locale: QuranTypography.locale,
      ),
    ),
  );
}

// --- Shared pieces -------------------------------------------------------------

TextStyle? _referenceStyle(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge
    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

/// Header, body and footer, laid out the same for an ayah and a hadith.
/// The footer wraps onto two lines on narrow screens.
class _DailyCardFrame extends ConsumerWidget {
  const _DailyCardFrame({
    required this.icon,
    required this.title,
    required this.onShare,
    required this.body,
    required this.reference,
    required this.actions,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onShare;
  final List<Widget> body;
  final Widget reference;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hijri = ref.watch(dailyDateProvider.select((d) => d.hijri));

    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        l10n.hijri(hijri),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.share,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: onShare,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              // The Arabic and translation can be selected and copied.
              child: SelectionArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: body,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 0,
              children: [
                reference,
                // Wraps too: two localised buttons can outgrow a phone.
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: actions,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Quoted source text sits on the warm, bordered "paper" surface, as on the
/// ayah detail screen.
class _SourcePaper extends StatelessWidget {
  const _SourcePaper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.quranColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.sourceBackground,
        border: Border.all(color: colors.sourceBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

/// A translation at the reader's chosen size, in its own direction.
class _TranslationText extends ConsumerWidget {
  const _TranslationText({
    required this.text,
    required this.language,
    required this.isRtl,
  });

  final String text;
  final String language;
  final bool isRtl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(
      settingsControllerProvider.select((s) => s.translationFontSize),
    );
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          locale: Locale(language),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: isRtl
                ? fontSize * TranslationTypography.rtlScale
                : fontSize,
            height: isRtl
                ? TranslationTypography.rtlLineHeight
                : TranslationTypography.lineHeight,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
          ),
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
