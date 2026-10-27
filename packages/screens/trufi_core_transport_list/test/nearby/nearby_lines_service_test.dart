import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

/// Synthetic feed around the anchor (0, 0); 0.001° ≈ 111.2 m.
///
/// | line | stops                     | shape                        | expected |
/// | ---- | ------------------------- | ---------------------------- | -------- |
/// | 201  | 80 m N, 400 m N           | lon 0 from 70 m N to 400 m N | stop 80  |
/// | X10  | ~470 m ENE, 1 km E        | E–W along lat 0.0012 (133 m) | passes 133 |
/// | 18   | 380 m S, 2 km S           | none (stop sequence)         | stop 380 |
/// | 99   | 700 m E, 1.5 km E         | E–W along lat 0, from 611 m  | absent   |
/// | 7    | e1: 250 m NE; e2: 120 m W | none                         | stop 120 (e2) |
/// | 5    | ~200 m W, 1 km E          | E–W along lat 0.00018 (20 m) | passes 20 |
GtfsData buildFeed() {
  const stops = <String, GtfsStop>{
    'A1': GtfsStop(id: 'A1', name: 'Calle San Simón', lat: 0.000719, lon: 0),
    'A2': GtfsStop(id: 'A2', name: 'Norte 400', lat: 0.003597, lon: 0),
    'B1': GtfsStop(id: 'B1', name: 'Este 450', lat: 0.0012, lon: 0.003865),
    'B2': GtfsStop(id: 'B2', name: 'Este 1000', lat: 0.0012, lon: 0.009),
    'C1': GtfsStop(id: 'C1', name: 'Sur 380', lat: -0.003417, lon: 0),
    'C2': GtfsStop(id: 'C2', name: 'Sur 2000', lat: -0.017987, lon: 0),
    'D1': GtfsStop(id: 'D1', name: 'Lejos 700', lat: 0, lon: 0.006296),
    'D2': GtfsStop(id: 'D2', name: 'Lejos 1500', lat: 0, lon: 0.01349),
    'E1a': GtfsStop(id: 'E1a', name: 'NE 250', lat: 0.00159, lon: 0.00159),
    'E1b': GtfsStop(id: 'E1b', name: 'N 1000', lat: 0.008994, lon: 0.00159),
    'E2a': GtfsStop(id: 'E2a', name: 'Oeste 120', lat: 0, lon: -0.001079),
    'E2b': GtfsStop(id: 'E2b', name: 'Oeste 1000', lat: 0, lon: -0.008994),
    'F1': GtfsStop(id: 'F1', name: 'Oeste 200', lat: 0.00018, lon: -0.0018),
    'F2': GtfsStop(id: 'F2', name: 'Este 1000 b', lat: 0.00018, lon: 0.009),
  };

  const routes = <String, GtfsRoute>{
    'a': GtfsRoute(
      id: 'a',
      agencyId: 'ag',
      shortName: '201',
      longName: 'Línea 201',
      type: GtfsRouteType.bus,
      colorHex: 'FF5722',
      textColorHex: 'FFFFFF',
    ),
    'b': GtfsRoute(
      id: 'b',
      shortName: 'X10',
      longName: 'Línea X10',
      type: GtfsRouteType.bus,
      colorHex: '#00ff00',
    ),
    'c': GtfsRoute(
      id: 'c',
      shortName: '18',
      longName: 'Línea 18',
      type: GtfsRouteType.trolleybus,
      colorHex: 'nope',
    ),
    'd': GtfsRoute(
      id: 'd',
      shortName: '99',
      longName: 'Línea 99',
      type: GtfsRouteType.bus,
    ),
    'e1': GtfsRoute(
      id: 'e1',
      shortName: '7',
      longName: 'Línea 7 ida',
      type: GtfsRouteType.bus,
    ),
    'e2': GtfsRoute(
      id: 'e2',
      shortName: '7',
      longName: 'Línea 7 vuelta',
      type: GtfsRouteType.bus,
    ),
    'f': GtfsRoute(
      id: 'f',
      shortName: '5',
      longName: 'Línea 5',
      type: GtfsRouteType.bus,
    ),
  };

  const trips = <String, GtfsTrip>{
    'at': GtfsTrip(
      id: 'at',
      routeId: 'a',
      serviceId: 's',
      headsign: 'Norte',
      shapeId: 'sa',
    ),
    'bt': GtfsTrip(
      id: 'bt',
      routeId: 'b',
      serviceId: 's',
      headsign: 'Av. Humberto Asin',
      shapeId: 'sb',
    ),
    'ct': GtfsTrip(id: 'ct', routeId: 'c', serviceId: 's', headsign: 'Sur'),
    'dt': GtfsTrip(id: 'dt', routeId: 'd', serviceId: 's', shapeId: 'sd'),
    'e1t': GtfsTrip(id: 'e1t', routeId: 'e1', serviceId: 's', headsign: 'Ida'),
    'e2t': GtfsTrip(
      id: 'e2t',
      routeId: 'e2',
      serviceId: 's',
      headsign: 'Vuelta',
    ),
    'ft': GtfsTrip(
      id: 'ft',
      routeId: 'f',
      serviceId: 's',
      headsign: 'Centro',
      shapeId: 'sf',
    ),
  };

  const stopTimes = <GtfsStopTime>[
    GtfsStopTime(tripId: 'at', stopId: 'A1', stopSequence: 1),
    GtfsStopTime(tripId: 'at', stopId: 'A2', stopSequence: 2),
    GtfsStopTime(tripId: 'bt', stopId: 'B1', stopSequence: 1),
    GtfsStopTime(tripId: 'bt', stopId: 'B2', stopSequence: 2),
    GtfsStopTime(tripId: 'ct', stopId: 'C1', stopSequence: 1),
    GtfsStopTime(tripId: 'ct', stopId: 'C2', stopSequence: 2),
    GtfsStopTime(tripId: 'dt', stopId: 'D1', stopSequence: 1),
    GtfsStopTime(tripId: 'dt', stopId: 'D2', stopSequence: 2),
    GtfsStopTime(tripId: 'e1t', stopId: 'E1a', stopSequence: 1),
    GtfsStopTime(tripId: 'e1t', stopId: 'E1b', stopSequence: 2),
    GtfsStopTime(tripId: 'e2t', stopId: 'E2a', stopSequence: 1),
    GtfsStopTime(tripId: 'e2t', stopId: 'E2b', stopSequence: 2),
    GtfsStopTime(tripId: 'ft', stopId: 'F1', stopSequence: 1),
    GtfsStopTime(tripId: 'ft', stopId: 'F2', stopSequence: 2),
  ];

  GtfsShape shape(String id, List<(double, double)> points) => GtfsShape(
    id: id,
    points: [
      for (var i = 0; i < points.length; i++)
        GtfsShapePoint(
          shapeId: id,
          lat: points[i].$1,
          lon: points[i].$2,
          sequence: i,
        ),
    ],
  );

  return GtfsData(
    agencies: const [
      GtfsAgency(id: 'ag', name: 'Trufi Express', url: '', timezone: ''),
    ],
    stops: stops,
    routes: routes,
    trips: trips,
    stopTimes: stopTimes,
    calendars: const {},
    calendarDates: const [],
    frequencies: const [],
    shapes: {
      'sa': shape('sa', [(0.00063, 0), (0.000719, 0), (0.003597, 0)]),
      'sb': shape('sb', [(0.0012, -0.005), (0.0012, 0), (0.0012, 0.009)]),
      'sd': shape('sd', [(0, 0.0055), (0, 0.01349)]),
      'sf': shape('sf', [(0.00018, -0.005), (0.00018, 0), (0.00018, 0.009)]),
    },
  );
}

