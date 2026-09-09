import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

import 'support/connection_tables.dart';

/// The persisted planner index (#993): a snapshot must restore exactly the
/// state the build produces, and anything that is not a snapshot for this
/// very input must be refused — never trusted, never crash.
void main() {
  final file = File('test/fixtures/sanaa_issue2_mini.gtfs.zip');
  late Uint8List zip;
  late String fingerprint;
  late PlannerIndexBundle built;
  late Uint8List blob;

  setUpAll(() {
    expect(
      file.existsSync(),
      isTrue,
      reason: 'run from the package root: ${file.absolute.path}',
    );
    zip = file.readAsBytesSync();
    fingerprint = PlannerIndexCodec.fingerprint(zip);
    built = PlannerIndexBundle.build(zip);
    blob = PlannerIndexCodec.encode(built, fingerprint: fingerprint);
  });

  PlannerIndexBundle load(
    Uint8List bytes, {
    String? fp,
    double radius = GtfsRouteIndex.defaultTransferRadiusMeters,
    int limit = GtfsRouteIndex.defaultSameNameRouteLimit,
  }) {
    String? reason;
    final bundle = PlannerIndexCodec.decode(
      bytes,
      fingerprint: fp ?? fingerprint,
      transferRadiusMeters: radius,
      sameNameRouteLimit: limit,
      onReject: (r) => reason = r,
    );
    expect(bundle, isNotNull, reason: 'rejected: $reason');
    return bundle!;
  }

  String? rejectReason(
    Uint8List bytes, {
    String? fp,
    double radius = GtfsRouteIndex.defaultTransferRadiusMeters,
    int limit = GtfsRouteIndex.defaultSameNameRouteLimit,
  }) {
    String? reason;
    final bundle = PlannerIndexCodec.decode(
      bytes,
      fingerprint: fp ?? fingerprint,
      transferRadiusMeters: radius,
      sameNameRouteLimit: limit,
      onReject: (r) => reason = r,
    );
    expect(bundle, isNull, reason: 'should have been rejected');
    return reason;
  }

  /// Canonical text of an itinerary: every field a caller can observe.
  String pathKey(RoutingPath p) => [
    p.originStop.id,
    p.originWalkDistance.toStringAsFixed(4),
    for (final s in p.segments)
      '${s.route.id}/${s.pattern.id}/${s.fromIdx}-${s.toIdx}/'
          '${s.fromStop.id}>${s.toStop.id}/${s.stopCount}/'
          '${s.stops.map((x) => x.id).join(',')}/'
          '${s.shapePoints.length}/${s.transitDistance.toStringAsFixed(4)}/'
          '${s.headsign}',
    p.destinationStop.id,
    p.destinationWalkDistance.toStringAsFixed(4),
    p.transferWalkDistance.toStringAsFixed(4),
    p.score.toStringAsFixed(6),
  ].join('|');

  List<RoutingPath> plan(PlannerIndexBundle b, LatLng from, LatLng to) {
    return GtfsRoutingService(
      data: b.data,
      spatialIndex: b.spatialIndex,
      routeIndex: b.routeIndex,
    ).findRoutes(
      origin: from,
      destination: to,
      maxWalkDistance: 1500,
      maxResults: 5,
      maxStopCandidates: 150,
      maxDirects: 5,
      maxTransferPaths: 5,
    );
  }

  group('round trip restores the parsed data field by field', () {
    late PlannerIndexBundle loaded;
    setUpAll(() => loaded = load(blob));

    test('agencies', () {
      expect(loaded.data.agencies.length, built.data.agencies.length);
      for (var i = 0; i < built.data.agencies.length; i++) {
        final a = built.data.agencies[i], b = loaded.data.agencies[i];
        expect(
          [
            b.id,
            b.name,
            b.url,
            b.timezone,
            b.lang,
            b.phone,
            b.fareUrl,
            b.email,
          ],
          [
            a.id,
            a.name,
            a.url,
            a.timezone,
            a.lang,
            a.phone,
            a.fareUrl,
            a.email,
          ],
        );
      }
    });

    test('stops, in map order, every field', () {
      expect(loaded.data.stops.keys, orderedEquals(built.data.stops.keys));
      for (final a in built.data.stops.values) {
        final b = loaded.data.stops[a.id]!;
        expect(
          [
            b.id,
            b.code,
            b.name,
            b.description,
            b.lat,
            b.lon,
            b.zoneId,
            b.url,
            b.locationType,
            b.parentStation,
            b.timezone,
            b.wheelchairBoarding,
            b.platformCode,
          ],
          [
            a.id,
            a.code,
            a.name,
            a.description,
            a.lat,
            a.lon,
            a.zoneId,
            a.url,
            a.locationType,
            a.parentStation,
            a.timezone,
            a.wheelchairBoarding,
            a.platformCode,
          ],
        );
      }
      // The fixture is Arabic: the string pool must round-trip UTF-8.
      expect(
        loaded.data.stops.values.any((s) => s.name.contains('شارع')),
        isTrue,
      );
    });

    test('routes, trips, calendars, frequencies', () {
      expect(loaded.data.routes.keys, orderedEquals(built.data.routes.keys));
      for (final a in built.data.routes.values) {
        final b = loaded.data.routes[a.id]!;
        expect(
          [
            b.agencyId,
            b.shortName,
            b.longName,
            b.description,
            b.type,
            b.url,
            b.colorHex,
            b.textColorHex,
            b.sortOrder,
          ],
          [
            a.agencyId,
            a.shortName,
            a.longName,
            a.description,
            a.type,
            a.url,
            a.colorHex,
            a.textColorHex,
            a.sortOrder,
          ],
        );
      }
      expect(loaded.data.trips.keys, orderedEquals(built.data.trips.keys));
      for (final a in built.data.trips.values) {
        final b = loaded.data.trips[a.id]!;
        expect(
          [
            b.routeId,
            b.serviceId,
            b.headsign,
            b.shortName,
            b.directionId,
            b.blockId,
            b.shapeId,
            b.wheelchairAccessible,
            b.bikesAllowed,
          ],
          [
            a.routeId,
            a.serviceId,
            a.headsign,
            a.shortName,
            a.directionId,
            a.blockId,
            a.shapeId,
            a.wheelchairAccessible,
            a.bikesAllowed,
          ],
        );
      }
      expect(
        loaded.data.calendars.keys,
        orderedEquals(built.data.calendars.keys),
      );
      for (final a in built.data.calendars.values) {
        final b = loaded.data.calendars[a.serviceId]!;
        expect(
          [
            b.monday,
            b.tuesday,
            b.wednesday,
            b.thursday,
            b.friday,
            b.saturday,
            b.sunday,
            b.startDate,
            b.endDate,
            b.startDate.isUtc,
          ],
          [
            a.monday,
            a.tuesday,
            a.wednesday,
            a.thursday,
            a.friday,
            a.saturday,
            a.sunday,
            a.startDate,
            a.endDate,
            a.startDate.isUtc,
          ],
        );
      }
      expect(loaded.data.calendarDates.length, built.data.calendarDates.length);
      expect(loaded.data.frequencies.length, built.data.frequencies.length);
      for (var i = 0; i < built.data.frequencies.length; i++) {
        final a = built.data.frequencies[i], b = loaded.data.frequencies[i];
        expect(
          [b.tripId, b.startTime, b.endTime, b.headwaySecs, b.exactTimes],
          [a.tripId, a.startTime, a.endTime, a.headwaySecs, a.exactTimes],
        );
      }
    });

    test('stop times, in file order', () {
      expect(loaded.data.stopTimes.length, built.data.stopTimes.length);
      for (var i = 0; i < built.data.stopTimes.length; i++) {
        final a = built.data.stopTimes[i], b = loaded.data.stopTimes[i];
        expect(
          [
            b.tripId,
            b.arrivalTime,
            b.departureTime,
            b.stopId,
            b.stopSequence,
            b.stopHeadsign,
            b.pickupType,
            b.dropOffType,
            b.shapeDistTraveled,
            b.timepoint,
          ],
          [
            a.tripId,
            a.arrivalTime,
            a.departureTime,
            a.stopId,
            a.stopSequence,
            a.stopHeadsign,
            a.pickupType,
            a.dropOffType,
            a.shapeDistTraveled,
            a.timepoint,
          ],
        );
      }
    });

    test('shapes with every point (Float64 coordinates, no rounding)', () {
      expect(loaded.data.shapes.keys, orderedEquals(built.data.shapes.keys));
      var points = 0;
      for (final a in built.data.shapes.values) {
        final b = loaded.data.shapes[a.id]!;
        expect(b.points.length, a.points.length);
        for (var i = 0; i < a.points.length; i++) {
          final pa = a.points[i], pb = b.points[i];
          expect(
            [pb.shapeId, pb.lat, pb.lon, pb.sequence, pb.distTraveled],
            [pa.shapeId, pa.lat, pa.lon, pa.sequence, pa.distTraveled],
          );
          points++;
        }
      }
      expect(points, greaterThan(500));
    });
  });

  group('round trip restores the indices', () {
    late PlannerIndexBundle loaded;
    setUpAll(() => loaded = load(blob));

    test('patterns: ids, stops, cumDist, bbox, line keys', () {
      final a = built.routeIndex, b = loaded.routeIndex;
      expect(b.patternCount, a.patternCount);
      expect(b.transferRadiusMeters, a.transferRadiusMeters);
      expect(b.sameNameRouteLimit, a.sameNameRouteLimit);
      for (var i = 0; i < a.patternCount; i++) {
        final pa = a.patternById(i), pb = b.patternById(i);
        expect(pb.id, pa.id);
        expect(pb.routeId, pa.routeId);
        expect(pb.stopIds, orderedEquals(pa.stopIds));
        expect(pb.headsign, pa.headsign);
        expect(pb.shapeId, pa.shapeId);
        expect(pb.cumDist, orderedEquals(pa.cumDist));
        expect(
          [pb.minLat, pb.minLon, pb.maxLat, pb.maxLon],
          [pa.minLat, pa.minLon, pa.maxLat, pa.maxLon],
        );
        for (final stopId in pa.stopIds) {
          expect(pb.indexOfStop(stopId), pa.indexOfStop(stopId));
        }
      }
      for (final route in built.data.routes.values) {
        expect(b.lineKeyForRoute(route.id), a.lineKeyForRoute(route.id));
        expect(
          b.getPatternsForRoute(route.id).map((p) => p.id),
          orderedEquals(a.getPatternsForRoute(route.id).map((p) => p.id)),
        );
      }
    });

    test('per-stop lookups in the same order (drives enumeration order)', () {
      final a = built.routeIndex, b = loaded.routeIndex;
      for (final stopId in built.data.stops.keys) {
        expect(
          b.getPatternsAtStop(stopId).map((p) => p.id),
          orderedEquals(a.getPatternsAtStop(stopId).map((p) => p.id)),
        );
        expect(
          b.getRoutesAtStop(stopId).toList(),
          orderedEquals(a.getRoutesAtStop(stopId).toList()),
        );
      }
    });

    test('connection table: all four columns, every entry', () {
      final a = built.routeIndex, b = loaded.routeIndex;
      expect(b.connectionCount, a.connectionCount);
      expect(a.connectionCount, greaterThan(100));
      for (var p = 0; p < a.patternCount; p++) {
        final ca = a.getConnectionsFor(p), cb = b.getConnectionsFor(p);
        expect(cb.length, ca.length);
        for (var k = 0; k < ca.length; k++) {
          expect(cb.otherPatternIdAt(k), ca.otherPatternIdAt(k));
          expect(cb.myStopIdxAt(k), ca.myStopIdxAt(k));
          expect(cb.otherStopIdxAt(k), ca.otherStopIdxAt(k));
          expect(cb.walkMetersAt(k), ca.walkMetersAt(k));
        }
      }
      expect(walkZeroTable(b), orderedEquals(sharedStopTable(b)));
      expect(walkZeroTable(b), orderedEquals(walkZeroTable(a)));
    });

    test('spatial index: same tree, same k-NN and range answers', () {
      final a = built.spatialIndex, b = loaded.spatialIndex;
      expect(
        b.preorder.map((s) => s.id),
        orderedEquals(a.preorder.map((s) => s.id)),
      );
      final rnd = Random(993);
      final stops = built.data.stops.values.toList();
      for (var i = 0; i < 200; i++) {
        final s = stops[rnd.nextInt(stops.length)];
        final at = LatLng(
          s.lat + (rnd.nextDouble() - 0.5) / 100,
          s.lon + (rnd.nextDouble() - 0.5) / 100,
        );
        String near(List<NearbyStop> l) =>
            l.map((n) => '${n.stop.id}@${n.distance}').join(',');
        expect(
          near(b.findNearestStops(at, maxResults: 150, maxDistance: 1500)),
          near(a.findNearestStops(at, maxResults: 150, maxDistance: 1500)),
        );
        expect(
          near(b.findStopsInRadius(at, 300)),
          near(a.findStopsInRadius(at, 300)),
        );
      }
    });

    test('schedule index: departures and frequencies', () {
      final a = built.scheduleIndex, b = loaded.scheduleIndex;
      expect(b.stopTimesByStop.keys, orderedEquals(a.stopTimesByStop.keys));
      final at = DateTime(2026, 9, 9, 7, 30);
      for (final stopId in built.data.stops.keys) {
        String deps(List<StopDeparture> l) => l
            .map(
              (d) =>
                  '${d.tripId}/${d.routeId}/${d.departureTime}/'
                  '${d.stopSequence}/${d.headsign}',
            )
            .join(',');
        expect(
          deps(b.getNextDepartures(stopId, atTime: at, limit: 20)),
          deps(a.getNextDepartures(stopId, atTime: at, limit: 20)),
        );
      }
      for (final route in built.data.routes.values) {
        final fa = a.getRouteFrequency(route.id);
        final fb = b.getRouteFrequency(route.id);
        expect(
          [fb?.routeId, fb?.avgHeadway, fb?.tripCount],
          [fa?.routeId, fa?.avgHeadway, fa?.tripCount],
        );
      }
    });

    test(
      'the reporter\'s four trips and 200 random pairs plan identically',
      () {
        const origin = LatLng(15.29408, 44.26392);
        const mall = LatLng(15.33736, 44.19833);
        const shareFrom = LatLng(15.2952334, 44.2623529);
        const university = LatLng(15.3536032, 44.1786948);
        final trips = <(LatLng, LatLng)>[
          (origin, mall),
          (mall, origin),
          (shareFrom, university),
          (university, shareFrom),
        ];
        final rnd = Random(2);
        final stops = built.data.stops.values.toList();
        for (var i = 0; i < 200; i++) {
          trips.add((
            stops[rnd.nextInt(stops.length)].position,
            stops[rnd.nextInt(stops.length)].position,
          ));
        }
        var itineraries = 0;
        for (final (from, to) in trips) {
          final a = plan(built, from, to), b = plan(loaded, from, to);
          expect(b.map(pathKey).toList(), orderedEquals(a.map(pathKey)));
          itineraries += a.length;
        }
        expect(itineraries, greaterThan(50));
        // The four reported trips still plan (#992) after the round trip.
        for (final trip in trips.take(4)) {
          expect(plan(loaded, trip.$1, trip.$2), isNotEmpty);
        }
      },
    );

    test(
      'a client fed from the snapshot answers like one fed from the build',
      () async {
        final fromBuild = LocalPlannerClient()
          ..loadFromParsed(
            data: built.data,
            spatialIndex: built.spatialIndex,
            routeIndex: built.routeIndex,
          );
        final fromSnapshot = LocalPlannerClient()
          ..loadFromParsed(
            data: loaded.data,
            spatialIndex: loaded.spatialIndex,
            routeIndex: loaded.routeIndex,
          );
        final a = await fromBuild.findRoutes(
          origin: const LatLng(15.33736, 44.19833),
          destination: const LatLng(15.29408, 44.26392),
          maxWalkDistance: 1500,
        );
        final b = await fromSnapshot.findRoutes(
          origin: const LatLng(15.33736, 44.19833),
          destination: const LatLng(15.29408, 44.26392),
          maxWalkDistance: 1500,
        );
        expect(b.map(pathKey).toList(), orderedEquals(a.map(pathKey)));
        final routeId = built.data.routes.keys.first;
        final da = await fromBuild.getRouteDetail(routeId);
        final db = await fromSnapshot.getRouteDetail(routeId);
        expect(db!.geometry, orderedEquals(da!.geometry));
        expect(
          db.stops.map((s) => s.id),
          orderedEquals(da.stops.map((s) => s.id)),
        );
      },
    );
  });

  group('the blob itself', () {
    test('re-encoding the restored bundle is byte-identical', () {
      final again = PlannerIndexCodec.encode(
        load(blob),
        fingerprint: fingerprint,
      );
      expect(again.length, blob.length);
      expect(again, orderedEquals(blob));
    });

    test('is compact next to the zip and starts with the magic', () {
      expect(String.fromCharCodes(blob.sublist(0, 4)), 'TPIX');
      expect(String.fromCharCodes(blob.sublist(blob.length - 4)), 'XIPT');
      // The fixture zip is 30 KB of compressed text; the snapshot holds the
      // parsed model plus three indices in ~80 KB.
      expect(blob.length, lessThan(zip.length * 4));
    });

    test('decodes from an unaligned view of a larger buffer', () {
      final padded = Uint8List(blob.length + 3)
        ..setRange(3, blob.length + 3, blob);
      final view = Uint8List.sublistView(padded, 3);
      expect(view.offsetInBytes % 8, isNot(0));
      expect(
        load(view).routeIndex.connectionCount,
        built.routeIndex.connectionCount,
      );
    });

    test('an empty feed round-trips', () {
      final bundle = PlannerIndexBundle(
        data: GtfsData.empty,
        spatialIndex: GtfsSpatialIndex(const {}),
        routeIndex: GtfsRouteIndex(GtfsData.empty),
        scheduleIndex: GtfsScheduleIndex(
          trips: const {},
          stopTimes: const [],
          calendars: const {},
          calendarDates: const [],
          frequencies: const [],
        ),
      );
      final bytes = PlannerIndexCodec.encode(bundle, fingerprint: 'x');
      final back = PlannerIndexCodec.decode(
        bytes,
        fingerprint: 'x',
        transferRadiusMeters: GtfsRouteIndex.defaultTransferRadiusMeters,
        sameNameRouteLimit: GtfsRouteIndex.defaultSameNameRouteLimit,
      );
      expect(back, isNotNull);
      expect(back!.data.stops, isEmpty);
      expect(back.routeIndex.patternCount, 0);
      expect(back.spatialIndex.findNearestStops(const LatLng(0, 0)), isEmpty);
    });
  });

  group('refuses what is not a snapshot for this input', () {
    test('another GTFS (fingerprint) → null', () {
      expect(
        rejectReason(blob, fp: PlannerIndexCodec.fingerprint(Uint8List(0))),
        contains('fingerprint'),
      );
    });

    test('other index knobs → null', () {
      expect(rejectReason(blob, radius: 0), contains('transferRadiusMeters'));
      expect(
        rejectReason(blob, limit: 1 << 30),
        contains('sameNameRouteLimit'),
      );
    });

    test('unknown format version → null (forward compatibility)', () {
      final other = Uint8List.fromList(blob);
      ByteData.sublistView(
        other,
      ).setUint32(4, PlannerIndexCodec.formatVersion + 1, Endian.host);
      expect(rejectReason(other), contains('format version'));
    });

    test('wrong magic, garbage, empty → null', () {
      final other = Uint8List.fromList(blob)..[0] = 0x00;
      expect(rejectReason(other), contains('not a planner snapshot'));
      expect(rejectReason(Uint8List(0)), isNotNull);
      expect(
        rejectReason(Uint8List.fromList(List.filled(64, 0xab))),
        isNotNull,
      );
      expect(rejectReason(zip), isNotNull, reason: 'the GTFS zip itself');
    });

    test('truncated anywhere → null, never an exception', () {
      final cuts = <int>{
        for (var i = 1; i < 64; i++) blob.length * i ~/ 64,
        blob.length - 1,
        blob.length - 4,
        blob.length - 5,
        16,
        17,
        63,
        64,
        65,
      };
      for (final cut in cuts) {
        expect(
          rejectReason(Uint8List.sublistView(blob, 0, cut)),
          isNotNull,
          reason: 'cut at $cut of ${blob.length}',
        );
      }
    });

    test('a single flipped byte anywhere in the payload → null', () {
      final rnd = Random(7);
      // Header + string pool live in the first KB; the rest is payload.
      for (var i = 0; i < 300; i++) {
        final at = rnd.nextInt(blob.length - 4);
        final other = Uint8List.fromList(blob);
        other[at] ^= 0x01 << rnd.nextInt(8);
        expect(rejectReason(other), isNotNull, reason: 'flip at $at');
      }
    });

    test('trailing or missing trailer → null', () {
      final longer = Uint8List(blob.length + 8)..setRange(0, blob.length, blob);
      expect(rejectReason(longer), isNotNull);
      final noTrailer = Uint8List.fromList(blob)
        ..fillRange(blob.length - 4, blob.length, 0);
      expect(rejectReason(noTrailer), contains('trailer'));
    });

    test('encode refuses a bundle it cannot represent losslessly', () {
      final data = GtfsData(
        agencies: const [],
        stops: const {},
        routes: const {},
        trips: const {},
        stopTimes: [
          const GtfsStopTime(
            tripId: 't',
            stopId: 's',
            stopSequence: 1,
            departureTime: Duration(milliseconds: 1500),
          ),
        ],
        calendars: const {},
        calendarDates: const [],
        frequencies: const [],
        shapes: const {},
      );
      final bundle = PlannerIndexBundle(
        data: data,
        spatialIndex: GtfsSpatialIndex(const {}),
        routeIndex: GtfsRouteIndex(data),
        scheduleIndex: GtfsScheduleIndex(
          trips: const {},
          stopTimes: data.stopTimes,
          calendars: const {},
          calendarDates: const [],
          frequencies: const [],
        ),
      );
      expect(
        () => PlannerIndexCodec.encode(bundle, fingerprint: 'x'),
        throwsA(isA<PlannerIndexEncodeException>()),
      );
    });
  });

  group('fingerprint', () {
    test('is content-sensitive, length-sensitive and stable', () {
      expect(fingerprint, hasLength(16));
      expect(PlannerIndexCodec.fingerprint(zip), fingerprint);
      final flipped = Uint8List.fromList(zip)..[zip.length ~/ 2] ^= 1;
      expect(PlannerIndexCodec.fingerprint(flipped), isNot(fingerprint));
      expect(
        PlannerIndexCodec.fingerprint(
          Uint8List.sublistView(zip, 0, zip.length - 1),
        ),
        isNot(fingerprint),
      );
      expect(
        PlannerIndexCodec.fingerprint(Uint8List(0)),
        isNot(PlannerIndexCodec.fingerprint(Uint8List(1))),
      );
    });

    test(
      'known answers (pin: the cache key must not drift between releases)',
      () {
        expect(PlannerIndexCodec.fingerprint(Uint8List(0)), '050c5d1ff2ecfaec');
        expect(
          PlannerIndexCodec.fingerprint(Uint8List.fromList([1, 2, 3, 4, 5])),
          isNot('050c5d1ff2ecfaec'),
        );
      },
    );
  });

  group('format version guard', () {
    test('the integer skeleton of the fixture snapshot is pinned — if this '
        'fails, the index build changed: bump PlannerIndexCodec.formatVersion '
        'and update the digest', () {
      final loaded = load(blob);
      final sb = StringBuffer();
      final index = loaded.routeIndex;
      for (var p = 0; p < index.patternCount; p++) {
        final pat = index.patternById(p);
        sb.writeln('P $p ${pat.routeId} ${pat.stopIds.join(',')}');
        final c = index.getConnectionsFor(p);
        for (var k = 0; k < c.length; k++) {
          sb.writeln(
            'C ${c.otherPatternIdAt(k)} ${c.myStopIdxAt(k)} '
            '${c.otherStopIdxAt(k)}',
          );
        }
      }
      sb.writeln(
        'S ${loaded.spatialIndex.preorder.map((s) => s.id).join(',')}',
      );
      for (final e in loaded.scheduleIndex.stopTimesByStop.entries) {
        sb.writeln('T ${e.key} ${e.value.map((st) => st.tripId).join(',')}');
      }
      final digest = PlannerIndexCodec.fingerprint(
        Uint8List.fromList(sb.toString().codeUnits),
      );
      expect(PlannerIndexCodec.formatVersion, 1);
      expect(digest, '94eb0e89a69b5fd9');
    });
  });
}
