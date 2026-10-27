import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

import 'in_memory_storage.dart';

// #1005: the cubit owns the duplicate guard (same origin AND same destination
// within ~50 m, direction matters) and the rename / swap / delete / markUsed
// flows the Your Routes screen drives.

// ~1e-5° of latitude ≈ 1.1 m.
const _degPerMeterLat = 1 / 111_000;

const _oLat = -17.39884;
const _oLng = -66.16269;
const _dLat = -17.37;
const _dLng = -66.15;

const _snapshot = SavedRouteSnapshot(
  transitLegs: [SavedRouteTransitLeg(shortName: 'B301', colorHex: '7E57C2')],
  distanceMeters: 5000,
  durationSeconds: 1800,
);

SavedRoute _route({
  String id = '1',
  String name = 'Casa a Trabajo',
  double oLat = _oLat,
  double oLng = _oLng,
  double dLat = _dLat,
  double dLng = _dLng,
  SavedRouteSnapshot? snapshot = _snapshot,
}) => SavedRoute(
  id: id,
  name: name,
  origin: SavedRoutePoint(name: 'Casa', latitude: oLat, longitude: oLng),
  destination: SavedRoutePoint(
    name: 'Trabajo',
    latitude: dLat,
    longitude: dLng,
  ),
  createdAt: DateTime(2026, 10, 13),
  snapshot: snapshot,
);

void main() {
  late InMemoryStorage storage;
  late SavedRoutesCubit cubit;

  Future<List<SavedRoute>> persisted() async {
    final repository = SavedRoutesRepositoryImpl(storage: storage);
    await repository.initialize();
    return repository.getAllRoutes();
  }

  setUp(() async {
    storage = InMemoryStorage();
    cubit = SavedRoutesCubit(
      repository: SavedRoutesRepositoryImpl(storage: storage),
    );
    await cubit.initialize();
  });

  tearDown(() => cubit.close());

  test('initialize loads what was already stored', () async {
    final seed = SavedRoutesRepositoryImpl(storage: storage);
    await seed.initialize();
    await seed.saveRoute(_route());

    final fresh = SavedRoutesCubit(
      repository: SavedRoutesRepositoryImpl(storage: storage),
    );
    await fresh.initialize();
    addTearDown(fresh.close);

    expect(fresh.state.isLoading, isFalse);
    expect(fresh.state.error, isNull);
    expect(fresh.state.routes, [_route()]);
  });

  test('initialize reports a loading failure', () async {
    final failing = SavedRoutesCubit(repository: _ThrowingRepository());
    await failing.initialize();
    addTearDown(failing.close);

    expect(failing.state.isLoading, isFalse);
    expect(failing.state.error, contains('boom'));
  });

  group('saveRoute', () {
    test('appends and persists a new route', () async {
      final saved = await cubit.saveRoute(_route());

      expect(saved, isTrue);
      expect(cubit.state.routes.length, 1);
      expect(await persisted(), [_route()]);
    });

    test('rejects the same trip picked 2 m off at both ends', () async {
      await cubit.saveRoute(_route());

      final saved = await cubit.saveRoute(
        _route(
          id: '2',
          name: 'Otro nombre',
          oLat: _oLat + 2 * _degPerMeterLat,
          dLat: _dLat + 2 * _degPerMeterLat,
        ),
      );

      expect(saved, isFalse);
      expect(cubit.state.routes.map((r) => r.id), ['1']);
      expect((await persisted()).length, 1);
    });

    test('accepts the same origin to a destination 500 m away', () async {
      await cubit.saveRoute(_route());

      final saved = await cubit.saveRoute(
        _route(id: '2', dLat: _dLat + 500 * _degPerMeterLat),
      );

      expect(saved, isTrue);
      expect(cubit.state.routes.length, 2);
    });

    test('accepts the reversed direction as a different trip', () async {
      await cubit.saveRoute(_route());

      final saved = await cubit.saveRoute(_route(id: '2').swapped());

      expect(saved, isTrue);
      expect(cubit.state.routes.length, 2);
    });
  });

  group('findDuplicate', () {
    test('returns the matching route and honours excludeId', () async {
      await cubit.saveRoute(_route());
      final route = cubit.state.routes.single;

      expect(
        cubit.findDuplicate(
          origin: route.origin,
          destination: route.destination,
        ),
        route,
      );
      expect(
        cubit.findDuplicate(
          origin: route.origin,
          destination: route.destination,
          excludeId: route.id,
        ),
        isNull,
      );
    });
  });

  group('renameRoute', () {
    test('trims and persists the new name', () async {
      await cubit.saveRoute(_route());

      await cubit.renameRoute('1', '  Trabajo ');

      expect(cubit.state.routes.first.name, 'Trabajo');
      expect((await persisted()).first.name, 'Trabajo');
    });

    test('ignores a blank name', () async {
      await cubit.saveRoute(_route());

      await cubit.renameRoute('1', '   ');

      expect(cubit.state.routes.first.name, 'Casa a Trabajo');
    });
  });

  group('swapRoute', () {
    test('inverts the endpoints and drops the snapshot', () async {
      await cubit.saveRoute(_route());

      final swapped = await cubit.swapRoute('1');

      expect(swapped, isTrue);
      final route = cubit.state.routes.single;
      expect(route.origin.name, 'Trabajo');
      expect(route.destination.name, 'Casa');
      expect(route.snapshot, isNull);
      expect((await persisted()).single.origin.name, 'Trabajo');
    });

    test('refuses when the reversed trip is already saved', () async {
      await cubit.saveRoute(_route());
      await cubit.saveRoute(_route(id: '2', name: 'Vuelta').swapped());

      final swapped = await cubit.swapRoute('1');

      expect(swapped, isFalse);
      expect(cubit.state.routes.first.origin.name, 'Casa');
      expect(cubit.state.routes.first.snapshot, _snapshot);
    });
  });

  test('deleteRoute removes the route everywhere', () async {
    await cubit.saveRoute(_route());

    await cubit.deleteRoute('1');

    expect(cubit.state.routes, isEmpty);
    expect(await persisted(), isEmpty);
  });

  test('markUsed stamps lastUsedAt and keeps the order', () async {
    await cubit.saveRoute(_route());
    await cubit.saveRoute(_route(id: '2', dLat: -17.3));

    await cubit.markUsed('2');

    expect(cubit.state.routes.map((r) => r.id), ['1', '2']);
    expect(cubit.state.routes.last.lastUsedAt, isNotNull);
    expect(cubit.state.routes.first.lastUsedAt, isNull);
    expect((await persisted()).last.lastUsedAt, isNotNull);
  });
}

class _ThrowingRepository implements SavedRoutesRepository {
  @override
  Future<void> initialize() async => throw StateError('boom');

  @override
  Future<void> dispose() async {}

  @override
  Future<List<SavedRoute>> getAllRoutes() async => [];

  @override
  Future<void> saveRoute(SavedRoute route) async {}

  @override
  Future<void> updateRoute(SavedRoute route) async {}

  @override
  Future<void> deleteRoute(String id) async {}
}
