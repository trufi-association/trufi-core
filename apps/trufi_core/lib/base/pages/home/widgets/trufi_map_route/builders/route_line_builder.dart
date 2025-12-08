import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' show TransportMode;

/// Centralized builder for creating TrufiLine objects for routes.
///
/// Converts the polyline building logic to use TrufiLine instead of
/// flutter_map Polyline.
class RouteLineBuilder {
  const RouteLineBuilder();

  /// Build a route line for a leg
  TrufiLine buildLegLine({
    required String id,
    required List<TrufiLatLng> points,
    required Color color,
    required bool isSelected,
    required TransportMode transportMode,
    int layerLevel = 5,
  }) {
    final latLngPoints = points
        .map((p) => latlng.LatLng(p.latitude, p.longitude))
        .toList();

    return TrufiLine(
      id: id,
      position: latLngPoints,
      color: color,
      lineWidth: isSelected ? 6.0 : 3.0,
      activeDots: transportMode == TransportMode.walk,
      layerLevel: layerLevel,
    );
  }

  /// Build a walking route line (dotted)
  TrufiLine buildWalkLine({
    required String id,
    required List<TrufiLatLng> points,
    required Color color,
    required bool isSelected,
    int layerLevel = 5,
  }) {
    final latLngPoints = points
        .map((p) => latlng.LatLng(p.latitude, p.longitude))
        .toList();

    return TrufiLine(
      id: id,
      position: latLngPoints,
      color: color,
      lineWidth: isSelected ? 6.0 : 3.0,
      activeDots: true, // Dotted pattern for walking
      layerLevel: layerLevel,
    );
  }

  /// Build a transit route line (solid)
  TrufiLine buildTransitLine({
    required String id,
    required List<TrufiLatLng> points,
    required Color color,
    required bool isSelected,
    int layerLevel = 5,
  }) {
    final latLngPoints = points
        .map((p) => latlng.LatLng(p.latitude, p.longitude))
        .toList();

    return TrufiLine(
      id: id,
      position: latLngPoints,
      color: color,
      lineWidth: isSelected ? 6.0 : 3.0,
      activeDots: false, // Solid pattern for transit
      layerLevel: layerLevel,
    );
  }

  /// Build a simple line between two points
  TrufiLine buildSimpleLine({
    required String id,
    required TrufiLatLng start,
    required TrufiLatLng end,
    required Color color,
    double lineWidth = 4.0,
    bool isDotted = false,
    int layerLevel = 5,
  }) {
    return TrufiLine(
      id: id,
      position: [
        latlng.LatLng(start.latitude, start.longitude),
        latlng.LatLng(end.latitude, end.longitude),
      ],
      color: color,
      lineWidth: lineWidth,
      activeDots: isDotted,
      layerLevel: layerLevel,
    );
  }
}
