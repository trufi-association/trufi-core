import 'package:latlong2/latlong.dart';

import '../../domain/entities/routing_location.dart';

/// Adapter for converting [RoutingLocation] to/from external location types.
///
/// This class provides static methods for converting between the package's
/// [RoutingLocation] and external location representations used by consumer apps.
class RoutingLocationAdapter {
  RoutingLocationAdapter._();

  /// Creates a [RoutingLocation] from position and optional metadata.
  static RoutingLocation fromPosition(
    LatLng position, {
    String description = '',
    String? address,
  }) {
    return RoutingLocation(
      position: position,
      description: description,
      address: address,
    );
  }

  /// Extracts the position from a [RoutingLocation].
  static LatLng toPosition(RoutingLocation location) {
    return location.position;
  }
}
