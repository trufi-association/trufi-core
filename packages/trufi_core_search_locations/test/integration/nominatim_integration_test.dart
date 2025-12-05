@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/src/services/nominatim_search_service.dart';

import '../test_config.dart';

/// Integration tests for Nominatim API.
///
/// These tests make real HTTP calls to the Nominatim server.
/// Run with: flutter test --tags integration
void main() {
  group('Nominatim Integration Tests', () {
    late NominatimSearchService service;

    setUp(() {
      service = NominatimSearchService(
        userAgent: TestConfig.nominatimUserAgent,
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('search returns results for "Berlin"', () async {
      final results = await service.search('Berlin');

      expect(results, isNotEmpty);
      expect(
        results.any((r) => r.displayName.toLowerCase().contains('berlin')),
        isTrue,
      );
    });

    test('search returns results with valid coordinates', () async {
      final results = await service.search('Brandenburg Gate');

      expect(results, isNotEmpty);

      final firstResult = results.first;
      expect(firstResult.latitude, isNotNull);
      expect(firstResult.longitude, isNotNull);
      // Brandenburg Gate is in Berlin (roughly lat: 52.5, lon: 13.4)
      expect(firstResult.latitude, closeTo(52.5, 0.5));
      expect(firstResult.longitude, closeTo(13.4, 0.5));
    });

    test('search respects limit parameter', () async {
      final limitedService = NominatimSearchService(
        userAgent: TestConfig.nominatimUserAgent,
        limit: 3,
      );

      try {
        final results = await limitedService.search('Restaurant Berlin');

        expect(results.length, lessThanOrEqualTo(3));
      } finally {
        limitedService.dispose();
      }
    });

    test('search with language returns localized results', () async {
      final germanService = NominatimSearchService(
        userAgent: TestConfig.nominatimUserAgent,
        language: 'de',
      );

      try {
        final results = await germanService.search('Berlin');

        expect(results, isNotEmpty);
        // German results should contain German text
        expect(
          results.any(
            (r) =>
                r.address?.contains('Deutschland') == true ||
                r.address?.contains('Germany') == true,
          ),
          isTrue,
        );
      } finally {
        germanService.dispose();
      }
    });

    test('search with country codes filters results', () async {
      final boliviaService = NominatimSearchService(
        userAgent: TestConfig.nominatimUserAgent,
        countryCodes: ['bo'],
      );

      try {
        final results = await boliviaService.search('Cochabamba');

        expect(results, isNotEmpty);
        // Results should be in Bolivia
        expect(
          results.any(
            (r) =>
                r.address?.toLowerCase().contains('bolivia') == true ||
                r.address?.toLowerCase().contains('cochabamba') == true,
          ),
          isTrue,
        );
      } finally {
        boliviaService.dispose();
      }
    });

    test('search with bias location prioritizes nearby results', () async {
      final biasedService = NominatimSearchService(
        userAgent: TestConfig.nominatimUserAgent,
        biasLatitude: TestConfig.berlinCenterLat,
        biasLongitude: TestConfig.berlinCenterLon,
      );

      try {
        final results = await biasedService.search('Restaurant');

        expect(results, isNotEmpty);
        // First result should be near Berlin
        final firstResult = results.first;
        // Within 100km of Berlin center
        expect(firstResult.latitude, closeTo(52.52, 1.0));
        expect(firstResult.longitude, closeTo(13.40, 1.0));
      } finally {
        biasedService.dispose();
      }
    });

    test('reverse geocoding returns valid location', () async {
      final result = await service.reverse(
        TestConfig.berlinCenterLat,
        TestConfig.berlinCenterLon,
      );

      expect(result, isNotNull);
      expect(result!.displayName, isNotEmpty);
      expect(result.latitude, closeTo(TestConfig.berlinCenterLat, 0.01));
      expect(result.longitude, closeTo(TestConfig.berlinCenterLon, 0.01));
    });

    test('reverse geocoding for Cochabamba returns valid location', () async {
      final result = await service.reverse(
        TestConfig.cochabambaCenterLat,
        TestConfig.cochabambaCenterLon,
      );

      expect(result, isNotNull);
      expect(result!.displayName, isNotEmpty);
      expect(
        result.address?.toLowerCase().contains('cochabamba') == true ||
            result.address?.toLowerCase().contains('bolivia') == true,
        isTrue,
      );
    });

    test('search returns empty list for nonsense query', () async {
      final results = await service.search('xyzqwerty123456789nonexistent');

      expect(results, isEmpty);
    });
  });
}
