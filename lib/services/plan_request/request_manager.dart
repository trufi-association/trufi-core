import 'package:async/async.dart';
import 'package:trufi_core/entities/ad_entity/ad_entity.dart';
import 'package:trufi_core/entities/plan_entity/plan_entity.dart';
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

  CancelableOperation<AdEntity> fetchAd(
    TrufiLocation to,
    String correlationId,
  );
}
