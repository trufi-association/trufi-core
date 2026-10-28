import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

/// trufi-sanaa#16: the planner lists one-transfer itineraries only when no
/// direct line exists ("fewest transfers win outright" — one fare per
/// ride). `directsHideTransfers: false` lists the one-transfer bucket after
/// the direct one instead: the direct rows are byte-identical to today's
/// answer, the transfer rows are what the one-transfer phase already
/// computed, and nothing else changes (phase 3 still only runs when both
/// buckets are empty). Pairs are random stops of the Sana'a fixtures,
/// >= 2.5 km apart, planned with the app's parameters.
void main() {
  late GtfsRoutingService mini; // sanaa_issue2_mini
  late GtfsRoutingService twoTransfers; // sanaa_issue2_two_transfers_mini

  Future<GtfsRoutingService> load(String path) async {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'run from the package root');
    final data = await GtfsParser.parseFromFile(path);
    final spatial = GtfsSpatialIndex(data.stops);
    return GtfsRoutingService(
      data: data,
      spatialIndex: spatial,
      routeIndex: GtfsRouteIndex(data, spatialIndex: spatial),
    );
  }

  setUpAll(() async {
    mini = await load('test/fixtures/sanaa_issue2_mini.gtfs.zip');
    twoTransfers = await load(
      'test/fixtures/sanaa_issue2_two_transfers_mini.gtfs.zip',
    );
  });

  List<RoutingPath> plan(
    GtfsRoutingService svc,
    LatLng from,
    LatLng to, {
    required bool directsHideTransfers,
    int maxResults = 5,
    int maxTransfers = 1,
  }) => svc.findRoutes(
    origin: from,
    destination: to,
    maxWalkDistance: 1500,
    maxResults: maxResults,
    maxStopCandidates: 150,
    maxDirects: maxResults,
    maxTransferPaths: maxResults,
    maxTransfers: maxTransfers,
    directsHideTransfers: directsHideTransfers,
  );

  String signature(RoutingPath p) =>
      '${p.originStop.id}>'
      '${p.segments.map((s) => '${s.route.id}/${s.fromIdx}-${s.toIdx}').join('+')}'
      '>${p.destinationStop.id}@${p.score.toStringAsFixed(6)}';

  // One direct line (19961501) and four one-transfer options.
  const aFrom = LatLng(15.346045, 44.220847);
  const aTo = LatLng(15.353365, 44.174865);
  // Three direct lines and two one-transfer options.
  const bFrom = LatLng(15.323871, 44.194232);
  const bTo = LatLng(15.372300, 44.176502);

  group('default (true): today\'s answer', () {
    test('a direct line hides every one-transfer option', () {
      final paths = plan(mini, aFrom, aTo, directsHideTransfers: true);
      expect(paths, hasLength(1));
      expect(paths.single.transfers, 0);
      expect(paths.single.segments.single.route.id, '19961501');
    });

    test('the parameter defaults to true', () {
      final explicit = plan(mini, aFrom, aTo, directsHideTransfers: true);
      final implicit = mini.findRoutes(
        origin: aFrom,
        destination: aTo,
        maxWalkDistance: 1500,
        maxResults: 5,
        maxStopCandidates: 150,
        maxTransfers: 1,
      );
      expect(implicit.map(signature), explicit.map(signature));
    });
  });

  group('directsHideTransfers: false', () {
    test('directs first, unchanged, then the one-transfer options', () {
      final today = plan(mini, aFrom, aTo, directsHideTransfers: true);
      final all = plan(mini, aFrom, aTo, directsHideTransfers: false);
      expect(all, hasLength(5));
      expect(all.take(1).map(signature), today.map(signature));
      expect(all.skip(1).map((p) => p.transfers), everyElement(1));
      // Transfers keep their own score order; a transfer may score better
      // than the direct and still come after it (bucket order, not score).
      final transferScores = all.skip(1).map((p) => p.score).toList();
      expect(transferScores, List.of(transferScores)..sort());
      expect(all[1].score, lessThan(all[0].score));
      expect(
        all.skip(1).map((p) => p.segments.map((s) => s.route.id).join('>')),
        [
          '18800489>19961501',
          '20080675>19961501',
          '19961501>18800916',
          '18800658>19961501',
        ],
      );
    });

    test('several directs stay in front, in the same order', () {
      final today = plan(twoTransfers, bFrom, bTo, directsHideTransfers: true);
      final all = plan(twoTransfers, bFrom, bTo, directsHideTransfers: false);
      expect(today, hasLength(3));
      expect(today.map((p) => p.transfers), everyElement(0));
      expect(all, hasLength(5));
      expect(all.take(3).map(signature), today.map(signature));
      expect(all.skip(3).map((p) => p.transfers), everyElement(1));
    });

    test('maxResults truncates after the directs', () {
      final all = plan(
        twoTransfers,
        bFrom,
        bTo,
        directsHideTransfers: false,
        maxResults: 3,
      );
      expect(all, hasLength(3));
      expect(all.map((p) => p.transfers), everyElement(0));
      final four = plan(
        twoTransfers,
        bFrom,
        bTo,
        directsHideTransfers: false,
        maxResults: 4,
      );
      expect(four, hasLength(4));
      expect(four.last.transfers, 1);
    });

    test('no direct line: identical to today (one-transfer bucket)', () {
      // The #992 mall trip on the mini fixture is answered with transfers
      // only; the knob changes nothing there.
      const from = LatLng(15.29408, 44.26392);
      const to = LatLng(15.33736, 44.19833);
      final today = plan(mini, from, to, directsHideTransfers: true);
      final all = plan(mini, from, to, directsHideTransfers: false);
      expect(today, isNotEmpty);
      expect(today.map((p) => p.transfers), everyElement(1));
      expect(all.map(signature), today.map(signature));
    });

    test('phase 3 still runs only when both buckets are empty', () {
      // The #998 trip needs two changes; both modes reach phase 3 and
      // return the same chains.
      const darSalm = LatLng(15.28064, 44.24430);
      const hasaba = LatLng(15.37844, 44.20752);
      final before = twoTransfers.multiTransferSearches;
      final today = plan(
        twoTransfers,
        darSalm,
        hasaba,
        directsHideTransfers: true,
        maxTransfers: 2,
      );
      final all = plan(
        twoTransfers,
        darSalm,
        hasaba,
        directsHideTransfers: false,
        maxTransfers: 2,
      );
      expect(twoTransfers.multiTransferSearches, before + 2);
      expect(today.map((p) => p.transfers), everyElement(2));
      expect(all.map(signature), today.map(signature));
      // And a pair with a direct line never reaches phase 3 in either mode.
      final b0 = twoTransfers.multiTransferSearches;
      plan(
        twoTransfers,
        bFrom,
        bTo,
        directsHideTransfers: false,
        maxTransfers: 4,
      );
      plan(
        twoTransfers,
        bFrom,
        bTo,
        directsHideTransfers: true,
        maxTransfers: 4,
      );
      expect(twoTransfers.multiTransferSearches, b0);
    });

    test('LocalPlannerClient passes the knob through (default true)', () async {
      final client = LocalPlannerClient()
        ..loadFromBytes(
          File('test/fixtures/sanaa_issue2_mini.gtfs.zip').readAsBytesSync(),
        );
      final today = await client.findRoutes(
        origin: aFrom,
        destination: aTo,
        maxWalkDistance: 1500,
      );
      expect(today, hasLength(1));
      final all = await client.findRoutes(
        origin: aFrom,
        destination: aTo,
        maxWalkDistance: 1500,
        directsHideTransfers: false,
      );
      expect(all, hasLength(5));
      expect(all.first.transfers, 0);
      expect(all.skip(1).map((p) => p.transfers), everyElement(1));
    });
  });
}
