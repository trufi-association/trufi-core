import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

import 'in_memory_repository.dart';

// #898: "Your places" accepted the same place twice. The first guard compared
// coordinates with a sub-metre epsilon, which the map picker never satisfies
// (two taps on the same building differ by metres) — so the reporter kept
// getting duplicates. The guard now lives on the cubit's write path and
// treats same name within ~50 m as the same place.

// ~1e-5° of latitude ≈ 1.1 m.
const _degPerMeterLat = 1 / 111_000;

SavedPlace _place({
  String id = '1',
  String name = 'Prueba',
  double lat = -17.39884,
  double lng = -66.16269,
  SavedPlaceType type = SavedPlaceType.other,
  String? iconName,
}) => SavedPlace(
  id: id,
  name: name,
  latitude: lat,
  longitude: lng,
  type: type,
  iconName: iconName,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  group('SavedPlacesCubit.distanceMeters', () {
    test('one thousandth of a degree of latitude is ~111 m', () {
      final d = SavedPlacesCubit.distanceMeters(-17.0, -66.0, -17.001, -66.0);
      expect(d, closeTo(111, 1));
    });

    test('identical points are 0 m apart', () {
      expect(SavedPlacesCubit.distanceMeters(-17.4, -66.1, -17.4, -66.1), 0);
    });
  });

  group('SavedPlacesCubit.normalizeName', () {
    test('trims, lower-cases and collapses whitespace', () {
      expect(SavedPlacesCubit.normalizeName('  Mi   Casa '), 'mi casa');
    });

    test('folds precomposed and combining accents', () {
      expect(SavedPlacesCubit.normalizeName('Café'), 'cafe');
      expect(SavedPlacesCubit.normalizeName('Cafe\u0301'), 'cafe'); // NFD
      expect(SavedPlacesCubit.normalizeName('Peñón'), 'penon');
    });
  });

  group('SavedPlacesCubit duplicate guard (#898)', () {
    late InMemorySavedPlacesRepository repository;
    late SavedPlacesCubit cubit;

    setUp(() async {
      repository = InMemorySavedPlacesRepository();
      cubit = SavedPlacesCubit(repository: repository);
      await cubit.initialize();
      await cubit.addOtherPlace(_place());
    });

    tearDown(() => cubit.close());

    test('the reporter\'s case: same name, picker 2 m off, is a duplicate', () {
      final twoMetresNorth = _place(
        id: '2',
        lat: -17.39884 + 2 * _degPerMeterLat,
      );
      expect(cubit.isDuplicatePlace(twoMetresNorth), isTrue);
    });

    test('radius: 10 m apart is a duplicate, 500 m apart is not', () {
      expect(
        cubit.isDuplicatePlace(
          _place(id: '2', lat: -17.39884 + 10 * _degPerMeterLat),
        ),
        isTrue,
      );
      expect(
        cubit.isDuplicatePlace(
          _place(id: '2', lat: -17.39884 + 500 * _degPerMeterLat),
        ),
        isFalse,
      );
    });

    test('name comparison trims, ignores case and accents', () {
      expect(
        cubit.isDuplicatePlace(_place(id: '2', name: '  prueba ')),
        isTrue,
      );
      expect(cubit.isDuplicatePlace(_place(id: '2', name: 'PRÚEBA')), isTrue);
    });

    test('same name far away is allowed', () {
      expect(cubit.isDuplicatePlace(_place(id: '2', lat: -17.5)), isFalse);
    });

    test('different name at the same location is allowed', () {
      expect(cubit.isDuplicatePlace(_place(id: '2', name: 'Otra')), isFalse);
    });

    test('a place does not collide with itself', () {
      expect(cubit.isDuplicatePlace(_place(), excludeId: '1'), isFalse);
    });

    test('home and work count as existing places', () async {
      await cubit.setHome(_place(id: 'h', name: 'Casa', lat: -17.4));
      expect(
        cubit.isDuplicatePlace(_place(id: '2', name: 'Casa', lat: -17.4)),
        isTrue,
      );
    });

    test('history entries never count', () async {
      await cubit.addToHistory(
        _place(
          id: 'hist',
          name: 'Cine',
          lat: -17.41,
          type: SavedPlaceType.history,
        ),
      );
      expect(
        cubit.isDuplicatePlace(_place(id: '2', name: 'Cine', lat: -17.41)),
        isFalse,
      );
    });

    test('savePlace rejects a duplicate and persists nothing', () async {
      final before = (await repository.getAllPlaces()).length;

      final saved = await cubit.savePlace(
        _place(id: '2', lat: -17.39884 + 2 * _degPerMeterLat),
      );

      expect(saved, isFalse);
      expect((await repository.getAllPlaces()).length, before);
      expect(cubit.state.otherPlaces.map((p) => p.id), ['1']);
    });

    test('savePlace accepts a distinct place', () async {
      final saved = await cubit.savePlace(_place(id: '2', name: 'Otra'));
      expect(saved, isTrue);
      expect(cubit.state.otherPlaces.map((p) => p.id), ['1', '2']);
    });

    test('savePlace as Home collides with an equal favourite', () async {
      final saved = await cubit.savePlace(
        _place(id: 'home_placeholder', type: SavedPlaceType.home),
      );
      expect(saved, isFalse);
      expect(cubit.state.home, isNull);
    });

    test('savePlace never blocks history', () async {
      final saved = await cubit.savePlace(
        _place(id: 'hist', type: SavedPlaceType.history),
      );
      expect(saved, isTrue);
    });

    group('updatePlace', () {
      setUp(() async {
        // A duplicate that slipped in before the guard existed.
        await cubit.addOtherPlace(_place(id: '2'));
      });

      test('pre-existing duplicates stay editable (icon only)', () async {
        final saved = await cubit.updatePlace(
          _place(id: '2', iconName: 'star'),
        );
        expect(saved, isTrue);
        expect(
          cubit.state.otherPlaces.firstWhere((p) => p.id == '2').iconName,
          'star',
        );
      });

      test('a nudge within the radius keeps the identity', () async {
        final saved = await cubit.updatePlace(
          _place(id: '2', lat: -17.39884 + 10 * _degPerMeterLat),
        );
        expect(saved, isTrue);
      });

      test('renaming onto another saved place is rejected', () async {
        await cubit.updatePlace(_place(id: '2', name: 'Otra'));
        final saved = await cubit.updatePlace(_place(id: '2', name: 'prueba'));
        expect(saved, isFalse);
        expect(
          cubit.state.otherPlaces.firstWhere((p) => p.id == '2').name,
          'Otra',
        );
      });

      test('renaming to a free name is accepted', () async {
        final saved = await cubit.updatePlace(_place(id: '2', name: 'Otra'));
        expect(saved, isTrue);
        expect(
          (await repository.getAllPlaces()).any((p) => p.name == 'Otra'),
          isTrue,
        );
      });
    });
  });
}
