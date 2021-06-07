import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/location/location_search_storage.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/pages/home/plan_map/plan_empty.dart';

import 'search_location_manager.dart';

class OfflineSearchLocation implements SearchLocationManager {
  @override
  Future<List<TrufiPlace>> fetchLocations(
    // FavoriteLocationsCubit favoriteLocationsCubit,
    LocationSearchBloc locationSearchBloc,
    String query, {
    String correlationId,
    int limit = 30,
  }) async {
    final LocationSearchStorage storage = locationSearchBloc.storage;

    final queryPlaces = await storage.fetchPlacesWithQuery(query);
    final queryStreets = await storage.fetchStreetsWithQuery(query);

    // Combine Places and Street sort by distance
    final List<LevenshteinObject<TrufiPlace>> sortedLevenshteinObjects = [
      ...queryPlaces, // High priority
      ...queryStreets // Low priority
    ]..sort((a, b) => a.distance.compareTo(b.distance));

    // Remove levenshteinObject
    final List<TrufiPlace> trufiPlaces = sortedLevenshteinObjects
        .take(limit)
        .map((LevenshteinObject<TrufiPlace> l) => l.object)
        .toList();

    // sort with street priority
    mergeSort(trufiPlaces, compare: (a, b) => (a is TrufiStreet) ? -1 : 1);

    // // Favorites to the top
    // mergeSort(trufiPlaces, compare: (a, b) {
    //   return sortByFavoriteLocations(a, b,);
    // });

    return trufiPlaces;
  }

  @override
  Future<LocationDetail> reverseGeodecoding(LatLng location) async {
    final response = await http.get(
      Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?lat=${location.latitude}&lon=${location.longitude}&format=json&zoom=17",
      ),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final String displayName = body["display_name"]?.toString();
    final String road = body["address"]["road"]?.toString();
    final String hamlet = body["address"]["hamlet"]?.toString();
    return LocationDetail(
      road ?? displayName ?? "",
      hamlet ?? "",
    );
  }
}
