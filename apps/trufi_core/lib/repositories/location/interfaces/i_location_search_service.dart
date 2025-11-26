import 'package:latlong2/latlong.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

abstract class ILocationSearchService {
  Future<List<TrufiLocation>> fetchLocations(String query, {int limit});

  Future<TrufiLocation> reverseGeodecoding(LatLng location);
}
