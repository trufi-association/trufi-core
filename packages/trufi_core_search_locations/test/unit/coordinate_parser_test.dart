import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// trufi-sanaa#22 — decimal latitude/longitude typed or pasted into the
/// search field. The parser is bounded: the whole input must be the pair.
void main() {
  ParsedCoordinates? parse(String input) => CoordinateParser.parse(input);

  group('the reporter\'s formats', () {
    test('comma and space (Google Maps)', () {
      expect(
        parse('15.294830, 44.2243701'),
        const ParsedCoordinates(15.294830, 44.2243701),
      );
    });

    test('comma without a space', () {
      expect(
        parse('15.294830,44.2243701'),
        const ParsedCoordinates(15.294830, 44.2243701),
      );
    });

    test('space only', () {
      expect(
        parse('15.29483 44.22437'),
        const ParsedCoordinates(15.29483, 44.22437),
      );
    });

    test('degree sign and hemisphere letters', () {
      expect(
        parse('15.33255° N, 44.19772° E'),
        const ParsedCoordinates(15.33255, 44.19772),
      );
    });

    test('negative pair (Cochabamba)', () {
      expect(parse('-17.39, -66.16'), const ParsedCoordinates(-17.39, -66.16));
    });
  });

  group('spelling tolerance', () {
    test('surrounding whitespace and one pair of parentheses', () {
      expect(
        parse('  (15.29483, 44.22437)  '),
        const ParsedCoordinates(15.29483, 44.22437),
      );
    });

    test('semicolon, tab and several spaces as separators', () {
      const expected = ParsedCoordinates(15.29483, 44.22437);
      expect(parse('15.29483;44.22437'), expected);
      expect(parse('15.29483 ; 44.22437'), expected);
      expect(parse('15.29483\t44.22437'), expected);
      expect(parse('15.29483   ,   44.22437'), expected);
    });

    test('explicit plus sign and integer or leading-dot values', () {
      expect(parse('+15, +44'), const ParsedCoordinates(15, 44));
      expect(parse('.5, -.25'), const ParsedCoordinates(0.5, -0.25));
    });

    test('hemisphere letters before or glued to the number, any case', () {
      const expected = ParsedCoordinates(15.33255, 44.19772);
      expect(parse('N 15.33255, E 44.19772'), expected);
      expect(parse('N15.33255 E44.19772'), expected);
      expect(parse('15.33255N,44.19772E'), expected);
      expect(parse('15.33255°N 44.19772°E'), expected);
      expect(parse('15.33255 n, 44.19772 e'), expected);
    });

    test('S and W negate', () {
      expect(
        parse('17.39° S, 66.16° W'),
        const ParsedCoordinates(-17.39, -66.16),
      );
      expect(parse('S 17.39 W 66.16'), const ParsedCoordinates(-17.39, -66.16));
    });

    test('degree look-alikes (ordinal indicator, ring above) count as °', () {
      expect(
        parse('15.33255º N, 44.19772º E'),
        const ParsedCoordinates(15.33255, 44.19772),
      );
      expect(
        parse('15.33255˚ N, 44.19772˚ E'),
        const ParsedCoordinates(15.33255, 44.19772),
      );
    });

    test('Unicode minus and en dash read as a minus sign', () {
      expect(
        parse('\u221217.39, \u221266.16'),
        const ParsedCoordinates(-17.39, -66.16),
      );
      expect(
        parse('\u201317.39, \u201366.16'),
        const ParsedCoordinates(-17.39, -66.16),
      );
    });

    test('no-break and thin spaces are spaces', () {
      expect(
        parse('15.29483,\u00a044.22437'),
        const ParsedCoordinates(15.29483, 44.22437),
      );
      expect(
        parse('15.29483\u202f44.22437'),
        const ParsedCoordinates(15.29483, 44.22437),
      );
    });
  });

  group('Arabic input', () {
    test('Arabic-Indic digits with the Arabic decimal separator and comma', () {
      // ١٥٫٢٩٤٨٣، ٤٤٫٢٢٤٣٧
      expect(
        parse(
          '\u0661\u0665\u066b\u0662\u0669\u0664\u0668\u0663\u060c '
          '\u0664\u0664\u066b\u0662\u0662\u0664\u0663\u0667',
        ),
        const ParsedCoordinates(15.29483, 44.22437),
      );
    });

    test('Arabic-Indic digits with ASCII punctuation', () {
      expect(
        parse('\u0661\u0665.\u0662\u0669, \u0664\u0664.\u0662\u0662'),
        const ParsedCoordinates(15.29, 44.22),
      );
    });

    test('Persian (extended Arabic-Indic) digits', () {
      // ۱۵٫۲۹, ۴۴٫۲۲
      expect(
        parse('\u06f1\u06f5\u066b\u06f2\u06f9, \u06f4\u06f4\u066b\u06f2\u06f2'),
        const ParsedCoordinates(15.29, 44.22),
      );
    });

    test('bidi marks copied along from an RTL UI are ignored', () {
      expect(
        parse('\u200f15.29483, 44.22437\u200e'),
        const ParsedCoordinates(15.29483, 44.22437),
      );
      expect(
        parse('\u202b15.29483\u202c, \u2066-44.22437\u2069'),
        const ParsedCoordinates(15.29483, -44.22437),
      );
    });

    test('fullwidth digits and comma', () {
      expect(
        parse('\uff11\uff15.\uff12\uff19\uff0c \uff14\uff14.\uff12\uff12'),
        const ParsedCoordinates(15.29, 44.22),
      );
    });
  });

  group('lat/lon order', () {
    test('latitude first by default', () {
      expect(parse('44.22, 15.29'), const ParsedCoordinates(44.22, 15.29));
    });

    test('longitude first only when the first value cannot be a latitude', () {
      expect(parse('120.5 10.25'), const ParsedCoordinates(10.25, 120.5));
      expect(parse('-100.5, 20'), const ParsedCoordinates(20, -100.5));
      expect(parse('179.99, -89.99'), const ParsedCoordinates(-89.99, 179.99));
    });

    test('a pair that fits both ways is read as written (latitude first)', () {
      // Cochabamba is (-17.39, -66.16); typed the other way round, -66.16
      // is still a legal latitude, so there is no safe way to swap it.
      expect(parse('-66.16, -17.39'), const ParsedCoordinates(-66.16, -17.39));
    });

    test('a hemisphere letter fixes the axis whatever the order', () {
      expect(
        parse('44.19772° E, 15.33255° N'),
        const ParsedCoordinates(15.33255, 44.19772),
      );
      expect(
        parse('66.16 W, 17.39 S'),
        const ParsedCoordinates(-17.39, -66.16),
      );
      // One letter is enough: the other value takes the remaining axis.
      expect(
        parse('44.19772 E, 15.33255'),
        const ParsedCoordinates(15.33255, 44.19772),
      );
      expect(
        parse('15.33255, 44.19772 E'),
        const ParsedCoordinates(15.33255, 44.19772),
      );
    });
  });

  group('decimal comma', () {
    test('accepted when the pair separator is unmistakable', () {
      expect(
        parse('15,29483 44,22437'),
        const ParsedCoordinates(15.29483, 44.22437),
      );
      expect(
        parse('15,29483, 44,22437'),
        const ParsedCoordinates(15.29483, 44.22437),
      );
      expect(parse('-17,39; -66,16'), const ParsedCoordinates(-17.39, -66.16));
      expect(
        parse('15,33255° N 44,19772° E'),
        const ParsedCoordinates(15.33255, 44.19772),
      );
    });

    test('rejected when the commas cannot be told apart', () {
      expect(parse('15,29483,44,22437'), isNull);
    });

    test('a comma with spaces around it is still the pair separator', () {
      expect(parse('15, 44'), const ParsedCoordinates(15, 44));
      expect(parse('15 , 44'), const ParsedCoordinates(15, 44));
    });
  });

  group('rejected input', () {
    test('empty, blank, a single number', () {
      expect(parse(''), isNull);
      expect(parse('   '), isNull);
      expect(parse('15.29483'), isNull);
      expect(parse('15.29483,'), isNull);
      expect(parse('-17.39°S'), isNull);
    });

    test('three numbers, a trailing altitude, DMS and DMM', () {
      expect(parse('15.29, 44.22, 2200'), isNull);
      expect(parse('15°17\'41.4"N 44°13\'27.7"E'), isNull);
      expect(parse('41 24.2028, 2 10.4418'), isNull);
    });

    test('text around or instead of the pair', () {
      expect(parse('ayacucho'), isNull);
      expect(parse('Calle 15, 4'), isNull);
      expect(parse('lat 15.29 lon 44.22'), isNull);
      expect(parse('15.29, 44.22 Sana\'a'), isNull);
      expect(parse('geo:15.29,44.22'), isNull);
      expect(parse('15.29.48, 44.22'), isNull);
      expect(parse('1e1, 44'), isNull);
    });

    test('out of range', () {
      expect(parse('90.0001, 95'), isNull); // neither order fits
      expect(parse('-91, -95'), isNull);
      expect(parse('15, 180.5'), isNull);
      expect(parse('15, -181'), isNull);
      expect(parse('200, 15'), isNull); // swapped, but 200 is no longitude
      expect(parse('95° N, 44° E'), isNull); // the letter does not rescue it
      expect(parse('15° N, 181° E'), isNull);
    });

    test('a first value beyond 90 with a second within 90 is the swapped '
        'reading, not an error', () {
      expect(parse('90.0001, 44'), const ParsedCoordinates(44, 90.0001));
      expect(parse('-91, 44'), const ParsedCoordinates(44, -91));
    });

    test('range edges are inclusive', () {
      expect(parse('90, 180'), const ParsedCoordinates(90, 180));
      expect(parse('-90, -180'), const ParsedCoordinates(-90, -180));
    });

    test('contradictory spellings', () {
      expect(parse('-15.3 S, 44 E'), isNull); // sign against the letter
      expect(parse('N 15 N, 44 E'), isNull); // letter on both sides
      expect(parse('15 N, 44 S'), isNull); // two latitudes
      expect(parse('15 E, 44 W'), isNull); // two longitudes
    });

    test('a hemisphere letter never stands alone', () {
      expect(parse('N, E'), isNull);
      expect(parse('15 N E'), isNull);
    });
  });

  group('format', () {
    test('five decimals, trailing zeros dropped', () {
      expect(
        CoordinateParser.format(15.294830, 44.2243701),
        '15.29483, 44.22437',
      );
      expect(CoordinateParser.format(15.3, 44.20000), '15.3, 44.2');
      expect(CoordinateParser.format(15, -66), '15, -66');
    });

    test('rounds, and a value that rounds to zero is never "-0"', () {
      expect(CoordinateParser.format(15.123456, 44.999999), '15.12346, 45');
      expect(CoordinateParser.format(-0.000001, 0), '0, 0');
    });

    test('decimals can be chosen', () {
      expect(
        CoordinateParser.format(15.294830, 44.2243701, decimals: 2),
        '15.29, 44.22',
      );
    });

    test('ParsedCoordinates.label is the default format', () {
      expect(parse('15.294830, 44.2243701')!.label, '15.29483, 44.22437');
    });
  });
}
