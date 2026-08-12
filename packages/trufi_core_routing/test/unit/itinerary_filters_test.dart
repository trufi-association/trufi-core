import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

Leg _leg(String mode, {bool transit = true}) => Leg(
  mode: mode,
  startTime: DateTime(2026, 8, 12, 8),
  endTime: DateTime(2026, 8, 12, 8, 30),
  duration: const Duration(minutes: 30),
  distance: 3000,
  transitLeg: transit,
);

Itinerary _itinerary(List<Leg> legs) => Itinerary(
  legs: legs,
  startTime: DateTime(2026, 8, 12, 8),
  endTime: DateTime(2026, 8, 12, 9),
  walkTime: const Duration(minutes: 5),
  duration: const Duration(hours: 1),
  walkDistance: 400,
);

void main() {
  group('filterMaxTransitLegs', () {
    final twoBuses = _itinerary([
      _leg('WALK', transit: false),
      _leg('BUS'),
      _leg('BUS'),
      _leg('WALK', transit: false),
    ]);
    final threeBuses = _itinerary([_leg('BUS'), _leg('BUS'), _leg('BUS')]);
    final walkOnly = _itinerary([_leg('WALK', transit: false)]);

    test('drops rides with more than two vehicles; walks do not count', () {
      expect(
        filterMaxTransitLegs([twoBuses, threeBuses, walkOnly]),
        [twoBuses, walkOnly],
      );
    });

    test('fail-open: keeps everything when nothing passes the cap', () {
      // A city where two vehicles genuinely can't cover the trip: long
      // chains beat "no routes found".
      expect(filterMaxTransitLegs([threeBuses]), [threeBuses]);
    });

    test('cap is configurable', () {
      expect(
        filterMaxTransitLegs([twoBuses, threeBuses], maxTransitLegs: 3),
        [twoBuses, threeBuses],
      );
    });
  });
}
