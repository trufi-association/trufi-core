import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

Leg _transitLeg({Route? route}) => Leg(
      mode: 'BUS',
      startTime: DateTime(2026, 1, 1, 12),
      endTime: DateTime(2026, 1, 1, 12, 30),
      duration: const Duration(minutes: 30),
      distance: 1000,
      transitLeg: true,
      route: route,
    );

Itinerary _itinerary(List<Leg> legs) => Itinerary(
      legs: legs,
      startTime: DateTime(2026, 1, 1, 12),
      endTime: DateTime(2026, 1, 1, 13),
      walkTime: Duration.zero,
      duration: const Duration(hours: 1),
      walkDistance: 0,
    );

void main() {
  group('Itinerary default transit colors (#930)', () {
    test('a colorless transit leg never gets the my-location blue', () {
      final it = _itinerary([_transitLeg()]);
      final color = it.legs.first.route?.color;
      expect(color, isNotNull);
      expect(color!.isNotEmpty, isTrue);
      // 1976D2 read exactly like the location dot; 4285F4 is the dot itself.
      expect(color.toUpperCase(), isNot(anyOf('1976D2', '4285F4')));
    });

    test('FFFFFF (GTFS "no color" default) is treated as unset', () {
      final it = _itinerary([_transitLeg(route: const Route(color: 'FFFFFF'))]);
      final color = it.legs.first.route?.color;
      expect(color!.toUpperCase(), isNot('FFFFFF'));
    });

    test('two colorless legs get distinct palette colors', () {
      final it = _itinerary([
        _transitLeg(),
        _transitLeg(route: const Route(color: '')),
      ]);
      final first = it.legs[0].route?.color;
      final second = it.legs[1].route?.color;
      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first, isNot(second));
    });

    test('a real GTFS route_color is preserved', () {
      final it = _itinerary([_transitLeg(route: const Route(color: 'AB1234'))]);
      expect(it.legs.first.route?.color, 'AB1234');
    });
  });
}
