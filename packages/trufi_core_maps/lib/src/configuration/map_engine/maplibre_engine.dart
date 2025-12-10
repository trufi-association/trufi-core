import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/controller/map_controller.dart';
import '../../presentation/map/maplibre_map.dart';
import 'trufi_map_engine.dart';

/// MapLibre GL engine implementation.
///
/// Provides vector map rendering with modern styling and better performance.
///
/// Example:
/// ```dart
/// MapLibreEngine(
///   styleString: 'https://tiles.openfreemap.org/styles/liberty',
/// )
/// ```
class MapLibreEngine implements ITrufiMapEngine {
  /// Style URL for MapLibre.
  ///
  /// Common styles:
  /// - OpenFreeMap Liberty: 'https://tiles.openfreemap.org/styles/liberty'
  /// - MapLibre Demo: 'https://demotiles.maplibre.org/style.json'
  final String styleString;

  /// Custom display name (optional).
  final String? displayName;

  /// Custom description (optional).
  final String? displayDescription;

  /// Custom preview widget (optional).
  final Widget? preview;

  const MapLibreEngine({
    this.styleString = 'https://demotiles.maplibre.org/style.json',
    this.displayName,
    this.displayDescription,
    this.preview,
  });

  @override
  String get id => 'maplibre';

  @override
  String get name => displayName ?? 'Vector (MapLibre)';

  @override
  String get description =>
      displayDescription ?? 'Vector map with modern styling and better performance';

  @override
  Widget? get previewWidget =>
      preview ??
      Container(
        color: Colors.blue.shade100,
        child: const Center(
          child: Icon(Icons.map, size: 40, color: Colors.blue),
        ),
      );

  @override
  Widget buildMap({
    required TrufiMapController controller,
    void Function(LatLng)? onMapClick,
    void Function(LatLng)? onMapLongClick,
  }) {
    return TrufiMapLibreMap(
      controller: controller,
      styleString: styleString,
      onMapClick: onMapClick,
      onMapLongClick: onMapLongClick,
    );
  }
}
