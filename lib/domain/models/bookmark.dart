import 'package:meta/meta.dart';

/// A bookmarked verse.
@immutable
class Bookmark {
  const Bookmark({required this.verseKey, required this.createdAt, this.note});

  final String verseKey;
  final DateTime createdAt;
  final String? note;

  Map<String, Object?> toJson() => {
    'verseKey': verseKey,
    'createdAt': createdAt.toUtc().toIso8601String(),
    if (note != null) 'note': note,
  };
}

/// Which way the reader is moving through the mushaf.
enum ReadingMode { surah, juz }

/// Where the reader stopped in one surah or juz.
@immutable
class ReadingPosition {
  const ReadingPosition({
    required this.mode,
    required this.ref,
    required this.verseKey,
    required this.updatedAt,
  });

  final ReadingMode mode;

  /// Surah or juz number.
  final int ref;
  final String verseKey;
  final DateTime updatedAt;
}
