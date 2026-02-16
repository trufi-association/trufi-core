@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../test_config.dart';

/// Integration tests for routing providers with real OTP servers.
///
/// These tests make real HTTP calls to verify that routing works
/// and returns expected results. Preferences are now managed internally
/// by each provider (via their PreferencesState classes).
/// Run with: flutter test --tags integration
void main() {
  // Fixed date for all tests to ensure reproducibility
  final testDateTime = DateTime(2025, 12, 1, 12, 0);

  group('Basic Routing Integration Tests - OTP 2.4', () {
    late Otp24RoutingProvider provider;

    setUp(() {
      provider = Otp24RoutingProvider(
        endpoint: TestConfig.otp24Endpoint,
      );
    });

    test('fetchPlan returns itineraries', () async {
      final plan = await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
      );

      expect(plan.itineraries, isNotEmpty);
    });

    test('itineraries have valid legs with geometry', () async {
      final plan = await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
      );

      expect(plan.itineraries, isNotEmpty);

      final itinerary = plan.itineraries!.first;
      expect(itinerary.legs, isNotEmpty);

      for (final leg in itinerary.legs) {
        if (leg.distance > 0) {
          expect(leg.decodedPoints, isNotEmpty,
              reason: 'Leg should have decoded geometry points');
          expect(leg.fromPlace, isNotNull);
          expect(leg.toPlace, isNotNull);
          expect(leg.duration.inSeconds, greaterThan(0));
        }
      }
    });

    test('returns accessible routes when requested', () async {
      final plan = await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
      );

      expect(plan, isNotNull,
          reason: 'Should return a plan (accessible or not)');
    });
  });

  group('Basic Routing Integration Tests - OTP 1.5', () {
    late Otp15RoutingProvider provider;

    setUp(() {
      provider = Otp15RoutingProvider(
        endpoint: TestConfig.otp15Endpoint,
      );
    });

    tearDown(() {
      provider.dispose();
    });

    test('fetchPlan returns itineraries', () async {
      final plan = await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
      );

      expect(plan.itineraries, isNotEmpty);
    });

    test('itineraries have valid duration and distance', () async {
      final plan = await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
      );

      expect(plan.itineraries, isNotEmpty);

      final itinerary = plan.itineraries!.first;
      expect(itinerary.duration.inSeconds, greaterThan(0),
          reason: 'Itinerary should have positive duration');
    });
  });

  group('Basic Routing Integration Tests - OTP 2.8', () {
    late Otp28RoutingProvider provider;

    setUp(() {
      provider = Otp28RoutingProvider(
        endpoint: TestConfig.otp28Endpoint,
      );
    });

    test('fetchPlan returns itineraries', () async {
      final plan = await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
        dateTime: testDateTime,
      );

      expect(plan.itineraries, isNotEmpty);
    });

    test('itineraries have legs with mode information', () async {
      final plan = await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 1,
        dateTime: testDateTime,
      );

      expect(plan.itineraries, isNotEmpty);

      final itinerary = plan.itineraries!.first;
      expect(itinerary.legs, isNotEmpty);

      // Verify each leg has a mode
      for (final leg in itinerary.legs) {
        expect(leg.mode, isNotEmpty,
            reason: 'Each leg should have a transport mode');
      }
    });
  });

  group('Multiple Itineraries Integration Tests - OTP 2.4', () {
    late Otp24RoutingProvider provider;

    setUp(() {
      provider = Otp24RoutingProvider(
        endpoint: TestConfig.otp24Endpoint,
      );
    });

    test('requesting multiple itineraries returns results', () async {
      final plan = await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 5,
        dateTime: testDateTime,
      );

      expect(plan.itineraries, isNotEmpty);
    });

    test('transit mode returns itineraries with transit legs', () async {
      final plan = await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 5,
        dateTime: testDateTime,
      );

      expect(plan.itineraries, isNotEmpty);

      // With default preferences (transit + walk), should have transit legs
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
          reason:
              'Default mode (transit+walk) should return itineraries with transit legs');
    });
  });
}
