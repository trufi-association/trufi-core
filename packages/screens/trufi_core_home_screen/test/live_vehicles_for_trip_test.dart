import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/src/utils/live_vehicles_filter.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import 'support/vehicle_eta_fakes.dart';

/// trufi-lima#7: with a trip selected the map drew every bus of the trip's
/// routes, including those of the opposite direction and those already past
/// the boarding stop, so the rider saw buses that would never reach them.
/// A vehicle is kept only if its route is on the trip AND it can still reach
/// that leg's boarding stop (`RealtimeVehiclesEtaProvider.headsTowards`).
void main() {
  // Boarding stops A (route 1132) and B (route 1481), central Lima.
  const stopA = (lat: -12.0464, lon: -77.0428);
  const stopB = (lat: -12.0600, lon: -77.0300);

  final itineraryTwoBuses = itinerary([
    walkLeg(),
    busLeg('1132', stopLat: stopA.lat, stopLon: stopA.lon, directionId: 0),
    busLeg('1481', stopLat: stopB.lat, stopLon: stopB.lon, directionId: 1),
  ]);

  // ~1.5 km south-west of A and ~1.5 km north-east of B.
  const nearA = TrufiLatLng(-12.0580, -77.0540);
  const nearB = TrufiLatLng(-12.0480, -77.0170);

  double bearing(TrufiLatLng from, double lat, double lon) =>
      routing.bearingDegrees(from, TrufiLatLng(lat, lon));

  final towardsA = bearing(nearA, stopA.lat, stopA.lon);
  final towardsB = bearing(nearB, stopB.lat, stopB.lon);

  final v1 = VehiclePosition(
    vehicleId: 'V1',
    position: nearA,
    routeId: '1132',
    directionId: 0,
    heading: towardsA,
    speed: 8,
  );
  final v2 = VehiclePosition(
    vehicleId: 'V2',
    position: nearA,
    routeId: '1132',
    directionId: 1,
    heading: towardsA,
    speed: 8,
  );
  final v3 = VehiclePosition(
    vehicleId: 'V3',
    position: nearA,
    routeId: '1132',
    directionId: 0,
    heading: (towardsA + 180) % 360,
    speed: 8,
  );
  final v4 = VehiclePosition(vehicleId: 'V4', position: nearB, routeId: '1481');
  final v5 = VehiclePosition(
    vehicleId: 'V5',
    position: nearA,
    routeId: '1185',
    heading: towardsA,
    speed: 8,
  );
  final v6 = VehiclePosition(
    vehicleId: 'V6',
    position: nearB,
    routeId: '1:1481',
    directionId: 1,
    heading: towardsB,
    speed: 8,
  );
  final all = [v1, v2, v3, v4, v5, v6];

  List<String> ids(List<VehiclePosition> vs) =>
      vs.map((v) => v.vehicleId).toList();

  test('keeps only buses of the trip that can still reach the boarding '
      'stop', () {
    final kept = liveVehiclesForTrip(all, itineraryTwoBuses);

    expect(ids(kept), ['V1', 'V4', 'V6']);
  });

  test('no itinerary: every vehicle is returned unchanged '
      '(already true today)', () {
    expect(liveVehiclesForTrip(all, null), all);
  });

  test('an itinerary with only walk legs: every vehicle is returned '
      '(already true today)', () {
    expect(liveVehiclesForTrip(all, itinerary([walkLeg()])), all);
  });

  test('a transit leg without fromPlace matches by route only: a bus '
      'heading away, of the opposite direction, is kept '
      '(already true today)', () {
    final noBoardingPoint = itinerary([
      walkLeg(),
      busLeg('1132', stopId: null, directionId: 0),
    ]);

    final kept = liveVehiclesForTrip(all, noBoardingPoint);

    // V1 heads to A, V2 is of the other direction, V3 heads away: all 1132.
    // V4, V5 and V6 are other routes and stay out.
    expect(ids(kept), ['V1', 'V2', 'V3']);
  });

  test('the same route on two legs is the union of both: a bus heading to '
      'B but away from A is kept (already true today)', () {
    // On the A-B line, nearer B: heading to B means driving away from A.
    const between = TrufiLatLng(
      -12.0464 - 0.0136 * 0.7,
      -77.0428 + 0.0128 * 0.7,
    );
    final headingToB = VehiclePosition(
      vehicleId: 'VB',
      position: between,
      routeId: '1132',
      heading: bearing(between, stopB.lat, stopB.lon),
      speed: 8,
    );
    final legA = busLeg(
      '1132',
      stopId: 'A',
      stopLat: stopA.lat,
      stopLon: stopA.lon,
    );
    final legB = busLeg(
      '1132',
      stopId: 'B',
      stopLat: stopB.lat,
      stopLon: stopB.lon,
    );

    // Guard: with only leg A the bus is dropped, so the union is what keeps
    // it with both legs.
    expect(
      liveVehiclesForTrip([headingToB], itinerary([walkLeg(), legA])),
      isEmpty,
    );
    expect(
      ids(liveVehiclesForTrip([headingToB], itinerary([walkLeg(), legB]))),
      ['VB'],
    );
    expect(
      ids(
        liveVehiclesForTrip([headingToB], itinerary([walkLeg(), legA, legB])),
      ),
      ['VB'],
    );
  });
}
