import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

// #1005: a saved route is the pair of endpoints plus an informative snapshot
// of the itinerary the user saved. It must survive a JSON round trip through
// SharedPreferences (also on web, where integral doubles come back as ints).

// ~1e-5° of latitude ≈ 1.1 m.
const _degPerMeterLat = 1 / 111_000;

const _origin = SavedRoutePoint(
  name: 'Casa',
  latitude: -17.39884,
  longitude: -66.16269,
);
const _destination = SavedRoutePoint(
  name: 'Trabajo',
  latitude: -17.37,
  longitude: -66.15,
  address: 'Av. América',
);
const _snapshot = SavedRouteSnapshot(
  transitLegs: [
    SavedRouteTransitLeg(shortName: 'B301', colorHex: '7E57C2'),
    SavedRouteTransitLeg(shortName: 'T105'),
  ],
  distanceMeters: 5000,
  durationSeconds: 1800,
);

SavedRoute _route({SavedRouteSnapshot? snapshot = _snapshot}) => SavedRoute(
  id: 'r1',
  name: 'Casa a Trabajo',
  origin: _origin,
  destination: _destination,
  createdAt: DateTime(2026, 10, 13, 10),
  lastUsedAt: DateTime(2026, 10, 13, 12),
  snapshot: snapshot,
);

SavedRoute _roundTrip(SavedRoute route) => SavedRoute.fromJson(
  jsonDecode(jsonEncode(route.toJson())) as Map<String, dynamic>,
);

void main() {
  group('SavedRoute JSON', () {
    test('round-trips with a snapshot', () {
      final original = _route();
      expect(_roundTrip(original), original);
    });

    test('round-trips without a snapshot and without lastUsedAt', () {
      final original = SavedRoute(
        id: 'r2',
        name: 'Sin viaje',
        origin: _origin,
        destination: _destination,
        createdAt: DateTime(2026, 1, 1),
      );
      final restored = _roundTrip(original);
      expect(restored, original);
      expect(restored.snapshot, isNull);
      expect(restored.lastUsedAt, isNull);
    });

    test('decodes integral coordinates stored as ints (web JSON)', () {
      final point = SavedRoutePoint.fromJson({
        'name': 'Plaza',
        'latitude': -17,
        'longitude': -66,
        'address': null,
      });
      expect(point.latitude, -17.0);
      expect(point.longitude, -66.0);
    });
  });

  group('SavedRoute.swapped', () {
    test('exchanges the endpoints, keeps identity, drops the snapshot', () {
      final route = _route();
      final swapped = route.swapped();
      expect(swapped.origin, route.destination);
      expect(swapped.destination, route.origin);
      expect(swapped.snapshot, isNull);
      expect(swapped.id, route.id);
      expect(swapped.name, route.name);
      expect(swapped.createdAt, route.createdAt);
      expect(swapped.lastUsedAt, route.lastUsedAt);
    });

    test('swapping twice restores the endpoints', () {
      final route = _route(snapshot: null);
      expect(route.swapped().swapped(), route);
    });
  });

  group('SavedRoutePoint.isNear', () {
    test('10 m apart is near, 500 m apart is not (50 m radius)', () {
      SavedRoutePoint shifted(double meters) => SavedRoutePoint(
        name: 'x',
        latitude: _origin.latitude + meters * _degPerMeterLat,
        longitude: _origin.longitude,
      );
      expect(_origin.isNear(shifted(10), radiusMeters: 50), isTrue);
      expect(_origin.isNear(shifted(500), radiusMeters: 50), isFalse);
    });
  });

  group('SavedRoute.isSameTripAs', () {
    test('same direction within the radius matches, reversed does not', () {
      final route = _route();
      expect(route.isSameTripAs(_route(), radiusMeters: 50), isTrue);
      expect(route.isSameTripAs(route.swapped(), radiusMeters: 50), isFalse);
    });
  });

  group('SavedRoute.create', () {
    test('sets createdAt and an id carrying both coordinate pairs', () {
      final before = DateTime.now();
      final route = SavedRoute.create(
        name: 'Nueva',
        origin: _origin,
        destination: _destination,
      );
      expect(route.createdAt.isBefore(before), isFalse);
      expect(route.id, contains('${_origin.latitude}_${_origin.longitude}'));
      expect(
        route.id,
        contains('${_destination.latitude}_${_destination.longitude}'),
      );
      expect(route.lastUsedAt, isNull);
      expect(route.snapshot, isNull);
    });
  });

  group('SavedRoutePoint <-> TrufiLocation', () {
    test('keeps name, coordinates and address; tags the type', () {
      const location = TrufiLocation(
        description: 'Terminal',
        latitude: -17.4,
        longitude: -66.2,
        address: 'Av. Ayacucho',
      );
      final point = SavedRoutePoint.fromTrufiLocation(location);
      expect(point.name, 'Terminal');
      expect(point.address, 'Av. Ayacucho');
      final back = point.toTrufiLocation();
      expect(back.description, 'Terminal');
      expect(back.latitude, -17.4);
      expect(back.longitude, -66.2);
      expect(back.address, 'Av. Ayacucho');
      expect(back.type, SavedRoutePoint.locationType);
    });
  });
}
