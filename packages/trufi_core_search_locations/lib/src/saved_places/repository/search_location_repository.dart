import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Abstract interface for searching and geocoding locations.
abstract class SearchLocationRepository {
  Future<List<TrufiPlace>> fetchLocations(
    String query, {
    int limit,
    String? correlationId,
  });

  Future<LocationDetail> reverseGeodecoding(TrufiLatLng location);
}
