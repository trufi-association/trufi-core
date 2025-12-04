import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;

/// Service for fetching transit route patterns.
///
/// This wraps the routing package's [routing.TransitRouteRepository] and converts
/// the routing package models to UI models.
class RouteTransportsServices {
  final routing.TransitRouteRepository? _repository;

  RouteTransportsServices(routing.OtpConfiguration otpConfiguration)
      : _repository = otpConfiguration.createTransitRouteRepository();

  Future<List<TransitRoute>> fetchPatterns() async {
    if (_repository == null) {
      throw UnsupportedError(
        'Transit routes are not supported for this OTP version',
      );
    }
    final patterns = await _repository.fetchPatterns();
    return patterns.map((p) => TransitRoute.fromRouting(p)).toList();
  }

  Future<TransitRoute> fetchDataPattern(String idStop) async {
    if (_repository == null) {
      throw UnsupportedError(
        'Transit routes are not supported for this OTP version',
      );
    }
    final pattern = await _repository.fetchPatternById(idStop);
    return TransitRoute.fromRouting(pattern);
  }
}
