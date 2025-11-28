import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;

import 'bounds.dart';

class TrufiCameraPosition {
  const TrufiCameraPosition({
    required this.target,
    this.zoom = 0.0,
    this.bearing = 0.0,
    this.viewportSize,
    this.visibleRegion,
  });

  final latlng.LatLng target;
  final double zoom;
  final double bearing;
  final Size? viewportSize;
  final LatLngBounds? visibleRegion;

  TrufiCameraPosition copyWith({
    latlng.LatLng? target,
    double? zoom,
    double? bearing,
    Size? viewportSize,
    LatLngBounds? visibleRegion,
  }) => TrufiCameraPosition(
    target: target ?? this.target,
    zoom: zoom ?? this.zoom,
    bearing: bearing ?? this.bearing,
    viewportSize: viewportSize ?? const Size(411.4, 923.4),
    visibleRegion: visibleRegion ?? this.visibleRegion,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrufiCameraPosition &&
          target == other.target &&
          zoom == other.zoom &&
          bearing == other.bearing &&
          viewportSize == other.viewportSize &&
          visibleRegion == other.visibleRegion;

  @override
  int get hashCode =>
      Object.hash(target, zoom, bearing, viewportSize, visibleRegion);

  @override
  String toString() =>
      'TrufiCameraPosition('
      'target: ${target.latitude},${target.longitude}, '
      'zoom: $zoom, '
      'bearing: $bearing, '
      'viewportSize: $viewportSize, '
      'visibleRegion: $visibleRegion)';
}
