import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

import '../../configuration/markers/vehicle_position_marker.dart';
import '../../domain/entities/marker.dart';
import '../../domain/layers/trufi_layer.dart';

typedef VehicleColorResolver = Color Function(VehiclePosition vehicle);

/// Builds a [TrufiLayer] from a list of [VehiclePosition]s.
///
/// By default, each vehicle is colored using its own [VehiclePosition.routeColor]
/// when present (parsed as a 6-digit hex string without the `#`). Pass a custom
/// [colorResolver] to override. Falls back to a neutral blue.
TrufiLayer buildVehiclePositionsLayer({
  required List<VehiclePosition> vehicles,
  String layerId = 'realtime-vehicles',
  int layerLevel = 1500,
  VehicleColorResolver? colorResolver,
  Color fallbackColor = const Color(0xFF1E88E5),
  double markerSize = 28,
}) {
  final markers = <TrufiMarker>[];

  for (final v in vehicles) {
    final color = colorResolver?.call(v) ?? _colorFromHex(v.routeColor) ?? fallbackColor;
    final heading = v.heading ?? 0;
    final headingBucket = (heading / 15).round();
    final total = markerSize * 1.55;
    markers.add(
      TrufiMarker(
        id: 'vehicle-${v.vehicleId}',
        position: LatLng(v.position.latitude, v.position.longitude),
        widget: VehiclePositionMarker(
          color: color,
          size: markerSize,
          heading: heading,
        ),
        size: Size(total, total),
        allowOverlap: true,
        layerLevel: layerLevel,
        imageCacheKey:
            'vehicle_${color.toARGB32()}_${headingBucket}_${markerSize.toInt()}',
      ),
    );
  }

  return TrufiLayer(id: layerId, markers: markers, layerLevel: layerLevel);
}

Color? _colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final clean = hex.startsWith('#') ? hex.substring(1) : hex;
  if (clean.length != 6 && clean.length != 8) return null;
  final parsed = int.tryParse(clean, radix: 16);
  if (parsed == null) return null;
  return clean.length == 6 ? Color(0xFF000000 | parsed) : Color(parsed);
}
