import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../domain/models/ayah.dart';
import '../../domain/models/surah.dart';
import '../../providers.dart';

/// The run of one surah's ayat on a page.
@immutable
class MushafSection {
  const MushafSection({required this.surah, required this.ayahs});

  final Surah surah;

  /// Consecutive ayat of [surah]; never empty.
  final List<Ayah> ayahs;

  /// The page shows this surah's opening (and so its header and basmalah).
  bool get startsSurah => ayahs.first.ayahNumber == 1;
}

/// One page of the Madani mushaf, Arabic only.
@immutable
class MushafPage {
  const MushafPage({required this.number, required this.sections});

  final int number;

  /// In mushaf order; a page can hold the end of one surah and the start of
  /// the next. Never empty.
  final List<MushafSection> sections;

  Ayah get firstAyah => sections.first.ayahs.first;
  int get juz => firstAyah.juz;
}

/// A page's ayat, grouped by surah. Kept for a few minutes after it scrolls
/// away, so scrolling back is instant.
final mushafPageProvider = FutureProvider.autoDispose.family<MushafPage, int>((
  ref,
  number,
) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 3), link.close);
  ref.onDispose(timer.cancel);

  final quran = ref.watch(quranRepositoryProvider);
  final (surahs, ayahs) = await (quran.surahs(), quran.pageAyahs(number)).wait;

  final sections = <MushafSection>[];
  var start = 0;
  for (var i = 1; i <= ayahs.length; i++) {
    if (i == ayahs.length || ayahs[i].surahNumber != ayahs[start].surahNumber) {
      sections.add(
        MushafSection(
          surah: surahs[ayahs[start].surahNumber - 1],
          ayahs: ayahs.sublist(start, i),
        ),
      );
      start = i;
    }
  }
  return MushafPage(number: number, sections: sections);
});
