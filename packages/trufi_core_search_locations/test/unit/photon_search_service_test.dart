import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:trufi_core_search_locations/src/services/photon_search_service.dart';
import 'package:trufi_core_search_locations/src/services/search_location_service.dart';

import '../test_config.dart';

class MockHttpClient extends Mock implements http.Client {}

/// Unit tests for PhotonSearchService with mocked HTTP client.
void main() {
  group('PhotonSearchService', () {
    late MockHttpClient mockHttpClient;
    late PhotonSearchService service;
    late String searchFixtureResponse;
    late String reverseFixtureResponse;

    setUpAll(() {
      registerFallbackValue(Uri.parse('https://example.com'));

      final searchFile = File('test/fixtures/photon_search_response.json');
      searchFixtureResponse = searchFile.readAsStringSync();

      final reverseFile = File('test/fixtures/photon_reverse_response.json');
      reverseFixtureResponse = reverseFile.readAsStringSync();
    });

    setUp(() {
      mockHttpClient = MockHttpClient();
      service = PhotonSearchService(
        baseUrl: TestConfig.photonEndpoint,
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
        verifyNever(() => mockHttpClient.get(any()));
      });

      test('returns empty list for whitespace-only query', () async {
        final results = await service.search('   ');

        expect(results, isEmpty);
        verifyNever(() => mockHttpClient.get(any()));
      });

      test('makes correct HTTP request', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response(searchFixtureResponse, 200));

        await service.search('Berlin');

        final captured = verify(
          () => mockHttpClient.get(captureAny()),
        ).captured.first as Uri;

        expect(captured.host, equals('photon.komoot.io'));
        expect(captured.path, equals('/api/'));
        expect(captured.queryParameters['q'], equals('Berlin'));
      });

      test('parses search results from fixture correctly', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response(searchFixtureResponse, 200));

        final results = await service.search('Berlin');

        expect(results, hasLength(3));

        // First result - Berlin city
        expect(results[0].displayName, equals('Berlin'));
        expect(results[0].latitude, closeTo(52.52, 0.01));
        expect(results[0].longitude, closeTo(13.40, 0.01));
        expect(results[0].id, equals('osm_62422'));

        // Second result - Brandenburg Gate
        expect(results[1].displayName, equals('Brandenburger Tor'));
        expect(results[1].id, equals('osm_26995159'));

        // Third result - Restaurant
        expect(results[2].displayName, equals('Berlin Döner'));
        expect(results[2].id, equals('osm_12345678'));
      });

      test('includes language parameter when specified', () async {
        service = PhotonSearchService(
          baseUrl: TestConfig.photonEndpoint,
          language: 'de',
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('{"features": []}', 200));

        await service.search('Munich');

        final captured = verify(
          () => mockHttpClient.get(captureAny()),
        ).captured.first as Uri;

        expect(captured.queryParameters['lang'], equals('de'));
      });

      test('includes bias coordinates when specified', () async {
        service = PhotonSearchService(
          baseUrl: TestConfig.photonEndpoint,
          biasLatitude: TestConfig.berlinCenterLat,
          biasLongitude: TestConfig.berlinCenterLon,
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('{"features": []}', 200));

        await service.search('Cafe');

        final captured = verify(
          () => mockHttpClient.get(captureAny()),
        ).captured.first as Uri;

        expect(
          captured.queryParameters['lat'],
          equals(TestConfig.berlinCenterLat.toString()),
        );
        expect(
          captured.queryParameters['lon'],
          equals(TestConfig.berlinCenterLon.toString()),
        );
      });

      test('includes bounding box when specified', () async {
        service = PhotonSearchService(
          baseUrl: TestConfig.photonEndpoint,
          boundingBox: TestConfig.berlinBoundingBox,
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('{"features": []}', 200));

        await service.search('Test');

        final captured = verify(
          () => mockHttpClient.get(captureAny()),
        ).captured.first as Uri;

        expect(captured.queryParameters['bbox'], equals('13.0,52.3,13.8,52.7'));
      });

      test('respects limit parameter', () async {
        service = PhotonSearchService(
          baseUrl: TestConfig.photonEndpoint,
          limit: 5,
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('{"features": []}', 200));

        await service.search('Test');

        final captured = verify(
          () => mockHttpClient.get(captureAny()),
        ).captured.first as Uri;

        expect(captured.queryParameters['limit'], equals('5'));
      });

      test('throws SearchLocationException on HTTP error', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('Server error', 500));

        expect(
          () => service.search('Test'),
          throwsA(isA<SearchLocationException>()),
        );
      });

      test('throws SearchLocationException on network error', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenThrow(http.ClientException('Connection refused'));

        expect(
          () => service.search('Test'),
          throwsA(isA<SearchLocationException>()),
        );
      });

      test('uses custom base URL', () async {
        service = PhotonSearchService(
          baseUrl: 'https://custom.photon.server',
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('{"features": []}', 200));

        await service.search('Test');

        final captured = verify(
          () => mockHttpClient.get(captureAny()),
        ).captured.first as Uri;

        expect(captured.host, equals('custom.photon.server'));
      });

      test('handles empty features array', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('{"features": []}', 200));

        final results = await service.search('NonExistent');

        expect(results, isEmpty);
      });

      test('handles missing features key', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('{}', 200));

        final results = await service.search('Test');

        expect(results, isEmpty);
      });

      test('handles result without osm_id', () async {
        final responseWithoutOsmId = jsonEncode({
          'features': [
            {
              'geometry': {
                'coordinates': [13.4, 52.52],
                'type': 'Point',
              },
              'properties': {
                'name': 'Test Location',
              },
            },
          ],
        });

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response(responseWithoutOsmId, 200));

        final results = await service.search('Test');

        expect(results, hasLength(1));
        expect(results[0].id, startsWith('photon_'));
      });

      test('builds display name from street when name is missing', () async {
        final responseWithStreet = jsonEncode({
          'features': [
            {
              'geometry': {
                'coordinates': [13.4, 52.52],
                'type': 'Point',
              },
              'properties': {
                'street': 'Main Street',
                'housenumber': '123',
                'city': 'Berlin',
              },
            },
          ],
        });

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response(responseWithStreet, 200));

        final results = await service.search('Main Street Berlin');

        expect(results, hasLength(1));
        expect(results[0].displayName, equals('Main Street 123'));
      });

      test('uses coordinates as display name when no properties', () async {
        final responseWithEmptyProps = jsonEncode({
          'features': [
            {
              'geometry': {
                'coordinates': [13.4050, 52.5200],
                'type': 'Point',
              },
              'properties': {},
            },
          ],
        });

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response(responseWithEmptyProps, 200));

        final results = await service.search('Test');

        expect(results, hasLength(1));
        expect(results[0].displayName, contains('52.5200'));
        expect(results[0].displayName, contains('13.4050'));
      });
    });

    group('reverse', () {
      test('returns location for valid coordinates', () async {
        when(
          () => mockHttpClient.get(any()),
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
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response(reverseFixtureResponse, 200));

        await service.reverse(52.52, 13.4);

        final captured = verify(
          () => mockHttpClient.get(captureAny()),
        ).captured.first as Uri;

        expect(captured.path, equals('/reverse'));
        expect(captured.queryParameters['lat'], equals('52.52'));
        expect(captured.queryParameters['lon'], equals('13.4'));
      });

      test('returns null on HTTP error', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('Error', 500));

        final result = await service.reverse(52.52, 13.4);

        expect(result, isNull);
      });

      test('returns null when features array is empty', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('{"features": []}', 200));

        final result = await service.reverse(0, 0);

        expect(result, isNull);
      });

      test('returns null on network error', () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenThrow(http.ClientException('Connection refused'));

        final result = await service.reverse(52.52, 13.4);

        expect(result, isNull);
      });

      test('includes language parameter when specified', () async {
        service = PhotonSearchService(
          baseUrl: TestConfig.photonEndpoint,
          language: 'es',
          client: mockHttpClient,
        );

        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response(reverseFixtureResponse, 200));

        await service.reverse(52.52, 13.4);

        final captured = verify(
          () => mockHttpClient.get(captureAny()),
        ).captured.first as Uri;

        expect(captured.queryParameters['lang'], equals('es'));
      });
    });

    group('SearchLocationService interface', () {
      test('implements SearchLocationService', () {
        expect(service, isA<SearchLocationService>());
      });
    });
  });
}
