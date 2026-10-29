/// A latitude/longitude pair read out of a search query by
/// [CoordinateParser].
class ParsedCoordinates {
  final double latitude;
  final double longitude;

  const ParsedCoordinates(this.latitude, this.longitude);

  /// "15.29483, 44.22437": [CoordinateParser.format] with its defaults.
  String get label => CoordinateParser.format(latitude, longitude);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedCoordinates &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'ParsedCoordinates($latitude, $longitude)';
}

/// Recognises decimal latitude/longitude typed or pasted into the search
/// field (trufi-sanaa#22).
///
/// People get coordinates from Google Maps, OpenStreetMap, a GPS app or a
/// chat message and paste them as they came: `15.294830, 44.2243701`,
/// `15.29483 44.22437`, `15.33255° N, 44.19772° E`, `-17.39, -66.16`.
/// This parser accepts decimal degrees in those spellings and nothing
/// else, so the search screen can offer the point with no network and no
/// index. It is bounded on purpose: the whole input must be the pair, so
/// a street name that happens to contain numbers never turns into one.
///
/// Accepted:
/// - two numbers separated by a comma, a semicolon or whitespace, with an
///   optional sign, an optional `°` (also `º`, `˚`) and an optional
///   hemisphere letter (N/S/E/W, before or after the number); S and W
///   negate. One pair of surrounding parentheses is tolerated;
/// - order is latitude, longitude. A hemisphere letter fixes the axis of
///   its number; with no letters the pair is read as longitude, latitude
///   only when that is the sole reading in range (first `|value| > 90`,
///   second `|value| <= 90`);
/// - Arabic-Indic and Persian digits, the Arabic comma `،` and decimal
///   separator `٫` and the Unicode minus are normalised first, and bidi
///   control marks and zero-width characters dropped, so a pair copied
///   from an Arabic UI or a chat app parses as-is;
/// - a comma glued between digits is a decimal comma (`15,29483 44,22437`)
///   only when the text has no dot and the pair separator is unmistakable
///   (whitespace, or a comma next to a space).
///
/// Rejected (null): a single number, three or more numbers, values out of
/// range (`|lat| > 90`, `|lon| > 180`), a sign contradicting the hemisphere
/// letter (`-15.3 S`), a letter on both sides of a number (`N 15 N`), two
/// letters on the same axis (`15 N, 44 S`), degrees-minutes-seconds,
/// `geo:` URIs and any surrounding text.
abstract final class CoordinateParser {
  /// A decimal number: `15`, `15.29`, `.5`, `-66.16`, `+44`.
  static const _number = r'[+-]?(?:\d+(?:\.\d+)?|\.\d+)';

  /// Same, written with a decimal comma: `15,29483`.
  static const _commaNumber = r'[+-]?\d+,\d+';

  static const _hemisphere = r'[NSEW]';

  /// One number with its optional hemisphere letter, either before it
  /// (`N 15.3`, `N15.3`) or after it (`15.3 N`, `15.3° N`) — never both,
  /// so in `S 17.39 W 66.16` the `W` cannot be read as a suffix of the
  /// first number. Named groups cannot repeat, hence `num1`/`num2`.
  static String _component(String number, String prefix) =>
      '(?:'
      '(?<${prefix}pre>$_hemisphere)\\s*(?<${prefix}num1>$number)\\s*°?'
      '|'
      '(?<${prefix}num2>$number)\\s*°?\\s*(?<${prefix}post>$_hemisphere)?'
      ')';

  /// `<component> <separator> <component>` and nothing else.
  static final RegExp _pair = RegExp(
    '^${_component(_number, 'a')}'
    r'(?:\s*[,;]\s*|\s+)'
    '${_component(_number, 'b')}\$',
    caseSensitive: false,
  );

  /// The decimal-comma spelling: the separator must be visibly different
  /// from a decimal comma (whitespace, a semicolon, or a comma with a space
  /// on either side), otherwise `15,29483,44,22437` has two readings.
  static final RegExp _commaPair = RegExp(
    '^${_component(_commaNumber, 'a')}'
    r'(?:\s*;\s*|\s*,\s+|\s+,\s*|\s+)'
    '${_component(_commaNumber, 'b')}\$',
    caseSensitive: false,
  );

