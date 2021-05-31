import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/pages/home/plan_map/plan_empty.dart';

import 'package:latlong/latlong.dart';

abstract class SearchLocationManager {
  Future<List<TrufiPlace>> fetchLocations(
    LocationSearchBloc locationSearchBloc,
    String query, {
    int limit,
    String correlationId,
  });

  Future<LocationDetail> reverseGeodecoding(LatLng location);
}
