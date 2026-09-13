import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// `TrufiPlannerConfig.maxTransfers` reaches the planner (#998) and a
/// three-bus itinerary survives the provider, the UI model and its JSON.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('convertToItinerary with three transit segments', () {
    const from = RoutingLocation(
      position: LatLng(0, -0.001),
      description: 'home',
    );
    const to = RoutingLocation(
      position: LatLng(0.000135, 0.061),
      description: 'work',
    );
    final start = DateTime(2026, 9, 11, 8);

    const a0 = GtfsStop(id: 'a0', name: 'a0', lat: 0, lon: 0);
    const a1 = GtfsStop(id: 'a1', name: 'a1', lat: 0, lon: 0.010);
    // Second bus boards 15 m north of a1 and alights at b2.
    const b0 = GtfsStop(id: 'b0', name: 'b0', lat: 0.000135, lon: 0.010);
    const b2 = GtfsStop(id: 'b2', name: 'b2', lat: 0.000135, lon: 0.040);
    // Third bus shares b2 and continues east.
    const c1 = GtfsStop(id: 'c1', name: 'c1', lat: 0.000135, lon: 0.060);

    GtfsRoute bus(String id, String name) => GtfsRoute(
      id: id,
      shortName: name,
      longName: 'line $id',
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

    final path = RoutingPath(
      originWalkDistance: 111,
      originStop: a0,
      segments: [
        segment(bus('A', '7'), [a0, a1]),
        segment(bus('B', '14'), [b0, b2]),
        segment(bus('C', '14b'), [b2, c1]),
      ],
      destinationStop: c1,
      destinationWalkDistance: 111,
      score: 0,
      transferWalkDistance: 15,
    );

    test('three BUS legs, a WALK only where the stops differ, 2 transfers', () {
      final itinerary = provider.convertToItinerary(path, from, to, start);
      expect(itinerary.legs.map((l) => l.mode), [
        'WALK',
        'BUS',
        'WALK',
        'BUS',
        'BUS',
        'WALK',
      ]);
      expect(itinerary.transfers, 2);
      expect(itinerary.legs.where((l) => l.transitLeg), hasLength(3));
      final walk = itinerary.legs[2];
      expect(walk.fromPlace?.stopId, 'a1');
      expect(walk.toPlace?.stopId, 'b0');
      expect(walk.distance, closeTo(15, 1));
      // The third bus boards where the second alights: no walk in between,
      // and it departs when the second arrives.
      expect(itinerary.legs[4].fromPlace?.stopId, 'b2');
      expect(itinerary.legs[4].startTime, itinerary.legs[3].endTime);
      expect(itinerary.walkDistance, closeTo(111 + 15 + 111, 1));
      // Legs are contiguous in time from start to end.
      for (var i = 1; i < itinerary.legs.length; i++) {
        expect(itinerary.legs[i].startTime, itinerary.legs[i - 1].endTime);
      }
      expect(itinerary.endTime, itinerary.legs.last.endTime);
    });

    test('survives the JSON round trip of the restored plan (#996)', () {
      final itinerary = provider.convertToItinerary(path, from, to, start);
      final json = jsonDecode(jsonEncode(itinerary.toJson()));
      final back = Itinerary.fromJson(json as Map<String, dynamic>);
      expect(back.legs.map((l) => l.mode), itinerary.legs.map((l) => l.mode));
      expect(back.transfers, 2);
      expect(
        back.legs.where((l) => l.transitLeg).map((l) => l.route?.shortName),
        ['7', '14', '14b'],
      );
      expect(back.legs[4].fromPlace?.stopId, 'b2');
      // Geometry travels as an encoded polyline (1e-5 precision).
      expect(back.legs[4].encodedPoints, itinerary.legs[4].encodedPoints);
      expect(
        back.legs[4].decodedPoints.length,
        itinerary.legs[4].decodedPoints.length,
      );
      for (var i = 0; i < back.legs[4].decodedPoints.length; i++) {
        expect(
          back.legs[4].decodedPoints[i].latitude,
          closeTo(itinerary.legs[4].decodedPoints[i].latitude, 1e-5),
        );
        expect(
          back.legs[4].decodedPoints[i].longitude,
          closeTo(itinerary.legs[4].decodedPoints[i].longitude, 1e-5),
        );
      }
      expect(back.walkDistance, itinerary.walkDistance);
      expect(back.duration, itinerary.duration);
    });

    test('the grouper keeps three-slot itineraries and counts their legs', () {
      final itinerary = provider.convertToItinerary(path, from, to, start);
      // A second itinerary differing only in the LAST bus is an alternative
      // of the same first-bus decision — one group, two options.
      final alt = provider.convertToItinerary(
        RoutingPath(
          originWalkDistance: 111,
          originStop: a0,
          segments: [
            segment(bus('A', '7'), [a0, a1]),
            segment(bus('B', '14'), [b0, b2]),
            segment(bus('D', '24'), [b2, c1]),
          ],
          destinationStop: c1,
          destinationWalkDistance: 111,
          score: 0,
          transferWalkDistance: 15,
        ),
        from,
        to,
        start,
      );
      final groups = groupItineraries([itinerary, alt]);
      expect(groups, hasLength(1));
      expect(groups.single.alternatives, hasLength(2));
      expect(
        groups.single.representative.legs.where((l) => l.transitLeg),
        hasLength(3),
      );
      // Three slots: the last one offers both final buses.
      expect(groups.single.slotRoutes, hasLength(3));
      expect(
        groups.single.slotRoutes[2].map((r) => r.shortName),
        containsAll(['14b', '24']),
      );
      // A two-bus itinerary on the same first bus is a different profile.
      final twoBuses = provider.convertToItinerary(
        RoutingPath(
          originWalkDistance: 111,
          originStop: a0,
          segments: [
            segment(bus('A', '7'), [a0, a1]),
            segment(bus('E', '9'), [a1, c1]),
          ],
          destinationStop: c1,
          destinationWalkDistance: 111,
          score: 0,
        ),
        from,
        to,
        start,
      );
      expect(groupItineraries([itinerary, alt, twoBuses]), hasLength(2));
    });
  });

  group('TrufiPlannerConfig.maxTransfers', () {
    test('defaults to 1 in both modes', () {
      expect(
        const TrufiPlannerConfig.local(gtfsAsset: 'a.zip').maxTransfers,
        1,
      );
      expect(
        const TrufiPlannerConfig.remote(serverUrl: 'https://p').maxTransfers,
        1,
      );
    });

    test('is configurable', () {
      const config = TrufiPlannerConfig.local(
        gtfsAsset: 'a.zip',
        maxTransfers: 2,
      );
      expect(config.maxTransfers, 2);
      expect(
        const TrufiPlannerConfig.local(
          gtfsAsset: 'a.zip',
          maxTransfers: 0,
        ).maxTransfers,
        0,
      );
    });

    test('rejects a negative limit', () {
      expect(
        () => TrufiPlannerConfig.local(gtfsAsset: 'a.zip', maxTransfers: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('end to end: the config limit reaches the planner', () {
    // The planner package's cut of the Sana'a feed with the reporter's
    // two-transfer pair (#998), served through a mocked asset bundle so the
    // provider preloads exactly as in the app (worker isolate included).
    const asset = 'assets/routing/test.gtfs.zip';
    final fixture = File(
      '../trufi_core_planner/test/fixtures/sanaa_issue2_two_transfers_mini.gtfs.zip',
    );
    const from = RoutingLocation(
      position: LatLng(15.28064, 44.24430),
      description: 'جولة دار سلم',
    );
    const to = RoutingLocation(
      position: LatLng(15.37844, 44.20752),
      description: 'الحصبه هايبر ماركت',
    );
    late Uint8List zip;

    setUpAll(() {
      expect(
        fixture.existsSync(),
        isTrue,
        reason:
            'run from packages/trufi_core_routing: ${fixture.absolute.path}',
      );
      zip = fixture.readAsBytesSync();
    });

    setUp(() {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            final key = utf8.decode(
              message!.buffer.asUint8List(
                message.offsetInBytes,
                message.lengthInBytes,
              ),
            );
            return key == asset ? ByteData.sublistView(zip) : null;
          });
    });

    tearDown(() {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    Future<Plan> planWith({required int maxTransfers}) async {
      final provider = TrufiPlannerProvider(
        config: TrufiPlannerConfig.local(
          gtfsAsset: asset,
          maxWalkingDistance: 1500,
          maxTransfers: maxTransfers,
          persistIndex: false,
        ),
      );
      await provider.initialize();
      expect(provider.isLoaded, isTrue, reason: provider.errorMessage);
      return provider.fetchPlan(
        from: from,
        to: to,
        dateTime: DateTime(2026, 9, 11, 8),
      );
    }

    test('default (1): the trip has no transit itinerary — as today', () async {
      final plan = await planWith(maxTransfers: 1);
      expect(
        plan.itineraries!.where((i) => i.legs.any((l) => l.transitLeg)),
        isEmpty,
      );
    });

    test('maxTransfers 2: a three-bus itinerary with its two walks', () async {
      final plan = await planWith(maxTransfers: 2);
      final transit = plan.itineraries!
          .where((i) => i.legs.any((l) => l.transitLeg))
          .toList();
      expect(transit, isNotEmpty);
      final top = transit.first;
      expect(top.transfers, 2);
      final buses = top.legs.where((l) => l.transitLeg).toList();
      expect(buses.map((l) => l.route?.shortName), ['7', '14', '14']);
      expect(buses.map((l) => l.route?.gtfsId), [
        '19985848',
        '18800916',
        '19954455',
      ]);
      // WALK, BUS, WALK (8 m), BUS, WALK (73 m), BUS, WALK.
      expect(top.legs.map((l) => l.mode), [
        'WALK',
        'BUS',
        'WALK',
        'BUS',
        'WALK',
        'BUS',
        'WALK',
      ]);
      expect(top.legs[2].distance, closeTo(8, 2));
      expect(top.legs[4].distance, closeTo(73, 3));
      for (final bus in buses) {
        expect(bus.decodedPoints.length, greaterThan(2));
        expect(bus.tripPatternId, contains('#'));
      }
    });
  });
}
