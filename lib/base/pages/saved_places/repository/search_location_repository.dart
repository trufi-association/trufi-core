import 'package:latlong2/latlong.dart';

import 'package:trufi_core/base/models/trufi_place.dart';

abstract class SearchLocationRepository {
  Future<List<TrufiPlace>> fetchLocations(
    String query, {
    int limit,
    String? correlationId,
    String? lang,
  });

  Future<LocationDetail> reverseGeodecoding(
    LatLng location, {
    String? lang,
  });
}
