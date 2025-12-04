import 'package:trufi_core_routing/trufi_core_routing.dart' show TransportMode;

import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_place.dart';

abstract class RequestPlanService {
  Future<Plan> fetchAdvancedPlan({
    required TrufiLocation from,
    required TrufiLocation to,
    required List<TransportMode> transportModes,
    String? localeName,
  });
}
