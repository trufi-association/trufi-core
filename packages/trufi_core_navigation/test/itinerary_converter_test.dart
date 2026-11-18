import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_navigation/trufi_core_navigation.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

import 'support/navigation_fixtures.dart';

/// `ItineraryConverter.toNavigationRoute` builds the stop list the whole
/// navigation runs on (start index, auto-advance, ETA, progress bar). #1059
/// adds one thing to it — the stops a transit leg only passes are flagged
/// [NavigationStop.isIntermediate] — and must not change which stops there
/// are or their order.
void main() {
  group('ItineraryConverter.toNavigationRoute', () {
    test('walk → bus → walk: the origin, the boarding stop, every '
        'intermediate place, the alighting stop and the destination', () {
      final route = ItineraryConverter.toNavigationRoute(SanaaTrip.itinerary());

      expect(route.stops, hasLength(48));
      expect(route.stops.map((stop) => stop.id), [
        for (var i = 0; i < 48; i++) 'stop-$i',
      ]);
      expect(route.stops.map((stop) => stop.name), [
        'Home',
        'Boarding stop',
        for (var i = 1; i <= 44; i++) 'Way node $i',
        'Alighting stop',
        'University',
      ]);
      expect(route.stops.map((stop) => stop.position), [
        SanaaTrip.origin,
        SanaaTrip.boarding,
        ...SanaaTrip.nodes,
        SanaaTrip.alighting,
        SanaaTrip.destination,
      ]);
    });

    test('only the places a transit leg passes are intermediate', () {
      final route = ItineraryConverter.toNavigationRoute(SanaaTrip.itinerary());

      expect(route.stops.map((stop) => stop.isIntermediate), [
        false, // Home
        false, // Boarding stop
        for (var i = 1; i <= 44; i++) true,
        false, // Alighting stop
        false, // University
      ]);
    });

    test('the legs keep their kind, line, color and duration', () {
      final route = ItineraryConverter.toNavigationRoute(SanaaTrip.itinerary());

      expect(route.legs.map((leg) => leg.id), ['leg-0', 'leg-1', 'leg-2']);
      expect(route.legs.map((leg) => leg.isWalking), [true, false, true]);
      expect(route.legs.map((leg) => leg.isTransit), [false, true, false]);
      expect(route.legs.map((leg) => leg.isBicycle), [false, false, false]);
      expect(route.legs.map((leg) => leg.modeName), ['WALK', 'BUS', 'WALK']);
      expect(route.legs.map((leg) => leg.routeName), [null, '7', null]);
      expect(route.legs.map((leg) => leg.color), [null, 0xFF1E88E5, null]);
      expect(route.legs.map((leg) => leg.duration.inMinutes), [2, 30, 3]);
      expect(route.legs[1].points, SanaaTrip.line);
    });

    test('the route takes its identity from the transit leg and its '
        'duration and geometry from the whole itinerary', () {
      final route = ItineraryConverter.toNavigationRoute(SanaaTrip.itinerary());

      expect(route.id, startsWith('route-'));
      expect(route.code, '7');
      expect(route.shortName, '7');
      expect(route.name, 'Line 7');
      expect(route.displayName, '7');
      expect(route.backgroundColor, 0xFF1E88E5);
      expect(route.duration, const Duration(minutes: 35));
      expect(route.geometry, [
        SanaaTrip.origin,
        SanaaTrip.boarding,
        ...SanaaTrip.line,
        SanaaTrip.alighting,
        SanaaTrip.destination,
      ]);
    });

    test('a transfer keeps both lines in order: each leg end once, each '
        "leg's intermediate places flagged", () {
      const transferFrom = LatLng(15.36, 44.21);
      const transferTo = LatLng(15.3605, 44.2105);
      const second = LatLng(15.365, 44.215);
      const end = LatLng(15.37, 44.22);

      final route = ItineraryConverter.toNavigationRoute(
        SanaaTrip.itineraryOf([
          SanaaTrip.busLeg(
            from: SanaaTrip.place('Boarding stop', SanaaTrip.boarding),
            to: SanaaTrip.place('Transfer out', transferFrom),
            points: [SanaaTrip.boarding, SanaaTrip.node(1), transferFrom],
            intermediatePlaces: [
              SanaaTrip.place('Way node 1', SanaaTrip.node(1)),
            ],
            startMinute: 0,
            minutes: 10,
          ),
          SanaaTrip.walkLeg(
            from: SanaaTrip.place('Transfer out', transferFrom),
            to: SanaaTrip.place('Transfer in', transferTo),
            points: [transferFrom, transferTo],
            startMinute: 10,
            minutes: 1,
          ),
          SanaaTrip.busLeg(
            from: SanaaTrip.place('Transfer in', transferTo),
            to: SanaaTrip.place('University', end),
            points: [transferTo, second, end],
            intermediatePlaces: [SanaaTrip.place('Way node 90', second)],
            startMinute: 11,
            minutes: 12,
            shortName: '12',
            longName: 'Line 12',
            color: 'E53935',
          ),
        ]),
      );

      expect(route.stops.map((stop) => stop.name), [
        'Boarding stop',
        'Way node 1',
        'Transfer out',
        'Transfer in',
        'Way node 90',
        'University',
      ]);
      expect(route.stops.map((stop) => stop.isIntermediate), [
        false,
        true,
        false,
        false,
        true,
        false,
      ]);
      // The first transit leg names the route; every leg keeps its own line.
      expect(route.code, '7');
      expect(route.name, 'Line 7');
      expect(route.legs.map((leg) => leg.routeName), ['7', null, '12']);
      expect(route.legs.map((leg) => leg.color), [
        0xFF1E88E5,
        null,
        0xFFE53935,
      ]);
      expect(route.duration, const Duration(minutes: 23));
    });

    test('a transit leg without intermediate places is its two ends', () {
      for (final places in <List<routing.Place>?>[null, const []]) {
        final route = ItineraryConverter.toNavigationRoute(
          SanaaTrip.itineraryOf([
            SanaaTrip.busLeg(
              from: SanaaTrip.place('Boarding stop', SanaaTrip.boarding),
              to: SanaaTrip.place('Alighting stop', SanaaTrip.alighting),
              points: SanaaTrip.line,
              intermediatePlaces: places,
              startMinute: 0,
              minutes: 30,
            ),
          ]),
        );

        expect(route.stops.map((stop) => stop.name), [
          'Boarding stop',
          'Alighting stop',
        ]);
        expect(route.stops.any((stop) => stop.isIntermediate), isFalse);
      }
    });

    test('only transit legs contribute intermediate places', () {
      final walk =
          SanaaTrip.walkLeg(
            from: SanaaTrip.place('Home', SanaaTrip.origin),
            to: SanaaTrip.place('University', SanaaTrip.destination),
            points: [SanaaTrip.origin, SanaaTrip.destination],
            startMinute: 0,
            minutes: 12,
          ).copyWith(
            intermediatePlaces: [
              SanaaTrip.place('A corner', SanaaTrip.boarding),
            ],
          );

      final route = ItineraryConverter.toNavigationRoute(
        SanaaTrip.itineraryOf([walk]),
      );

      expect(route.stops.map((stop) => stop.name), ['Home', 'University']);
      // No transit leg: the route falls back to the labels.
      expect(route.code, 'ROUTE');
      expect(route.name, 'Route');
      expect(route.shortName, isNull);
      expect(route.backgroundColor, isNull);
    });

    test('unnamed places take the labels, the English ones by default', () {
      routing.Itinerary unnamed() => SanaaTrip.itineraryOf([
        SanaaTrip.walkLeg(
          from: SanaaTrip.place('', SanaaTrip.origin),
          to: SanaaTrip.place('', SanaaTrip.boarding),
          points: [SanaaTrip.origin, SanaaTrip.boarding],
          startMinute: 0,
          minutes: 2,
        ),
        SanaaTrip.walkLeg(
          from: SanaaTrip.place('', SanaaTrip.boarding),
          to: SanaaTrip.place('', SanaaTrip.destination),
          points: [SanaaTrip.boarding, SanaaTrip.destination],
          startMinute: 2,
          minutes: 9,
        ),
      ]);

      expect(
        ItineraryConverter.toNavigationRoute(
          unnamed(),
        ).stops.map((stop) => stop.name),
        ['Origin', 'Transfer', 'Destination'],
      );
      final localized = ItineraryConverter.toNavigationRoute(
        unnamed(),
        originLabel: 'Origen',
        transferLabel: 'Transbordo',
        destinationLabel: 'Destino',
        routeLabel: 'Ruta',
      );
      expect(localized.stops.map((stop) => stop.name), [
        'Origen',
        'Transbordo',
        'Destino',
      ]);
      expect(localized.name, 'Ruta');
    });

    test('legs without places fall back to the ends of their geometry', () {
      final route = ItineraryConverter.toNavigationRoute(
        SanaaTrip.itineraryOf([
          SanaaTrip.walkLeg(
            from: null,
            to: null,
            points: [SanaaTrip.origin, SanaaTrip.boarding],
            startMinute: 0,
            minutes: 2,
          ),
          SanaaTrip.busLeg(
            from: null,
            to: null,
            points: SanaaTrip.line,
            intermediatePlaces: null,
            startMinute: 2,
            minutes: 30,
          ),
        ]),
      );

      expect(route.stops.map((stop) => stop.name), [
        'Origin',
        'Transfer',
        'Destination',
      ]);
      expect(route.stops.map((stop) => stop.position), [
        SanaaTrip.origin,
        SanaaTrip.boarding,
        SanaaTrip.alighting,
      ]);
    });
  });
}