NearbyLinesService buildService(
  GtfsData data, {
  double stopPreferenceMeters = NearbyLinesService.defaultStopPreferenceMeters,
}) => NearbyLinesService(
  data: data,
  spatialIndex: GtfsSpatialIndex(data.stops),
  routeIndex: GtfsRouteIndex(data),
  stopPreferenceMeters: stopPreferenceMeters,
);

void main() {
  const anchor = LatLng(0, 0);
  final data = buildFeed();
  final service = buildService(data);
  final result = service.find(anchor);

  test('one row per line, sorted by distance, within 500 m', () {
    expect(result.lines.map((l) => l.displayName), [
      '5',
      '201',
      '7',
      'X10',
      '18',
    ]);
    expect(result.lines.map((l) => l.distanceMeters.round()), [
      20,
      80,
      120,
      133,
      380,
    ]);
    expect(result.anchor, anchor);
    expect(result.maxRadiusMeters, 500);
  });

  test('stop vs passes: a line only "passes" when it runs well inside its '
      'nearest stop', () {
    expect(result.lines.map((l) => l.kind), [
      NearbyMatchKind.passes,
      NearbyMatchKind.stop,
      NearbyMatchKind.stop,
      NearbyMatchKind.passes,
      NearbyMatchKind.stop,
    ]);
    final a = result.lines[1];
    expect(a.stopId, 'A1');
    expect(a.stopName, 'Calle San Simón');
    expect(a.nearestPoint, data.stops['A1']!.position);
    expect(a.headsign, 'Norte');

    final f = result.lines[0];
    expect(f.stopId, isNull);
    expect(f.nearestPoint.latitude, closeTo(0.00018, 1e-9));
    expect(f.nearestPoint.longitude, closeTo(0, 1e-9));

    final b = result.lines[3];
    expect(b.headsign, 'Av. Humberto Asin');
    expect(b.nearestPoint.latitude, closeTo(0.0012, 1e-9));
  });

  test('routes sharing a short name collapse into one line keyed like the '
      'planner', () {
    final seven = result.lines[2];
    final routeIndex = service.routeIndex;
    expect(seven.lineKey, routeIndex.lineKeyForRoute('e2'));
    expect(seven.lineKey, routeIndex.lineKeyForRoute('e1'));
    expect(seven.routeId, 'e2');
    expect(seven.patternId, routeIndex.getPattern('e2')!.id);
    expect(seven.stopId, 'E2a');
    expect(result.lines.where((l) => l.shortName == '7'), hasLength(1));
  });

  test('lines beyond the radius are absent', () {
    expect(result.lines.any((l) => l.displayName == '99'), isFalse);
  });

  test('route fields, colors, agency, trip and detail code', () {
    final a = result.lines[1];
    expect(a.routeId, 'a');
    expect(a.longName, 'Línea 201');
    expect(a.routeType, GtfsRouteType.bus);
    expect(a.color, const Color(0xFFFF5722));
    expect(a.textColor, const Color(0xFFFFFFFF));
    expect(a.agencyName, 'Trufi Express');
    expect(a.tripId, 'at');
    expect(a.shapeId, 'sa');
    expect(a.detailCode, 'a#${a.patternId}');

    expect(result.lines[3].color, const Color(0xFF00FF00));
    expect(result.lines[3].textColor, isNull);
    expect(result.lines[3].agencyName, isNull);
    expect(result.lines[4].color, isNull);
    expect(result.lines[4].routeType, GtfsRouteType.trolleybus);
    expect(result.lines[4].tripId, 'ct');
  });

  test('brackets are cumulative and within() filters', () {
    expect(result.bracketCounts, {
      NearbyRadius.m100: 2,
      NearbyRadius.m300: 4,
      NearbyRadius.m500: 5,
    });
    expect(result.within(NearbyRadius.m100), result.lines.take(2));
    expect(result.within(NearbyRadius.m500), result.lines);
  });

  test('an anchor far from everything yields an empty result', () {
    final far = service.find(const LatLng(0.09, 0.09));
    expect(far.lines, isEmpty);
    expect(far.bracketCounts.values, everyElement(0));
  });

  test('geometryOf returns the shape, or the stop sequence without one', () {
    final a = service.geometryOf(result.lines[1])!;
    expect(a.polyline, data.shapes['sa']!.polyline);
    expect(a.stops.map((s) => s.id), ['A1', 'A2']);

    final c = service.geometryOf(result.lines[4])!;
    expect(c.polyline, [
      data.stops['C1']!.position,
      data.stops['C2']!.position,
    ]);
    expect(c.stops.map((s) => s.name), ['Sur 380', 'Sur 2000']);
  });

  test('tripIdFor resolves the pattern to its first trip', () {
    final pattern = service.routeIndex.getPattern('a')!;
    expect(service.tripIdFor(pattern), 'at');
  });

  test('stopPreferenceMeters 0 reports every line by its geometry', () {
    final strict = buildService(data, stopPreferenceMeters: 0).find(anchor);
    final a = strict.lines.firstWhere((l) => l.displayName == '201');
    expect(a.kind, NearbyMatchKind.passes);
    expect(a.distanceMeters, closeTo(70, 0.5));
    expect(a.stopName, isNull);
  });

  test('parseGtfsColorHex accepts RRGGBB with or without # only', () {
    expect(parseGtfsColorHex('FF5722'), const Color(0xFFFF5722));
    expect(parseGtfsColorHex('#00ff00'), const Color(0xFF00FF00));
    expect(parseGtfsColorHex(null), isNull);
    expect(parseGtfsColorHex(''), isNull);
    expect(parseGtfsColorHex('12345'), isNull);
    expect(parseGtfsColorHex('zzzzzz'), isNull);
  });

  test('bbox prefilter: a pattern whose stops are all far away is never '
      'evaluated, even if its shape crosses the anchor', () {
    const far = GtfsData(
      agencies: [],
      stops: {
        'G1': GtfsStop(id: 'G1', name: 'g1', lat: 0.05, lon: 0.05),
        'G2': GtfsStop(id: 'G2', name: 'g2', lat: 0.06, lon: 0.05),
      },
      routes: {
        'g': GtfsRoute(
          id: 'g',
          shortName: 'G',
          longName: 'G',
          type: GtfsRouteType.bus,
        ),
      },
      trips: {
        'gt': GtfsTrip(id: 'gt', routeId: 'g', serviceId: 's', shapeId: 'sg'),
      },
      stopTimes: [
        GtfsStopTime(tripId: 'gt', stopId: 'G1', stopSequence: 1),
        GtfsStopTime(tripId: 'gt', stopId: 'G2', stopSequence: 2),
      ],
      calendars: {},
      calendarDates: [],
      frequencies: [],
      shapes: {
        'sg': GtfsShape(
          id: 'sg',
          points: [
            GtfsShapePoint(shapeId: 'sg', lat: 0.05, lon: 0.05, sequence: 0),
            GtfsShapePoint(shapeId: 'sg', lat: 0, lon: 0, sequence: 1),
            GtfsShapePoint(shapeId: 'sg', lat: 0.06, lon: 0.05, sequence: 2),
          ],
        ),
      },
    );
    expect(buildService(far).find(anchor).lines, isEmpty);
  });

  test('timing: 400 patterns × 300-point shapes over 2 000 stops', () {
    const routeCount = 400;
    const stopsPerRoute = 5;
    const shapePoints = 300;
    final stops = <String, GtfsStop>{};
    final routes = <String, GtfsRoute>{};
    final trips = <String, GtfsTrip>{};
    final stopTimes = <GtfsStopTime>[];
    final shapes = <String, GtfsShape>{};
    for (var r = 0; r < routeCount; r++) {
      final lat = -0.05 + 0.1 * r / routeCount;
      routes['r$r'] = GtfsRoute(
        id: 'r$r',
        shortName: '$r',
        longName: 'Line $r',
        type: GtfsRouteType.bus,
      );
      trips['t$r'] = GtfsTrip(
        id: 't$r',
        routeId: 'r$r',
        serviceId: 's',
        shapeId: 'sh$r',
      );
      for (var s = 0; s < stopsPerRoute; s++) {
        final id = 'r${r}s$s';
        stops[id] = GtfsStop(
          id: id,
          name: id,
          lat: lat,
          lon: -0.05 + 0.1 * s / (stopsPerRoute - 1),
        );
        stopTimes.add(GtfsStopTime(tripId: 't$r', stopId: id, stopSequence: s));
      }
      shapes['sh$r'] = GtfsShape(
        id: 'sh$r',
        points: [
          for (var p = 0; p < shapePoints; p++)
            GtfsShapePoint(
              shapeId: 'sh$r',
              lat: lat + 0.00001 * (p % 3),
              lon: -0.05 + 0.1 * p / (shapePoints - 1),
              sequence: p,
            ),
        ],
      );
    }
    final big = GtfsData(
      agencies: const [],
      stops: stops,
      routes: routes,
      trips: trips,
      stopTimes: stopTimes,
      calendars: const {},
      calendarDates: const [],
      frequencies: const [],
      shapes: shapes,
    );
    expect(stops, hasLength(2000));
    final bigService = buildService(big);

    final sw = Stopwatch()..start();
    final found = bigService.find(anchor);
    sw.stop();
    // ignore: avoid_print
    print(
      'nearby find over $routeCount patterns: ${sw.elapsedMicroseconds} µs, '
      '${found.lines.length} lines',
    );
    expect(found.lines, isNotEmpty);
    expect(found.lines.every((l) => l.distanceMeters <= 500), isTrue);
    expect(sw.elapsedMilliseconds, lessThan(200));
  });
}
