import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

import 'in_memory_repository.dart';
import 'in_memory_storage.dart';

// #1003: SavedPlacesTrufiScreen resolves picked points through the app's
// SearchLocationsCubit — the geocoder the home screen already uses — so no
// city app has to wire anything to get street names under its favourites.

const _lat = -17.39884;
const _lng = -66.16269;

SearchLocation _answer({required String displayName, String? address}) =>
    SearchLocation(
      id: 'x',
      displayName: displayName,
      address: address,
      latitude: _lat,
      longitude: _lng,
    );

/// A geocoder that answers [reverse] from a fixed table.
class _FakeSearchService implements SearchLocationService {
  _FakeSearchService(this.onReverse);

  final Future<SearchLocation?> Function(double lat, double lng) onReverse;
  int reverseCalls = 0;

  @override
  Future<List<SearchLocation>> search(String query) async => const [];

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) {
    reverseCalls++;
    return onReverse(latitude, longitude);
  }

  @override
  void dispose() {}
}

SavedPlace _parada({String? address}) => SavedPlace(
  id: 'legacy',
  name: 'Parada',
  address: address,
  latitude: _lat,
  longitude: _lng,
  type: SavedPlaceType.other,
  createdAt: DateTime(2026, 1, 1),
);

/// The example app's assembly: MapEngineManager + the app-level
/// SearchLocationsCubit + the screen's own providers.
Future<void> _pumpTrufiScreen(
  WidgetTester tester, {
  required SavedPlacesTrufiScreen screen,
  SearchLocationService? searchService,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapEngineManager(
            engines: defaultMapEngines,
            defaultCenter: const LatLng(-17.3895, -66.1568),
          ),
        ),
        if (searchService != null)
          BlocProvider(
            create: (_) => SearchLocationsCubit(
              searchLocationService: searchService,
              localRepository: SearchLocationsRepositoryImpl(
                storage: InMemoryStorage(),
              ),
            ),
          ),
        ...screen.providers,
      ],
      child: MaterialApp(
        localizationsDelegates: [
          ...screen.localizationsDelegates,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: SavedPlacesLocalizations.supportedLocales,
        home: Scaffold(body: Builder(builder: screen.builder)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openEditOfParada(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.more_vert_rounded));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Edit place'));
  await tester.pumpAndSettle();
}

void main() {
  group('addressFromReverseGeocode', () {
    test('a street point: the address already names the street', () {
      expect(
        addressFromReverseGeocode(
          _answer(
            displayName: 'Avenida Heroínas',
            address: 'Avenida Heroínas, Cochabamba, Bolivia',
          ),
        ),
        'Avenida Heroínas, Cochabamba, Bolivia',
      );
    });

    test('a POI: name first, then its address', () {
      expect(
        addressFromReverseGeocode(
          _answer(
            displayName: 'Mercado La Cancha',
            address: 'Av. San Martín, Cochabamba, Bolivia',
          ),
        ),
        'Mercado La Cancha, Av. San Martín, Cochabamba, Bolivia',
      );
    });

    test('name only, address only, nothing', () {
      expect(
        addressFromReverseGeocode(_answer(displayName: 'Plaza Colón')),
        'Plaza Colón',
      );
      expect(
        addressFromReverseGeocode(
          _answer(displayName: '', address: 'Cochabamba, Bolivia'),
        ),
        'Cochabamba, Bolivia',
      );
      expect(addressFromReverseGeocode(_answer(displayName: ' ')), isNull);
    });
  });

  group('SavedPlacesTrufiScreen', () {
    testWidgets('resolves a legacy favourite through the app\'s '
        'SearchLocationsCubit and stores the street', (tester) async {
      final repository = InMemorySavedPlacesRepository();
      await repository.savePlace(_parada());
      final service = _FakeSearchService(
        (lat, lng) async => _answer(
          displayName: 'Avenida Heroínas',
          address: 'Avenida Heroínas, Cochabamba, Bolivia',
        ),
      );

      await _pumpTrufiScreen(
        tester,
        screen: SavedPlacesTrufiScreen(
          config: SavedPlacesConfig(repository: repository),
        ),
        searchService: service,
      );
      expect(find.text('Parada'), findsOneWidget);
      expect(find.textContaining('Heroínas'), findsNothing);

      await _openEditOfParada(tester);
      expect(service.reverseCalls, 1);
      expect(
        find.text('Avenida Heroínas, Cochabamba, Bolivia'),
        findsOneWidget,
        reason: 'the location card shows the resolved street',
      );

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(
          SavedPlaceTile,
          'Avenida Heroínas, Cochabamba, Bolivia',
        ),
        findsOneWidget,
      );
      expect(
        (await repository.getOtherPlaces()).single.address,
        'Avenida Heroínas, Cochabamba, Bolivia',
      );
    });

    testWidgets('without a SearchLocationsCubit the place keeps working and '
        'gets its coordinates as address', (tester) async {
      final repository = InMemorySavedPlacesRepository();
      await repository.savePlace(_parada());

      await _pumpTrufiScreen(
        tester,
        screen: SavedPlacesTrufiScreen(
          config: SavedPlacesConfig(repository: repository),
        ),
      );
      await _openEditOfParada(tester);
      expect(find.text('-17.39884, -66.16269'), findsOneWidget);

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        (await repository.getOtherPlaces()).single.address,
        '-17.39884, -66.16269',
      );
    });

    testWidgets('a geocoder that answers nothing yields the coordinates', (
      tester,
    ) async {
      final repository = InMemorySavedPlacesRepository();
      await repository.savePlace(_parada());
      final service = _FakeSearchService((_, _) async => null);

      await _pumpTrufiScreen(
        tester,
        screen: SavedPlacesTrufiScreen(
          config: SavedPlacesConfig(repository: repository),
        ),
        searchService: service,
      );
      await _openEditOfParada(tester);
      expect(service.reverseCalls, 1);
      expect(find.text('-17.39884, -66.16269'), findsOneWidget);
    });

    testWidgets('SavedPlacesConfig.resolveAddress overrides the cubit', (
      tester,
    ) async {
      final repository = InMemorySavedPlacesRepository();
      await repository.savePlace(_parada());
      final service = _FakeSearchService(
        (_, _) async => _answer(displayName: 'from the cubit'),
      );

      await _pumpTrufiScreen(
        tester,
        screen: SavedPlacesTrufiScreen(
          config: SavedPlacesConfig(
            repository: repository,
            resolveAddress: (_, _) async => 'from the app',
          ),
        ),
        searchService: service,
      );
      await _openEditOfParada(tester);
      expect(service.reverseCalls, 0);
      expect(find.text('from the app'), findsOneWidget);
    });
  });
}