  /// Reads [input] as a coordinate pair, or returns null when it is not one.
  static ParsedCoordinates? parse(String input) {
    var text = _normalize(input);
    if (text.startsWith('(') && text.endsWith(')')) {
      text = text.substring(1, text.length - 1).trim();
    }
    if (text.isEmpty) return null;

    var decimalComma = false;
    var match = _pair.firstMatch(text);
    if (match == null && !text.contains('.')) {
      match = _commaPair.firstMatch(text);
      decimalComma = true;
    }
    if (match == null) return null;

    final first = _Component.from(match, 'a', decimalComma: decimalComma);
    final second = _Component.from(match, 'b', decimalComma: decimalComma);
    if (first == null || second == null) return null;
    if (first.axis != null && first.axis == second.axis) return null;

    final bool swapped;
    if (first.axis == _Axis.longitude || second.axis == _Axis.latitude) {
      swapped = true;
    } else if (first.axis == null && second.axis == null) {
      // No letters: latitude first, as Google Maps and OSM write it. The
      // other order is taken only when it is the only one that fits.
      swapped = first.value.abs() > 90 && second.value.abs() <= 90;
    } else {
      swapped = false;
    }
    final latitude = swapped ? second.value : first.value;
    final longitude = swapped ? first.value : second.value;
    if (latitude.abs() > 90 || longitude.abs() > 180) return null;
    return ParsedCoordinates(latitude, longitude);
  }

  /// "15.29483, 44.22437": [decimals] places (five is about a metre),
  /// trailing zeros dropped, never "-0".
  static String format(double latitude, double longitude, {int decimals = 5}) {
    String one(double value) {
      var s = value.toStringAsFixed(decimals);
      if (s.contains('.')) {
        s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
      }
      return s == '-0' ? '0' : s;
    }

    return '${one(latitude)}, ${one(longitude)}';
  }

  /// Characters that travel along with text copied from an RTL UI, a chat
  /// app or a web page and carry no meaning for the parser: bidi marks,
  /// embeddings and isolates, and the zero-width space and joiners. They
  /// would break the match, so they are dropped.
  static const _invisible = {
    0x200E, 0x200F, 0x061C, // LRM, RLM, ALM
    0x202A, 0x202B, 0x202C, 0x202D, 0x202E, // embeddings and overrides
    0x2066, 0x2067, 0x2068, 0x2069, // isolates
    0x200B, 0x200C, 0x200D, 0x2060, // ZWSP, ZWNJ, ZWJ, word joiner
    0xFEFF, // BOM / zero-width no-break space
  };

  /// ASCII digits, `.`, `,`, `;`, `-` and `°` for their localized or
  /// typographic look-alikes; everything else passes through unchanged.
  static String _normalize(String input) {
    final out = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        out.writeCharCode(0x30 + rune - 0x0660); // Arabic-Indic digits
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        out.writeCharCode(0x30 + rune - 0x06F0); // Extended (Persian) digits
      } else if (rune >= 0xFF10 && rune <= 0xFF19) {
        out.writeCharCode(0x30 + rune - 0xFF10); // fullwidth digits
      } else if (_invisible.contains(rune)) {
        continue;
      } else {
        out.write(switch (rune) {
          0x066B => '.', // Arabic decimal separator
          0x060C || 0xFF0C => ',', // Arabic comma, fullwidth comma
          0x061B => ';', // Arabic semicolon
          0x2212 || 0x2013 || 0xFE63 || 0xFF0D => '-', // minus, en dash
          0x00BA || 0x02DA => '°', // ordinal indicator, ring above
          0x00A0 || 0x202F || 0x2009 => ' ', // no-break and thin spaces
          _ => String.fromCharCode(rune),
        });
      }
    }
    return out.toString().trim();
  }
}

enum _Axis { latitude, longitude }

class _Component {
  final double value;
  final _Axis? axis;

  const _Component(this.value, this.axis);

  /// Reads the component named [prefix] from [match]. Null when the
  /// spelling contradicts itself: a minus sign together with a hemisphere
  /// letter.
  static _Component? from(
    RegExpMatch match,
    String prefix, {
    required bool decimalComma,
  }) {
    final letter =
        (match.namedGroup('${prefix}pre') ?? match.namedGroup('${prefix}post'))
            ?.toUpperCase();

    var digits =
        (match.namedGroup('${prefix}num1') ??
        match.namedGroup('${prefix}num2'))!;
    if (decimalComma) digits = digits.replaceFirst(',', '.');
    if (letter != null && digits.startsWith('-')) return null;
    var value = double.parse(digits);

    _Axis? axis;
    switch (letter) {
      case 'N':
        axis = _Axis.latitude;
      case 'S':
        axis = _Axis.latitude;
        value = -value;
      case 'E':
        axis = _Axis.longitude;
      case 'W':
        axis = _Axis.longitude;
        value = -value;
    }
    return _Component(value, axis);
  }
}
