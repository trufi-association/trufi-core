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
///   darkStyleString: 'https://tiles.openfreemap.org/styles/dark', // optional
/// )
/// ```
class MapLibreEngine implements ITrufiMapEngine {
  /// Style URL for MapLibre (light mode).
  ///
  /// Common styles:
  /// - OpenFreeMap Liberty: 'https://tiles.openfreemap.org/styles/liberty'
  /// - MapLibre Demo: 'https://demotiles.maplibre.org/style.json'
  final String styleString;

  /// Style URL for dark mode (optional).
  ///
  /// If not provided, the light style will be used for both modes.
  ///
  /// Common dark styles:
  /// - OpenFreeMap Dark: 'https://tiles.openfreemap.org/styles/dark'
  /// - Stadia Alidade Dark: 'https://tiles.stadiamaps.com/styles/alidade_smooth_dark.json'
  final String? darkStyleString;

  /// Custom display name (optional).
  final String? displayName;

  /// Custom description (optional).
  final String? displayDescription;

  /// Custom preview widget (optional).
  final Widget? preview;

  const MapLibreEngine({
    this.styleString = 'https://demotiles.maplibre.org/style.json',
    this.darkStyleString,
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
    bool isDarkMode = false,
  }) {
    final effectiveStyle = isDarkMode && darkStyleString != null
        ? darkStyleString!
        : styleString;

    return TrufiMapLibreMap(
      controller: controller,
      styleString: effectiveStyle,
      onMapClick: onMapClick,
      onMapLongClick: onMapLongClick,
    );
  }
}
