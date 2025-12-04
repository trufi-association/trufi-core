@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../test_config.dart';

/// Integration tests for OTP 2.8 GraphQL API.
///
/// These tests make real HTTP calls to the OTP 2.8 server.
/// Run with: flutter test --tags integration
void main() {
  group('OTP 2.8 Integration Tests', () {
    late Otp28PlanRepository repository;
    late DateTime testDateTime;

    setUp(() {
      repository = Otp28PlanRepository(
        endpoint: TestConfig.otp28Endpoint,
      );
      
      // Set test time to December 1, 2025 at 12:00 PM (noon)
      testDateTime = DateTime(2025, 12, 1, 12, 0);
    });

    test('fetchPlan returns valid plan with itineraries', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
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
        dateTime: testDateTime,
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
        dateTime: testDateTime,
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

    test('fetchPlan transit legs contain route and agency info', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 5,
        dateTime: testDateTime,
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
        expect(transitLeg.route, isNotNull);
        expect(transitLeg.route!.shortName, isNotNull);

        // OTP 2.8 includes route type
        // expect(transitLeg.route!.type, isNotNull);

        // Agency info should be present with extended fields
        if (transitLeg.agency != null) {
          expect(transitLeg.agency!.name, isNotNull);
          // OTP 2.8 may include timezone
          // expect(transitLeg.agency!.timezone, isNotNull);
        }
      }
    });

    test('fetchPlan with simple query works', () async {
      final simpleRepository = Otp28PlanRepository(
        endpoint: TestConfig.otp28Endpoint,
        useSimpleQuery: true,
      );

      final plan = await simpleRepository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
      );

      expect(plan, isNotNull);
      expect(plan.itineraries, isNotEmpty);
    });

    test('fetchPlan with locale parameter works', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        locale: 'es',
        dateTime: testDateTime,
      );

      expect(plan, isNotNull);
      expect(plan.itineraries, isNotEmpty);
    });

    test('fetchPlan with alternative origin works', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.alternativeOrigin,
        to: TestConfig.destinationLocation,
        numItineraries: 2,
        dateTime: testDateTime,
      );

      expect(plan, isNotNull);
      expect(plan.itineraries, isNotEmpty);
    });

    test('fetchPlan legs may contain walking steps', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
      );

      final itinerary = plan.itineraries!.first;

      // Find a walking leg
      final walkingLeg = itinerary.legs.where((leg) => leg.mode == 'WALK').firstOrNull;

      // If there's a walking leg, it may have steps
      if (walkingLeg != null && walkingLeg.steps != null) {
        expect(walkingLeg.steps, isNotEmpty);
        for (final step in walkingLeg.steps!) {
          expect(step.distance, greaterThanOrEqualTo(0));
        }
      }
    });
  });
}
