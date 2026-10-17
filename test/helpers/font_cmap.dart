import 'dart:io';
import 'dart:typed_data';

/// The Unicode code points a TrueType font maps to a glyph, read from its
/// `cmap` table (formats 4 and 12, which cover every font we bundle).
Set<int> fontCodePoints(String path) {
  final bytes = ByteData.sublistView(File(path).readAsBytesSync());
  final cmap = _tableOffset(bytes, 'cmap');
  final mapped = <int>{};
  final subtables = bytes.getUint16(cmap + 2);
  for (var i = 0; i < subtables; i++) {
    final offset = cmap + bytes.getUint32(cmap + 4 + i * 8 + 4);
    switch (bytes.getUint16(offset)) {
      case 4:
        _readFormat4(bytes, offset, mapped);
      case 12:
        _readFormat12(bytes, offset, mapped);
    }
  }
  return mapped;
}

int _tableOffset(ByteData bytes, String tag) {
  final tables = bytes.getUint16(4);
  for (var i = 0; i < tables; i++) {
    final record = 12 + i * 16;
    final name = String.fromCharCodes([
      for (var j = 0; j < 4; j++) bytes.getUint8(record + j),
    ]);
    if (name == tag) return bytes.getUint32(record + 8);
  }
  throw StateError('no $tag table');
}

void _readFormat4(ByteData b, int offset, Set<int> out) {
  final segCountX2 = b.getUint16(offset + 6);
  final ends = offset + 14;
  final starts = ends + segCountX2 + 2;
  final deltas = starts + segCountX2;
  final rangeOffsets = deltas + segCountX2;
  for (var s = 0; s < segCountX2 ~/ 2; s++) {
    final end = b.getUint16(ends + s * 2);
    final start = b.getUint16(starts + s * 2);
    final delta = b.getInt16(deltas + s * 2);
    final rangeOffset = b.getUint16(rangeOffsets + s * 2);
    for (var c = start; c <= end && c != 0xFFFF; c++) {
      var glyph = 0;
      if (rangeOffset == 0) {
        glyph = (c + delta) & 0xFFFF;
      } else {
        final at = rangeOffsets + s * 2 + rangeOffset + (c - start) * 2;
        glyph = b.getUint16(at);
        if (glyph != 0) glyph = (glyph + delta) & 0xFFFF;
      }
      if (glyph != 0) out.add(c);
    }
  }
}

void _readFormat12(ByteData b, int offset, Set<int> out) {
  final groups = b.getUint32(offset + 12);
  for (var g = 0; g < groups; g++) {
    final start = b.getUint32(offset + 16 + g * 12);
    final end = b.getUint32(offset + 20 + g * 12);
    for (var c = start; c <= end; c++) {
      out.add(c);
    }
  }
}
