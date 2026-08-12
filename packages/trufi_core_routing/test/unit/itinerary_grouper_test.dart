import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Scenarios distilled from a real OTP 1.5 plan over the Cochabamba GTFS
/// (see issue #737): a transfer search returned 24 itineraries where e.g.
/// legs `123 [A→T]` + `106 [T→D1]` / `120 [T→D2]` are one decision (board
/// the 123) with interchangeable second legs.
///
/// Coordinates are real Cochabamba stops; distances between the D* stops
/// are ~100-160 m (same destination area) and O2 sits ~1.3 km from O1
/// (genuinely different boarding point).
const _origin = (lat: -17.4650, lon: -66.1400); // O1
const _originFar = (lat: -17.4544, lon: -66.1310); // O2, ~1.3 km from O1
const _transfer = (lat: -17.3950, lon: -66.1570); // T
const _transferNear = (lat: -17.3958, lon: -66.1565); // ~105 m from T
const _dest = (lat: -17.3550, lon: -66.1900); // D1
const _destNear = (lat: -17.3563, lon: -66.1908); // ~165 m from D1
const _destSameRouteFar = (lat: -17.3520, lon: -66.1930); // ~450 m from D1

Place _stop(String id, ({double lat, double lon}) at) =>
    Place(name: id, lat: at.lat, lon: at.lon, stopId: id);

Leg _walk({int minutes = 5}) => Leg(
  mode: 'WALK',
  startTime: DateTime(2026, 8, 12, 8),
  endTime: DateTime(2026, 8, 12, 8, minutes),
  duration: Duration(minutes: minutes),
  distance: 300,
  transitLeg: false,
);

Leg _bus(
  String route, {
  required Place from,
  required Place to,
  String? feedPrefix,
}) {
  final gtfsId = feedPrefix != null ? '$feedPrefix:$route' : route;
  return Leg(
    mode: 'BUS',
    startTime: DateTime(2026, 8, 12, 8),
    endTime: DateTime(2026, 8, 12, 8, 30),
    duration: const Duration(minutes: 30),
    distance: 5000,
    transitLeg: true,
    route: Route(gtfsId: gtfsId, shortName: route),
    shortName: route,
    fromPlace: from,
    toPlace: to,
  );
}

Itinerary _itinerary(List<Leg> legs, {int startMinute = 0}) => Itinerary(
  legs: legs,
  startTime: DateTime(2026, 8, 12, 8, startMinute),
  endTime: DateTime(2026, 8, 12, 9, startMinute),
  walkTime: const Duration(minutes: 10),
  duration: const Duration(hours: 1),
  walkDistance: 600,
);

