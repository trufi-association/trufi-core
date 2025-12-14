import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Abstract interface for route planning requests.
abstract class RequestPlanService {
  /// Fetch a route plan from origin to destination.
  Future<routing.Plan> fetchPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    List<routing.TransportMode>? transportModes,
    String? locale,
    DateTime? dateTime,
  });
}
