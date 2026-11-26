import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Navigation keeps the buses of the trip's routes whatever their position
/// (the rider's own bus and those ahead), and only separates directions when
/// both sides know the GTFS `direction_id`.
void main() {
  final t0 = DateTime(2026, 11, 26, 9);

  Leg busLeg(String route, {int? directionId}) => Leg(
    mode: 'BUS',
    startTime: t0,
    endTime: t0.add(const Duration(minutes: 30)),
    duration: const Duration(minutes: 30),
    distance: 5000,
    transitLeg: true,
    route: Route(gtfsId: '1:$route', shortName: route),
    fromPlace: const Place(name: 'stop', lat: -12.0464, lon: -77.0428),
    directionId: directionId,
  );

  Itinerary trip(List<Leg> legs) => Itinerary(
    legs: legs,
    startTime: t0,
    endTime: t0.add(const Duration(minutes: 30)),
    walkTime: Duration.zero,
    duration: const Duration(minutes: 30),
    walkDistance: 0,
  );

  VehiclePosition bus(
    String id,
    String route, {
    int? direction,
    double? heading,
  }) => VehiclePosition(
    vehicleId: id,
    // Far from the boarding stop and heading away from it.
    position: const TrufiLatLng(-12.10, -77.00),
    routeId: route,
    directionId: direction,
    heading: heading ?? 0,
    speed: 8,
  );

  List<String> ids(List<VehiclePosition> vs) => [
    for (final v in vs) v.vehicleId,
  ];

  test('keeps a bus of the trip\'s route wherever it is and heads', () {
    final kept = liveVehiclesOnTrip([
      bus('away', '1:7', heading: 200),
      bus('towards', '1:7', heading: 20),
      bus('other', '1:99'),
    ], trip([busLeg('7')]));

    expect(ids(kept), ['away', 'towards']);
  });

  test('the boarding-stop rule would have dropped the bus heading away', () {
    final vehicles = [bus('away', '1:7', heading: 200)];
    final itinerary = trip([busLeg('7')]);

    expect(liveVehiclesForTrip(vehicles, itinerary), isEmpty);
    expect(ids(liveVehiclesOnTrip(vehicles, itinerary)), ['away']);
  });

  test('matches routes without the feed prefix', () {
    final kept = liveVehiclesOnTrip([bus('v', '7')], trip([busLeg('7')]));

    expect(ids(kept), ['v']);
  });

  test('a known opposite direction is dropped; an unknown one is kept', () {
    final itinerary = trip([busLeg('7', directionId: 0)]);

    final kept = liveVehiclesOnTrip([
      bus('same', '1:7', direction: 0),
      bus('opposite', '1:7', direction: 1),
      bus('unknown', '1:7'),
    ], itinerary);

    expect(ids(kept), ['same', 'unknown']);
  });

  test('a leg without direction keeps both directions', () {
    final kept = liveVehiclesOnTrip([
      bus('a', '1:7', direction: 0),
      bus('b', '1:7', direction: 1),
    ], trip([busLeg('7')]));

    expect(ids(kept), ['a', 'b']);
  });

  test('no itinerary, or no transit leg: every vehicle', () {
    final vehicles = [bus('a', '1:7')];

    expect(liveVehiclesOnTrip(vehicles, null), vehicles);
    expect(liveVehiclesOnTrip(vehicles, trip(const [])), vehicles);
  });
}
