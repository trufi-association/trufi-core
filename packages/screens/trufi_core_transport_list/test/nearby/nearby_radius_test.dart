import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

void main() {
  test(
    'brackets are 100, 300 and 500 m and the query radius is the widest',
    () {
      expect(NearbyRadius.maxMeters, 500);
      expect(NearbyRadius.values.map((r) => r.meters), [100, 300, 500]);
      expect(NearbyRadius.largest, NearbyRadius.m500);
      expect(NearbyRadius.maxMeters, NearbyRadius.largest.meters);
    },
  );

  test('a bracket includes its upper bound and nothing beyond it', () {
    expect(NearbyRadius.m300.contains(300), isTrue);
    expect(NearbyRadius.m300.contains(300.1), isFalse);
    expect(NearbyRadius.m100.contains(100), isTrue);
    expect(NearbyRadius.m100.contains(0), isTrue);
    expect(NearbyRadius.m500.contains(500.5), isFalse);
  });
}
