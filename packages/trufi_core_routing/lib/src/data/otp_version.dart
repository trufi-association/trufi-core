import '../domain/repositories/plan_repository.dart';
import 'otp_1_5/otp_1_5_plan_repository.dart';
import 'otp_2_4/otp_2_4_plan_repository.dart';
import 'otp_2_7/otp_2_7_plan_repository.dart';
import 'otp_2_8/otp_2_8_plan_repository.dart';

/// Supported OTP (OpenTripPlanner) versions.
enum OtpVersion {
  /// OTP 1.5 - Legacy REST API.
  ///
  /// Uses: REST API at /otp/routers/default/plan endpoint.
  /// Location format: "lat,lon"
  /// Times: milliseconds since epoch
  v1_5,

  /// OTP 2.4 - Standard OTP GraphQL schema.
  ///
  /// Uses: plan query, itineraries, route, agency, stops.
  /// Location format: "name::lat,lon"
  /// Times: milliseconds since epoch
  v2_4,

  /// OTP 2.7 - Standard OTP GraphQL schema.
  ///
  /// Uses: plan query, itineraries, route, agency, stops.
  /// Similar to 2.8 but without emissions data.
  /// Location format: "name::lat,lon"
  /// Times: milliseconds since epoch
  v2_7,

  /// OTP 2.8 - Latest standard OTP GraphQL schema.
  ///
  /// Uses: plan query, itineraries with emissions, enhanced booking info.
  /// Location format: "name::lat,lon"
  /// Times: milliseconds since epoch
  v2_8,
}

/// Extension methods for [OtpVersion].
extension OtpVersionExtension on OtpVersion {
  /// Returns a human-readable name for this version.
  String get displayName {
    switch (this) {
      case OtpVersion.v1_5:
        return 'OTP 1.5';
      case OtpVersion.v2_4:
        return 'OTP 2.4';
      case OtpVersion.v2_7:
        return 'OTP 2.7';
      case OtpVersion.v2_8:
        return 'OTP 2.8';
    }
  }

  /// Returns a description of the schema used by this version.
  String get schemaDescription {
    switch (this) {
      case OtpVersion.v1_5:
        return 'Legacy REST API (/otp/routers/default/plan)';
      case OtpVersion.v2_4:
        return 'Standard OTP GraphQL schema (plan → itineraries → legs)';
      case OtpVersion.v2_7:
        return 'Standard OTP GraphQL schema without emissions data';
      case OtpVersion.v2_8:
        return 'Enhanced OTP GraphQL schema with emissions and booking support';
    }
  }
}

/// Factory for creating [PlanRepository] instances based on OTP version.
class OtpRepositoryFactory {
  OtpRepositoryFactory._();

  /// Creates a [PlanRepository] for the specified OTP version.
  ///
  /// [endpoint] is the API endpoint URL (REST for 1.5, GraphQL for 2.x).
  /// [version] specifies which OTP version to use.
  /// [useSimpleQuery] if true, uses a simpler query with fewer parameters
  /// (only applicable for GraphQL versions 2.x).
  static PlanRepository create({
    required String endpoint,
    required OtpVersion version,
    bool useSimpleQuery = false,
  }) {
    switch (version) {
      case OtpVersion.v1_5:
        return Otp15PlanRepository(
          endpoint: endpoint,
        );
      case OtpVersion.v2_4:
        return Otp24PlanRepository(
          endpoint: endpoint,
          useSimpleQuery: useSimpleQuery,
        );
      case OtpVersion.v2_7:
        return Otp27PlanRepository(
          endpoint: endpoint,
          useSimpleQuery: useSimpleQuery,
        );
      case OtpVersion.v2_8:
        return Otp28PlanRepository(
          endpoint: endpoint,
          useSimpleQuery: useSimpleQuery,
        );
    }
  }
}
