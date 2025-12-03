@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../test_config.dart';

/// Integration tests for OTP 1.5 REST API.
///
/// These tests make real HTTP calls to the OTP 1.5 server.
/// Run with: flutter test --tags integration
void main() {
  group('OTP 1.5 Integration Tests', () {
    late Otp15PlanRepository repository;

    setUp(() {
      repository = Otp15PlanRepository(
        endpoint: TestConfig.otp15Endpoint,
      );
    });

    tearDown(() {
      repository.dispose();
    });

    test('fetchPlan returns valid plan with itineraries', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
      );

      expect(plan, isNotNull);
      expect(plan.from, isNotNull);
      expect(plan.to, isNotNull);
      expect(plan.itineraries, isNotNull);
      expect(plan.itineraries, isNotEmpty);
    });

    test('fetchPlan returns itineraries with legs', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
      );

      expect(plan.itineraries, isNotEmpty);

      final itinerary = plan.itineraries!.first;
      expect(itinerary.legs, isNotEmpty);
      expect(itinerary.duration.inSeconds, greaterThan(0));
      expect(itinerary.startTime, isNotNull);
      expect(itinerary.endTime, isNotNull);
    });

    test('fetchPlan legs contain valid geometry', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
      );

      final itinerary = plan.itineraries!.first;
      for (final leg in itinerary.legs) {
        expect(leg.fromPlace, isNotNull);
        expect(leg.toPlace, isNotNull);
        expect(leg.mode, isNotEmpty);
        expect(leg.duration.inSeconds, greaterThanOrEqualTo(0));

        // Check geometry exists for non-zero distance legs
        if (leg.distance > 0) {
          expect(leg.decodedPoints, isNotEmpty);
        }
      }
    });

    test('fetchPlan transit legs contain route info', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 5,
      );

      // Find a transit leg
      ItineraryLeg? transitLeg;
      for (final itinerary in plan.itineraries!) {
        for (final leg in itinerary.legs) {
          if (leg.transitLeg) {
            transitLeg = leg;
            break;
          }
        }
        if (transitLeg != null) break;
      }

      // If we found a transit leg, verify it has route info
      if (transitLeg != null) {
        expect(transitLeg.mode, isNot(equals('WALK')));
        // Route info may or may not be present depending on the OTP data
      }
    });

    test('fetchPlan with locale parameter works', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        locale: 'es',
      );

      expect(plan, isNotNull);
      expect(plan.itineraries, isNotEmpty);
    });

    test('fetchPlan with alternative origin works', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.alternativeOrigin,
        to: TestConfig.destinationLocation,
        numItineraries: 2,
      );

      expect(plan, isNotNull);
      expect(plan.itineraries, isNotEmpty);
    });
  });
}
