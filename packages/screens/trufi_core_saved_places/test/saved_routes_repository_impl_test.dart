import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

import 'in_memory_storage.dart';

// #1005: saved routes live as one JSON list on the StorageService, so they
// survive an app restart (a second repository over the same storage).

SavedRoute _route(String id, {String name = 'Casa a Trabajo'}) => SavedRoute(
  id: id,
  name: name,
  origin: const SavedRoutePoint(
    name: 'Casa',
    latitude: -17.39884,
    longitude: -66.16269,
  ),
  destination: const SavedRoutePoint(
    name: 'Trabajo',
    latitude: -17.37,
    longitude: -66.15,
  ),
  createdAt: DateTime(2026, 10, 13),
);

void main() {
  late InMemoryStorage storage;
  late SavedRoutesRepositoryImpl repository;

  setUp(() async {
    storage = InMemoryStorage();
    repository = SavedRoutesRepositoryImpl(storage: storage);
    await repository.initialize();
  });

  test('starts empty when nothing was stored', () async {
    expect(await repository.getAllRoutes(), isEmpty);
  });

  test('a saved route is read back by a fresh repository (restart)', () async {
    await repository.saveRoute(_route('1'));

    final second = SavedRoutesRepositoryImpl(storage: storage);
    await second.initialize();

    expect(await second.getAllRoutes(), [_route('1')]);
  });

  test('saveRoute appends in insertion order', () async {
    await repository.saveRoute(_route('1'));
    await repository.saveRoute(_route('2', name: 'Gimnasio'));

    expect((await repository.getAllRoutes()).map((r) => r.id).toList(), [
      '1',
      '2',
    ]);
  });

  test('updateRoute replaces the route with the same id in place', () async {
    await repository.saveRoute(_route('1'));
    await repository.saveRoute(_route('2'));

    await repository.updateRoute(_route('1', name: 'Renombrada'));

    final routes = await repository.getAllRoutes();
    expect(routes.map((r) => r.name).toList(), [
      'Renombrada',
      'Casa a Trabajo',
    ]);
  });

  test('updateRoute with an unknown id is a no-op', () async {
    await repository.saveRoute(_route('1'));

    await repository.updateRoute(_route('missing'));

    expect(await repository.getAllRoutes(), [_route('1')]);
  });

  test('deleteRoute removes only that route', () async {
    await repository.saveRoute(_route('1'));
    await repository.saveRoute(_route('2'));

    await repository.deleteRoute('1');

    expect(await repository.getAllRoutes(), [_route('2')]);
  });

  test('stores the list under the documented key', () async {
    await repository.saveRoute(_route('1'));
    expect(
      await storage.containsKey(SavedRoutesRepositoryImpl.storageKey),
      isTrue,
    );
  });

  test('reading before initialize throws StateError', () {
    final fresh = SavedRoutesRepositoryImpl(storage: InMemoryStorage());
    expect(fresh.getAllRoutes(), throwsStateError);
  });
}
