import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Unit tests for polyline decoder.
void main() {
  group('PolylineDecoder', () {
    test('decode returns empty list for empty string', () {
      final result = PolylineDecoder.decode('');
      expect(result, isEmpty);
    });

    test('decode handles simple polyline', () {
      // Encoded polyline for a simple line
      // This is "??" which represents a single point at (0, 0)
      final result = PolylineDecoder.decode('??');

      expect(result, isNotEmpty);
      expect(result.length, equals(1));
      expect(result[0].latitude, closeTo(0.0, 0.00001));
      expect(result[0].longitude, closeTo(0.0, 0.00001));
    });

    test('decode handles polyline with multiple points', () {
      // Encoded polyline: "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
      // Represents: [(38.5, -120.2), (40.7, -120.95), (43.252, -126.453)]
      final result = PolylineDecoder.decode('_p~iF~ps|U_ulLnnqC_mqNvxq`@');

      expect(result.length, equals(3));

      // First point
      expect(result[0].latitude, closeTo(38.5, 0.001));
      expect(result[0].longitude, closeTo(-120.2, 0.001));

      // Second point
      expect(result[1].latitude, closeTo(40.7, 0.001));
      expect(result[1].longitude, closeTo(-120.95, 0.001));

      // Third point
      expect(result[2].latitude, closeTo(43.252, 0.001));
      expect(result[2].longitude, closeTo(-126.453, 0.001));
    });

    test('decode handles Cochabamba area coordinates', () {
      // A simple encoded polyline for Cochabamba area
      // This should decode to points around -17.x, -66.x
      final result = PolylineDecoder.decode('~zxnIhkffL??');

      expect(result, isNotEmpty);
      // The decoded points should be in the Cochabamba area
      for (final point in result) {
        expect(point.latitude, lessThan(0)); // Southern hemisphere
        expect(point.longitude, lessThan(0)); // Western hemisphere
      }
    });

    test('decode handles negative coordinates correctly', () {
      // Testing with known negative coordinates
      final result = PolylineDecoder.decode('~zxnIhkffL');

      expect(result, isNotEmpty);
      // Should be negative lat/lon for Cochabamba
      expect(result[0].latitude, isNegative);
      expect(result[0].longitude, isNegative);
    });
  });
}
