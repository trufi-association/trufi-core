import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Abstract interface for home screen local storage.
abstract class HomeScreenRepository {
  /// Initialize the repository.
  Future<void> initialize();

  /// Dispose resources.
  Future<void> dispose();

  /// Save the origin location.
  Future<void> saveFromPlace(TrufiLocation? data);

  /// Get the saved origin location.
  Future<TrufiLocation?> getFromPlace();

  /// Save the destination location.
  Future<void> saveToPlace(TrufiLocation? data);

  /// Get the saved destination location.
  Future<TrufiLocation?> getToPlace();

  /// Save the current plan.
  Future<void> savePlan(routing.Plan? data);

  /// Get the saved plan.
  Future<routing.Plan?> getPlan();

  /// Save the selected itinerary.
  Future<void> saveSelectedItinerary(routing.Itinerary? data);

  /// Get the saved selected itinerary.
  Future<routing.Itinerary?> getSelectedItinerary();

  /// Clear all saved data.
  Future<void> clear();
}
