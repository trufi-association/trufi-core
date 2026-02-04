@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/src/services/photon_search_service.dart';

import '../test_config.dart';

/// Integration tests for Photon API.
///
/// These tests make real HTTP calls to the Photon server.
/// Run with: flutter test --tags integration
void main() {
  group('Photon Integration Tests', () {
    late PhotonSearchService service;

    setUp(() {
      service = PhotonSearchService(baseUrl: TestConfig.photonEndpoint);
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
      final results = await service.search('Brandenburg Gate Berlin');

      expect(results, isNotEmpty);

      final firstResult = results.first;
      expect(firstResult.latitude, isNotNull);
      expect(firstResult.longitude, isNotNull);
      // Brandenburg Gate is in Berlin (roughly lat: 52.5, lon: 13.4)
      expect(firstResult.latitude, closeTo(52.5, 0.5));
      expect(firstResult.longitude, closeTo(13.4, 0.5));
    });

    test('search respects limit parameter', () async {
      final limitedService = PhotonSearchService(
        baseUrl: TestConfig.photonEndpoint,
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
      final germanService = PhotonSearchService(
        baseUrl: TestConfig.photonEndpoint,
        language: 'de',
      );

      try {
        final results = await germanService.search('Berlin');

        expect(results, isNotEmpty);
      } finally {
        germanService.dispose();
      }
    });

    test('search with bias location prioritizes nearby results', () async {
      final biasedService = PhotonSearchService(
        baseUrl: TestConfig.photonEndpoint,
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

    test('search with bounding box limits results', () async {
      final boundedService = PhotonSearchService(
        baseUrl: TestConfig.photonEndpoint,
        boundingBox: TestConfig.berlinBoundingBox,
      );

      try {
        final results = await boundedService.search('Restaurant');

        expect(results, isNotEmpty);
        // All results should be within bounding box
        for (final result in results) {
          expect(
            result.latitude,
            inInclusiveRange(
              TestConfig.berlinBoundingBox[1],
              TestConfig.berlinBoundingBox[3],
            ),
          );
          expect(
            result.longitude,
            inInclusiveRange(
              TestConfig.berlinBoundingBox[0],
              TestConfig.berlinBoundingBox[2],
            ),
          );
        }
      } finally {
        boundedService.dispose();
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
    });

    test('search returns empty list for nonsense query', () async {
      final results = await service.search('xyzqwerty123456789nonexistent');

      expect(results, isEmpty);
    });

    test('search returns results with osm_id as identifier', () async {
      final results = await service.search('Berlin');

      expect(results, isNotEmpty);
      for (final result in results) {
        expect(result.id, isNotEmpty);
        // Most results should have OSM-based ID
        expect(
          result.id.startsWith('osm_') || result.id.startsWith('photon_'),
          isTrue,
        );
      }
    });
  });
}
