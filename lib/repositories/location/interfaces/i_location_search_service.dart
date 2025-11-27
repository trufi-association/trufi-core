import 'package:latlong2/latlong.dart';
import 'package:trufi_core/models/trufi_location.dart';

abstract class ILocationSearchService {
  Future<List<TrufiLocation>> fetchLocations(String query, {int limit});

  Future<TrufiLocation> reverseGeodecoding(LatLng location);
}
