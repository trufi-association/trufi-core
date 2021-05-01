import 'package:async/async.dart';
import 'package:trufi_core/trufi_models.dart';

abstract class RequestManager {
  CancelableOperation<Plan> fetchTransitPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  );

  CancelableOperation<Plan> fetchCarPlan(
    TrufiLocation from,
    TrufiLocation to,
    String correlationId,
  );

  CancelableOperation<Ad> fetchAd(
    TrufiLocation to,
    String correlationId,
  );
}
