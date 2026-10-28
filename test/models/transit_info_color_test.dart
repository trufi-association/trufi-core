import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/transit_route/transit_info.dart';

// trufi-arequipa#77: a feed colour that would vanish on the white tiles
// falls back to the mode's colour.
void main() {
  TransitInfo info(String? color) =>
      TransitInfo(shortName: 'C9', mode: TransportMode.bus, color: color);

  test('a brand colour is used as given', () {
    expect(info('0061D0').backgroundColor, const Color(0xFF0061D0));
  });

  test('no colour falls back to the mode', () {
    expect(info(null).backgroundColor, TransportMode.bus.backgroundColor);
  });

  test('white and near-white fall back to the mode', () {
    expect(info('FFFFFF').backgroundColor, TransportMode.bus.backgroundColor);
    expect(info('FAFAFA').backgroundColor, TransportMode.bus.backgroundColor);
  });

  test('an unparsable colour falls back to the mode', () {
    expect(info('zzzzzz').backgroundColor, TransportMode.bus.backgroundColor);
  });

  test('the threshold leaves light brand colours alone', () {
    // Pale yellow, luminance about 0.8: still a colour.
    expect(info('F0E68C').backgroundColor, const Color(0xFFF0E68C));
  });
}
