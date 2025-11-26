import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

abstract class MapRouteLocalRepository {
  Future<void> loadRepository();

  Future<void> savePlan(PlanEntity? data);
  Future<PlanEntity?> getPlan();

  Future<void> saveOriginPosition(TrufiLocation? location);
  Future<TrufiLocation?> getOriginPosition();

  Future<void> saveDestinationPosition(TrufiLocation? location);
  Future<TrufiLocation?> getDestinationPosition();
}
