import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

void main() {
  group('SavedPlace', () {
    test('creates SavedPlace with required fields', () {
      final place = SavedPlace(
        id: '1',
        name: 'Test Place',
        latitude: 52.5200,
        longitude: 13.4050,
        type: SavedPlaceType.other,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(place.id, '1');
      expect(place.name, 'Test Place');
      expect(place.latitude, 52.5200);
      expect(place.longitude, 13.4050);
      expect(place.type, SavedPlaceType.other);
    });

    test('copyWith creates a new instance with updated values', () {
      final original = SavedPlace(
        id: '1',
        name: 'Original',
        latitude: 52.5200,
        longitude: 13.4050,
        type: SavedPlaceType.other,
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(name: 'Updated');

      expect(updated.id, '1');
      expect(updated.name, 'Updated');
      expect(updated.latitude, 52.5200);
      expect(original.name, 'Original');
    });

    test('toJson and fromJson work correctly', () {
      final original = SavedPlace(
        id: '1',
        name: 'Test Place',
        address: 'Test Address',
        latitude: 52.5200,
        longitude: 13.4050,
        type: SavedPlaceType.other,
        iconName: 'star',
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        lastUsedAt: DateTime(2024, 1, 2, 12, 0, 0),
      );

      final json = original.toJson();
      final restored = SavedPlace.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.address, original.address);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.type, original.type);
      expect(restored.iconName, original.iconName);
    });

    test('toTrufiLocation converts correctly', () {
      final place = SavedPlace(
        id: '1',
        name: 'Test Place',
        address: 'Test Address',
        latitude: 52.5200,
        longitude: 13.4050,
        type: SavedPlaceType.home,
        createdAt: DateTime(2024, 1, 1),
      );

      final location = place.toTrufiLocation();

      expect(location.description, 'Test Place');
      expect(location.latitude, 52.5200);
      expect(location.longitude, 13.4050);
      expect(location.address, 'Test Address');
      expect(location.type, 'saved_place:home');
    });

    test('equality works correctly', () {
      final place1 = SavedPlace(
        id: '1',
        name: 'Test',
        latitude: 52.5200,
        longitude: 13.4050,
        type: SavedPlaceType.other,
        createdAt: DateTime(2024, 1, 1),
      );

      final place2 = SavedPlace(
        id: '1',
        name: 'Test',
        latitude: 52.5200,
        longitude: 13.4050,
        type: SavedPlaceType.other,
        createdAt: DateTime(2024, 1, 1),
      );

      final place3 = SavedPlace(
        id: '2',
        name: 'Different',
        latitude: 52.5200,
        longitude: 13.4050,
        type: SavedPlaceType.other,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(place1, equals(place2));
      expect(place1, isNot(equals(place3)));
    });
  });

  group('SavedPlaceType', () {
    test('all types have correct values', () {
      expect(SavedPlaceType.values.length, 4);
      expect(SavedPlaceType.values, contains(SavedPlaceType.home));
      expect(SavedPlaceType.values, contains(SavedPlaceType.work));
      expect(SavedPlaceType.values, contains(SavedPlaceType.other));
      expect(SavedPlaceType.values, contains(SavedPlaceType.history));
    });
  });

  group('SavedPlacesState', () {
    test('initial state has correct defaults', () {
      const state = SavedPlacesState();

      expect(state.status, SavedPlacesStatus.initial);
      expect(state.home, isNull);
      expect(state.work, isNull);
      expect(state.otherPlaces, isEmpty);
      expect(state.history, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('allPlaces returns combined list', () {
      final home = SavedPlace(
        id: 'home',
        name: 'Home',
        latitude: 52.5200,
        longitude: 13.4050,
        type: SavedPlaceType.home,
        createdAt: DateTime(2024, 1, 1),
      );

      final otherPlace = SavedPlace(
        id: 'other1',
        name: 'Other Place 1',
        latitude: 52.5201,
        longitude: 13.4051,
        type: SavedPlaceType.other,
        createdAt: DateTime(2024, 1, 1),
      );

      final state = SavedPlacesState(
        home: home,
        otherPlaces: [otherPlace],
      );

      expect(state.allPlaces.length, 2);
      expect(state.allPlaces, contains(home));
      expect(state.allPlaces, contains(otherPlace));
    });

    test('copyWith preserves and updates values correctly', () {
      final home = SavedPlace(
        id: 'home',
        name: 'Home',
        latitude: 52.5200,
        longitude: 13.4050,
        type: SavedPlaceType.home,
        createdAt: DateTime(2024, 1, 1),
      );

      const original = SavedPlacesState(
        status: SavedPlacesStatus.loaded,
      );

      final updated = original.copyWith(home: home);

      expect(updated.status, SavedPlacesStatus.loaded);
      expect(updated.home, home);
    });

    test('clearHome removes home from state', () {
      final home = SavedPlace(
        id: 'home',
        name: 'Home',
        latitude: 52.5200,
        longitude: 13.4050,
        type: SavedPlaceType.home,
        createdAt: DateTime(2024, 1, 1),
      );

      final original = SavedPlacesState(home: home);
      final cleared = original.copyWith(clearHome: true);

      expect(original.home, home);
      expect(cleared.home, isNull);
    });
  });
}
