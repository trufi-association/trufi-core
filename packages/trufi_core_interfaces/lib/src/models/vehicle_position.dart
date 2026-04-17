import 'package:equatable/equatable.dart';

import 'trufi_latlng.dart';

/// Real-time position of a transit vehicle as published by a GTFS-Realtime feed
/// and exposed through OTP's `vehiclePositions` GraphQL field.
class VehiclePosition extends Equatable {
  final String vehicleId;
  final TrufiLatLng position;
  final double? heading;
  final double? speed;
  final String? label;
  final String? routeId;
  final String? routeColor;
  final String? tripId;
  final DateTime? timestamp;

  const VehiclePosition({
    required this.vehicleId,
    required this.position,
    this.heading,
    this.speed,
    this.label,
    this.routeId,
    this.routeColor,
    this.tripId,
    this.timestamp,
  });

  VehiclePosition copyWith({
    String? vehicleId,
    TrufiLatLng? position,
    double? heading,
    double? speed,
    String? label,
    String? routeId,
    String? routeColor,
    String? tripId,
    DateTime? timestamp,
  }) {
    return VehiclePosition(
      vehicleId: vehicleId ?? this.vehicleId,
      position: position ?? this.position,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      label: label ?? this.label,
      routeId: routeId ?? this.routeId,
      routeColor: routeColor ?? this.routeColor,
      tripId: tripId ?? this.tripId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
    vehicleId,
    position,
    heading,
    speed,
    label,
    routeId,
    routeColor,
    tripId,
    timestamp,
  ];

  @override
  String toString() =>
      'VehiclePosition($vehicleId, $position, heading=$heading, route=$routeId)';
}
