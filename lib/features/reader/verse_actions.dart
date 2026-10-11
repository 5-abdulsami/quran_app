import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/quran/citation.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';

/// Opens the per-verse actions sheet: copy, share, bookmark, navigate.
///
/// As on the web, copied and shared text ALWAYS ends with the reference, e.g.
/// "Qur'an 2:255 (Surah Al-Baqara)".
Future<void> showVerseActions(
  BuildContext context, {
  required Ayah ayah,
  required Surah surah,
  bool showOpenDetail = true,
  bool showReadInContext = false,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _VerseActionsSheet(
    ayah: ayah,
    surah: surah,
    showOpenDetail: showOpenDetail,
    showReadInContext: showReadInContext,
  ),
);

class _VerseActionsSheet extends ConsumerWidget {
  const _VerseActionsSheet({
    required this.ayah,
    required this.surah,
    required this.showOpenDetail,
    required this.showReadInContext,
  });

  final Ayah ayah;
  final Surah surah;
  final bool showOpenDetail;
  final bool showReadInContext;

  String _payload({String? arabic, bool withTranslations = false}) =>
      versePayload(
        surah: ayah.surahNumber,
        ayah: ayah.ayahNumber,
        surahName: surah.nameSimple,
        arabic: arabic,
        translations: withTranslations
            ? [for (final t in ayah.translations) t.text]
            : const [],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bookmarked =
        ref.watch(bookmarkedKeysProvider).value?.contains(ayah.verseKey) ??
        false;
    final hasTranslation = ayah.translations.isNotEmpty;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    Future<void> copy(String text) async {
      Navigator.of(context).pop();
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(SnackBar(content: Text(l10n.copied)));
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                '${surah.nameSimple} · ${ayah.verseKey}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(),
            _Action(
              icon: Icons.content_copy,
              label: l10n.copyArabic,
              onTap: () => copy(_payload(arabic: ayah.displayText)),
            ),
            if (hasTranslation) ...[
              _Action(
                icon: Icons.translate,
                label: l10n.copyTranslation,
                onTap: () => copy(_payload(withTranslations: true)),
              ),
              _Action(
                icon: Icons.copy_all,
                label: l10n.copyBoth,
                onTap: () => copy(
                  _payload(arabic: ayah.displayText, withTranslations: true),
                ),
              ),
            ],
            // Only ayah 1 of a surah with a header basmalah has one split off;
            // copy the verse exactly as the source stores it.
            if (ayah.leadingBismillah != null)
              _Action(
                icon: Icons.format_quote,
                label: l10n.copyWithBasmalah,
                onTap: () => copy(
                  _payload(
                    arabic: ayah.textUthmani,
                    withTranslations: hasTranslation,
                  ),
                ),
              ),
            _Action(
              icon: Icons.tag,
              label: l10n.copyVerseKey,
              onTap: () => copy(ayah.verseKey),
            ),
            _Action(
              icon: Icons.share_outlined,
              label: l10n.share,
              onTap: () {
                Navigator.of(context).pop();
                SharePlus.instance.share(
                  ShareParams(
                    text: _payload(
                      arabic: ayah.displayText,
                      withTranslations: true,
                    ),
                    subject: "Qur'an ${ayah.verseKey}",
                  ),
                );
              },
            ),
            _Action(
              icon: bookmarked
                  ? Icons.bookmark_remove
                  : Icons.bookmark_add_outlined,
              label: bookmarked ? l10n.removeBookmark : l10n.bookmarkVerse,
              onTap: () async {
                Navigator.of(context).pop();
                final nowBookmarked = await ref
                    .read(bookmarkRepositoryProvider)
                    .toggle(ayah.verseKey);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      nowBookmarked ? l10n.bookmarkAdded : l10n.bookmarkRemoved,
                    ),
                  ),
                );
              },
            ),
            if (showOpenDetail)
              _Action(
                icon: Icons.open_in_full,
                label: l10n.openDetail,
                onTap: () {
                  Navigator.of(context).pop();
                  router.push(
                    AppRoutes.ayah(ayah.surahNumber, ayah.ayahNumber),
                  );
                },
              ),
            if (showReadInContext)
              _Action(
                icon: Icons.menu_book_outlined,
                label: l10n.readInContext,
                onTap: () {
                  Navigator.of(context).pop();
                  router.push(
                    AppRoutes.surah(ayah.surahNumber, ayah: ayah.ayahNumber),
                  );
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
}
