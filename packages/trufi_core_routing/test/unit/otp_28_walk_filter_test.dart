import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

Itinerary _walk(double meters) => Itinerary(
  legs: [
    Leg(
      mode: 'WALK',
      startTime: DateTime(2026, 1, 1, 12),
      endTime: DateTime(2026, 1, 1, 13),
      duration: const Duration(hours: 1),
      distance: meters,
      transitLeg: false,
    ),
  ],
  startTime: DateTime(2026, 1, 1, 12),
  endTime: DateTime(2026, 1, 1, 13),
  duration: const Duration(hours: 1),
  walkDistance: meters,
  walkTime: const Duration(hours: 1),
);

Itinerary _transit() => Itinerary(
  legs: [
    Leg(
      mode: 'BUS',
      startTime: DateTime(2026, 1, 1, 12),
      endTime: DateTime(2026, 1, 1, 13),
      duration: const Duration(hours: 1),
      distance: 5000,
      transitLeg: true,
    ),
  ],
  startTime: DateTime(2026, 1, 1, 12),
  endTime: DateTime(2026, 1, 1, 13),
  duration: const Duration(hours: 1),
  walkDistance: 200,
  walkTime: const Duration(minutes: 3),
);

void main() {
  group('Otp28RoutingProvider.filterLongWalks (issue #900)', () {
    test('keeps long walks when the rider asked for walk-only routes', () {
      final result = Otp28RoutingProvider.filterLongWalks([
        _walk(3992),
      ], walkOnlyRequested: true);
      expect(result, hasLength(1));
    });

    test('still drops long walk noise from transit searches', () {
      final result = Otp28RoutingProvider.filterLongWalks([
        _transit(),
        _walk(3992),
      ], walkOnlyRequested: false);
      expect(result, hasLength(1));
      expect(result!.single.legs.single.transitLeg, isTrue);
    });

    test('short walks survive either way', () {
      for (final walkOnly in [true, false]) {
        final result = Otp28RoutingProvider.filterLongWalks([
          _walk(800),
        ], walkOnlyRequested: walkOnly);
        expect(result, hasLength(1), reason: 'walkOnlyRequested=$walkOnly');
      }
    });

    test('null itineraries pass through', () {
      expect(
        Otp28RoutingProvider.filterLongWalks(null, walkOnlyRequested: false),
        isNull,
      );
    });
  });
}
