import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../test_config.dart';

class MockHttpClient extends Mock implements http.Client {}

/// Unit tests for OTP 1.5 repository with mocked HTTP client.
void main() {
  group('Otp15PlanRepository', () {
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
        endpoint: 'https://test-otp.example.com',
        httpClient: mockHttpClient,
      );
    });

    tearDown(() {
      repository.dispose();
    });

    test('fetchPlan makes correct HTTP request', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        numItineraries: 3,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.host, equals('test-otp.example.com'));
      expect(captured.path, equals('/otp/routers/default/plan'));
      expect(captured.queryParameters['fromPlace'], isNotNull);
      expect(captured.queryParameters['toPlace'], isNotNull);
      expect(captured.queryParameters['numItineraries'], equals('3'));
      expect(captured.queryParameters['mode'], equals('TRANSIT,WALK'));
    });

    test('fetchPlan formats location as lat,lon', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      // OTP 1.5 uses "lat,lon" format
      expect(
        captured.queryParameters['fromPlace'],
        equals('-17.3452624,-66.1975204'),
      );
      expect(
        captured.queryParameters['toPlace'],
        equals('-17.4647819,-66.1494349'),
      );
    });

    test('fetchPlan includes locale when provided', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
        locale: 'es',
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      expect(captured.queryParameters['locale'], equals('es'));
    });

    test('fetchPlan parses successful response', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      final plan = await repository.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
      );

      expect(plan.from, isNotNull);
      expect(plan.to, isNotNull);
      expect(plan.itineraries, isNotEmpty);
    });

    test('fetchPlan throws on HTTP error', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      expect(
        () => repository.fetchPlan(
          from: TestConfig.originLocation,
          to: TestConfig.destinationLocation,
        ),
        throwsA(isA<Otp15Exception>()),
      );
    });

    test('fetchPlan throws on OTP error in response', () async {
      final errorResponse = jsonEncode({
        'error': {
          'id': 404,
          'msg': 'PATH_NOT_FOUND',
        },
      });

      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(errorResponse, 200));

      expect(
        () => repository.fetchPlan(
          from: TestConfig.originLocation,
          to: TestConfig.destinationLocation,
        ),
        throwsA(isA<Otp15Exception>()),
      );
    });

    test('fetchPlan throws on invalid JSON response', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('invalid json', 200));

      expect(
        () => repository.fetchPlan(
          from: TestConfig.originLocation,
          to: TestConfig.destinationLocation,
        ),
        throwsA(isA<Otp15Exception>()),
      );
    });

    test('fetchPlan handles network error', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(http.ClientException('Connection refused'));

      expect(
        () => repository.fetchPlan(
          from: TestConfig.originLocation,
          to: TestConfig.destinationLocation,
        ),
        throwsA(isA<Otp15Exception>()),
      );
    });

    test('fetchPlan removes trailing slash from endpoint', () async {
      final repoWithSlash = Otp15PlanRepository(
        endpoint: 'https://test-otp.example.com/',
        httpClient: mockHttpClient,
      );

      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(fixtureResponse, 200));

      await repoWithSlash.fetchPlan(
        from: TestConfig.originLocation,
        to: TestConfig.destinationLocation,
      );

      final captured = verify(
        () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
      ).captured.first as Uri;

      // Should not have double slash in path (https:// is ok)
      expect(captured.path, isNot(contains('//')));
      expect(captured.path, equals('/otp/routers/default/plan'));

      repoWithSlash.dispose();
    });
  });
}