void main() {
  final o1 = _stop('stop_o1', _origin);
  final t = _stop('stop_t', _transfer);
  final tNear = _stop('stop_t2', _transferNear);
  final d1 = _stop('stop_d1', _dest);
  final d2 = _stop('stop_d2', _destNear);

  group('groupItineraries', () {
    test('empty input returns no groups', () {
      expect(groupItineraries(const []), isEmpty);
    });

    test('A→B and A→C with a shared first leg merge into one row', () {
      final aThenB = _itinerary([
        _walk(),
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: d1),
        _walk(),
      ]);
      final aThenC = _itinerary(
        [
          _walk(),
          _bus('123', from: o1, to: t),
          _bus('120', from: tNear, to: d2),
          _walk(),
        ],
        startMinute: 4,
      );

      final groups = groupItineraries([aThenB, aThenC]);

      expect(groups, hasLength(1));
      expect(groups.single.representative, same(aThenB));
      expect(groups.single.alternatives, [aThenB, aThenC]);
      expect(groups.single.hasRouteAlternatives, isTrue);
      expect(
        groups.single.slotRoutes[1].map((r) => r.shortName),
        ['106', '120'],
      );
    });

    test('different main buses never merge, even sharing the second leg', () {
      // Real case: routes 18 and 8 converge into the same second leg. The
      // main bus is a different decision — separate rows (product rule:
      // group only what shares the main bus).
      final viaRoute18 = _itinerary([
        _bus('18', from: o1, to: t),
        _bus('120', from: t, to: d1),
      ]);
      final viaRoute8 = _itinerary([
        _bus('8', from: o1, to: t),
        _bus('120', from: t, to: d1),
      ]);

      expect(groupItineraries([viaRoute18, viaRoute8]), hasLength(2));
    });

    test('same main bus boarding too far apart stays separate', () {
      final o2 = _stop('stop_o2', _originFar); // ~1.3 km from o1
      final near = _itinerary([
        _bus('18', from: o1, to: t),
        _bus('120', from: t, to: d1),
      ]);
      final far = _itinerary([
        _bus('18', from: o2, to: t),
        _bus('120', from: t, to: d1),
      ]);

      expect(groupItineraries([near, far]), hasLength(2));
    });

    test('same route alighting a few stops later still groups (wider '
        'tolerance for the same bus)', () {
      final dFar = _stop('stop_d3', _destSameRouteFar);
      final short = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: d1),
      ]);
      final long = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: dFar),
      ], startMinute: 2);

      final groups = groupItineraries([short, long]);
      expect(groups, hasLength(1));
      expect(groups.single.hasRouteAlternatives, isFalse);
    });

    test('connections are options with no constraint of their own — same '
        'main bus groups even when the second legs end far apart', () {
      final dFar = _stop('stop_d3', _destSameRouteFar);
      final one = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: d1),
      ]);
      final other = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('290', from: t, to: dFar),
      ]);

      final groups = groupItineraries([one, other]);
      expect(groups, hasLength(1));
      expect(groups.single.hasRouteAlternatives, isTrue);
      expect(
        groups.single.slotRoutes[1].map((r) => r.shortName),
        ['106', '290'],
      );
    });

    test('feed prefixes do not break matching across providers', () {
      // OTP emits `1:123`, the local planner raw `123` (PR #982 lesson).
      final otp = _itinerary([
        _bus('123', from: o1, to: t, feedPrefix: '1'),
        _bus('106', from: t, to: d1, feedPrefix: '1'),
      ]);
      final local = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: d1),
      ], startMinute: 6);

      final groups = groupItineraries([otp, local]);
      expect(groups, hasLength(1));
      expect(groups.single.hasRouteAlternatives, isFalse);
      expect(groups.single.slotRoutes[0], hasLength(1));
    });

    test('walk-only itineraries collapse into one walk group', () {
      final walkA = _itinerary([_walk()]);
      final walkB = _itinerary([_walk(minutes: 8)], startMinute: 1);
      final transit = _itinerary([_bus('17', from: o1, to: d1)]);

      final groups = groupItineraries([walkA, transit, walkB]);
      expect(groups, hasLength(2));
      expect(groups.first.alternatives, [walkA, walkB]);
      expect(groups.first.signature, 'walk');
      expect(groups.first.slotRoutes, isEmpty);
    });

    test('different transfer counts never merge', () {
      final direct = _itinerary([_bus('17', from: o1, to: d1)]);
      final withTransfer = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: d1),
      ]);

      expect(groupItineraries([direct, withTransfer]), hasLength(2));
    });

    test('even with the SAME main bus, direct and transfer never merge — '
        'they are different products', () {
      // Guards the slot-count check on its own: the previous test already
      // fails via the route key, this one only via the leg count.
      final direct = _itinerary([_bus('123', from: o1, to: t)]);
      final withConnection = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: d1),
      ]);

      expect(groupItineraries([direct, withConnection]), hasLength(2));
    });

    test('ranking is preserved: groups keep the order of their best member '
        'and the first representative is the first itinerary', () {
      final best = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: d1),
      ]);
      final second = _itinerary([_bus('17', from: o1, to: d1)]);
      // Duplicate of `best` ranked last, departing earlier.
      final laterDuplicate = _itinerary(
        [
          _bus('123', from: o1, to: t),
          _bus('120', from: tNear, to: d2),
        ],
        // Earlier departure than `best`: must NOT displace it as
        // representative.
        startMinute: 0,
      );

      final groups = groupItineraries([best, second, laterDuplicate]);

      expect(groups, hasLength(2));
      expect(groups.first.representative, same(best));
      expect(groups.first.alternatives.first, same(best));
      expect(groups[1].representative, same(second));
    });

    test('alternatives beyond the representative are sorted by start time',
        () {
      final rep = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: d1),
      ], startMinute: 10);
      final early = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: d1),
      ], startMinute: 0);
      final late = _itinerary([
        _bus('123', from: o1, to: t),
        _bus('106', from: t, to: d1),
      ], startMinute: 20);

      final groups = groupItineraries([rep, late, early]);
      expect(groups, hasLength(1));
      expect(groups.single.alternatives, [rep, early, late]);
    });

    test('signatures are unique across groups', () {
      final o2 = _stop('stop_o2', _originFar);
      final groups = groupItineraries([
        _itinerary([_bus('18', from: o1, to: t)]),
        _itinerary([_bus('8', from: o2, to: t)]),
      ]);
      expect(groups, hasLength(2));
      expect(groups[0].signature, isNot(groups[1].signature));
    });

    test('unidentifiable main buses fail closed: no grouping', () {
      // A feed with no route names/ids: "same main bus" cannot be
      // established, so nothing merges (better N honest rows than a group
      // that mixes different buses).
      Leg nameless({required Place from, required Place to}) => Leg(
        mode: 'BUS',
        startTime: DateTime(2026, 8, 12, 8),
        endTime: DateTime(2026, 8, 12, 8, 30),
        duration: const Duration(minutes: 30),
        distance: 5000,
        transitLeg: true,
        fromPlace: from,
        toPlace: to,
      );

      final groups = groupItineraries([
        _itinerary([nameless(from: o1, to: d1)]),
        _itinerary([nameless(from: o1, to: d1)], startMinute: 5),
      ]);

      expect(groups, hasLength(2));
    });

    test('walk-only and bike-only are different options, not departures',
        () {
      Leg bike() => Leg(
        mode: 'BICYCLE',
        startTime: DateTime(2026, 8, 12, 8),
        endTime: DateTime(2026, 8, 12, 8, 20),
        duration: const Duration(minutes: 20),
        distance: 4000,
        transitLeg: false,
      );

      final groups = groupItineraries([
        _itinerary([_walk()]),
        _itinerary([bike()], startMinute: 1),
      ]);

      expect(groups, hasLength(2));
      expect(groups[0].signature, isNot(groups[1].signature));
    });

    test('legs without stops group only on the exact same route', () {
      // Defensive: a provider that fills neither stopId nor coordinates.
      Leg bare(String route) => Leg(
        mode: 'BUS',
        startTime: DateTime(2026, 8, 12, 8),
        endTime: DateTime(2026, 8, 12, 8, 30),
        duration: const Duration(minutes: 30),
        distance: 5000,
        transitLeg: true,
        route: Route(gtfsId: route, shortName: route),
      );

      final sameRoute = groupItineraries([
        _itinerary([bare('42')]),
        _itinerary([bare('42')], startMinute: 5),
      ]);
      expect(sameRoute, hasLength(1));

      final differentRoute = groupItineraries([
        _itinerary([bare('42')]),
        _itinerary([bare('43')]),
      ]);
      expect(differentRoute, hasLength(2));
    });
  });
}
