import 'package:flutter/material.dart';

import '../../domain/models/ayah.dart';
import '../../domain/models/bookmark.dart';
import '../../domain/models/surah.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../ui/widgets/quran_text.dart';

/// A bookmarked verse: reference, a one-line Arabic snippet and the note.
class BookmarkTile extends StatelessWidget {
  const BookmarkTile({
    required this.bookmark,
    required this.ayah,
    required this.surah,
    required this.onTap,
    this.onEditNote,
    super.key,
  });

  final Bookmark bookmark;
  final Ayah ayah;
  final Surah surah;
  final VoidCallback onTap;
  final VoidCallback? onEditNote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final note = bookmark.note;

    return Semantics(
      button: true,
      label: l10n.verseSemantics(surah.nameSimple, ayah.ayahNumber),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          // The edit button brings its own 48 dp of space on the end side;
          // without it the Arabic needs the same margin as the start side.
          padding: EdgeInsetsDirectional.fromSTEB(
            16,
            10,
            onEditNote == null ? 16 : 4,
            10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${surah.nameSimple} · ${ayah.verseKey}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    QuranText(ayah.displayText, fontSize: 20, maxLines: 1),
                    if (note != null)
                      Text(
                        note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (onEditNote != null)
                IconButton(
                  tooltip: note == null ? l10n.addNote : l10n.editNote,
                  icon: Icon(
                    note == null ? Icons.note_add_outlined : Icons.edit_note,
                  ),
                  onPressed: onEditNote,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
