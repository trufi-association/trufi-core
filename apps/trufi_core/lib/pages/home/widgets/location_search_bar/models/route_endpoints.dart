import 'package:flutter/material.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

/// Defines a callback function signature for building route search widgets.
///
/// This typedef is used to create custom route search UI components with
/// the necessary callbacks for handling location selection and route operations.
typedef RouteSearchBuilder = Widget Function({
  required void Function(TrufiLocation) onSaveFrom,
  required void Function() onClearFrom,
  required void Function(TrufiLocation) onSaveTo,
  required void Function() onClearTo,
  required void Function() onFetchPlan,
  required void Function() onReset,
  required void Function() onSwap,
  required TrufiLocation? origin,
  required TrufiLocation? destination,
});

/// Represents a pair of origin and destination locations for route planning.
///
/// This class encapsulates the start and end points of a journey,
/// making it easier to pass route endpoints as a single object.
class RouteEndpoints {
  /// The starting location of the route
  final TrufiLocation origin;

  /// The destination location of the route
  final TrufiLocation destination;

  /// Creates a [RouteEndpoints] instance with the given origin and destination.
  const RouteEndpoints({
    required this.origin,
    required this.destination,
  });

  /// Creates a copy of this [RouteEndpoints] with the given fields replaced
  /// with new values.
  RouteEndpoints copyWith({
    TrufiLocation? origin,
    TrufiLocation? destination,
  }) {
    return RouteEndpoints(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteEndpoints &&
        other.origin == origin &&
        other.destination == destination;
  }

  @override
  int get hashCode => Object.hash(origin, destination);

  @override
  String toString() => 'RouteEndpoints(origin: $origin, destination: $destination)';
}
