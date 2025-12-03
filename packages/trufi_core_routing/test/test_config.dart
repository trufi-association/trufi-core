import 'package:latlong2/latlong.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Test configuration for OTP integration and unit tests.
class TestConfig {
  TestConfig._();

  /// OTP 1.5 endpoint (Cochabamba - REST API)
  static const otp15Endpoint =
      'https://otp-150.trufi-core.trufi.dev/otp/routers/default/plan';

  /// OTP 2.4 endpoint (Cochabamba - GraphQL)
  static const otp24Endpoint =
      'https://otp-240.trufi-core.trufi.dev/otp/routers/default/index/graphql';

  /// OTP 2.8 endpoint (Cochabamba - GraphQL)
  static const otp28Endpoint =
      'https://otp-281.trufi-core.trufi.dev/otp/routers/default/index/graphql';

  /// Test origin location in Cochabamba
  /// Avenida Circunvalacion y Calle 16 de Julio
  static final originLocation = RoutingLocation(
    position: const LatLng(-17.3452624, -66.1975204),
    description: 'Av. Circunvalacion',
  );

  /// Test destination location in Cochabamba
  /// Avenida Rio Parapeti
  static final destinationLocation = RoutingLocation(
    position: const LatLng(-17.4647819, -66.1494349),
    description: 'Av. Rio Parapeti',
  );

  /// Alternative origin for testing (closer to center)
  /// Avenida Chiquicollo
  static final alternativeOrigin = RoutingLocation(
    position: const LatLng(-17.3666004, -66.199784),
    description: 'Av. Chiquicollo',
  );

  /// Center of Cochabamba coverage area
  static const cochabambaCenter = LatLng(-17.3988354, -66.1626903);
}
