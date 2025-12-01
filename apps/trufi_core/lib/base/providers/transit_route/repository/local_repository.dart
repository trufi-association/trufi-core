import 'package:trufi_core/base/models/transit_route/transit_route.dart';

abstract class RouteTransportsLocalRepository {
  Future<void> loadRepository();
  Future<void> saveTransports(List<TransitRoute> data);
  Future<List<TransitRoute>> getTransports();
}
