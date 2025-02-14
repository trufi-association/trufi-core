import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/repository/search_location/location_search_storage.dart';
import '../search_location_repository.dart';

class DefaultSearchLocation implements SearchLocationRepository {
  final LocationSearchStorage storage = LocationSearchStorage();
  final String photonUrl;
  DefaultSearchLocation(String searchAssetPath, this.photonUrl) {
    storage.load(searchAssetPath);
  }

  @override
  Future<List<TrufiPlace>> fetchLocations(
    String query, {
    String? correlationId,
    int limit = 30,
    String? lang,
  }) async {
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
  Future<LocationDetail> reverseGeodecoding(
    LatLng location, {
    String? lang,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$photonUrl/reverse?lon=${location.longitude}&lat=${location.latitude}",
      ),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body["type"] == "FeatureCollection") {
      final features = body["features"] as List;
      if (features.isNotEmpty) {
        final feature = features.first;
        final properties = feature["properties"];
        return LocationDetail(
            properties["name"], properties["street"] ?? "", location);
      }
    }
    throw Exception("no data found");
  }
}
