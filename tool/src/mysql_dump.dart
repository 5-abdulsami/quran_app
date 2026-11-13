// A reader for the `INSERT INTO ... VALUES (...), (...);` statements of a
// mysqldump / mariadb-dump file.
//
// It understands exactly what those tools emit: single-quoted strings with
// backslash escapes, NULL, and bare numeric literals. It does not execute or
// interpret anything else in the file.

/// Every row inserted into [table], as raw column values in schema order.
///
/// String values are unescaped; `NULL` becomes null; numbers are returned as
/// their literal text.
Iterable<List<String?>> mysqlInsertRows(String sql, String table) sync* {
  final marker = 'INSERT INTO `$table` VALUES';
  var i = 0;
  while (true) {
    final start = sql.indexOf(marker, i);
    if (start < 0) return;
    final reader = _ValuesReader(sql, start + marker.length);
    yield* reader.rows();
    i = reader.position;
  }
}

class _ValuesReader {
  _ValuesReader(this._sql, this.position);

  final String _sql;
  int position;

  static const _quote = 0x27; // '
  static const _backslash = 0x5C; // \
  static const _openParen = 0x28;
  static const _closeParen = 0x29;
  static const _comma = 0x2C;
  static const _semicolon = 0x3B;

  /// MySQL's backslash escapes.
  static const _escapes = {
    0x30: '\u0000', // \0
    0x62: '\b', // \b
    0x6E: '\n', // \n
    0x72: '\r', // \r
    0x74: '\t', // \t
    0x5A: '\u001A', // \Z
  };

  int get _char => _sql.codeUnitAt(position);

  Iterable<List<String?>> rows() sync* {
    while (true) {
      _skipWhitespaceAnd(_comma);
      if (position >= _sql.length) {
        throw const FormatException('Unterminated INSERT statement');
      }
      if (_char == _semicolon) {
        position++;
        return;
      }
      if (_char != _openParen) {
        throw FormatException('Expected "(" in VALUES list', _sql, position);
      }
      position++;
      yield _row();
    }
  }

  List<String?> _row() {
    final values = <String?>[];
    while (true) {
      _skipWhitespaceAnd(null);
      values.add(_char == _quote ? _string() : _literal());
      _skipWhitespaceAnd(null);
      switch (_char) {
        case _comma:
          position++;
        case _closeParen:
          position++;
          return values;
        default:
          throw FormatException('Malformed row', _sql, position);
      }
    }
  }

  String _string() {
    final buffer = StringBuffer();
    position++; // opening quote
    var runStart = position;
    while (true) {
      if (position >= _sql.length) {
        throw const FormatException('Unterminated string literal');
      }
      final c = _char;
      if (c == _backslash) {
        buffer.write(_sql.substring(runStart, position));
        final escaped = _sql.codeUnitAt(position + 1);
        buffer.write(_escapes[escaped] ?? String.fromCharCode(escaped));
        position += 2;
        runStart = position;
      } else if (c == _quote) {
        buffer.write(_sql.substring(runStart, position));
        // A doubled quote is an escaped quote.
        if (position + 1 < _sql.length &&
            _sql.codeUnitAt(position + 1) == _quote) {
          buffer.write("'");
          position += 2;
          runStart = position;
        } else {
          position++;
          return buffer.toString();
        }
      } else {
        position++;
      }
    }
  }

  String? _literal() {
    final start = position;
    while (_char != _comma && _char != _closeParen) {
      position++;
    }
    final text = _sql.substring(start, position).trim();
    return text == 'NULL' ? null : text;
  }

  void _skipWhitespaceAnd(int? extra) {
    while (position < _sql.length) {
      final c = _char;
      if (c == 0x20 || c == 0x0A || c == 0x0D || c == 0x09 || c == extra) {
        position++;
      } else {
        return;
      }
    }
  }
}
