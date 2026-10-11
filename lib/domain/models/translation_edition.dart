import 'package:meta/meta.dart';

/// A translation installed on the device (bundled or downloaded).
@immutable
class TranslationEdition {
  const TranslationEdition({
    required this.id,
    required this.language,
    required this.name,
    required this.translator,
    required this.isRtl,
    required this.attribution,
    required this.bundled,
  });

  /// e.g. 'en.sahih'
  final String id;
  final String language;

  /// Edition title, e.g. "Saheeh International".
  final String name;

  /// Translator credit as the source supplies it.
  final String translator;
  final bool isRtl;

  /// Licence-required credit. Never dropped or reworded.
  final String attribution;

  /// Shipped with the app; cannot be deleted.
  final bool bundled;
}
