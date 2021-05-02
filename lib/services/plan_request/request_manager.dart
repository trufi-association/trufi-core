import 'package:async/async.dart';
import 'package:trufi_core/entities/plan_entities/plan_entity.dart';
import 'package:trufi_core/trufi_models.dart';

abstract class RequestManager {
  CancelableOperation<PlanEntity> fetchTransitPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  );

  CancelableOperation<PlanEntity> fetchCarPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  );

  CancelableOperation<Ad> fetchAd(
    TrufiLocation to,
    String correlationId,
  );
}
