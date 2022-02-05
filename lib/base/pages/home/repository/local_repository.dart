import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_place.dart';

abstract class MapRouteLocalRepository {
  Future<void> loadRepository();

  Future<void> saveFromPlace(TrufiLocation? data);
  Future<TrufiLocation?> getFromPlace();

  Future<void> saveToPlace(TrufiLocation? data);
  Future<TrufiLocation?> getToPlace();

  Future<void> savePlan(Plan? data);
  Future<Plan?> getPlan();

  Future<void> saveSelectedItinerary(Itinerary? data);
  Future<Itinerary?> getSelectedItinerary();
}
