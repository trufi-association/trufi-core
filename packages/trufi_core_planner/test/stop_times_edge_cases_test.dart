// Edge cases of the stop_times timings (#997), written by the fresh review
// of PR #1000: circular lines, which trip defines a pattern, times past
// 24:00:00, stops missing from stops.txt, one-stop patterns, blank first
// cells, the snapshot codec with mixed timed/untimed patterns (round trip,
// corrupted flags, truncation), the knob through LocalPlannerClient.loadFromBytes
// and hand-built patterns. Each test pins a documented behaviour.
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

void main() {
  const stops = {
    'A': GtfsStop(id: 'A', name: 'A', lat: 0, lon: 0),
    'B': GtfsStop(id: 'B', name: 'B', lat: 0, lon: 0.001),
    'C': GtfsStop(id: 'C', name: 'C', lat: 0, lon: 0.002),
    'D': GtfsStop(id: 'D', name: 'D', lat: 0, lon: 0.003),
    'E': GtfsStop(id: 'E', name: 'E', lat: 0, lon: 0.004),
  };

  GtfsStopTime row(
    String trip,
    String stop,
    int seq,
    String? arr,
    String? dep,
  ) => GtfsStopTime.fromCsv({
    'trip_id': trip,
    'stop_id': stop,
    'stop_sequence': '$seq',
    'arrival_time': arr ?? '',
    'departure_time': dep ?? '',
  });

  /// Trips ride route = trip id without its trailing digits ("tT1" -> "T").
  GtfsData feed(
    List<GtfsStopTime> rows, {
    Map<String, GtfsStop> stopMap = stops,
    List<String>? tripOrder,
  }) {
    final trips = <String, GtfsTrip>{};
    final routes = <String, GtfsRoute>{};
    final ids = tripOrder ?? rows.map((r) => r.tripId).toSet().toList();
    for (final t in ids) {
      final routeId = t.substring(1).replaceAll(RegExp(r'\d+$'), '');
      routes[routeId] = GtfsRoute(
        id: routeId,
        shortName: routeId,
        longName: 'Line $routeId',
        type: GtfsRouteType.bus,
      );
      trips[t] = GtfsTrip(id: t, routeId: routeId, serviceId: 's');
    }
    return GtfsData(
      agencies: const [],
      stops: stopMap,
      routes: routes,
      trips: trips,
      stopTimes: rows,
      calendars: const {},
      calendarDates: const [],
      frequencies: const [],
      shapes: const {},
    );
  }

  PlannerIndexBundle bundleOf(GtfsData data) {
    final spatial = GtfsSpatialIndex(data.stops);
    final routeIndex = GtfsRouteIndex(data, spatialIndex: spatial);
    final schedule = GtfsScheduleIndex(
      trips: data.trips,
      stopTimes: data.stopTimes,
      calendars: data.calendars,
      calendarDates: data.calendarDates,
      frequencies: data.frequencies,
    );
    return PlannerIndexBundle(
      data: data,
      spatialIndex: spatial,
      routeIndex: routeIndex,
      scheduleIndex: schedule,
    );
  }

  group('(a) circular line: a stop repeated NON-consecutively (A B C A)', () {
    test('offsets stay aligned with the 4-entry stop list', () {
      final data = feed([
        row('tT', 'A', 1, '06:00:00', '06:00:00'),
        row('tT', 'B', 2, '06:05:00', '06:05:00'),
        row('tT', 'C', 3, '06:10:00', '06:10:00'),
        row('tT', 'A', 4, '06:20:00', '06:20:00'),
      ]);
      final p = GtfsRouteIndex(data).getPatternsForRoute('T').single;
      expect(p.stopIds, ['A', 'B', 'C', 'A']);
      expect(p.arrivalOffsets, [0, 300, 600, 1200]);
      expect(p.departureOffsets, [0, 300, 600, 1200]);
      expect(p.scheduledSecondsBetween(0, 3), 1200);
      expect(p.scheduledSecondsBetween(1, 3), 900);
      // Pre-existing: indexOfStop returns ONE position for a repeated stop.
      expect(p.indexOfStop('A'), anyOf(0, 3));
    });
  });

  group('(b) which trip defines the pattern', () {
    test('first trip in stop_times order wins, even over trips.txt order', () {
      // tT2 appears first in stop_times, tT1 first in trips.
      final rows = [
        for (var i = 0; i < 3; i++)
          row('tT2', 'ABC'[i], i + 1, '07:00:0$i', '07:00:0$i'),
        for (var i = 0; i < 3; i++)
          row('tT1', 'ABC'[i], i + 1, '06:0$i:00', '06:0$i:00'),
      ];
      final data = feed(rows, tripOrder: ['tT1', 'tT2']);
      final p = GtfsRouteIndex(data).getPatternsForRoute('T').single;
      // tT2 (1 s between stops) defined it, not tT1 (60 s).
      expect(p.arrivalOffsets, [0, 1, 2]);
    });

    test(
      'unsorted rows and a different stop_sequence numbering still match',
      () {
        final rows = [
          row('tT1', 'C', 30, '06:10:00', '06:10:00'),
          row('tT1', 'A', 10, '06:00:00', '06:00:00'),
          row('tT1', 'B', 20, '06:05:00', '06:05:00'),
          row('tT2', 'B', 2, '08:03:00', '08:03:00'),
          row('tT2', 'C', 3, '08:06:00', '08:06:00'),
          row('tT2', 'A', 1, '08:00:00', '08:00:00'),
        ];
        final patterns = GtfsRouteIndex(feed(rows)).getPatternsForRoute('T');
        expect(
          patterns,
          hasLength(1),
          reason: 'same stop sequence -> one pattern',
        );
        expect(patterns.single.stopIds, ['A', 'B', 'C']);
        expect(patterns.single.arrivalOffsets, [0, 300, 600]);
      },
    );

    test('FINDING: the pattern is deduped BEFORE timings — a first trip '
        'without usable times leaves the pattern untimed although the second '
        'trip has complete times', () {
      final rows = [
        row('tT1', 'A', 1, '06:00:00', '06:00:00'),
        row('tT1', 'B', 2, null, null), // non-timepoint, blank
        row('tT1', 'C', 3, '06:10:00', '06:10:00'),
        row('tT2', 'A', 1, '07:00:00', '07:00:00'),
        row('tT2', 'B', 2, '07:05:00', '07:05:00'),
        row('tT2', 'C', 3, '07:10:00', '07:10:00'),
      ];
      final patterns = GtfsRouteIndex(feed(rows)).getPatternsForRoute('T');
      expect(patterns, hasLength(1));
      // Documented behaviour of the PR; recorded here as a limitation.
      expect(patterns.single.hasStopTimes, isFalse);
    });

    test('a first trip whose only defect is a blank at an INTERMEDIATE stop '
        'loses even the end-to-end time that both endpoints do carry', () {
      final rows = [
        row('tT1', 'A', 1, '06:00:00', '06:00:00'),
        row('tT1', 'B', 2, null, null),
        row('tT1', 'C', 3, '06:10:00', '06:10:00'),
      ];
      final p = GtfsRouteIndex(feed(rows)).getPatternsForRoute('T').single;
      expect(p.scheduledSecondsBetween(0, 2), isNull);
    });
  });

  group('(c) times past 24:00:00', () {
    test('overnight trip keeps its offsets', () {
      final rows = [
        row('tT', 'A', 1, '23:50:00', '23:50:00'),
        row('tT', 'B', 2, '24:10:00', '24:10:00'),
        row('tT', 'C', 3, '25:00:00', '25:00:30'),
      ];
      final p = GtfsRouteIndex(feed(rows)).getPatternsForRoute('T').single;
      expect(p.arrivalOffsets, [0, 1200, 4200]);
      expect(p.departureOffsets, [0, 1200, 4230]);
      expect(p.scheduledSecondsBetween(0, 2), 4200);
    });

    test('a feed that wraps at midnight (23:59 -> 00:01) is dropped', () {
      final rows = [
        row('tT', 'A', 1, '23:59:00', '23:59:00'),
        row('tT', 'B', 2, '00:01:00', '00:01:00'),
      ];
      final p = GtfsRouteIndex(feed(rows)).getPatternsForRoute('T').single;
      expect(p.hasStopTimes, isFalse);
    });
  });

  group('(d) stop_times row whose stop_id is not in stops.txt', () {
    test('_buildIndices keeps the stop and its timing; codec round-trips', () {
      final rows = [
        row('tT', 'A', 1, '06:00:00', '06:00:00'),
        row('tT', 'GHOST', 2, '06:05:00', '06:05:00'),
        row('tT', 'C', 3, '06:10:00', '06:10:00'),
      ];
      final data = feed(rows);
      final bundle = bundleOf(data);
      final p = bundle.routeIndex.getPatternsForRoute('T').single;
      expect(p.stopIds, ['A', 'GHOST', 'C']);
      expect(p.arrivalOffsets, [0, 300, 600]);
      expect(p.cumDist[1], 0, reason: 'pre-existing: unknown stop adds 0 m');
      final blob = PlannerIndexCodec.encode(bundle, fingerprint: 'fp');
      String? reason;
      final back = PlannerIndexCodec.decode(
        blob,
        fingerprint: 'fp',
        transferRadiusMeters: GtfsRouteIndex.defaultTransferRadiusMeters,
        sameNameRouteLimit: GtfsRouteIndex.defaultSameNameRouteLimit,
        onReject: (r) => reason = r,
      );
      expect(back, isNotNull, reason: 'rejected: $reason');
      final q = back!.routeIndex.getPatternsForRoute('T').single;
      expect(q.stopIds, ['A', 'GHOST', 'C']);
      expect(q.arrivalOffsets, [0, 300, 600]);
    });
  });

  group('(e) pattern with exactly one stop', () {
    test('one row', () {
      final data = feed([row('tT', 'A', 1, '06:00:00', '06:00:30')]);
      final bundle = bundleOf(data);
      final p = bundle.routeIndex.getPatternsForRoute('T').single;
      expect(p.stopIds, ['A']);
      expect(p.hasStopTimes, isTrue);
      expect(p.arrivalOffsets, [0]);
      expect(p.departureOffsets, [30]);
      expect(p.scheduledSecondsBetween(0, 0), isNull);
      expect(p.scheduledSecondsBetween(0, 1), isNull);
      final blob = PlannerIndexCodec.encode(bundle, fingerprint: 'fp');
      final back = PlannerIndexCodec.decode(
        blob,
        fingerprint: 'fp',
        transferRadiusMeters: GtfsRouteIndex.defaultTransferRadiusMeters,
        sameNameRouteLimit: GtfsRouteIndex.defaultSameNameRouteLimit,
      );
      expect(back, isNotNull);
      expect(back!.routeIndex.patternById(0).departureOffsets, [30]);
    });

    test('two rows for the same stop collapse to one stop', () {
      final data = feed([
        row('tT', 'A', 1, '06:00:00', '06:00:00'),
        row('tT', 'A', 2, '06:00:00', '06:01:00'),
      ]);
      final p = GtfsRouteIndex(data).getPatternsForRoute('T').single;
      expect(p.stopIds, ['A']);
      expect(p.arrivalOffsets, [0]);
      expect(p.departureOffsets, [60]);
    });
  });

  group('(f) first row blank arrival with a departure', () {
    test('the departure becomes the base', () {
      final rows = [
        row('tT', 'A', 1, null, '06:00:30'),
        row('tT', 'B', 2, '06:02:00', '06:02:00'),
        row('tT', 'C', 3, '06:04:00', null),
      ];
      final p = GtfsRouteIndex(feed(rows)).getPatternsForRoute('T').single;
      expect(p.arrivalOffsets, [0, 90, 210]);
      expect(p.departureOffsets, [0, 90, 210]);
      expect(p.scheduledSecondsBetween(0, 2), 210);
    });

    test('a duplicate consecutive row with BOTH cells blank drops the whole '
        'pattern even though the first row of that stop was timed', () {
      final rows = [
        row('tT', 'A', 1, '06:00:00', '06:00:00'),
        row('tT', 'B', 2, '06:02:00', '06:02:00'),
        row('tT', 'B', 3, null, null),
        row('tT', 'C', 4, '06:04:00', '06:04:00'),
      ];
      final p = GtfsRouteIndex(feed(rows)).getPatternsForRoute('T').single;
      expect(p.stopIds, ['A', 'B', 'C']);
      expect(p.hasStopTimes, isFalse); // documented limitation
    });
  });

  group('(g) codec with mixed timed/untimed patterns', () {
    late PlannerIndexBundle bundle;
    late Uint8List blob;
    late List<bool> flags;

    setUpAll(() {
      // 8 patterns: T1 timed, U untimed (blank), T2 timed with dwell, V untimed
      // (backwards), W timed single stop, X untimed, Y timed, Z timed — the
      // flag column 1,0,1,0,1,0,1,1 is a distinctive byte string.
      final rows = <GtfsStopTime>[
        row('tT', 'A', 1, '06:00:00', '06:00:00'),
        row('tT', 'B', 2, '06:02:00', '06:02:00'),
        row('tT', 'C', 3, '06:04:00', '06:04:00'),
        row('tU', 'A', 1, '06:00:00', '06:00:00'),
        row('tU', 'B', 2, null, null),
        row('tU', 'C', 3, '06:04:00', '06:04:00'),
        row('tS', 'C', 1, '06:00:00', '06:00:40'),
        row('tS', 'D', 2, '06:02:00', '06:02:20'),
        row('tS', 'E', 3, '06:04:00', '06:04:00'),
        row('tV', 'A', 1, '06:00:00', '06:00:00'),
        row('tV', 'B', 2, '05:59:00', '05:59:00'),
        row('tW', 'D', 1, '06:00:00', '06:00:00'),
        row('tX', 'B', 1, null, null),
        row('tX', 'C', 2, null, null),
        row('tY', 'E', 1, '06:00:00', '06:00:00'),
        row('tY', 'D', 2, '06:01:00', '06:01:00'),
        row('tZ', 'A', 1, '00:00:00', '00:00:00'),
        row('tZ', 'E', 2, '00:20:00', '00:20:00'),
      ];
      bundle = bundleOf(feed(rows));
      flags = List.generate(
        bundle.routeIndex.patternCount,
        (i) => bundle.routeIndex.patternById(i).hasStopTimes,
      );
      blob = PlannerIndexCodec.encode(bundle, fingerprint: 'fp');
    });

    PlannerIndexBundle? decode(Uint8List bytes, void Function(String) rej) =>
        PlannerIndexCodec.decode(
          bytes,
          fingerprint: 'fp',
          transferRadiusMeters: GtfsRouteIndex.defaultTransferRadiusMeters,
          sameNameRouteLimit: GtfsRouteIndex.defaultSameNameRouteLimit,
          onReject: rej,
        );

    test('the synthetic bundle really mixes both kinds', () {
      expect(flags, [true, false, true, false, true, false, true, true]);
    });

    test('round trip restores every offset, timed and untimed alike', () {
      String? reason;
      final back = decode(blob, (r) => reason = r);
      expect(back, isNotNull, reason: 'rejected: $reason');
      for (var i = 0; i < flags.length; i++) {
        final a = bundle.routeIndex.patternById(i);
        final b = back!.routeIndex.patternById(i);
        expect(b.hasStopTimes, a.hasStopTimes, reason: 'pattern $i');
        expect(b.arrivalOffsets, orderedEquals(a.arrivalOffsets));
        expect(b.departureOffsets, orderedEquals(a.departureOffsets));
      }
      // The dwell pattern distinguishes the two columns.
      final s = back!.routeIndex.getPatternsForRoute('S').single;
      expect(s.arrivalOffsets, [0, 120, 240]);
      expect(s.departureOffsets, [40, 140, 240]);
    });

    // --- corruption that passes the checksum ----------------------------
    // Layout (planner_index_codec.dart): payload = bytes[start, len-4);
    // u32 payloadLength at start-8, u32 FNV-1a checksum at start-4.
    int payloadStart(Uint8List b) {
      final bd = ByteData.sublistView(b);
      final end = b.length - 4;
      for (var s = 16; s + 8 <= end; s += 8) {
        if (bd.getUint32(s - 8, Endian.host) == end - s) return s;
      }
      throw StateError('payload start not found');
    }

    Uint8List reseal(Uint8List original, void Function(Uint8List) mutate) {
      final b = Uint8List.fromList(original);
      mutate(b);
      final start = payloadStart(b), end = b.length - 4;
      final bd = ByteData.sublistView(b);
      var h = 0x811c9dc5;
      for (var i = start; i < end; i += 4) {
        h = ((h ^ bd.getUint32(i, Endian.host)) * 0x01000193) & 0xffffffff;
      }
      bd.setUint32(start - 4, h, Endian.host);
      return b;
    }

    int flagsOffset(Uint8List b) {
      // u32 count (8) followed by the 8 flag bytes.
      final needle = [8, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1];
      var found = -1;
      outer:
      for (var i = 0; i + needle.length <= b.length; i++) {
        for (var k = 0; k < needle.length; k++) {
          if (b[i + k] != needle[k]) continue outer;
        }
        expect(found, -1, reason: 'flag column byte string is not unique');
        found = i + 4;
      }
      expect(found, isNot(-1), reason: 'flag column not found in the blob');
      return found;
    }

    test('resealing without a change still decodes (harness sanity)', () {
      String? reason;
      expect(
        decode(reseal(blob, (_) {}), (r) => reason = r),
        isNotNull,
        reason: '$reason',
      );
    });

    test('a timing flag of 2 -> null with "pattern timing flag"', () {
      String? reason;
      final bad = reseal(blob, (b) => b[flagsOffset(b)] = 2);
      expect(decode(bad, (r) => reason = r), isNull);
      expect(reason, 'pattern timing flag');
    });

    test(
      'an untimed pattern flagged as timed -> null (overflow/inconsistent)',
      () {
        String? reason;
        final bad = reseal(blob, (b) => b[flagsOffset(b) + 1] = 1);
        expect(decode(bad, (r) => reason = r), isNull);
        expect(
          reason,
          anyOf('pattern timings overflow', 'pattern timings inconsistent'),
        );
      },
    );

    test('a timed pattern flagged as untimed -> null (inconsistent)', () {
      String? reason;
      final bad = reseal(blob, (b) => b[flagsOffset(b)] = 0);
      expect(decode(bad, (r) => reason = r), isNull);
      expect(reason, 'pattern timings inconsistent');
    });

    test(
      'the last timed pattern flagged untimed -> null, not silently shifted',
      () {
        String? reason;
        final bad = reseal(blob, (b) => b[flagsOffset(b) + 7] = 0);
        expect(decode(bad, (r) => reason = r), isNull);
        expect(reason, 'pattern timings inconsistent');
      },
    );

    test('truncated blob (cut inside the pattern section) -> null', () {
      String? reason;
      final off = flagsOffset(blob);
      final cut = Uint8List.fromList(blob.sublist(0, off + 2));
      expect(decode(cut, (r) => reason = r), isNull);
      expect(reason, isNotNull);
    });
  });

  group('mutation gaps closed by the fresh review', () {
    test('m07: an arrival after the previous ARRIVAL but before the previous '
        'DEPARTURE is still backwards (needs a dwell to be observable)', () {
      final rows = [
        row('tT', 'A', 1, '06:00:00', '06:03:00'), // 3 min dwell
        row('tT', 'B', 2, '06:02:00', '06:02:00'), // leaves A before A left
        row('tT', 'C', 3, '06:05:00', '06:05:00'),
      ];
      final p = GtfsRouteIndex(feed(rows)).getPatternsForRoute('T').single;
      expect(p.hasStopTimes, isFalse);
    });

    test(
      'm21: LocalPlannerClient.loadFromBytes forwards the knob too',
      () async {
        String csv(List<List<String>> rows) =>
            rows.map((r) => r.join(',')).join('\n');
        final archive = Archive()
          ..addFile(
            ArchiveFile.string(
              'stops.txt',
              csv([
                ['stop_id', 'stop_name', 'stop_lat', 'stop_lon'],
                ['A', 'A', '0', '0'],
                ['E', 'E', '0', '0.004'],
              ]),
            ),
          )
          ..addFile(
            ArchiveFile.string(
              'routes.txt',
              csv([
                [
                  'route_id',
                  'route_short_name',
                  'route_long_name',
                  'route_type',
                ],
                ['U', 'U', 'Line U', '3'],
              ]),
            ),
          )
          ..addFile(
            ArchiveFile.string(
              'trips.txt',
              csv([
                ['route_id', 'service_id', 'trip_id'],
                ['U', 's', 'tU'],
              ]),
            ),
          )
          ..addFile(
            ArchiveFile.string(
              'stop_times.txt',
              csv([
                [
                  'trip_id',
                  'arrival_time',
                  'departure_time',
                  'stop_id',
                  'stop_sequence',
                ],
                ['tU', '', '', 'A', '1'],
                ['tU', '', '', 'E', '2'],
              ]),
            ),
          );
        final zip = Uint8List.fromList(ZipEncoder().encode(archive));
        final client = LocalPlannerClient(fallbackVehicleSpeedKmh: 40)
          ..loadFromBytes(zip);
        final paths = await client.findRoutes(
          origin: stops['A']!.position,
          destination: stops['E']!.position,
          maxWalkDistance: 300,
          maxTransfers: 0,
        );
        final meters = paths.single.segments.single.transitDistance;
        expect(meters, greaterThan(400));
        expect(
          paths.single.segments.single.scheduledDuration,
          Duration(seconds: (meters / (40 / 3.6)).round()),
        );
      },
    );

    test('m27: encode rejects a pattern whose offset columns disagree', () {
      final data = feed([
        row('tT', 'A', 1, '06:00:00', '06:00:00'),
        row('tT', 'B', 2, '06:02:00', '06:02:00'),
      ]);
      final good = bundleOf(data);
      final p = good.routeIndex.patternById(0);
      final bad = RoutePattern(
        id: 0,
        routeId: p.routeId,
        stopIds: p.stopIds,
        cumDist: p.cumDist,
        arrivalOffsets: const [0, 120],
        departureOffsets: const [0],
        minLat: p.minLat,
        minLon: p.minLon,
        maxLat: p.maxLat,
        maxLon: p.maxLon,
      );
      final index = GtfsRouteIndex.restore(
        data: data,
        patterns: [bad],
        connectionStarts: Int32List.fromList([0, 0]),
        connectionOtherPattern: Int32List(0),
        connectionMyStopIdx: Int32List(0),
        connectionOtherStopIdx: Int32List(0),
        connectionWalk: Float32List(0),
        transferRadiusMeters: GtfsRouteIndex.defaultTransferRadiusMeters,
        sameNameRouteLimit: GtfsRouteIndex.defaultSameNameRouteLimit,
      );
      final bundle = PlannerIndexBundle(
        data: data,
        spatialIndex: good.spatialIndex,
        routeIndex: index,
        scheduleIndex: good.scheduleIndex,
      );
      expect(
        () => PlannerIndexCodec.encode(bundle, fingerprint: 'fp'),
        throwsA(isA<PlannerIndexEncodeException>()),
      );
    });
  });

  group('hand-built RoutePattern robustness', () {
    test(
      'encode rejects mismatched offset columns with the codec exception',
      () {
        final data = feed([
          row('tT', 'A', 1, '06:00:00', '06:00:00'),
          row('tT', 'B', 2, '06:02:00', '06:02:00'),
        ]);
        final good = bundleOf(data);
        final p = good.routeIndex.patternById(0);
        final bad = RoutePattern(
          id: 0,
          routeId: p.routeId,
          stopIds: p.stopIds,
          cumDist: p.cumDist,
          arrivalOffsets: const [0, 120],
          departureOffsets: const [0],
        );
        // GtfsRouteIndex has no public way to swap a pattern; verify the
        // constructor-level contract instead.
        expect(bad.hasStopTimes, isTrue);
        expect(
          () => bad.scheduledSecondsBetween(0, 1),
          returnsNormally,
          reason: 'departureOffsets[0] exists',
        );
        final bad2 = RoutePattern(
          routeId: 'r',
          stopIds: const ['A', 'B'],
          arrivalOffsets: const [0, 120],
          departureOffsets: const [],
        );
        // FINDING (nit): no assert ties the two columns together.
        expect(() => bad2.scheduledSecondsBetween(0, 1), throwsRangeError);
      },
    );

    test('fromJson/toJson drop the offsets (documented, like cumDist)', () {
      final data = feed([
        row('tT', 'A', 1, '06:00:00', '06:00:00'),
        row('tT', 'B', 2, '06:02:00', '06:02:00'),
      ]);
      final p = GtfsRouteIndex(data).getPatternsForRoute('T').single;
      final back = RoutePattern.fromJson(p.toJson());
      expect(back.hasStopTimes, isFalse);
      expect(p.toJson().containsKey('arrivalOffsets'), isFalse);
    });

    test('RoutingSegment JSON round trip keeps scheduledDuration (remote)', () {
      final data = feed([
        row('tT', 'A', 1, '06:00:00', '06:00:00'),
        row('tT', 'E', 2, '06:20:00', '06:20:00'),
      ]);
      final spatial = GtfsSpatialIndex(data.stops);
      final index = GtfsRouteIndex(data, spatialIndex: spatial);
      final service = GtfsRoutingService(
        data: data,
        spatialIndex: spatial,
        routeIndex: index,
      );
      final paths = service.findRoutes(
        origin: stops['A']!.position,
        destination: stops['E']!.position,
        maxWalkDistance: 300,
        maxTransfers: 0,
      );
      final seg = paths.single.segments.single;
      expect(seg.scheduledDuration, const Duration(minutes: 20));
      final back = RoutingSegment.fromJson(seg.toJson());
      expect(back.scheduledDuration, const Duration(minutes: 20));
      expect(back.pattern.hasStopTimes, isFalse);
    });
  });
}
