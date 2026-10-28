import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/transit_route/transit_info.dart';
import 'package:trufi_core/base/utils/colors/route_color.dart';

// trufi-arequipa#77: a feed colour that would vanish on the white tiles
// falls back to the mode's colour, in every model that reads route_color.
void main() {
  group('parseRouteColor', () {
    test('a brand colour is used as given', () {
      expect(parseRouteColor('0061D0'), const Color(0xFF0061D0));
      expect(parseRouteColor('#0061D0'), const Color(0xFF0061D0));
    });
    test('none, unparsable, three digits, white and near white are null', () {
      expect(parseRouteColor(null), isNull);
      expect(parseRouteColor('zzzzzz'), isNull);
      expect(parseRouteColor('FFF'), isNull);
      expect(parseRouteColor('FFFFFF'), isNull);
      expect(parseRouteColor('FAFAFA'), isNull);
    });
    test('the threshold leaves the feed\'s lightest brand colour alone', () {
      // FEDD00, Arequipa's lightest operator colour: luminance about 0.73.
      expect(parseRouteColor('FEDD00'), const Color(0xFFFEDD00));
    });
  });

  group('TransitInfo (route list)', () {
    TransitInfo info(String? color) =>
        TransitInfo(shortName: 'C9', mode: TransportMode.bus, color: color);
    test('white falls back to the mode', () {
      expect(info('FFFFFF').backgroundColor, TransportMode.bus.backgroundColor);
      expect(info(null).backgroundColor, TransportMode.bus.backgroundColor);
      expect(info('0061D0').backgroundColor, const Color(0xFF0061D0));
    });
  });

  group('TransportRoute (planner polyline, chips)', () {
    test('white falls back to the mode in both colours', () {
      final white =
          TransportRoute(id: 'r', mode: TransportMode.bus, color: 'FFFFFF');
      expect(white.backgroundColor, TransportMode.bus.backgroundColor);
      expect(white.primaryColor, TransportMode.bus.color);
      final brand =
          TransportRoute(id: 'r', mode: TransportMode.bus, color: '0061D0');
      expect(brand.backgroundColor, const Color(0xFF0061D0));
    });
  });
}
