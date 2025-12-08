import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart' as home_screen;

/// Concrete repository interface for trufi_core types.
///
/// Extends the generic interface from trufi_core_home_screen.
abstract class MapRouteLocalRepository
    implements home_screen.MapRouteLocalRepository<TrufiLocation, Plan, Itinerary> {
  @override
  Future<void> loadRepository();

  @override
  Future<void> saveFromPlace(TrufiLocation? data);
  @override
  Future<TrufiLocation?> getFromPlace();

  @override
  Future<void> saveToPlace(TrufiLocation? data);
  @override
  Future<TrufiLocation?> getToPlace();

  @override
  Future<void> savePlan(Plan? data);
  @override
  Future<Plan?> getPlan();

  @override
  Future<void> saveSelectedItinerary(Itinerary? data);
  @override
  Future<Itinerary?> getSelectedItinerary();
}
