import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_routing/src/providers/otp_1_5/otp_15_preferences.dart';
import 'package:trufi_core_routing/src/providers/otp_1_5/otp_15_routing_provider.dart';

import '../test_config.dart';

class MockHttpClient extends Mock implements http.Client {}

/// Unit tests for routing enums and OTP routing provider parameter handling.
///
/// The provider reads preferences from its internal state
/// (Otp15PreferencesState) rather than from a fetchPlan parameter.
/// We use SharedPreferences.setMockInitialValues to pre-configure the
/// internal state before testing.
void main() {
  // Fixed date for all tests to ensure reproducibility
  final fixedDate = DateTime(2025, 6, 15, 10, 30);

  group('RoutingMode enum', () {
    test('has correct OTP names', () {
      expect(RoutingMode.walk.otpName, equals('WALK'));
      expect(RoutingMode.transit.otpName, equals('TRANSIT'));
      expect(RoutingMode.bicycle.otpName, equals('BICYCLE'));
      expect(RoutingMode.car.otpName, equals('CAR'));
    });
  });

  group('WalkSpeedLevel enum', () {
    test('has correct speed values', () {
      expect(WalkSpeedLevel.slow.speedValue, equals(0.8));
      expect(WalkSpeedLevel.normal.speedValue, equals(1.33));
      expect(WalkSpeedLevel.fast.speedValue, equals(1.8));
    });

    test('has correct reluctance values', () {
      expect(WalkSpeedLevel.slow.reluctanceValue, equals(3.5));
      expect(WalkSpeedLevel.normal.reluctanceValue, equals(2.0));
      expect(WalkSpeedLevel.fast.reluctanceValue, equals(1.5));
    });
  });

  group('OTP 1.5 Routing Provider - Internal Preferences', () {
    late MockHttpClient mockHttpClient;
    late Otp15RoutingProvider provider;
    late String fixtureResponse;

    setUpAll(() {
      registerFallbackValue(Uri.parse('https://example.com'));
      final file = File('test/fixtures/otp_1_5_response.json');
      fixtureResponse = file.readAsStringSync();
    });

    setUp(() {
      mockHttpClient = MockHttpClient();
    });

    tearDown(() {
      provider.dispose();
    });

    /// Helper to create a provider with pre-configured internal preferences.
    ///
    /// Sets up SharedPreferences mock values so the provider's initialize()
    /// reads the desired preferences from its internal state.
    Future<Otp15RoutingProvider> createProviderWithPrefs({
      bool wheelchair = false,
      double walkSpeed = 1.33,
      double? maxWalkDistance,
      double walkReluctance = 2.0,
      double bikeSpeed = 5.0,
      Set<RoutingMode> transportModes = const {
        RoutingMode.transit,
        RoutingMode.walk,
      },
    }) async {
      SharedPreferences.setMockInitialValues({
        'routing_prefs_otp15': jsonEncode({
          'wheelchair': wheelchair,
          'walkSpeed': walkSpeed,
          'maxWalkDistance': maxWalkDistance,
          'walkReluctance': walkReluctance,
          'bikeSpeed': bikeSpeed,
          'transportModes': transportModes.map((m) => m.name).toList(),
        }),
      });

      final p = Otp15RoutingProvider(
        endpoint: 'https://test-otp.example.com/otp/routers/default/plan',
        httpClient: mockHttpClient,
      );
      await p.initialize();
      return p;
    }

    test('includes wheelchair parameter when enabled', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      provider = await createProviderWithPrefs(wheelchair: true);

      await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['wheelchair'], equals('true'));
    });

    test('includes walkSpeed parameter', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      provider = await createProviderWithPrefs(walkSpeed: 0.8);

      await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['walkSpeed'], equals('0.8'));
    });

    test('includes walkReluctance parameter', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      provider = await createProviderWithPrefs(walkReluctance: 3.5);

      await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['walkReluctance'], equals('3.5'));
    });

    test('includes maxWalkDistance when set', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      provider = await createProviderWithPrefs(maxWalkDistance: 500.0);

      await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['maxWalkDistance'], equals('500.0'));
    });

    test('does not include maxWalkDistance when null', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      // Default preferences have maxWalkDistance as null
      provider = await createProviderWithPrefs();

      await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters.containsKey('maxWalkDistance'), isFalse);
    });

    test('includes bikeSpeed when bicycle mode is selected', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      provider = await createProviderWithPrefs(
        bikeSpeed: 6.0,
        transportModes: {RoutingMode.bicycle, RoutingMode.walk},
      );

      await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['bikeSpeed'], equals('6.0'));
    });

    test('does not include bikeSpeed when bicycle mode is not selected', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      provider = await createProviderWithPrefs(
        bikeSpeed: 6.0,
        transportModes: {RoutingMode.transit, RoutingMode.walk},
      );

      await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters.containsKey('bikeSpeed'), isFalse);
    });

    test('builds correct mode string from transportModes', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      provider = await createProviderWithPrefs(
        transportModes: {RoutingMode.bicycle, RoutingMode.transit},
      );

      await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      final mode = captured.queryParameters['mode']!;
      expect(mode.contains('BICYCLE'), isTrue);
      expect(mode.contains('TRANSIT'), isTrue);
    });

    test('uses default modes with default preferences', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      provider = await createProviderWithPrefs();

      await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['mode'], equals('TRANSIT,WALK'));
    });

    test('formats date correctly in query params', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      provider = await createProviderWithPrefs();

      await provider.fetchPlan(
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

      provider = await createProviderWithPrefs(
        wheelchair: true,
        walkSpeed: 0.8,
        walkReluctance: 3.0,
        maxWalkDistance: 400.0,
      );

      await provider.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        dateTime: fixedDate,
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
}
