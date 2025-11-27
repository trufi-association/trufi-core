import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/models/trufi_location.dart';

abstract class MapRouteLocalRepository {
  Future<void> loadRepository();

  Future<void> savePlan(PlanEntity? data);
  Future<PlanEntity?> getPlan();

  Future<void> saveOriginPosition(TrufiLocation? location);
  Future<TrufiLocation?> getOriginPosition();

  Future<void> saveDestinationPosition(TrufiLocation? location);
  Future<TrufiLocation?> getDestinationPosition();
}
