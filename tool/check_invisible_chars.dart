// Fails if any source file contains an invisible or bidi-control character.
//
// Such characters are invisible in review yet change how text behaves, which
// is unacceptable in code that handles Quranic text. Patterns that need one
// must use a \u{...} escape instead.
//
// Usage: dart run tool/check_invisible_chars.dart

import 'dart:io';

const _forbidden = {
  0xFEFF, 0x200B, 0x200C, 0x200D, 0x200E, 0x200F, 0x202A, 0x202B, 0x202C, //
  0x202D, 0x202E, 0x2060, 0x2061, 0x2062, 0x2063, 0x2064, 0x2066, 0x2067,
  0x2068, 0x2069,
};

void main() {
  final roots = ['lib', 'test', 'integration_test', 'tool'];
  var scanned = 0;
  var found = 0;

  for (final root in roots) {
    final dir = Directory(root);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File) continue;
      final path = entity.path.replaceAll(r'\', '/');
      if (path.contains('/cache/') || path.contains('/generated/')) continue;
      if (!path.endsWith('.dart') && !path.endsWith('.arb')) continue;

      scanned += 1;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final rune in lines[i].runes) {
          if (_forbidden.contains(rune)) {
            stderr.writeln('$path:${i + 1}: U+${rune.toRadixString(16)}');
            found += 1;
          }
        }
      }
    }
  }

  stdout.writeln('Scanned $scanned files: $found invisible characters.');
  if (found > 0) exitCode = 1;
}
