import 'package:flutter/widgets.dart';
import 'package:trufi_core/models/enums/transport_mode.dart' as app_mode;
import 'package:trufi_core/repositories/storage/local_storage_adapter.dart';
import 'package:trufi_core/repositories/storage/shared_preferences_storage.dart';
import 'package:trufi_core/routing/trufi_routing_config.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// OTP-based routing configuration.
///
/// This is the default routing implementation using OpenTripPlanner.
///
/// Example:
/// ```dart
/// OtpRoutingConfig(
///   otpEndpoint: 'https://otp.example.com/graphql',
///   otpVersion: OtpVersion.v2_8,
/// )
/// ```
class OtpRoutingConfig extends TrufiRoutingConfig {
  const OtpRoutingConfig({
    required this.otpEndpoint,
    this.otpVersion = OtpVersion.v2_8,
    this.useSimpleQuery = false,
  });

  /// The OTP GraphQL endpoint URL.
  final String otpEndpoint;

  /// The OTP version to use.
  final OtpVersion otpVersion;

  /// Whether to use a simpler query with fewer parameters.
  final bool useSimpleQuery;

  @override
  RoutingMapController createRoutingController(TrufiMapController mapController) {
    final repository = OtpRepositoryFactory.create(
      endpoint: otpEndpoint,
      version: otpVersion,
      useSimpleQuery: useSimpleQuery,
    );

    return RoutingMapController(
      mapController,
      routingService: RoutingService(repository: repository),
      cacheRepository: StorageMapRouteRepository(
        LocalStorageAdapter(SharedPreferencesStorage()),
      ),
      transportIconBuilder: (leg) => _buildTransportIcon(leg),
    );
  }

  static Widget _buildTransportIcon(ItineraryLeg leg) {
    final mode = app_mode.getTransportMode(mode: leg.transportMode.otpName);
    return mode.getImage();
  }
}
