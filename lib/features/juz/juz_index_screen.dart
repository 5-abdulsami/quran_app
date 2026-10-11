import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/quran_repository.dart';
import '../../domain/models/juz.dart';
import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../ui/app_shell.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/theme/quran_typography.dart';
import '../../ui/widgets/async_value_view.dart';
import '../../ui/widgets/number_medallion.dart';

/// Last-read verse per juz, kept live for the progress bars.
final _juzPositionsProvider = StreamProvider<Map<int, String>>(
  (ref) => ref.watch(readingPositionRepositoryProvider).watchJuzPositions(),
);

/// Share of a juz read, from the last saved position in it (0..1), or null.
double? juzProgress(Juz juz, String? lastVerseKey) {
  if (lastVerseKey == null) return null;
  final id = QuranRepository.ayahIdFor(lastVerseKey);
  if (id == null || id < juz.firstAyahId || id > juz.lastAyahId) return null;
  return (id - juz.firstAyahId + 1) / juz.ayahCount;
}

/// The 30 juz with their traditional names and boundaries.
class JuzIndexScreen extends ConsumerWidget {
  const JuzIndexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final juzs = ref.watch(juzsProvider);
    final surahs = ref.watch(surahsProvider).value ?? const <Surah>[];
    final positions = ref.watch(_juzPositionsProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navJuz),
        actions: const [SettingsAction()],
      ),
      body: AsyncValueView(
        value: juzs,
        onRetry: () => ref.invalidate(juzsProvider),
        data: (all) => ListView.separated(
          itemCount: all.length,
          separatorBuilder: (_, _) => const Divider(indent: 72),
          itemBuilder: (context, index) => _JuzTile(
            juz: all[index],
            surahs: surahs,
            progress: juzProgress(all[index], positions[all[index].number]),
          ),
        ),
      ),
    );
  }
}

class _JuzTile extends StatelessWidget {
  const _JuzTile({
    required this.juz,
    required this.surahs,
    required this.progress,
  });

  final Juz juz;
  final List<Surah> surahs;
  final double? progress;

  String _surahName(int number) =>
      surahs.elementAtOrNull(number - 1)?.nameSimple ?? '$number';

  String _endpoint(String verseKey) =>
      '$verseKey ${_surahName(int.parse(verseKey.split(':').first))}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ListTile(
      onTap: () => context.push(AppRoutes.juz(juz.number)),
      leading: NumberMedallion(juz.number),
      title: Text(
        '${l10n.juzNumber(juz.number)} · ${juz.nameTransliterated}',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_endpoint(juz.firstVerseKey)} – ${_endpoint(juz.lastVerseKey)}',
          ),
          Text(
            juz.surahNumbers.map(_surahName).join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: muted,
          ),
          if (progress case final value?) ...[
            const SizedBox(height: 6),
            Semantics(
              label: l10n.progressRead((value * 100).round()),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
      trailing: Text(
        juz.nameArabic,
        textDirection: TextDirection.rtl,
        locale: QuranTypography.locale,
        style: TextStyle(
          fontFamily: QuranTypography.familyOf(context),
          fontSize: 22,
          height: 1.6,
          color: context.quranColors.quranText,
        ),
      ),
    );
  }
}
