import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

class _InMemoryRepository implements SavedPlacesRepository {
  final Map<String, SavedPlace> _places = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<List<SavedPlace>> getPlacesByType(SavedPlaceType type) async =>
      _places.values.where((p) => p.type == type).toList();

  @override
  Future<List<SavedPlace>> getAllPlaces() async => _places.values.toList();

  @override
  Future<SavedPlace?> getHome() async =>
      _places.values.where((p) => p.type == SavedPlaceType.home).firstOrNull;

  @override
  Future<SavedPlace?> getWork() async =>
      _places.values.where((p) => p.type == SavedPlaceType.work).firstOrNull;

  @override
  Future<List<SavedPlace>> getOtherPlaces() async =>
      getPlacesByType(SavedPlaceType.other);

  @override
  Future<List<SavedPlace>> getHistory() async =>
      getPlacesByType(SavedPlaceType.history);

  @override
  Future<void> savePlace(SavedPlace place) async => _places[place.id] = place;

  @override
  Future<void> updatePlace(SavedPlace place) async => _places[place.id] = place;

  @override
  Future<void> deletePlace(String id) async => _places.remove(id);

  @override
  Future<void> deletePlacesByType(SavedPlaceType type) async =>
      _places.removeWhere((_, p) => p.type == type);

  @override
  Future<void> clearHistory() async =>
      deletePlacesByType(SavedPlaceType.history);

  @override
  Future<void> addToHistory(SavedPlace place) async => savePlace(place);
}

SavedPlace _place({
  String id = '1',
  String name = 'Prueba',
  double lat = -17.39884,
  double lng = -66.16269,
}) => SavedPlace(
      id: id,
      name: name,
      latitude: lat,
      longitude: lng,
      type: SavedPlaceType.other,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('SavedPlacesCubit.isDuplicatePlace (#898)', () {
    late SavedPlacesCubit cubit;

    setUp(() async {
      cubit = SavedPlacesCubit(repository: _InMemoryRepository());
      await cubit.initialize();
      await cubit.addOtherPlace(_place());
    });

    tearDown(() => cubit.close());

    test('same name and same coordinates is a duplicate', () {
      expect(cubit.isDuplicatePlace(_place(id: '2')), isTrue);
    });

    test('name comparison trims and ignores case', () {
      expect(cubit.isDuplicatePlace(_place(id: '2', name: '  prueba ')), isTrue);
    });

    test('same name at a different location is allowed', () {
      expect(
        cubit.isDuplicatePlace(_place(id: '2', lat: -17.5)),
        isFalse,
      );
    });

    test('different name at the same location is allowed', () {
      expect(cubit.isDuplicatePlace(_place(id: '2', name: 'Otra')), isFalse);
    });

    test('editing a place does not collide with itself', () {
      expect(cubit.isDuplicatePlace(_place(), excludeId: '1'), isFalse);
    });

    test('home and work count as existing places', () async {
      await cubit.setHome(_place(id: 'h', name: 'Casa', lat: -17.4));
      expect(
        cubit.isDuplicatePlace(_place(id: '2', name: 'Casa', lat: -17.4)),
        isTrue,
      );
    });
  });
}
