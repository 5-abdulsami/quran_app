import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/db/content_db.dart';
import '../../core/quran/attribution.dart';
import '../../domain/models/reciter.dart';
import '../../domain/models/translation_edition.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../ui/widgets/attribution_text.dart';

final _appVersionProvider = FutureProvider.autoDispose<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

final _contentMetaProvider = FutureProvider.autoDispose<Map<String, String>>(
  (ref) => ref.watch(quranRepositoryProvider).meta(),
);

/// Sources, credits and licences, as the source terms require: the Arabic
/// text and every translator are credited by name.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final editions =
        ref.watch(editionsProvider).value ?? const <TranslationEdition>[];
    final meta = ref.watch(_contentMetaProvider).value ?? const {};
    final appVersion = ref.watch(_appVersionProvider).value ?? '—';
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutSources)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.aboutBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
          _Card(
            title: l10n.arabicText,
            children: [
              const Text(attributionArabic),
              const SizedBox(height: 4),
              Text(
                '${meta[MetaKeys.arabicEdition] ?? arabicEdition} · '
                'alquran.cloud/terms-and-conditions',
                style: muted,
              ),
            ],
          ),
          _Card(
            title: l10n.translations,
            children: [
              for (final edition in editions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(edition.name, style: theme.textTheme.titleSmall),
                      AttributionText(
                        creditLine(
                          translatorName: edition.translator,
                          sourceName: edition.name,
                          attribution: edition.attribution,
                          translatedBy: l10n.translatedBy,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          _Card(
            title: l10n.font,
            children: [
              Text(l10n.fontCredit),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
                    applicationVersion: appVersion,
                  ),
                  child: Text(l10n.viewLicences),
                ),
              ),
            ],
          ),
          _Card(
            title: l10n.recitation,
            children: [
              Text(l10n.recitationCredit),
              const SizedBox(height: 4),
              Text(
                [
                  for (final r in [...Reciters.arabic, ...Reciters.urdu])
                    r.name,
                ].join(' · '),
                style: muted,
              ),
            ],
          ),
          _Card(
            title: l10n.appVersion,
            children: [
              Text(appVersion),
              const SizedBox(height: 8),
              Text(l10n.dataVersion, style: theme.textTheme.titleSmall),
              Text(
                [
                  meta[MetaKeys.dataVersion],
                  meta[MetaKeys.buildDate]?.split('T').first,
                ].nonNulls.join(' · '),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    ),
  );
}
