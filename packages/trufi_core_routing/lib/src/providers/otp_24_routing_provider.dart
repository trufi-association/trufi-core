import '../data/otp_2_4/otp_2_4_plan_repository.dart';
import '../data/otp_2_4/otp_2_4_transit_route_repository.dart';
import '../domain/entities/routing_capabilities.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/repositories/transit_route_repository.dart';
import 'routing_provider.dart';

/// Routing provider for OpenTripPlanner 2.4.
///
/// OTP 2.4 uses the standard OTP GraphQL schema with:
/// - plan query with itineraries
/// - Transit route patterns
/// - Real-time data support
///
/// Example:
/// ```dart
/// final provider = Otp24RoutingProvider(
///   endpoint: 'https://otp.example.com',
/// );
/// final repository = provider.createPlanRepository();
/// ```
class Otp24RoutingProvider implements IRoutingProvider {
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

  const Otp24RoutingProvider({
    required this.endpoint,
    this.useSimpleQuery = false,
    this.displayName,
    this.displayDescription,
  });

  @override
  String get id => 'otp_2_4';

  @override
  String get name => displayName ?? 'OTP 2.4';

  @override
  String get description =>
      displayDescription ?? 'OpenTripPlanner 2.4 (Online)';

  @override
  bool get supportsTransitRoutes => true;

  @override
  bool get requiresInternet => true;

  @override
  RoutingCapabilities get capabilities => RoutingCapabilities.otp24;

  @override
  Future<void> initialize() async {}

  @override
  PlanRepository createPlanRepository() {
    return Otp24PlanRepository(
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
