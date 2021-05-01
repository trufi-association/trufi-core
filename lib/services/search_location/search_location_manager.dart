import 'package:trufi_core/blocs/location_search_bloc.dart';
import 'package:trufi_core/blocs/locations/favorite_locations_cubit/favorite_locations_cubit.dart';
import 'package:trufi_core/trufi_models.dart';

abstract class SearchLocationManager {
  Future<List<TrufiPlace>> fetchLocations(
    FavoriteLocationsCubit favoriteLocationsCubit,
    LocationSearchBloc locationSearchBloc,
    String query, {
    int limit,
    String correlationId,
  });
}
