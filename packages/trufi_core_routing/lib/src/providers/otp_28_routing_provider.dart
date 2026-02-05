import '../data/otp_2_4/otp_2_4_transit_route_repository.dart';
import '../data/otp_2_8/otp_2_8_plan_repository.dart';
import '../domain/entities/routing_capabilities.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/repositories/transit_route_repository.dart';
import 'routing_provider.dart';

/// Routing provider for OpenTripPlanner 2.8.
///
/// OTP 2.8 uses GraphQL API with enhanced features:
/// - Emissions data in itineraries
/// - Enhanced booking info support
/// - Better real-time support
///
/// Example:
/// ```dart
/// final provider = Otp28RoutingProvider(
///   endpoint: 'https://otp.trufi.app',
/// );
/// final repository = provider.createPlanRepository();
/// ```
class Otp28RoutingProvider implements IRoutingProvider {
  /// The OTP endpoint URL.
  ///
  /// Can be the base URL (e.g., "https://example.com/otp") or
  /// the full GraphQL endpoint.
  final String endpoint;

  /// Whether to use simplified GraphQL queries.
  final bool useSimpleQuery;

  /// Custom display name for this provider.
  final String? displayName;

  /// Custom description for this provider.
  final String? displayDescription;

  const Otp28RoutingProvider({
    required this.endpoint,
    this.useSimpleQuery = false,
    this.displayName,
    this.displayDescription,
  });

  @override
  String get id => 'otp_2_8';

  @override
  String get name => displayName ?? 'OTP 2.8';

  @override
  String get description =>
      displayDescription ?? 'OpenTripPlanner 2.8 (Online)';

  @override
  bool get supportsTransitRoutes => true;

  @override
  bool get requiresInternet => true;

  @override
  RoutingCapabilities get capabilities => RoutingCapabilities.otp28;

  @override
  PlanRepository createPlanRepository() {
    return Otp28PlanRepository(
      endpoint: _graphqlEndpoint,
      useSimpleQuery: useSimpleQuery,
    );
  }

  @override
  TransitRouteRepository? createTransitRouteRepository() {
    return Otp24TransitRouteRepository(_graphqlEndpoint);
  }

  /// Returns the GraphQL endpoint URL.
  String get _graphqlEndpoint {
    if (endpoint.contains('/graphql')) {
      return endpoint;
    }
    final base =
        endpoint.endsWith('/') ? endpoint.substring(0, endpoint.length - 1) : endpoint;
    return '$base/otp/routers/default/index/graphql';
  }
}
