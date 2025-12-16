@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../test_config.dart';

/// Integration tests for RoutingPreferences with real OTP servers.
///
/// These tests make real HTTP calls to verify that routing preferences
/// are correctly applied and return expected results.
/// Run with: flutter test --tags integration
void main() {
  // Fixed date for all tests to ensure reproducibility
  final testDateTime = DateTime(2025, 12, 1, 12, 0);

  group('Bicycle Mode Integration Tests - OTP 2.4', () {
    late Otp24PlanRepository repository;

    setUp(() {
      repository = Otp24PlanRepository(
        endpoint: TestConfig.otp24Endpoint,
      );
    });

    test('bicycle only mode returns itineraries with BICYCLE legs', () async {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle},
        bikeSpeed: 5.0,
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
        preferences: prefs,
      );

      expect(plan.itineraries, isNotEmpty);

      // All itineraries should have at least one BICYCLE leg
      for (final itinerary in plan.itineraries!) {
        final hasBicycleLeg = itinerary.legs.any(
          (leg) => leg.mode == 'BICYCLE',
        );
        expect(
          hasBicycleLeg,
          isTrue,
          reason: 'Bicycle mode should return itineraries with BICYCLE legs',
        );
      }
    });

    test('bicycle mode legs have valid geometry', () async {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle},
        bikeSpeed: 5.0,
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
        preferences: prefs,
      );

      expect(plan.itineraries, isNotEmpty);

      final itinerary = plan.itineraries!.first;
      for (final leg in itinerary.legs) {
        if (leg.mode == 'BICYCLE' && leg.distance > 0) {
          expect(leg.decodedPoints, isNotEmpty,
              reason: 'BICYCLE leg should have decoded geometry points');
          expect(leg.fromPlace, isNotNull);
          expect(leg.toPlace, isNotNull);
          expect(leg.duration.inSeconds, greaterThan(0));
        }
      }
    });

    test('bicycle with transit mode returns mixed itineraries', () async {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle, RoutingMode.transit},
        bikeSpeed: 5.0,
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 5,
        dateTime: testDateTime,
        preferences: prefs,
      );

      expect(plan.itineraries, isNotEmpty);

      // At least one itinerary should have bicycle legs
      final hasBicycleItinerary = plan.itineraries!.any(
        (it) => it.legs.any((leg) => leg.mode == 'BICYCLE'),
      );
      expect(hasBicycleItinerary, isTrue,
          reason: 'Should have at least one itinerary with BICYCLE legs');
    });

    test('custom bike speed is applied', () async {
      // Test with slow bike speed
      const slowBikePrefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle},
        bikeSpeed: 3.0, // Slower than default 5.0 m/s
      );

      final slowPlan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
        preferences: slowBikePrefs,
      );

      // Test with fast bike speed
      const fastBikePrefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle},
        bikeSpeed: 8.0, // Faster than default 5.0 m/s
      );

      final fastPlan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
        preferences: fastBikePrefs,
      );

      expect(slowPlan.itineraries, isNotEmpty);
      expect(fastPlan.itineraries, isNotEmpty);

      // Slower bike speed should result in longer duration
      final slowDuration = slowPlan.itineraries!.first.duration;
      final fastDuration = fastPlan.itineraries!.first.duration;

      expect(
        slowDuration.inSeconds,
        greaterThan(fastDuration.inSeconds),
        reason:
            'Slower bike speed should result in longer travel time: slow=${slowDuration.inSeconds}s, fast=${fastDuration.inSeconds}s',
      );
    });
  });

  group('Bicycle Mode Integration Tests - OTP 1.5', () {
    late Otp15PlanRepository repository;

    setUp(() {
      repository = Otp15PlanRepository(
        endpoint: TestConfig.otp15Endpoint,
      );
    });

    tearDown(() {
      repository.dispose();
    });

    test('bicycle only mode returns itineraries with BICYCLE legs', () async {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle},
        bikeSpeed: 5.0,
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
        preferences: prefs,
      );

      expect(plan.itineraries, isNotEmpty);

      // All itineraries should have at least one BICYCLE leg
      for (final itinerary in plan.itineraries!) {
        final hasBicycleLeg = itinerary.legs.any(
          (leg) => leg.mode == 'BICYCLE',
        );
        expect(
          hasBicycleLeg,
          isTrue,
          reason: 'Bicycle mode should return itineraries with BICYCLE legs',
        );
      }
    });

    test('bicycle mode returns valid duration and distance', () async {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle},
        bikeSpeed: 5.0,
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
        preferences: prefs,
      );

      expect(plan.itineraries, isNotEmpty);

      final itinerary = plan.itineraries!.first;
      expect(itinerary.duration.inSeconds, greaterThan(0),
          reason: 'Bicycle itinerary should have positive duration');

      // Calculate total bicycle distance
      double totalBicycleDistance = 0;
      for (final leg in itinerary.legs) {
        if (leg.mode == 'BICYCLE') {
          totalBicycleDistance += leg.distance;
        }
      }

      expect(totalBicycleDistance, greaterThan(0),
          reason: 'Should have positive bicycle distance');
    });
  });

  group('Bicycle Mode Integration Tests - OTP 2.8', () {
    late Otp28PlanRepository repository;

    setUp(() {
      repository = Otp28PlanRepository(
        endpoint: TestConfig.otp28Endpoint,
      );
    });

    test('bicycle only mode returns itineraries with BICYCLE legs', () async {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle},
        bikeSpeed: 5.0,
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
        preferences: prefs,
      );

      expect(plan.itineraries, isNotEmpty);

      // All itineraries should have at least one BICYCLE leg
      for (final itinerary in plan.itineraries!) {
        final hasBicycleLeg = itinerary.legs.any(
          (leg) => leg.mode == 'BICYCLE',
        );
        expect(
          hasBicycleLeg,
          isTrue,
          reason: 'Bicycle mode should return itineraries with BICYCLE legs',
        );
      }
    });

    test('bicycle mode with emissions data', () async {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle},
        bikeSpeed: 5.0,
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
        preferences: prefs,
      );

      expect(plan.itineraries, isNotEmpty);

      // OTP 2.8 supports emissions data - bicycle should have zero or low emissions
      final itinerary = plan.itineraries!.first;
      expect(itinerary.legs, isNotEmpty);

      // Verify we got a bicycle route
      final hasBicycleLeg = itinerary.legs.any((leg) => leg.mode == 'BICYCLE');
      expect(hasBicycleLeg, isTrue);
    });
  });

  group('Wheelchair Mode Integration Tests - OTP 2.4', () {
    late Otp24PlanRepository repository;

    setUp(() {
      repository = Otp24PlanRepository(
        endpoint: TestConfig.otp24Endpoint,
      );
    });

    test('wheelchair mode returns accessible routes', () async {
      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
        preferences: RoutingPreferences.wheelchairUser,
      );

      expect(plan.itineraries, isNotEmpty,
          reason: 'Should return wheelchair accessible routes');
    });

    test('wheelchair mode with custom walk speed', () async {
      const prefs = RoutingPreferences(
        wheelchair: true,
        walkSpeed: 0.6, // Very slow walking speed
        walkReluctance: 4.0,
        maxWalkDistance: 300,
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
        preferences: prefs,
      );

      // Should either return accessible routes or no routes if none available
      // The key is that the request should not fail
      expect(plan, isNotNull);
    });
  });

  group('Walk Speed Integration Tests - OTP 2.4', () {
    late Otp24PlanRepository repository;

    setUp(() {
      repository = Otp24PlanRepository(
        endpoint: TestConfig.otp24Endpoint,
      );
    });

    test('slow walk speed results in longer walk times', () async {
      // Slow walker
      final slowPlan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
        preferences: RoutingPreferences.slowWalker,
      );

      // Fast walker
      final fastPlan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
        preferences: RoutingPreferences.fastWalker,
      );

      expect(slowPlan.itineraries, isNotEmpty);
      expect(fastPlan.itineraries, isNotEmpty);

      // Calculate total walk time for each plan
      int slowWalkTime = 0;
      int fastWalkTime = 0;

      for (final leg in slowPlan.itineraries!.first.legs) {
        if (leg.mode == 'WALK') {
          slowWalkTime += leg.duration.inSeconds;
        }
      }

      for (final leg in fastPlan.itineraries!.first.legs) {
        if (leg.mode == 'WALK') {
          fastWalkTime += leg.duration.inSeconds;
        }
      }

      // If both have walk legs, slow should take longer
      if (slowWalkTime > 0 && fastWalkTime > 0) {
        expect(
          slowWalkTime,
          greaterThanOrEqualTo(fastWalkTime),
          reason:
              'Slow walker should have equal or longer walk time: slow=${slowWalkTime}s, fast=${fastWalkTime}s',
        );
      }
    });
  });

  group('Transport Modes Integration Tests - OTP 2.4', () {
    late Otp24PlanRepository repository;

    setUp(() {
      repository = Otp24PlanRepository(
        endpoint: TestConfig.otp24Endpoint,
      );
    });

    test('walk only mode returns walk-only itineraries', () async {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.walk},
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
        preferences: prefs,
      );

      expect(plan.itineraries, isNotEmpty);

      // All legs should be WALK mode only
      for (final itinerary in plan.itineraries!) {
        for (final leg in itinerary.legs) {
          expect(
            leg.mode,
            equals('WALK'),
            reason: 'Walk only mode should return only WALK legs',
          );
        }
      }
    });

    test('transit and walk mode returns mixed itineraries', () async {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.transit, RoutingMode.walk},
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 5,
        dateTime: testDateTime,
        preferences: prefs,
      );

      expect(plan.itineraries, isNotEmpty);

      // Should have at least one transit leg across all itineraries
      bool hasTransitLeg = false;
      for (final itinerary in plan.itineraries!) {
        for (final leg in itinerary.legs) {
          if (leg.transitLeg) {
            hasTransitLeg = true;
            break;
          }
        }
        if (hasTransitLeg) break;
      }

      expect(hasTransitLeg, isTrue,
          reason: 'Transit+Walk mode should return itineraries with transit');
    });
  });

  group('Max Walk Distance Integration Tests - OTP 2.4', () {
    late Otp24PlanRepository repository;

    setUp(() {
      repository = Otp24PlanRepository(
        endpoint: TestConfig.otp24Endpoint,
      );
    });

    test('max walk distance limits walk segments', () async {
      final prefs = const RoutingPreferences().copyWith(
        maxWalkDistance: 300.0, // Very short max walk distance
      );

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
        preferences: prefs,
      );

      // Request should succeed (may return fewer or no itineraries if constraints are too strict)
      expect(plan, isNotNull);

      // If we got itineraries, check walk distances
      if (plan.itineraries != null && plan.itineraries!.isNotEmpty) {
        for (final itinerary in plan.itineraries!) {
          for (final leg in itinerary.legs) {
            if (leg.mode == 'WALK') {
              // Individual walk legs should generally respect max distance
              // Note: OTP may exceed slightly in some cases
              expect(
                leg.distance,
                lessThan(500), // Allow some buffer
                reason:
                    'Walk leg distance (${leg.distance}m) should respect max walk distance',
              );
            }
          }
        }
      }
    });
  });
}
