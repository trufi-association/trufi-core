import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../test_config.dart';

class MockHttpClient extends Mock implements http.Client {}

/// Unit tests for RoutingPreferences parameters in OTP repositories.
void main() {
  // Fixed date for all tests to ensure reproducibility
  final fixedDate = DateTime(2025, 6, 15, 10, 30);

  group('RoutingPreferences Model', () {
    test('default preferences have correct values', () {
      const prefs = RoutingPreferences();

      expect(prefs.wheelchair, isFalse);
      expect(prefs.walkSpeed, equals(1.33));
      expect(prefs.maxWalkDistance, isNull);
      expect(prefs.walkReluctance, equals(2.0));
      expect(prefs.bikeSpeed, equals(5.0));
      expect(prefs.transportModes, equals({RoutingMode.transit, RoutingMode.walk}));
    });

    test('copyWith creates new instance with updated values', () {
      const prefs = RoutingPreferences();
      final updated = prefs.copyWith(
        wheelchair: true,
        walkSpeed: 0.8,
        maxWalkDistance: 500.0,
      );

      expect(updated.wheelchair, isTrue);
      expect(updated.walkSpeed, equals(0.8));
      expect(updated.maxWalkDistance, equals(500.0));
      // Original unchanged
      expect(prefs.wheelchair, isFalse);
      expect(prefs.walkSpeed, equals(1.33));
    });

    test('copyWith can clear maxWalkDistance', () {
      final prefs = const RoutingPreferences().copyWith(maxWalkDistance: 500.0);
      expect(prefs.maxWalkDistance, equals(500.0));

      final cleared = prefs.copyWith(clearMaxWalkDistance: true);
      expect(cleared.maxWalkDistance, isNull);
    });

    test('walkSpeedLevel returns correct level for speed values', () {
      expect(
        const RoutingPreferences(walkSpeed: 0.5).walkSpeedLevel,
        equals(WalkSpeedLevel.slow),
      );
      expect(
        const RoutingPreferences(walkSpeed: 1.33).walkSpeedLevel,
        equals(WalkSpeedLevel.normal),
      );
      expect(
        const RoutingPreferences(walkSpeed: 1.8).walkSpeedLevel,
        equals(WalkSpeedLevel.fast),
      );
    });

    test('RoutingMode has correct OTP names', () {
      expect(RoutingMode.walk.otpName, equals('WALK'));
      expect(RoutingMode.transit.otpName, equals('TRANSIT'));
      expect(RoutingMode.bicycle.otpName, equals('BICYCLE'));
      expect(RoutingMode.car.otpName, equals('CAR'));
    });

    test('WalkSpeedLevel has correct speed values', () {
      expect(WalkSpeedLevel.slow.speedValue, equals(0.8));
      expect(WalkSpeedLevel.normal.speedValue, equals(1.33));
      expect(WalkSpeedLevel.fast.speedValue, equals(1.8));
    });

    test('WalkSpeedLevel has correct reluctance values', () {
      expect(WalkSpeedLevel.slow.reluctanceValue, equals(3.5));
      expect(WalkSpeedLevel.normal.reluctanceValue, equals(2.0));
      expect(WalkSpeedLevel.fast.reluctanceValue, equals(1.5));
    });

    test('equality works correctly', () {
      const prefs1 = RoutingPreferences();
      const prefs2 = RoutingPreferences();
      const prefs3 = RoutingPreferences(wheelchair: true);

      expect(prefs1, equals(prefs2));
      expect(prefs1, isNot(equals(prefs3)));
    });

    test('predefined preferences have expected values', () {
      expect(RoutingPreferences.slowWalker.walkSpeed, equals(0.8));
      expect(RoutingPreferences.slowWalker.walkReluctance, equals(3.5));
      expect(RoutingPreferences.slowWalker.maxWalkDistance, equals(500));

      expect(RoutingPreferences.fastWalker.walkSpeed, equals(1.8));
      expect(RoutingPreferences.fastWalker.walkReluctance, equals(1.5));

      expect(RoutingPreferences.wheelchairUser.wheelchair, isTrue);
      expect(RoutingPreferences.wheelchairUser.walkSpeed, equals(0.8));
      expect(RoutingPreferences.wheelchairUser.maxWalkDistance, equals(400));
    });
  });

  group('OTP 1.5 Repository - RoutingPreferences', () {
    late MockHttpClient mockHttpClient;
    late Otp15PlanRepository repository;
    late String fixtureResponse;

    setUpAll(() {
      registerFallbackValue(Uri.parse('https://example.com'));
      final file = File('test/fixtures/otp_1_5_response.json');
      fixtureResponse = file.readAsStringSync();
    });

    setUp(() {
      mockHttpClient = MockHttpClient();
      repository = Otp15PlanRepository(
        endpoint: 'https://test-otp.example.com/otp/routers/default/plan',
        httpClient: mockHttpClient,
      );
    });

    tearDown(() {
      repository.dispose();
    });

    test('includes wheelchair parameter when enabled', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      const prefs = RoutingPreferences(wheelchair: true);

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
        preferences: prefs,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['wheelchair'], equals('true'));
    });

    test('includes walkSpeed parameter', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      const prefs = RoutingPreferences(walkSpeed: 0.8);

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
        preferences: prefs,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['walkSpeed'], equals('0.8'));
    });

    test('includes walkReluctance parameter', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      const prefs = RoutingPreferences(walkReluctance: 3.5);

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
        preferences: prefs,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['walkReluctance'], equals('3.5'));
    });

    test('includes maxWalkDistance when set', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      final prefs = const RoutingPreferences().copyWith(maxWalkDistance: 500.0);

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
        preferences: prefs,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['maxWalkDistance'], equals('500.0'));
    });

    test('does not include maxWalkDistance when null', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      const prefs = RoutingPreferences(); // maxWalkDistance is null by default

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
        preferences: prefs,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters.containsKey('maxWalkDistance'), isFalse);
    });

    test('includes bikeSpeed when bicycle mode is selected', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      const prefs = RoutingPreferences(
        bikeSpeed: 6.0,
        transportModes: {RoutingMode.bicycle, RoutingMode.walk},
      );

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
        preferences: prefs,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['bikeSpeed'], equals('6.0'));
    });

    test('does not include bikeSpeed when bicycle mode is not selected', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      const prefs = RoutingPreferences(
        bikeSpeed: 6.0,
        transportModes: {RoutingMode.transit, RoutingMode.walk}, // No bicycle
      );

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
        preferences: prefs,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters.containsKey('bikeSpeed'), isFalse);
    });

    test('builds correct mode string from transportModes', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle, RoutingMode.transit},
      );

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
        preferences: prefs,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      final mode = captured.queryParameters['mode']!;
      expect(mode.contains('BICYCLE'), isTrue);
      expect(mode.contains('TRANSIT'), isTrue);
    });

    test('uses default modes when preferences is null', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
        preferences: null,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['mode'], equals('TRANSIT,WALK'));
    });

    test('formats date correctly in query params', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate, // 2025-06-15 10:30
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      // OTP 1.5 uses MM-DD-YYYY format
      expect(captured.queryParameters['date'], equals('06-15-2025'));
      expect(captured.queryParameters['time'], equals('10:30'));
    });

    test('includes all wheelchair-related preferences together', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
        preferences: RoutingPreferences.wheelchairUser,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['wheelchair'], equals('true'));
      expect(captured.queryParameters['walkSpeed'], equals('0.8'));
      expect(captured.queryParameters['walkReluctance'], equals('3.0'));
      expect(captured.queryParameters['maxWalkDistance'], equals('400.0'));
    });
  });

  group('RoutingPreferences - Transport Modes', () {
    test('single walk mode', () {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.walk},
      );

      expect(prefs.transportModes.length, equals(1));
      expect(prefs.transportModes.contains(RoutingMode.walk), isTrue);
    });

    test('bicycle only mode', () {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle},
      );

      expect(prefs.transportModes.length, equals(1));
      expect(prefs.transportModes.contains(RoutingMode.bicycle), isTrue);
    });

    test('combined bicycle and transit mode', () {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.bicycle, RoutingMode.transit, RoutingMode.walk},
      );

      expect(prefs.transportModes.length, equals(3));
      expect(prefs.transportModes.contains(RoutingMode.bicycle), isTrue);
      expect(prefs.transportModes.contains(RoutingMode.transit), isTrue);
      expect(prefs.transportModes.contains(RoutingMode.walk), isTrue);
    });

    test('car mode', () {
      const prefs = RoutingPreferences(
        transportModes: {RoutingMode.car},
      );

      expect(prefs.transportModes.contains(RoutingMode.car), isTrue);
      expect(RoutingMode.car.otpName, equals('CAR'));
    });
  });

  group('RoutingPreferences - Bike Speed', () {
    test('default bike speed is 5.0 m/s', () {
      const prefs = RoutingPreferences();
      expect(prefs.bikeSpeed, equals(5.0));
    });

    test('can set custom bike speed', () {
      const prefs = RoutingPreferences(bikeSpeed: 7.0);
      expect(prefs.bikeSpeed, equals(7.0));
    });

    test('copyWith updates bike speed', () {
      const prefs = RoutingPreferences();
      final updated = prefs.copyWith(bikeSpeed: 4.0);

      expect(updated.bikeSpeed, equals(4.0));
      expect(prefs.bikeSpeed, equals(5.0)); // Original unchanged
    });
  });
}
