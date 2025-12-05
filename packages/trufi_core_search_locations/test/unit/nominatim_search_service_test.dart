import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:trufi_core_search_locations/src/services/nominatim_search_service.dart';
import 'package:trufi_core_search_locations/src/services/search_location_service.dart';

import '../test_config.dart';

class MockHttpClient extends Mock implements http.Client {}

/// Unit tests for NominatimSearchService with mocked HTTP client.
void main() {
  group('NominatimSearchService', () {
    late MockHttpClient mockHttpClient;
    late NominatimSearchService service;
    late String searchFixtureResponse;
    late String reverseFixtureResponse;

    setUpAll(() {
      registerFallbackValue(Uri.parse('https://example.com'));

      final searchFile = File('test/fixtures/nominatim_search_response.json');
      searchFixtureResponse = searchFile.readAsStringSync();

      final reverseFile = File('test/fixtures/nominatim_reverse_response.json');
      reverseFixtureResponse = reverseFile.readAsStringSync();
    });

    setUp(() {
      mockHttpClient = MockHttpClient();
      service = NominatimSearchService(
        userAgent: TestConfig.nominatimUserAgent,
        client: mockHttpClient,
      );
    });

    tearDown(() {
      service.dispose();
    });

    group('search', () {
      test('returns empty list for empty query', () async {
        final results = await service.search('');

        expect(results, isEmpty);
        verifyNever(() => mockHttpClient.get(any(), headers: any(named: 'headers')));
      });

      test('returns empty list for whitespace-only query', () async {
        final results = await service.search('   ');

        expect(results, isEmpty);
        verifyNever(() => mockHttpClient.get(any(), headers: any(named: 'headers')));
      });

      test('makes correct HTTP request', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response(searchFixtureResponse, 200));

        await service.search('Berlin');

        final captured = verify(
          () => mockHttpClient.get(
            captureAny(),
            headers: captureAny(named: 'headers'),
          ),
        ).captured;

        final uri = captured[0] as Uri;
        final headers = captured[1] as Map<String, String>;

        expect(uri.host, equals('nominatim.openstreetmap.org'));
        expect(uri.path, equals('/search'));
        expect(uri.queryParameters['q'], equals('Berlin'));
        expect(uri.queryParameters['format'], equals('json'));
        expect(uri.queryParameters['addressdetails'], equals('1'));
        expect(headers['User-Agent'], equals(TestConfig.nominatimUserAgent));
      });

      test('parses search results from fixture correctly', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response(searchFixtureResponse, 200));

        final results = await service.search('Berlin');

        expect(results, hasLength(3));

        // First result - Berlin city
        expect(results[0].displayName, equals('Berlin'));
        expect(results[0].latitude, closeTo(52.52, 0.01));
        expect(results[0].longitude, closeTo(13.40, 0.01));
        expect(results[0].id, equals('relation_62422'));

        // Second result - Brandenburg Gate
        expect(results[1].displayName, equals('Brandenburger Tor'));
        expect(results[1].id, equals('way_26995159'));

        // Third result - Restaurant
        expect(results[2].displayName, equals('Berlin Döner'));
        expect(results[2].id, equals('node_12345678'));
      });

      test('includes language parameter when specified', () async {
        service = NominatimSearchService(
          userAgent: TestConfig.nominatimUserAgent,
          language: 'es',
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        await service.search('Madrid');

        final captured = verify(
          () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured.first as Uri;

        expect(captured.queryParameters['accept-language'], equals('es'));
      });

      test('includes country codes when specified', () async {
        service = NominatimSearchService(
          userAgent: TestConfig.nominatimUserAgent,
          countryCodes: ['de', 'at'],
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        await service.search('Vienna');

        final captured = verify(
          () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured.first as Uri;

        expect(captured.queryParameters['countrycodes'], equals('de,at'));
      });

      test('includes bounding box when specified', () async {
        service = NominatimSearchService(
          userAgent: TestConfig.nominatimUserAgent,
          boundingBox: TestConfig.berlinBoundingBox,
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        await service.search('Test');

        final captured = verify(
          () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured.first as Uri;

        expect(captured.queryParameters['viewbox'], isNotNull);
        expect(captured.queryParameters['bounded'], equals('1'));
      });

      test('includes bias location viewbox when specified', () async {
        service = NominatimSearchService(
          userAgent: TestConfig.nominatimUserAgent,
          biasLatitude: TestConfig.berlinCenterLat,
          biasLongitude: TestConfig.berlinCenterLon,
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        await service.search('Test');

        final captured = verify(
          () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured.first as Uri;

        expect(captured.queryParameters['viewbox'], isNotNull);
        expect(captured.queryParameters['bounded'], equals('0'));
      });

      test('respects limit parameter', () async {
        service = NominatimSearchService(
          userAgent: TestConfig.nominatimUserAgent,
          limit: 5,
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        await service.search('Test');

        final captured = verify(
          () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured.first as Uri;

        expect(captured.queryParameters['limit'], equals('5'));
      });

      test('throws SearchLocationException on HTTP error', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('Server error', 500));

        expect(
          () => service.search('Test'),
          throwsA(isA<SearchLocationException>()),
        );
      });

      test('throws SearchLocationException on network error', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenThrow(http.ClientException('Connection refused'));

        expect(
          () => service.search('Test'),
          throwsA(isA<SearchLocationException>()),
        );
      });

      test('uses custom base URL', () async {
        service = NominatimSearchService(
          baseUrl: 'https://custom.nominatim.server',
          userAgent: TestConfig.nominatimUserAgent,
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        await service.search('Test');

        final captured = verify(
          () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured.first as Uri;

        expect(captured.host, equals('custom.nominatim.server'));
      });

      test('handles result without osm_id', () async {
        final responseWithoutOsmId = jsonEncode([
          {
            'lat': '52.52',
            'lon': '13.40',
            'display_name': 'Test Location',
          },
        ]);

        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response(responseWithoutOsmId, 200));

        final results = await service.search('Test');

        expect(results, hasLength(1));
        expect(results[0].id, startsWith('nominatim_'));
      });
    });

    group('reverse', () {
      test('returns location for valid coordinates', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response(reverseFixtureResponse, 200));

        final result = await service.reverse(
          TestConfig.berlinCenterLat,
          TestConfig.berlinCenterLon,
        );

        expect(result, isNotNull);
        expect(result!.latitude, closeTo(52.52, 0.01));
        expect(result.longitude, closeTo(13.40, 0.01));
        expect(result.displayName, equals('Berlin'));
      });

      test('makes correct HTTP request', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response(reverseFixtureResponse, 200));

        await service.reverse(52.52, 13.4);

        final captured = verify(
          () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured.first as Uri;

        expect(captured.path, equals('/reverse'));
        expect(captured.queryParameters['lat'], equals('52.52'));
        expect(captured.queryParameters['lon'], equals('13.4'));
        expect(captured.queryParameters['format'], equals('json'));
      });

      test('returns null on HTTP error', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('Error', 500));

        final result = await service.reverse(52.52, 13.4);

        expect(result, isNull);
      });

      test('returns null when response contains error', () async {
        final errorResponse = jsonEncode({'error': 'Unable to geocode'});

        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response(errorResponse, 200));

        final result = await service.reverse(0, 0);

        expect(result, isNull);
      });

      test('returns null on network error', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenThrow(http.ClientException('Connection refused'));

        final result = await service.reverse(52.52, 13.4);

        expect(result, isNull);
      });

      test('includes language parameter when specified', () async {
        service = NominatimSearchService(
          userAgent: TestConfig.nominatimUserAgent,
          language: 'de',
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response(reverseFixtureResponse, 200));

        await service.reverse(52.52, 13.4);

        final captured = verify(
          () => mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured.first as Uri;

        expect(captured.queryParameters['accept-language'], equals('de'));
      });
    });

    group('SearchLocationService interface', () {
      test('implements SearchLocationService', () {
        expect(service, isA<SearchLocationService>());
      });
    });
  });
}
