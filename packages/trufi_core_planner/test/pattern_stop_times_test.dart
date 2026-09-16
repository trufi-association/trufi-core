import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

/// Ride durations come from the feed's `stop_times` (#997): the arrival at
/// the alighting stop minus the departure from the boarding stop of the trip
/// that defined the pattern. A pattern without usable timings falls back to
/// distance at a configurable average speed (default 20 km/h) — the old
/// behaviour, minus the hard-coded 18.
void main() {
  // Five stops along the equator, 0.001° ≈ 111.19 m apart: A → B → C → D → E.
  const stops = {
    'A': GtfsStop(id: 'A', name: 'A', lat: 0, lon: 0),
    'B': GtfsStop(id: 'B', name: 'B', lat: 0, lon: 0.001),
    'C': GtfsStop(id: 'C', name: 'C', lat: 0, lon: 0.002),
    'D': GtfsStop(id: 'D', name: 'D', lat: 0, lon: 0.003),
    'E': GtfsStop(id: 'E', name: 'E', lat: 0, lon: 0.004),
  };
  const ids = ['A', 'B', 'C', 'D', 'E'];
  final origin = LatLng(0, 0);
  final destination = LatLng(0, 0.004);

  GtfsRoute route(String id) => GtfsRoute(
    id: id,
    shortName: id,
    longName: 'Line $id',
    type: GtfsRouteType.bus,
  );

  /// `trip` visits A..E in order; [times] gives `(arrival, departure)` per
  /// stop as GTFS strings (null = blank cell).
  List<GtfsStopTime> timedTrip(
    String trip,
    List<(String?, String?)> times, {
    List<String> stopIds = ids,
  }) => [
    for (var i = 0; i < stopIds.length; i++)
      GtfsStopTime.fromCsv({
        'trip_id': trip,
        'stop_id': stopIds[i],
        'stop_sequence': '${i + 1}',
        'arrival_time': times[i].$1 ?? '',
        'departure_time': times[i].$2 ?? '',
      }),
  ];

  GtfsData feed(Map<String, List<GtfsStopTime>> tripsWithTimes) {
    final trips = <String, GtfsTrip>{};
    final routes = <String, GtfsRoute>{};
    final stopTimes = <GtfsStopTime>[];
    tripsWithTimes.forEach((tripId, rows) {
      // Trip "tX" or "tX2" rides route "X".
      final routeId = tripId.substring(1).replaceAll(RegExp(r'\d+$'), '');
      routes[routeId] = route(routeId);
      trips[tripId] = GtfsTrip(id: tripId, routeId: routeId, serviceId: 's');
      stopTimes.addAll(rows);
    });
    return GtfsData(
      agencies: const [],
      stops: stops,
      routes: routes,
      trips: trips,
      stopTimes: stopTimes,
      calendars: const {},
      calendarDates: const [],
      frequencies: const [],
      shapes: const {},
    );
  }

  GtfsRoutingService serviceFor(GtfsData data, {double? speedKmh}) {
    final spatial = GtfsSpatialIndex(data.stops);
    final index = GtfsRouteIndex(data, spatialIndex: spatial);
    return speedKmh == null
        ? GtfsRoutingService(
            data: data,
            spatialIndex: spatial,
            routeIndex: index,
          )
        : GtfsRoutingService(
            data: data,
            spatialIndex: spatial,
            routeIndex: index,
            fallbackVehicleSpeedKmh: speedKmh,
          );
  }

  RoutingSegment directRide(GtfsRoutingService service, String routeId) {
    final paths = service.findRoutes(
      origin: origin,
      destination: destination,
      maxWalkDistance: 300,
      maxTransfers: 0,
    );
    final path = paths.singleWhere(
      (p) => p.segments.length == 1 && p.segments.single.route.id == routeId,
      orElse: () => throw StateError('no direct ride on $routeId: $paths'),
    );
    return path.segments.single;
  }

  // A..E at 111.19 m per hop = 444.78 m end to end.
  final endToEndMeters =
      4 *
      const Distance(
        roundResult: false,
      ).distance(LatLng(0, 0), LatLng(0, 0.001));

  const clockTimes = <(String?, String?)>[
    ('06:00:00', '06:00:30'), // 30 s dwell at the first stop
    ('06:02:00', '06:02:00'),
    ('06:04:00', '06:04:00'),
    ('06:06:00', '06:06:00'),
    ('06:08:00', '06:08:00'),
  ];
  const offsetTimes = <(String?, String?)>[
    ('00:00:00', '00:00:30'),
    ('00:02:00', '00:02:00'),
    ('00:04:00', '00:04:00'),
    ('00:06:00', '00:06:00'),
    ('00:08:00', '00:08:00'),
  ];

  group('RoutePattern timings from stop_times', () {
    test(
      'timetable clock times: arrival at alight minus departure at board',
      () {
        final data = feed({'tT': timedTrip('tT', clockTimes)});
        final pattern = GtfsRouteIndex(data).getPatternsForRoute('T').single;
        expect(pattern.hasStopTimes, isTrue);
        expect(pattern.arrivalOffsets, [0, 120, 240, 360, 480]);
        expect(pattern.departureOffsets, [30, 120, 240, 360, 480]);
        // 06:08:00 − 06:00:30: the dwell before departure is not ride time.
        expect(pattern.scheduledSecondsBetween(0, 4), 450);
        expect(pattern.scheduledSecondsBetween(1, 3), 240);
      },
    );

    test('frequency-based offsets from 00:00:00 give the same answer', () {
      final data = feed({'tT': timedTrip('tT', offsetTimes)});
      final pattern = GtfsRouteIndex(data).getPatternsForRoute('T').single;
      expect(pattern.scheduledSecondsBetween(0, 4), 450);
      expect(pattern.scheduledSecondsBetween(2, 3), 120);
    });

    test('out-of-order or equal indices have no scheduled time', () {
      final data = feed({'tT': timedTrip('tT', clockTimes)});
      final pattern = GtfsRouteIndex(data).getPatternsForRoute('T').single;
      expect(pattern.scheduledSecondsBetween(2, 2), isNull);
      expect(pattern.scheduledSecondsBetween(3, 1), isNull);
      expect(pattern.scheduledSecondsBetween(-1, 2), isNull);
      expect(pattern.scheduledSecondsBetween(0, 5), isNull);
    });

    test('consecutive rows for the same stop collapse like the stop list', () {
      // A, B, B (second row leaves 90 s later), C: three stops, the B
      // departure is the last row's.
      final rows = timedTrip(
        'tT',
        const [
          ('06:00:00', '06:00:00'),
          ('06:01:00', '06:01:00'),
          ('06:01:00', '06:02:30'),
          ('06:04:00', '06:04:00'),
        ],
        stopIds: const ['A', 'B', 'B', 'C'],
      );
      final data = feed({'tT': rows});
      final pattern = GtfsRouteIndex(data).getPatternsForRoute('T').single;
      expect(pattern.stopIds, ['A', 'B', 'C']);
      expect(pattern.arrivalOffsets, [0, 60, 240]);
      expect(pattern.departureOffsets, [0, 150, 240]);
      expect(pattern.scheduledSecondsBetween(1, 2), 90);
    });

    test('a blank arrival takes the departure and vice versa', () {
      final data = feed({
        'tT': timedTrip('tT', const [
          (null, '06:00:00'),
          ('06:02:00', null),
          ('06:04:00', '06:04:00'),
          ('06:06:00', '06:06:00'),
          ('06:08:00', null),
        ]),
      });
      final pattern = GtfsRouteIndex(data).getPatternsForRoute('T').single;
      expect(pattern.hasStopTimes, isTrue);
      expect(pattern.scheduledSecondsBetween(0, 4), 480);
    });

    test('a stop with neither time leaves the pattern without timings', () {
      final data = feed({
        'tT': timedTrip('tT', const [
          ('06:00:00', '06:00:00'),
          (null, null),
          ('06:04:00', '06:04:00'),
          ('06:06:00', '06:06:00'),
          ('06:08:00', '06:08:00'),
        ]),
      });
      final pattern = GtfsRouteIndex(data).getPatternsForRoute('T').single;
      expect(pattern.hasStopTimes, isFalse);
      expect(pattern.arrivalOffsets, isEmpty);
      expect(pattern.departureOffsets, isEmpty);
      expect(pattern.scheduledSecondsBetween(0, 4), isNull);
    });

    test('times running backwards leave the pattern without timings', () {
      final data = feed({
        'tT': timedTrip('tT', const [
          ('06:00:00', '06:00:00'),
          ('06:02:00', '06:02:00'),
          ('06:01:00', '06:01:00'), // earlier than the previous departure
          ('06:06:00', '06:06:00'),
          ('06:08:00', '06:08:00'),
        ]),
        'tU': timedTrip('tU', const [
          ('06:00:00', '06:00:00'),
          ('06:02:00', '06:01:00'), // leaves before it arrives
          ('06:04:00', '06:04:00'),
          ('06:06:00', '06:06:00'),
          ('06:08:00', '06:08:00'),
        ]),
      });
      final index = GtfsRouteIndex(data);
      expect(index.getPatternsForRoute('T').single.hasStopTimes, isFalse);
      expect(index.getPatternsForRoute('U').single.hasStopTimes, isFalse);
    });

    test('every time 00:00:00 is no timing at all', () {
      final data = feed({
        'tT': timedTrip('tT', List.filled(5, ('00:00:00', '00:00:00'))),
      });
      final pattern = GtfsRouteIndex(data).getPatternsForRoute('T').single;
      expect(pattern.hasStopTimes, isTrue);
      expect(pattern.scheduledSecondsBetween(0, 4), isNull);
    });

    test('no stop_times rows at all (JSON pattern) has no timings', () {
      final pattern = RoutePattern(routeId: 'r', stopIds: const ['A', 'B']);
      expect(pattern.hasStopTimes, isFalse);
      expect(pattern.scheduledSecondsBetween(0, 1), isNull);
    });

    test('the trip that defines the pattern sets its timing', () {
      // Same stop sequence twice on route T: the first trip wins, the second
      // (twice as slow) is the same pattern and is not consulted.
      final slow = <(String?, String?)>[
        for (var i = 0; i < 5; i++)
          (
            '06:${(i * 4).toString().padLeft(2, '0')}:00',
            '06:${(i * 4).toString().padLeft(2, '0')}:00',
          ),
      ];
      final data = feed({
        'tT': timedTrip('tT', clockTimes),
        'tT2': timedTrip('tT2', slow),
      });
      final patterns = GtfsRouteIndex(data).getPatternsForRoute('T');
      expect(patterns, hasLength(1));
      expect(patterns.single.scheduledSecondsBetween(0, 4), 450);
    });
  });

  group('GtfsRoutingService ride durations (#997)', () {
    test('a timed pattern rides for what the feed says', () {
      final service = serviceFor(feed({'tT': timedTrip('tT', clockTimes)}));
      final ride = directRide(service, 'T');
      expect(ride.scheduledDuration, const Duration(seconds: 450));
      expect(ride.transitDistance, closeTo(endToEndMeters, 0.5));
    });

    test('an untimed pattern rides at the default 20 km/h', () {
      final service = serviceFor(
        feed({'tU': timedTrip('tU', List.filled(5, (null, null)))}),
      );
      final ride = directRide(service, 'U');
      final expected = (endToEndMeters / (20 / 3.6)).round(); // ≈ 80 s
      expect(ride.scheduledDuration, Duration(seconds: expected));
      expect(GtfsRoutingService.defaultFallbackVehicleSpeedKmh, 20);
    });

    test(
      'the fallback speed is configurable and only touches untimed rides',
      () {
        final data = feed({
          'tT': timedTrip('tT', clockTimes),
          'tU': timedTrip('tU', List.filled(5, (null, null))),
        });
        final slow = serviceFor(data, speedKmh: 10);
        expect(
          directRide(slow, 'U').scheduledDuration,
          Duration(seconds: (endToEndMeters / (10 / 3.6)).round()),
        );
        expect(
          directRide(slow, 'T').scheduledDuration,
          const Duration(seconds: 450),
        );
        expect(slow.fallbackVehicleSpeedKmh, 10);
      },
    );

    test('a non-positive fallback speed is rejected', () {
      final data = feed({'tT': timedTrip('tT', clockTimes)});
      for (final bad in [0.0, -5.0, double.nan, double.infinity]) {
        expect(
          () => serviceFor(data, speedKmh: bad),
          throwsArgumentError,
          reason: '$bad',
        );
      }
    });

    test('LocalPlannerClient forwards the knob to the service', () async {
      final data = feed({'tU': timedTrip('tU', List.filled(5, (null, null)))});
      final spatial = GtfsSpatialIndex(data.stops);
      final index = GtfsRouteIndex(data, spatialIndex: spatial);
      final client = LocalPlannerClient(fallbackVehicleSpeedKmh: 40)
        ..loadFromParsed(data: data, spatialIndex: spatial, routeIndex: index);
      final paths = await client.findRoutes(
        origin: origin,
        destination: destination,
        maxWalkDistance: 300,
        maxTransfers: 0,
      );
      expect(
        paths.single.segments.single.scheduledDuration,
        Duration(seconds: (endToEndMeters / (40 / 3.6)).round()),
      );
      expect(
        LocalPlannerClient().fallbackVehicleSpeedKmh,
        GtfsRoutingService.defaultFallbackVehicleSpeedKmh,
      );
    });
  });
}
