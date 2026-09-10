import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// `TrufiPlannerProvider.convertToItinerary` must emit a WALK leg between
/// two transit segments when the rider alights at one stop and boards at
/// another (walkable transfer, trufi-sanaa#2). Without it the map drew the
/// itinerary jumping between the two stops and the summary hid the walk.
void main() {
  const from = RoutingLocation(
    position: LatLng(0, -0.001),
    description: 'home',
  );
  const to = RoutingLocation(
    position: LatLng(0.000135, 0.041),
    description: 'work',
  );
  final start = DateTime(2026, 9, 9, 8);

  const a0 = GtfsStop(id: 'a0', name: 'a0', lat: 0, lon: 0);
  const a1 = GtfsStop(id: 'a1', name: 'a1', lat: 0, lon: 0.010);
  // 15 m north of a1.
  const b0 = GtfsStop(id: 'b0', name: 'b0', lat: 0.000135, lon: 0.010);
  const b2 = GtfsStop(id: 'b2', name: 'b2', lat: 0.000135, lon: 0.040);

  const routeA = GtfsRoute(
    id: 'A',
    shortName: '7',
    longName: 'A',
    type: GtfsRouteType.bus,
  );
  const routeB = GtfsRoute(
    id: 'B',
    shortName: '7',
    longName: 'B',
    type: GtfsRouteType.bus,
  );

  RoutingSegment segment(GtfsRoute route, List<GtfsStop> stops) =>
      RoutingSegment(
        route: route,
        fromStop: stops.first,
        toStop: stops.last,
        stopCount: stops.length,
        stops: stops,
        pattern: RoutePattern(
          routeId: route.id,
          stopIds: stops.map((s) => s.id).toList(),
        ),
        transitDistance: 1000,
        scheduledDuration: const Duration(minutes: 5),
      );

  final provider = TrufiPlannerProvider(
    config: const TrufiPlannerConfig.local(gtfsAsset: 'assets/unused.zip'),
  );

  test('walkable transfer: a WALK leg joins the alight and boarding stops', () {
    final path = RoutingPath(
      originWalkDistance: 111,
      originStop: a0,
      segments: [
        segment(routeA, [a0, a1]),
        segment(routeB, [b0, b2]),
      ],
      destinationStop: b2,
      destinationWalkDistance: 111,
      score: 0,
      transferWalkDistance: 15,
    );

    final itinerary = provider.convertToItinerary(path, from, to, start);

    expect(itinerary.legs.map((l) => l.mode), [
      'WALK',
      'BUS',
      'WALK',
      'BUS',
      'WALK',
    ]);
    final walk = itinerary.legs[2];
    expect(walk.transitLeg, isFalse);
    expect(walk.fromPlace?.stopId, 'a1');
    expect(walk.toPlace?.stopId, 'b0');
    expect(walk.distance, closeTo(15, 1));
    expect(walk.decodedPoints, [a1.position, b0.position]);
    expect(walk.duration.inSeconds, closeTo(15 / 1.2, 1));
    // Legs are contiguous in time: the second bus departs after the walk.
    expect(walk.startTime, itinerary.legs[1].endTime);
    expect(itinerary.legs[3].startTime, walk.endTime);
    expect(itinerary.walkDistance, closeTo(111 + 15 + 111, 1));
    expect(itinerary.transfers, 1);
  });

  test('shared-stop transfer: no walk leg is inserted', () {
    final path = RoutingPath(
      originWalkDistance: 111,
      originStop: a0,
      segments: [
        segment(routeA, [a0, a1]),
        segment(routeB, [a1, b2]),
      ],
      destinationStop: b2,
      destinationWalkDistance: 111,
      score: 0,
    );

    final itinerary = provider.convertToItinerary(path, from, to, start);

    expect(itinerary.legs.map((l) => l.mode), ['WALK', 'BUS', 'BUS', 'WALK']);
    expect(itinerary.walkDistance, closeTo(222, 1));
    expect(itinerary.legs[2].startTime, itinerary.legs[1].endTime);
  });
}
