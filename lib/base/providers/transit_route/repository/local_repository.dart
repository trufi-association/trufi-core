import 'package:trufi_core/base/blocs/providers/city_selection_manager.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';

abstract class RouteTransportsLocalRepository {
  Future<void> loadRepository();
  Future<void> saveTransports(List<TransitRoute> data);
  Future<CityInstance?> getCityInstance();
  Future<void> saveCityInstance(CityInstance data);
  Future<List<TransitRoute>> getTransports();
}
