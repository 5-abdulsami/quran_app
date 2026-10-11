import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/quran_repository.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/bookmark.dart';
import '../../providers.dart';

/// All bookmarks, newest first, kept live.
final bookmarksProvider = StreamProvider<List<Bookmark>>(
  (ref) => ref.watch(bookmarkRepositoryProvider).watchAll(),
);

/// A bookmark with its verse, ready to list.
typedef BookmarkedVerse = ({Bookmark bookmark, Ayah ayah});

/// Bookmarks joined with their verses (Arabic only; snippets need no
/// translation), newest first.
final bookmarkedVersesProvider = FutureProvider<List<BookmarkedVerse>>((
  ref,
) async {
  final bookmarks = await ref.watch(bookmarksProvider.future);
  final ids = [
    for (final b in bookmarks) ?QuranRepository.ayahIdFor(b.verseKey),
  ];
  final ayahs = {
    for (final a in await ref.watch(quranRepositoryProvider).ayahsByIds(ids))
      a.verseKey: a,
  };
  return [
    for (final b in bookmarks)
      if (ayahs[b.verseKey] case final ayah?) (bookmark: b, ayah: ayah),
  ];
});

/// The global most recent reading position, for "Continue reading".
final mostRecentPositionProvider = StreamProvider<ReadingPosition?>(
  (ref) => ref.watch(readingPositionRepositoryProvider).watchMostRecent(),
);
