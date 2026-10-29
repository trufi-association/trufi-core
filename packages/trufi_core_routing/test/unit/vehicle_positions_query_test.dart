import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// #1017: an on-demand snapshot asks OTP for the requested routes only.
void main() {
  group('buildVehiclePositionsQuery', () {
    test('without ids it asks for every route', () {
      final q = buildVehiclePositionsQuery();
      expect(q, contains('routes {'));
      expect(q, isNot(contains('routes(ids')));
      expect(buildVehiclePositionsQuery(routeIds: {}), q);
      expect(buildVehiclePositionsQuery(routeIds: {' '}), q);
    });

    test('prefixed ids become routes(ids: [...])', () {
      final q = buildVehiclePositionsQuery(routeIds: {'1:1185', '1:1481'});
      expect(q, contains('routes(ids: ["1:1185", "1:1481"]) {'));
      expect(q, contains('vehiclePositions'));
    });

    test('an id without a feed prefix cannot be filtered: whole fleet', () {
      // OTP ids are feed:route; a bare "1185" would match nothing, so the
      // caller keeps matching feed-agnostically over the full answer.
      final q = buildVehiclePositionsQuery(routeIds: {'1:1185', '1481'});
      expect(q, isNot(contains('routes(ids')));
    });

    test('a colon at either end is not a feed prefix: whole fleet', () {
      for (final id in [':1185', '1185:']) {
        final q = buildVehiclePositionsQuery(routeIds: {id});
        expect(q, isNot(contains('routes(ids')), reason: id);
      }
    });

    test('quotes inside an id are escaped', () {
      final q = buildVehiclePositionsQuery(routeIds: {'1:a"b'});
      expect(q, contains(r'routes(ids: ["1:a\"b"]) {'));
    });
  });
}
