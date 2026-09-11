import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

/// Regression for trufi-sanaa#2 (second reopening, #998): the reporter's
/// trip جولة دار سلم → الحصبه هايبر ماركت answered "no routes" on v5.25.0
/// while OpenTripPlanner on the same GTFS returned three itineraries, all
/// with two transfers. No line serves both ends and no pair of lines meets
/// in between: the minimum is two changes of bus.
///
/// The fixture is a cut of the bundled Sana'a feed with the eleven routes
/// involved in OTP's chains and their neighbours (five named "7", five
/// named "14", one "7/14" — above `sameNameRouteLimit`, so each is its own
/// line as in the full feed). With the default limit of one transfer the
/// engine still finds nothing; with two it reproduces OTP's first
/// itinerary stop for stop: 7 `19985848` → 8 m → 14 `18800916` → 73 m →
/// 14 `19954455`, and the reverse trip 7 → 7/14 → 7 (OTP's second).
void main() {
  late GtfsData data;
  late GtfsSpatialIndex spatial;
  late GtfsRouteIndex index;
  final file = File('test/fixtures/sanaa_issue2_two_transfers_mini.gtfs.zip');

  setUpAll(() async {
    expect(
      file.existsSync(),
      isTrue,
      reason: 'run from the package root: ${file.absolute.path}',
    );
    data = await GtfsParser.parseFromFile(file.path);
    spatial = GtfsSpatialIndex(data.stops);
    index = GtfsRouteIndex(data, spatialIndex: spatial);
  });

  // The reporter's coordinates, verbatim from the issue comment.
  const darSalm = LatLng(15.28064, 44.24430); // جولة دار سلم
  const hasaba = LatLng(15.37844, 44.20752); // الحصبه هايبر ماركت

  /// The app's parameters (`TrufiPlannerConfig.local(maxWalkingDistance:
  /// 1500)`, pool 150, 5 itineraries) with the transfer limit under test.
  List<RoutingPath> plan(LatLng from, LatLng to, {required int maxTransfers}) {
    final service = GtfsRoutingService(
      data: data,
      spatialIndex: spatial,
      routeIndex: index,
    );
    return service.findRoutes(
      origin: from,
      destination: to,
      maxWalkDistance: 1500,
      maxResults: 5,
      maxStopCandidates: 150,
      maxDirects: 5,
      maxTransferPaths: 5,
      maxTransfers: maxTransfers,
    );
  }

  List<String> chain(RoutingPath p) =>
      p.segments.map((s) => s.route.id).toList();

  group('fixture', () {
    test('eleven routes, every short name above the same-name limit', () {
      expect(data.routes, hasLength(11));
      expect(data.routes.values.where((r) => r.shortName == '7'), hasLength(5));
      expect(
        data.routes.values.where((r) => r.shortName == '14'),
        hasLength(5),
      );
      // Distinct lines: "14 → 14" must be allowed to connect.
      expect(
        index.lineKeyForRoute('18800916'),
        isNot(index.lineKeyForRoute('19954455')),
      );
    });
  });

  group('default limit (1 transfer) — what v5.25.0 answers', () {
    test('forward: no routes', () {
      expect(plan(darSalm, hasaba, maxTransfers: 1), isEmpty);
    });

    test('reverse: no routes', () {
      expect(plan(hasaba, darSalm, maxTransfers: 1), isEmpty);
    });
  });

  group('maxTransfers: 2', () {
    test('forward reproduces OTP\'s 7 → 14 → 14 stop for stop', () {
      final paths = plan(darSalm, hasaba, maxTransfers: 2);
      expect(paths, isNotEmpty);
      final top = paths.first;
      expect(chain(top), ['19985848', '18800916', '19954455']);
      expect(top.segments.map((s) => s.route.shortName), ['7', '14', '14']);
      expect(top.transfers, 2);
      // Alight the 7 on شارع تعز and board the 14 across the street, 8 m.
      expect(top.segments[0].toStop.id, '1223812364');
      expect(top.segments[1].fromStop.id, '11789489571');
      // Alight the first 14 on شارع الستين, 73 m to the second 14.
      expect(top.segments[1].toStop.id, '588459651');
      expect(top.segments[2].fromStop.id, '588459648');
      expect(top.segments[2].toStop.id, '1634764477');
      expect(top.transferWalkDistance, closeTo(81, 2));
      expect(top.destinationWalkDistance, closeTo(136, 1));
      expect(top.totalTransitDistance, closeTo(17800, 50));
      expect(
        top.totalWalkDistance,
        top.originWalkDistance +
            top.destinationWalkDistance +
            top.transferWalkDistance,
      );
      // Segments are resolved like every other result: stop lists and
      // shape geometry per leg, indices recorded.
      for (final s in top.segments) {
        expect(s.stops.first.id, s.fromStop.id);
        expect(s.stops.last.id, s.toStop.id);
        expect(s.stops, hasLength(s.stopCount));
        expect(s.shapePoints.length, greaterThan(2));
        expect(s.fromIdx, s.pattern.indexOfStop(s.fromStop.id));
        expect(s.toIdx, s.pattern.indexOfStop(s.toStop.id));
      }
    });

    test(
      'forward offers the alternative through the other 14, ranked after',
      () {
        final paths = plan(darSalm, hasaba, maxTransfers: 2);
        expect(paths, hasLength(2));
        expect(chain(paths[1]), ['19985848', '18904090', '19954455']);
        expect(paths[1].score, greaterThan(paths[0].score));
      },
    );

    test('reverse reproduces OTP\'s second chain mirrored: 7 → 7/14 → 7', () {
      final paths = plan(hasaba, darSalm, maxTransfers: 2);
      expect(paths, isNotEmpty);
      final top = paths.first;
      expect(chain(top), ['20083001', '19955711', '19985849']);
      expect(top.segments.map((s) => s.route.shortName), ['7', '7/14', '7']);
      expect(top.transfers, 2);
      // The second transfer happens at a genuinely shared stop.
      expect(top.segments[1].toStop.id, '504469874');
      expect(top.segments[2].fromStop.id, '504469874');
      expect(top.transferWalkDistance, closeTo(99, 2));
    });

    test('every returned itinerary has exactly two transfers', () {
      for (final trip in [(darSalm, hasaba), (hasaba, darSalm)]) {
        for (final p in plan(trip.$1, trip.$2, maxTransfers: 2)) {
          expect(p.transfers, 2);
          expect(p.segments, hasLength(3));
        }
      }
    });

    test('maxTransfers: 3 gives the same answer (fewest transfers win)', () {
      for (final trip in [(darSalm, hasaba), (hasaba, darSalm)]) {
        final two = plan(trip.$1, trip.$2, maxTransfers: 2);
        final three = plan(trip.$1, trip.$2, maxTransfers: 3);
        expect(three.map(chain), two.map(chain));
        expect(three.map((p) => p.score), two.map((p) => p.score));
      }
    });

    test('LocalPlannerClient passes the limit through', () async {
      final client = LocalPlannerClient()
        ..loadFromBytes(file.readAsBytesSync());
      expect(
        await client.findRoutes(
          origin: darSalm,
          destination: hasaba,
          maxWalkDistance: 1500,
        ),
        isEmpty,
        reason: 'client default is 1',
      );
      final paths = await client.findRoutes(
        origin: darSalm,
        destination: hasaba,
        maxWalkDistance: 1500,
        maxTransfers: 2,
      );
      expect(
        paths.map((p) => chain(p).join('>')),
        contains('19985848>18800916>19954455'),
      );
    });
  });

  group('regression: trips that already plan are untouched by the limit', () {
    // The four pairs of the first reopening (#992) on that fixture, all
    // answered with one transfer today. Raising the limit must not change
    // a byte of them — phase 3 only runs on an empty result.
    late GtfsData data992;
    late GtfsSpatialIndex spatial992;
    late GtfsRouteIndex index992;
    final file992 = File('test/fixtures/sanaa_issue2_mini.gtfs.zip');
    const cases = <(LatLng, LatLng)>[
      (LatLng(15.29408, 44.26392), LatLng(15.33736, 44.19833)),
      (LatLng(15.33736, 44.19833), LatLng(15.29408, 44.26392)),
      (LatLng(15.2952334, 44.2623529), LatLng(15.3536032, 44.1786948)),
      (LatLng(15.3536032, 44.1786948), LatLng(15.2952334, 44.2623529)),
    ];

    setUpAll(() async {
      data992 = await GtfsParser.parseFromFile(file992.path);
      spatial992 = GtfsSpatialIndex(data992.stops);
      index992 = GtfsRouteIndex(data992, spatialIndex: spatial992);
    });

    String signature(List<RoutingPath> paths) => paths
        .map(
          (p) =>
              '${p.originStop.id}>'
              '${p.segments.map((s) => '${s.route.id}/${s.pattern.id}/${s.fromIdx}-${s.toIdx}').join('+')}'
              '>${p.destinationStop.id}@${p.score.toStringAsFixed(6)}',
        )
        .join('|');

    test('maxTransfers 1, 2 and 3 return identical lists; phase 3 idle', () {
      final service = GtfsRoutingService(
        data: data992,
        spatialIndex: spatial992,
        routeIndex: index992,
      );
      for (final (from, to) in cases) {
        List<RoutingPath> run(int maxTransfers) => service.findRoutes(
          origin: from,
          destination: to,
          maxWalkDistance: 1500,
          maxResults: 5,
          maxStopCandidates: 150,
          maxDirects: 5,
          maxTransferPaths: 5,
          maxTransfers: maxTransfers,
        );
        final base = run(1);
        expect(base, isNotEmpty);
        expect(signature(run(2)), signature(base));
        expect(signature(run(3)), signature(base));
      }
      expect(service.multiTransferSearches, 0);
    });
  });
}
