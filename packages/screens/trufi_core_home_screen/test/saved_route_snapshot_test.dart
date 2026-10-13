import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

// #1005: the saved route keeps a snapshot of the itinerary it was saved
// from, so the Your Routes card can show the same badges and summary the
// results did.

void main() {
  routing.Leg walk() => routing.Leg(
    mode: 'WALK',
    startTime: DateTime(2026, 10, 13, 8),
    endTime: DateTime(2026, 10, 13, 8, 5),
    duration: const Duration(minutes: 5),
    distance: 400,
    transitLeg: false,
  );

  routing.Leg bus(String name, String? color) => routing.Leg(
    mode: 'BUS',
    startTime: DateTime(2026, 10, 13, 8, 5),
    endTime: DateTime(2026, 10, 13, 8, 15),
    duration: const Duration(minutes: 10),
    distance: 2300,
    transitLeg: true,
    route: routing.Route(gtfsId: '1:$name', shortName: name, color: color),
    shortName: name,
  );

  routing.Itinerary itinerary(List<routing.Leg> legs) => routing.Itinerary(
    legs: legs,
    startTime: DateTime(2026, 10, 13, 8),
    endTime: DateTime(2026, 10, 13, 8, 30),
    walkTime: const Duration(minutes: 10),
    duration: const Duration(minutes: 30),
    walkDistance: 800,
  );

  test('keeps one entry per transit leg, in order, with the colour each '
      'badge showed', () {
    final trip = itinerary([
      walk(),
      bus('123', '7E57C2'),
      walk(),
      bus('106', ''),
    ]);

    final snapshot = savedRouteSnapshotFromItinerary(trip);

    expect(snapshot.transitLegs.map((l) => l.shortName), ['123', '106']);
    expect(snapshot.transitLegs.first.colorHex, '7E57C2');
    // An empty GTFS colour is replaced by the itinerary's default palette
    // when the Itinerary is built, so the saved badge matches the results.
    expect(snapshot.transitLegs.last.colorHex, 'E91E63');
    expect(snapshot.distanceMeters, trip.distance);
    expect(snapshot.distanceMeters, 5400);
    expect(snapshot.durationSeconds, 1800);
  });

  test('a walk-only itinerary has no transit legs', () {
    final snapshot = savedRouteSnapshotFromItinerary(itinerary([walk()]));

    expect(snapshot.transitLegs, isEmpty);
    expect(snapshot.distanceMeters, 400);
  });
}
