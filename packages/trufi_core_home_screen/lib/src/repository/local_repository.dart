import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Abstract repository for storing route planner state locally.
abstract class MapRouteLocalRepository<TLocation extends ITrufiLocation,
    TPlan extends IPlan, TItinerary extends IItinerary> {
  Future<void> loadRepository();

  Future<void> saveFromPlace(TLocation? data);
  Future<TLocation?> getFromPlace();

  Future<void> saveToPlace(TLocation? data);
  Future<TLocation?> getToPlace();

  Future<void> savePlan(TPlan? data);
  Future<TPlan?> getPlan();

  Future<void> saveSelectedItinerary(TItinerary? data);
  Future<TItinerary?> getSelectedItinerary();
}
