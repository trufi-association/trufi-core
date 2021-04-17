import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trufi_core/blocs/favorite_locations_bloc.dart';
import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/blocs/preferences_bloc.dart';
import 'package:trufi_core/blocs/request_manager/offline_request_manager.dart';
import 'package:trufi_core/location/location_search_storage.dart';
import 'package:trufi_core/trufi_models.dart';

void main() {
  group("OfflineRequestManager", () {
    OfflineRequestManager subject;
    MockFavoriteLocationBloc favoriteLocationBloc;
    MockPreferencesBloc preferencesBloc;
    MockLocationSearchBloc locationSearchBloc;
    MockLocationSearchStorage locationSearchStorage;

    const query = "TestQuery";

    setUp(() {
      subject = OfflineRequestManager();

      favoriteLocationBloc = MockFavoriteLocationBloc();
      preferencesBloc = MockPreferencesBloc();
      locationSearchBloc = MockLocationSearchBloc();

      locationSearchStorage = MockLocationSearchStorage();
      when(locationSearchBloc.storage).thenReturn(locationSearchStorage);

      when(locationSearchStorage.fetchPlacesWithQuery(query)).thenAnswer(
        (_) => Future.value(getTrufiLocationList()),
      );

      when(locationSearchStorage.fetchStreetsWithQuery(query)).thenAnswer(
        (_) => Future.value(getTrufiStreetList()),
      );

      when(favoriteLocationBloc.locations).thenReturn(
          [TrufiLocation(description: "Favorite", longitude: 5, latitude: 8)]);
    });

    test("should sort streets first", () async {
      final results = await subject.fetchLocations(
          favoriteLocationBloc, locationSearchBloc, preferencesBloc, query);

      for (var i = 0; i < results.length; i++) {
        if (i == 0)
          expect(results[i] is TrufiLocation, true,
              reason: "This is our Favorite");
        if (i != 0 && i < 4)
          expect(results[i] is TrufiStreet, true,
              reason: "Second result is not TrufiStreet");
        if (i >= 4)
          expect(results[i] is TrufiLocation, true,
              reason: "Second result is not TrufiLocation");
      }
    });

    test("should sort shortest distance first", () async {
      final List<dynamic> results = await subject.fetchLocations(
          favoriteLocationBloc, locationSearchBloc, preferencesBloc, query);

      for (var i = 0; i < results.length; i++) {
        final result = results[i];
        if (i == 0) expect(result.description, "Favorite");
        if (i == 1) expect(result.description, "Streets: Long Distance");
        if (i == 2) expect(result.description, "Streets: Medium Distance");
        if (i == 3) expect(result.description, "Streets: Short Distance");
        if (i == 4) expect(result.description, "Location: Shortest Distance");
        if (i == 5) expect(result.description, "Location: Medium Distance");
        if (i == 6) expect(result.description, "Location: Longest Distance");
      }
    });

    test("should take the limit into account", () async {
      final results = await subject.fetchLocations(
          favoriteLocationBloc, locationSearchBloc, preferencesBloc, query,
          limit: 5);

      expect(results.length, 5);
    });
  });
}

List<LevenshteinObject<TrufiStreet>> getTrufiStreetList() {
  return [
    LevenshteinObject(
      TrufiStreet(
        location: TrufiLocation(
          latitude: 15,
          description: 'Streets: Long Distance',
          longitude: 45,
        ),
      ),
      105,
    ),
    LevenshteinObject(
      TrufiStreet(
        location: TrufiLocation(
          latitude: 85,
          description: 'Streets: Short Distance',
          longitude: 55,
        ),
      ),
      22,
    ),
    LevenshteinObject(
      TrufiStreet(
        location: TrufiLocation(
          latitude: 22,
          description: 'Streets: Medium Distance',
          longitude: 79,
        ),
      ),
      53,
    )
  ];
}

List<LevenshteinObject<TrufiLocation>> getTrufiLocationList() {
  return [
    LevenshteinObject(
      TrufiLocation(
        description: "Location: Medium Distance",
        longitude: 5,
        latitude: 8,
      ),
      109,
    ),
    LevenshteinObject(
        TrufiLocation(
          description: "Location: Longest Distance",
          longitude: 5,
          latitude: 8,
        ),
        190),
    LevenshteinObject(
        TrufiLocation(
          description: "Location: Shortest Distance",
          longitude: 5,
          latitude: 8,
        ),
        30),
    LevenshteinObject(
        TrufiLocation(description: "Favorite", longitude: 5, latitude: 8), 30)
  ];
}

class MockFavoriteLocationBloc extends Mock implements FavoriteLocationsBloc {}

class MockPreferencesBloc extends Mock implements PreferencesBloc {}

class MockLocationSearchBloc extends Mock implements LocationSearchBloc {}

class MockLocationSearchStorage extends Mock implements LocationSearchStorage {}
