import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' show TransportMode;

/// Abstract service for fetching route plans.
abstract class RequestPlanService<TLocation extends ITrufiLocation,
    TPlan extends IPlan> {
  Future<TPlan> fetchAdvancedPlan({
    required TLocation from,
    required TLocation to,
    required List<TransportMode> transportModes,
    String? localeName,
  });
}
