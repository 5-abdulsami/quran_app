// The ordered list of audio files to play for a run of verses. Pure, so the
// basmalah and Arabic/Urdu interleaving rules are unit tested without audio.

import 'package:meta/meta.dart';

import 'models/reciter.dart';
import 'models/surah.dart';

/// One audio file in the queue.
@immutable
class RecitationTrack {
  const RecitationTrack({
    required this.reciter,
    required this.surah,
    required this.ayah,
    this.isBasmalah = false,
  });

  final Reciter reciter;
  final Surah surah;

  /// The verse this track belongs to. A basmalah track belongs to the verse it
  /// opens, so the reader highlights that verse while it plays.
  final int ayah;
  final bool isBasmalah;

  String get verseKey => '${surah.number}:$ayah';

  String get fileName =>
      isBasmalah ? basmalahFileName : verseFileName(surah.number, ayah);

  @override
  bool operator ==(Object other) =>
      other is RecitationTrack &&
      other.reciter.id == reciter.id &&
      other.surah.number == surah.number &&
      other.ayah == ayah &&
      other.isBasmalah == isBasmalah;

  @override
  int get hashCode => Object.hash(reciter.id, surah.number, ayah, isBasmalah);
}

/// The tracks for [verses] (in reading order) under [mode].
///
/// A surah's first verse is preceded by the basmalah, except in Al-Fatihah
/// (where it is verse 1 itself) and At-Tawbah (which has none), matching the
/// reader's header rule. In [RecitationMode.arabicThenUrdu] each verse, and
/// each basmalah, is followed by its Urdu translation.
List<RecitationTrack> buildRecitationQueue(
  List<(Surah, int)> verses, {
  required RecitationMode mode,
  required Reciter arabic,
  required Reciter urdu,
}) {
  final readers = [
    if (mode.includesArabic) arabic,
    if (mode.includesUrdu) urdu,
  ];
  return [
    for (final (surah, ayah) in verses) ...[
      if (ayah == 1 && surah.rendersHeaderBismillah)
        for (final reciter in readers)
          RecitationTrack(
            reciter: reciter,
            surah: surah,
            ayah: ayah,
            isBasmalah: true,
          ),
      for (final reciter in readers)
        RecitationTrack(reciter: reciter, surah: surah, ayah: ayah),
    ],
  ];
}

/// EveryAyah's file for a verse: surah and ayah, three digits each.
String verseFileName(int surah, int ayah) =>
    '${surah.toString().padLeft(3, '0')}${ayah.toString().padLeft(3, '0')}.mp3';

/// The basmalah is Al-Fatihah's first verse.
const basmalahFileName = '001001.mp3';

/// Every file needed to play [surah] in full offline, with any reciter.
List<String> surahFileNames(Surah surah) => [
  if (surah.rendersHeaderBismillah) basmalahFileName,
  for (var ayah = 1; ayah <= surah.ayahCount; ayah++)
    verseFileName(surah.number, ayah),
];
