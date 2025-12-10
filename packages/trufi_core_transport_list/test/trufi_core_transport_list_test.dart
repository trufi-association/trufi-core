import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

void main() {
  group('TransportRoute', () {
    test('displayName returns shortName when available', () {
      const route = TransportRoute(
        id: '1',
        code: 'R1',
        name: 'Route 1',
        shortName: '101',
      );
      expect(route.displayName, '101');
    });

    test('displayName returns name when shortName is null', () {
      const route = TransportRoute(
        id: '1',
        code: 'R1',
        name: 'Route 1',
      );
      expect(route.displayName, 'Route 1');
    });

    test('longNameLast extracts last segment', () {
      const route = TransportRoute(
        id: '1',
        code: 'R1',
        name: 'Route 1',
        longName: 'Terminal A → Terminal B',
      );
      expect(route.longNameLast, 'Terminal B');
    });
  });
}
