import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_search_locations/src/models/search_location.dart';

/// Unit tests for SearchLocation model.
void main() {
  group('SearchLocation', () {
    test('creates instance with required parameters', () {
      const location = SearchLocation(
        id: 'test_id',
        displayName: 'Test Location',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      expect(location.id, 'test_id');
      expect(location.displayName, 'Test Location');
      expect(location.latitude, 40.7128);
      expect(location.longitude, -74.0060);
      expect(location.address, isNull);
    });

    test('creates instance with all parameters', () {
      const location = SearchLocation(
        id: 'test_id',
        displayName: 'Test Location',
        address: '123 Main Street',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      expect(location.id, 'test_id');
      expect(location.displayName, 'Test Location');
      expect(location.address, '123 Main Street');
      expect(location.latitude, 40.7128);
      expect(location.longitude, -74.0060);
    });

    group('formattedDisplay', () {
      test('returns displayName with address when address is present', () {
        const location = SearchLocation(
          id: 'test_id',
          displayName: 'Test Location',
          address: '123 Main Street',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        expect(location.formattedDisplay, 'Test Location, 123 Main Street');
      });

      test('returns only displayName when address is null', () {
        const location = SearchLocation(
          id: 'test_id',
          displayName: 'Test Location',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        expect(location.formattedDisplay, 'Test Location');
      });

      test('returns only displayName when address is empty', () {
        const location = SearchLocation(
          id: 'test_id',
          displayName: 'Test Location',
          address: '',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        expect(location.formattedDisplay, 'Test Location');
      });
    });

    group('equality', () {
      test('two locations with same id are equal', () {
        const location1 = SearchLocation(
          id: 'same_id',
          displayName: 'Location 1',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        const location2 = SearchLocation(
          id: 'same_id',
          displayName: 'Different Name',
          latitude: 0.0,
          longitude: 0.0,
        );

        expect(location1, equals(location2));
      });

      test('two locations with different ids are not equal', () {
        const location1 = SearchLocation(
          id: 'id_1',
          displayName: 'Same Name',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        const location2 = SearchLocation(
          id: 'id_2',
          displayName: 'Same Name',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        expect(location1, isNot(equals(location2)));
      });

      test('location is equal to itself', () {
        const location = SearchLocation(
          id: 'test_id',
          displayName: 'Test Location',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        expect(location, equals(location));
      });
    });

    group('hashCode', () {
      test('same id produces same hashCode', () {
        const location1 = SearchLocation(
          id: 'same_id',
          displayName: 'Location 1',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        const location2 = SearchLocation(
          id: 'same_id',
          displayName: 'Different Name',
          latitude: 0.0,
          longitude: 0.0,
        );

        expect(location1.hashCode, equals(location2.hashCode));
      });
    });

    test('toString returns expected format', () {
      const location = SearchLocation(
        id: 'test_id',
        displayName: 'Test Location',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      expect(
        location.toString(),
        'SearchLocation(id: test_id, displayName: Test Location)',
      );
    });
  });
}
