import 'package:trufi_core_routing/trufi_core_routing.dart' show TransportMode;
import 'package:trufi_core_home_screen/trufi_core_home_screen.dart' as home_screen;

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_place.dart';

/// Concrete service interface for trufi_core types.
///
/// Extends the generic interface from trufi_core_home_screen.
abstract class RequestPlanService
    implements home_screen.RequestPlanService<TrufiLocation, Plan> {
  @override
  Future<Plan> fetchAdvancedPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    required List<TransportMode> transportModes,
    String? localeName,
  });
}
