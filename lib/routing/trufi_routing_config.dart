import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Abstract configuration for routing functionality.
///
/// This allows different routing implementations to be used with TrufiApp.
/// The default implementation uses `trufi_core_routing` with OTP.
///
/// Example with default OTP routing:
/// ```dart
/// TrufiApp(
///   routingConfig: OtpRoutingConfig(
///     otpEndpoint: 'https://otp.example.com/graphql',
///     otpVersion: OtpVersion.v2_8,
///   ),
/// )
/// ```
abstract class TrufiRoutingConfig {
  const TrufiRoutingConfig();

  /// Creates the routing controller for the map.
  ///
  /// This is called when the RouteNavigationScreen initializes.
  /// The returned controller handles all routing operations.
  RoutingMapController createRoutingController(TrufiMapController mapController);
}
