import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';

import 'in_memory_repository.dart';

// #1003: "Your places" showed three identical "Parada" rows. The #898 guard
// only sees same-name places within 50 m, so names reused across town are
// legal — the sheet now warns softly while typing. This is the predicate
// behind that notice.

SavedPlace _place({
  required String id,
  required String name,
  double lat = -17.39884,
  double lng = -66.16269,
  SavedPlaceType type = SavedPlaceType.other,
}) => SavedPlace(
  id: id,
  name: name,
  latitude: lat,
  longitude: lng,
  type: type,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  group('SavedPlacesCubit.hasSameName', () {
    late SavedPlacesCubit cubit;

    setUp(() async {
      cubit = SavedPlacesCubit(repository: InMemorySavedPlacesRepository());
      await cubit.initialize();
      await cubit.addOtherPlace(_place(id: '1', name: 'Parada'));
    });

    tearDown(() => cubit.close());

    test('the reporter\'s case: same name 3 km away is not a duplicate for '
        '#898 but does share the name', () {
      final acrossTown = _place(id: '2', name: 'Parada', lat: -17.37);
      expect(cubit.isDuplicatePlace(acrossTown), isFalse);
      expect(cubit.hasSameName(acrossTown.name), isTrue);
    });

    test('comparison trims, ignores case, accents and inner spaces', () {
      expect(cubit.hasSameName('  parada '), isTrue);
      expect(cubit.hasSameName('PARÁDA'), isTrue);
      expect(cubit.hasSameName('Pa  rada'), isFalse);
    });

    test('a different name is free', () {
      expect(cubit.hasSameName('Parada 2'), isFalse);
      expect(cubit.hasSameName('Otra'), isFalse);
    });

    test('editing a place does not collide with itself', () {
      expect(cubit.hasSameName('Parada', excludeId: '1'), isFalse);
      expect(cubit.hasSameName('Parada', excludeId: '2'), isTrue);
    });

    test('an empty or blank name is never "taken"', () {
      expect(cubit.hasSameName(''), isFalse);
      expect(cubit.hasSameName('   '), isFalse);
    });

    test('Home and Work count as existing names', () async {
      await cubit.setHome(_place(id: 'h', name: 'Casa', lat: -17.4));
      await cubit.setWork(_place(id: 'w', name: 'Oficina', lat: -17.41));
      expect(cubit.hasSameName('casa'), isTrue);
      expect(cubit.hasSameName('Oficina'), isTrue);
      expect(cubit.hasSameName('Casa', excludeId: 'home'), isFalse);
    });

    test('history entries never count', () async {
      await cubit.addToHistory(
        _place(id: 'hist', name: 'Cine', type: SavedPlaceType.history),
      );
      expect(cubit.hasSameName('Cine'), isFalse);
    });
  });

  group('localized default labels (#1019)', () {
    test(
      'a Home stored as "Home" counts as "Casa" under the Spanish labels',
      () async {
        final cubit = SavedPlacesCubit(
          repository: InMemorySavedPlacesRepository(),
        );
        await cubit.initialize();
        await cubit.setHome(
          _place(id: 'h', name: 'Home', type: SavedPlaceType.home),
        );
        final es = lookupSavedPlacesLocalizations(const Locale('es'));
        expect(cubit.hasSameName('Casa', localization: es), isTrue);
        expect(cubit.hasSameName('casa ', localization: es), isTrue);
        // Without the localization only the stored name is compared.
        expect(cubit.hasSameName('Casa'), isFalse);
        // The other default label (Work) does not match.
        expect(cubit.hasSameName('Trabajo', localization: es), isFalse);
      },
    );

    test('editing Home itself never collides with its own label', () async {
      final cubit = SavedPlacesCubit(
        repository: InMemorySavedPlacesRepository(),
      );
      await cubit.initialize();
      await cubit.setHome(
        _place(id: 'h', name: 'Home', type: SavedPlaceType.home),
      );
      final es = lookupSavedPlacesLocalizations(const Locale('es'));
      expect(
        cubit.hasSameName(
          'Casa',
          excludeId: cubit.state.home!.id,
          localization: es,
        ),
        isFalse,
      );
    });
  });
}
