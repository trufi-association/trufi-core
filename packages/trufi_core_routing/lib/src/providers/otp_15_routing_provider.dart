import '../data/otp_1_5/otp_1_5_plan_repository.dart';
import '../domain/entities/routing_capabilities.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/repositories/transit_route_repository.dart';
import 'routing_provider.dart';

/// Routing provider for OpenTripPlanner 1.5.
///
/// OTP 1.5 uses the legacy REST API at /otp/routers/default/plan endpoint.
/// Location format: "lat,lon"
/// Times: milliseconds since epoch
///
/// Note: This version does NOT support listing transit routes (patterns query).
///
/// Example:
/// ```dart
/// final provider = Otp15RoutingProvider(
///   endpoint: 'https://otp.example.com',
/// );
/// final repository = provider.createPlanRepository();
/// ```
class Otp15RoutingProvider implements IRoutingProvider {
  /// The OTP endpoint URL.
  ///
  /// Can be the base URL (e.g., "https://example.com/otp") or
  /// the full REST endpoint.
  final String endpoint;

  /// Custom display name for this provider.
  final String? displayName;

  /// Custom description for this provider.
  final String? displayDescription;

  const Otp15RoutingProvider({
    required this.endpoint,
    this.displayName,
    this.displayDescription,
  });

  @override
  String get id => 'otp_1_5';

  @override
  String get name => displayName ?? 'OTP 1.5';

  @override
  String get description =>
      displayDescription ?? 'OpenTripPlanner 1.5 (Online)';

  @override
  bool get supportsTransitRoutes => false;

  @override
  bool get requiresInternet => true;

  @override
  RoutingCapabilities get capabilities => RoutingCapabilities.otp15;

  @override
  Future<void> initialize() async {}

  @override
  PlanRepository createPlanRepository() {
    return Otp15PlanRepository(endpoint: _restEndpoint);
  }

  @override
  TransitRouteRepository? createTransitRouteRepository() {
    // OTP 1.5 doesn't support patterns query via REST
    return null;
  }

  /// Returns the REST API endpoint URL for OTP 1.5.
  String get _restEndpoint {
    if (endpoint.contains('/plan')) {
      return endpoint;
    }
    final base =
        endpoint.endsWith('/') ? endpoint.substring(0, endpoint.length - 1) : endpoint;
    return '$base/otp/routers/default/plan';
  }
}
