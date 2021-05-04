import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trufi_core/location/location_search_storage.dart';
import 'package:trufi_core/services/search_location/offline_search_location.dart';
import 'package:trufi_core/trufi_models.dart';

import '../mocks/location_search_bloc.dart';

void main() {
  group("OfflineRepository", () {
    OfflineSearchLocation subject;
    MockFavoriteLocationsCubit favoriteLocationCubit;
    MockLocationSearchBloc locationSearchBloc;
    MockLocationSearchStorage locationSearchStorage;

    const query = "TestQuery";

    setUp(() {
      subject = OfflineSearchLocation();

      favoriteLocationCubit = MockFavoriteLocationsCubit();
      locationSearchBloc = MockLocationSearchBloc();

      locationSearchStorage = MockLocationSearchStorage();
      when(locationSearchBloc.storage).thenReturn(locationSearchStorage);

      when(locationSearchStorage.fetchPlacesWithQuery(query)).thenAnswer(
        (_) => Future.value(getTrufiLocationList()),
      );

      when(locationSearchStorage.fetchStreetsWithQuery(query)).thenAnswer(
        (_) => Future.value(getTrufiStreetList()),
      );

      when(favoriteLocationCubit.locations).thenReturn(
          [TrufiLocation(description: "Favorite", longitude: 5, latitude: 8)]);
    });

    test("should sort streets first", () async {
      final results = await subject.fetchLocations(
          favoriteLocationCubit, locationSearchBloc, query);

      for (var i = 0; i < results.length; i++) {
        if (i == 0) {
          expect(results[i] is TrufiLocation, true,
              reason: "This is our Favorite");
        }
        if (i != 0 && i < 4) {
          expect(results[i] is TrufiStreet, true,
              reason: "Second result is not TrufiStreet");
        }
        if (i >= 4) {
          expect(results[i] is TrufiLocation, true,
              reason: "Second result is not TrufiLocation");
        }
      }
    });

    test("should sort shortest distance first", () async {
      final List<dynamic> results = await subject.fetchLocations(
          favoriteLocationCubit, locationSearchBloc, query);

      expect(results[0].description, "Favorite");
      expect(results[1].description, "Streets: Long Distance");
      expect(results[2].description, "Streets: Medium Distance");
      expect(results[3].description, "Streets: Short Distance");
      expect(results[4].description, "Location: Shortest Distance");
      expect(results[5].description, "Location: Medium Distance");
      expect(results[6].description, "Location: Longest Distance");
    });

    test("should take the limit into account", () async {
      final results = await subject.fetchLocations(
          favoriteLocationCubit, locationSearchBloc, query,
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

class MockLocationSearchStorage extends Mock implements LocationSearchStorage {}
