import 'data/otp_version.dart';
import 'data/otp_2_4/otp_2_4_transit_route_repository.dart';
import 'domain/repositories/plan_repository.dart';
import 'domain/repositories/transit_route_repository.dart';

/// Configuration for OTP (OpenTripPlanner) connection.
///
/// This provides a single entry point for configuring OTP endpoints
/// and creating the appropriate repositories based on the OTP version.
class OtpConfiguration {
  /// The base OTP endpoint URL.
  ///
  /// For OTP 1.5: REST API base URL (e.g., "https://example.com/otp")
  /// For OTP 2.x: GraphQL endpoint (e.g., "https://example.com/otp/gtfs/v1")
  final String endpoint;

  /// The OTP version to use.
  final OtpVersion version;

  /// Whether to use simplified GraphQL queries (OTP 2.x only).
  final bool useSimpleQuery;

  const OtpConfiguration({
    required this.endpoint,
    this.version = OtpVersion.v2_4,
    this.useSimpleQuery = false,
  });

  /// Creates the appropriate [PlanRepository] for this configuration.
  PlanRepository createPlanRepository() {
    return OtpRepositoryFactory.create(
      endpoint: _planEndpoint,
      version: version,
      useSimpleQuery: useSimpleQuery,
    );
  }

  /// Creates the appropriate [TransitRouteRepository] for this configuration.
  ///
  /// Note: Transit routes are only available for GraphQL-based OTP versions (2.x).
  /// Returns null for OTP 1.5.
  TransitRouteRepository? createTransitRouteRepository() {
    switch (version) {
      case OtpVersion.v1_5:
        // OTP 1.5 doesn't support patterns query via REST
        return null;
      case OtpVersion.v2_4:
      case OtpVersion.v2_8:
        return Otp24TransitRouteRepository(_graphqlEndpoint);
    }
  }

  /// Returns the endpoint for plan queries.
  ///
  /// For OTP 1.5, appends '/otp/routers/default/plan' if not already present.
  /// For OTP 2.x, this is the GraphQL endpoint.
  String get _planEndpoint {
    switch (version) {
      case OtpVersion.v1_5:
        return _restEndpoint;
      case OtpVersion.v2_4:
      case OtpVersion.v2_8:
        return _graphqlEndpoint;
    }
  }

  /// Returns the REST API endpoint URL for OTP 1.5.
  ///
  /// If the endpoint already contains '/plan', uses it as-is.
  /// Otherwise, appends '/otp/routers/default/plan' for standard OTP setup.
  String get _restEndpoint {
    if (endpoint.contains('/plan')) {
      return endpoint;
    }
    // Standard OTP 1.5 REST endpoint
    final base = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;
    return '$base/otp/routers/default/plan';
  }

  /// Returns the GraphQL endpoint URL.
  ///
  /// If the endpoint already contains '/graphql', uses it as-is.
  /// Otherwise, appends '/index/graphql' for standard OTP setup.
  String get _graphqlEndpoint {
    if (endpoint.contains('/graphql')) {
      return endpoint;
    }
    // Standard OTP 2.x GraphQL endpoint
    return '$endpoint/index/graphql';
  }
}
