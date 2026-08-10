import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// The provider re-orders OTP's arrival-time list by the router's own
/// generalized cost (#849, #847). The fixture numbers are the real
/// Sacaba → UMSS measurement against the Cochabamba production graph:
/// a same-line transfer (233+233, 34 min, cost 3552) came back FIRST,
/// above a direct 241 (33 min, cost 2587).
Itinerary _itinerary({
  required int minutes,
  int? cost,
  int transitLegs = 1,
}) {
  final start = DateTime(2026, 8, 11, 12);
  final end = start.add(Duration(minutes: minutes));
  return Itinerary(
    legs: [
      for (var i = 0; i < transitLegs; i++)
        Leg(
          mode: 'BUS',
          startTime: start,
          endTime: end,
          duration: Duration(minutes: minutes ~/ transitLegs),
          distance: 5000,
          transitLeg: true,
        ),
    ],
    startTime: start,
    endTime: end,
    duration: Duration(minutes: minutes),
    walkDistance: 200,
    walkTime: const Duration(minutes: 3),
    generalizedCost: cost,
  );
}

void main() {
  group('Otp28RoutingProvider.sortByGeneralizedCost (#849)', () {
    test('the direct ride the router priced best comes first', () {
      final sameLineTransfer = _itinerary(
        minutes: 34,
        cost: 3552,
        transitLegs: 2,
      );
      final direct = _itinerary(minutes: 33, cost: 2587);
      final otherDirect = _itinerary(minutes: 33, cost: 2835);

      final sorted = Otp28RoutingProvider.sortByGeneralizedCost([
        sameLineTransfer, // OTP's arrival order put the transfer first
        direct,
        otherDirect,
      ]);

      expect(sorted, [direct, otherDirect, sameLineTransfer]);
    });

    test('equal costs keep the arrival order (stable beyond 32 items)', () {
      // Dart's List.sort is only de-facto stable below ~32 elements —
      // a fixture this size is what catches a stability regression.
      final itineraries = [
        for (var i = 0; i < 40; i++) _itinerary(minutes: 30 + i, cost: 1000),
      ];

      final sorted = Otp28RoutingProvider.sortByGeneralizedCost(itineraries);

      expect(sorted, itineraries);
    });

    test('unpriced itineraries sink below priced ones, keeping their '
        'relative order', () {
      final unpricedA = _itinerary(minutes: 20);
      final unpricedB = _itinerary(minutes: 25);
      final priced = _itinerary(minutes: 40, cost: 5000);

      final sorted = Otp28RoutingProvider.sortByGeneralizedCost([
        unpricedA,
        priced,
        unpricedB,
      ]);

      expect(sorted, [priced, unpricedA, unpricedB]);
    });

    test('null and short lists pass through untouched', () {
      expect(Otp28RoutingProvider.sortByGeneralizedCost(null), isNull);
      final single = [_itinerary(minutes: 10, cost: 1)];
      expect(Otp28RoutingProvider.sortByGeneralizedCost(single), same(single));
    });
  });

  group('Itinerary.generalizedCost parsing', () {
    test('round-trips through JSON', () {
      final json = _itinerary(minutes: 33, cost: 2587).toJson();
      expect(json['generalizedCost'], 2587);
      expect(Itinerary.fromJson(json).generalizedCost, 2587);
    });

    test('absent cost stays null (older servers)', () {
      final json = _itinerary(minutes: 33).toJson()..remove('generalizedCost');
      expect(Itinerary.fromJson(json).generalizedCost, isNull);
    });
  });
}
