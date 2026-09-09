import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

import 'support/connection_tables.dart';

/// Regression for trufi-sanaa#2 (reopened): four real origin/destination
/// pairs from the reporter that the planner answered with "no routes".
///
/// The fixture is a cut of the bundled Sana'a feed with the ten routes
/// involved (their stops, stop_times, shapes and frequencies). It is built
/// per OSM relation, so 8 of the 10 routes carry `route_short_name` "7":
/// distinct lines, distinct terminals, one informal ref. The feed's stops
/// are OSM way nodes, so two lines crossing at a corner in opposite
/// directions rarely share a `stop_id`.
///
/// Two index rules hid every valid one-transfer itinerary:
///   1. only patterns sharing a `stop_id` were connected — the reverse
///      university trip needs a 15 m walk between two kerbs (case B-rev);
///   2. two routes with the same `route_short_name` were "the same line" and
///      never chained — every "7 → 7" transfer, i.e. the whole mall trip
///      (cases A-fwd / A-rev; A-rev even has a shared stop).
void main() {
  late GtfsData data;
  late GtfsSpatialIndex spatial;
  final file = File('test/fixtures/sanaa_issue2_mini.gtfs.zip');

  setUpAll(() async {
    expect(
      file.existsSync(),
      isTrue,
      reason: 'run from the package root: ${file.absolute.path}',
    );
    data = await GtfsParser.parseFromFile(file.path);
    spatial = GtfsSpatialIndex(data.stops);
  });

  // The reporter's coordinates, verbatim from the issue.
  const origin = LatLng(15.29408, 44.26392);
  const mall = LatLng(15.33736, 44.19833);
  const shareFrom = LatLng(15.2952334, 44.2623529);
  const university = LatLng(15.3536032, 44.1786948);

  final cases = <String, (LatLng, LatLng)>{
    'A-fwd origin → mall': (origin, mall),
    'A-rev mall → origin': (mall, origin),
    'B-fwd share link → university': (shareFrom, university),
    'B-rev university → share link': (university, shareFrom),
  };

  /// Same parameters the app wires through `LocalPlannerClient`
  /// (maxWalkingDistance 1500, maxItineraries 5, pool 150).
  List<RoutingPath> plan(
    GtfsRouteIndex index,
    (LatLng, LatLng) trip, {
    int maxTransferCandidates = GtfsRoutingService.defaultMaxTransferCandidates,
  }) {
    final service = GtfsRoutingService(
      data: data,
      spatialIndex: spatial,
      routeIndex: index,
      maxTransferCandidates: maxTransferCandidates,
    );
    return service.findRoutes(
      origin: trip.$1,
      destination: trip.$2,
      maxWalkDistance: 1500,
      maxResults: 5,
      maxStopCandidates: 150,
      maxDirects: 5,
      maxTransferPaths: 5,
    );
  }

  group('fixture', () {
    test('is the Sana\'a shape: ten routes, eight of them named "7"', () {
      expect(data.routes, hasLength(10));
      final sevens = data.routes.values.where((r) => r.shortName == '7');
      expect(sevens, hasLength(8));
      expect(
        data.routes.values.where((r) => r.shortName == '14'),
        hasLength(2),
      );
    });

    test('no case has a direct line — every answer needs a transfer', () {
      final index = GtfsRouteIndex(data, spatialIndex: spatial);
      for (final entry in cases.entries) {
        for (final path in plan(index, entry.value)) {
          expect(path.transfers, 1, reason: entry.key);
        }
      }
    });
  });

  group(
    'default index (100 m transfers, same name is one line only if ≤3 routes carry it)',
    () {
      late GtfsRouteIndex index;
      setUpAll(() => index = GtfsRouteIndex(data, spatialIndex: spatial));

      for (final entry in cases.entries) {
        test('${entry.key}: at least one itinerary', () {
          final paths = plan(index, entry.value);
          expect(paths, isNotEmpty);
        });
      }

      test('A-fwd: rides two different lines that are both called "7"', () {
        final paths = plan(index, cases['A-fwd origin → mall']!);
        final top = paths.first;
        expect(top.segments.map((s) => s.route.shortName), ['7', '7']);
        expect(top.segments[0].route.id, isNot(top.segments[1].route.id));
        // The transfer measured in the issue analysis: alight on طريق خولان
        // (597203117) and walk ~63 m to 6015583033 — two distinct stop ids.
        expect(top.segments[0].toStop.id, isNot(top.segments[1].fromStop.id));
        expect(top.transferWalkDistance, inInclusiveRange(1, 100));
        expect(
          top.totalWalkDistance,
          top.originWalkDistance +
              top.destinationWalkDistance +
              top.transferWalkDistance,
        );
      });

      test('A-rev: "7 → 7" as well, this time at a shared stop', () {
        final paths = plan(index, cases['A-rev mall → origin']!);
        expect(
          paths.map((p) => p.segments.map((s) => s.route.shortName)),
          everyElement(['7', '7']),
        );
        // At least one itinerary transfers at a genuinely shared stop_id —
        // the case that proves the same-name rule alone was blocking.
        expect(
          paths.any(
            (p) =>
                p.segments[0].toStop.id == p.segments[1].fromStop.id &&
                p.transferWalkDistance == 0,
          ),
          isTrue,
        );
      });

      test(
        'B-fwd: the "7 → 14" transfer at شارع تعز (shared stop) survives',
        () {
          // This is the one case that already worked on the device. In this
          // 597-stop cut the 150-candidate pool reaches farther than in the
          // full feed, so a "7 → 7" variant with a long final walk can outrank
          // it — what matters is that the known-good answer is still offered,
          // unchanged: same stops, same legs, no transfer walk.
          final paths = plan(index, cases['B-fwd share link → university']!);
          final known = paths.where(
            (p) =>
                p.segments.map((s) => s.route.id).join('>') ==
                '18800583>18800916',
          );
          expect(known, hasLength(1));
          final path = known.single;
          expect(path.segments.map((s) => s.route.shortName), ['7', '14']);
          expect(path.segments[0].toStop.id, '11789489571');
          expect(path.segments[1].fromStop.id, '11789489571');
          expect(path.transferWalkDistance, 0);
          expect(path.originWalkDistance, closeTo(407, 1));
          expect(path.destinationWalkDistance, closeTo(426, 1));
        },
      );

      test('B-rev: "14 → 7" alighting on one kerb and boarding 15 m away', () {
        final paths = plan(index, cases['B-rev university → share link']!);
        final top = paths.first;
        expect(top.segments.map((s) => s.route.shortName), ['14', '7']);
        expect(top.segments[0].toStop.id, '504469874');
        expect(top.segments[1].fromStop.id, '1223812364');
        expect(top.transferWalkDistance, inInclusiveRange(10, 20));
        // The second leg really starts at the boarding stop: its resolved
        // stop list begins there, not at the alight stop.
        expect(top.segments[1].stops.first.id, '1223812364');
        expect(
          top.segments[1].fromIdx,
          top.segments[1].pattern.indexOfStop('1223812364'),
        );
      });

      test('itineraries between different "7" routes are not collapsed', () {
        // Dedupe is by line, and with 8 routes named "7" each route is its
        // own line — so two "7 → 7" answers with different route ids may
        // coexist. Under the old `shortName|shortName` key A-rev would have
        // shown one row.
        final paths = plan(index, cases['A-rev mall → origin']!);
        final keys = paths
            .map((p) => p.segments.map((s) => s.route.id).join('|'))
            .toSet();
        expect(keys.length, paths.length, reason: 'no two paths share routes');
        expect(paths.length, greaterThan(1));
      });
    },
  );

  group('the two rules, one at a time (why both are needed)', () {
    /// Both rules as they were: shared stops only, any shared short name is
    /// one line.
    late GtfsRouteIndex legacy;

    /// Walkable transfers, but the old unconditional same-name rule.
    late GtfsRouteIndex radiusOnly;

    /// Shared stops only, but the same-name rule made conditional.
    late GtfsRouteIndex nameRuleOnly;

    setUpAll(() {
      legacy = GtfsRouteIndex(
        data,
        spatialIndex: spatial,
        transferRadiusMeters: 0,
        sameNameRouteLimit: 1 << 30,
      );
      radiusOnly = GtfsRouteIndex(
        data,
        spatialIndex: spatial,
        sameNameRouteLimit: 1 << 30,
      );
      nameRuleOnly = GtfsRouteIndex(
        data,
        spatialIndex: spatial,
        transferRadiusMeters: 0,
      );
    });

    test('legacy behaviour reproduces the report: only B-fwd plans', () {
      expect(plan(legacy, cases['A-fwd origin → mall']!), isEmpty);
      expect(plan(legacy, cases['A-rev mall → origin']!), isEmpty);
      expect(plan(legacy, cases['B-fwd share link → university']!), isNotEmpty);
      expect(plan(legacy, cases['B-rev university → share link']!), isEmpty);
    });

    test('walkable transfers alone rescue B-rev but not the mall', () {
      expect(
        plan(radiusOnly, cases['B-rev university → share link']!),
        isNotEmpty,
      );
      expect(plan(radiusOnly, cases['A-fwd origin → mall']!), isEmpty);
      expect(plan(radiusOnly, cases['A-rev mall → origin']!), isEmpty);
    });

    test(
      'the conditional name rule alone rescues A-rev (shared stop) only',
      () {
        expect(plan(nameRuleOnly, cases['A-rev mall → origin']!), isNotEmpty);
        expect(plan(nameRuleOnly, cases['A-fwd origin → mall']!), isEmpty);
        expect(
          plan(nameRuleOnly, cases['B-rev university → share link']!),
          isEmpty,
        );
      },
    );

    test('connection table grows with each rule, never shrinks', () {
      final full = GtfsRouteIndex(data, spatialIndex: spatial);
      expect(legacy.connectionCount, lessThan(nameRuleOnly.connectionCount));
      expect(legacy.connectionCount, lessThan(radiusOnly.connectionCount));
      expect(nameRuleOnly.connectionCount, lessThan(full.connectionCount));
      expect(radiusOnly.connectionCount, lessThan(full.connectionCount));
    });

    test('shared-stop connections are exactly the brute-force table', () {
      // "Kept exactly as before" pinned against an independent computation
      // (public API only): one walk-0 entry per (pattern, position, other
      // pattern at that stop, other line) — no missing, no extra, no
      // duplicates. The thinning rule must not touch these: on this cut 94
      // of them follow another shared stop with the same pattern and would
      // vanish if it did.
      final full = GtfsRouteIndex(data, spatialIndex: spatial);
      final expected = sharedStopTable(full);
      expect(expected.length, greaterThan(100));
      expect(walkZeroTable(full), expected);
      // Same for the legacy index (all of its table is shared-stop), and
      // every legacy connection is still in the new table.
      expect(walkZeroTable(legacy), sharedStopTable(legacy));
      expect(walkZeroTable(full), containsAll(walkZeroTable(legacy)));
    });

    test('LocalPlannerClient passes both knobs to the index it builds', () {
      final bytes = file.readAsBytesSync();
      final asLegacy = LocalPlannerClient(
        transferRadiusMeters: 0,
        sameNameRouteLimit: 1 << 30,
      )..loadFromBytes(bytes);
      expect(asLegacy.routeIndex!.connectionCount, legacy.connectionCount);
      final asDefault = LocalPlannerClient()..loadFromBytes(bytes);
      expect(asDefault.routeIndex!.transferRadiusMeters, 100);
      expect(asDefault.routeIndex!.sameNameRouteLimit, 3);
      expect(
        asDefault.routeIndex!.connectionCount,
        GtfsRouteIndex(data, spatialIndex: spatial).connectionCount,
      );
    });
  });

  group('candidate cap (GtfsRoutingService.maxTransferCandidates)', () {
    late GtfsRouteIndex index;
    setUpAll(() => index = GtfsRouteIndex(data, spatialIndex: spatial));

    List<(String, int)> signature(List<RoutingPath> paths) => [
      for (final p in paths)
        (p.segments.map((s) => s.route.id).join('>'), p.score.round()),
    ];

    test('the default cap does not truncate any of the four cases', () {
      for (final entry in cases.entries) {
        expect(
          signature(plan(index, entry.value)),
          signature(plan(index, entry.value, maxTransferCandidates: 1 << 30)),
          reason: entry.key,
        );
      }
    });

    test(
      'a cap that runs out on the first origin stops loses A-rev\'s best',
      () {
        // Candidates are enumerated origin stop by origin stop, nearest first:
        // a small budget is spent before the stop where the 54 m-walk
        // itinerary (7 20046784 → 7 18800658) boards, so only the shared-stop
        // one is left and the top score gets worse — the failure mode that
        // made the cap move from 1 500 to 20 000.
        final full = plan(index, cases['A-rev mall → origin']!);
        final capped = plan(
          index,
          cases['A-rev mall → origin']!,
          maxTransferCandidates: 100,
        );
        expect(capped.length, lessThan(full.length));
        expect(capped.first.score, greaterThan(full.first.score));
        expect(
          signature(capped).map((s) => s.$1),
          isNot(contains('20046784>18800658')),
        );
        expect(signature(full).map((s) => s.$1), contains('20046784>18800658'));
      },
    );
  });
}
