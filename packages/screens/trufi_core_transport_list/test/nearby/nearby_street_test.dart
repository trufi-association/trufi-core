import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart' show GtfsRouteType;
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

/// The street anchor of the nearby-lines search (trufi-sanaa#20): the
/// model that carries a street's corners and the union that turns one
/// result per corner into one row per line.
NearbyLine row(String name, double distance, {String? routeId}) => NearbyLine(
  lineKey: 'n:$name',
  routeId: routeId ?? name,
  patternId: 0,
  shortName: name,
  longName: 'Line $name',
  routeType: GtfsRouteType.bus,
  distanceMeters: distance,
  kind: NearbyMatchKind.stop,
  stopName: 'Stop $name at ${distance.round()}',
  nearestPoint: LatLng(distance / 111195, 0),
);

NearbyLinesResult result(LatLng anchor, List<NearbyLine> lines) =>
    NearbyLinesResult(anchor: anchor, maxRadiusMeters: 500, lines: lines);

void main() {
  const c1 = LatLng(-17.3925, -66.1588);
  const c2 = LatLng(-17.3907, -66.1571);
  const c3 = LatLng(-17.3890, -66.1554);

  group('NearbyStreetAnchor', () {
    test('drops repeated corner coordinates and keeps the index order', () {
      // A three-way corner is listed once per crossing street in the index.
      final street = NearbyStreetAnchor(
        name: 'Avenida Ayacucho',
        corners: const [c1, c2, c1, c3, c2],
      );
      expect(street.corners, [c1, c2, c3]);
      expect(() => street.corners.add(c1), throwsUnsupportedError);
    });

    test('center is the mean of the corners, null without corners', () {
      final street = NearbyStreetAnchor(name: 'A', corners: const [c1, c3]);
      expect(street.center?.latitude, closeTo((-17.3925 - 17.3890) / 2, 1e-9));
      expect(
        street.center?.longitude,
        closeTo((-66.1588 - 66.1554) / 2, 1e-9),
      );
      expect(NearbyStreetAnchor(name: 'A', corners: const []).center, isNull);
    });

    test('is a value: same name, subtitle and corners are equal', () {
      expect(
        NearbyStreetAnchor(name: 'A', subtitle: 'Cercado', corners: const [c1]),
        NearbyStreetAnchor(name: 'A', subtitle: 'Cercado', corners: const [c1]),
      );
      expect(
        NearbyStreetAnchor(name: 'A', corners: const [c1]),
        isNot(NearbyStreetAnchor(name: 'A', corners: const [c2])),
      );
    });
  });

  group('NearbyLinesResult.union', () {
    test('keeps each line once, at its nearest corner, nearest first', () {
      final union = NearbyLinesResult.union(
        [
          result(c1, [row('201', 80), row('X10', 150)]),
          result(c2, [row('201', 40), row('18', 380)]),
          // Same line, same distance at another corner: a tie, one row.
          result(c3, [row('X10', 150), row('7', 40)]),
        ],
        anchor: c2,
      );

      expect(union.anchor, c2);
      expect(union.maxRadiusMeters, NearbyRadius.maxMeters);
      expect(union.lines.map((l) => l.displayName), ['7', '201', 'X10', '18']);
      expect(union.lines.map((l) => l.distanceMeters), [40, 40, 150, 380]);
      // The 201 row is the c2 match (40 m), not the c1 one (80 m).
      expect(union.lines[1].stopName, 'Stop 201 at 40');
      expect(union.bracketCounts, {
        NearbyRadius.m100: 2,
        NearbyRadius.m300: 3,
        NearbyRadius.m500: 4,
      });
      expect(() => union.lines.clear(), throwsUnsupportedError);
    });

    test('no results, or only empty ones, is an empty result', () {
      expect(NearbyLinesResult.union(const [], anchor: c1).lines, isEmpty);
      expect(
        NearbyLinesResult.union([result(c1, const [])], anchor: c1).lines,
        isEmpty,
      );
    });
  });

  group('NearbyLine.compare', () {
    test('distance, then numeric names before the rest, then the route id', () {
      final lines = [
        row('B', 100),
        row('10', 100),
        row('2', 100),
        row('A', 100, routeId: 'r2'),
        row('A', 100, routeId: 'r1'),
        row('1', 50),
      ]..sort(NearbyLine.compare);
      expect(lines.map((l) => '${l.displayName}/${l.routeId}'), [
        '1/1',
        '2/2',
        '10/10',
        'A/r1',
        'A/r2',
        'B/B',
      ]);
    });
  });
}
