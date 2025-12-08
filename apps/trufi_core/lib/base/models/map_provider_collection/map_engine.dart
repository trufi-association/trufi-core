import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// Interface for map engines.
///
/// Implement this interface to create custom map engines that can be
/// used with TrufiCoreMapsCollection.
abstract class ITrufiMapEngine {
  /// Unique identifier for this engine
  String get id;

  /// Display name for UI
  String get name;

  /// Optional description
  String get description;

  /// Build the map widget
  Widget buildMap({
    required TrufiMapController controller,
    void Function(TrufiLatLng)? onMapClick,
    void Function(TrufiLatLng)? onMapLongClick,
  });
}

/// MapLibre GL engine implementation
class MapLibreEngine implements ITrufiMapEngine {
  /// Style URL for MapLibre (e.g., 'https://tiles.openfreemap.org/styles/liberty')
  final String styleString;

  const MapLibreEngine({
    this.styleString = 'https://demotiles.maplibre.org/style.json',
  });

  @override
  String get id => 'maplibre';

  @override
  String get name => 'Vector (MapLibre)';

  @override
  String get description => 'Vector map with modern styling and better performance';

  @override
  Widget buildMap({
    required TrufiMapController controller,
    void Function(TrufiLatLng)? onMapClick,
    void Function(TrufiLatLng)? onMapLongClick,
  }) {
    return TrufiMapLibreMap(
      controller: controller,
      styleString: styleString,
      onMapClick: onMapClick != null
          ? (point) => onMapClick(TrufiLatLng(point.latitude, point.longitude))
          : null,
      onMapLongClick: onMapLongClick != null
          ? (point) => onMapLongClick(TrufiLatLng(point.latitude, point.longitude))
          : null,
    );
  }
}

/// FlutterMap (OpenStreetMap raster tiles) engine implementation
class FlutterMapEngine implements ITrufiMapEngine {
  /// Tile URL template (e.g., 'https://tile.openstreetmap.org/{z}/{x}/{y}.png')
  final String tileUrl;

  const FlutterMapEngine({
    this.tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  });

  @override
  String get id => 'fluttermap';

  @override
  String get name => 'OSM (Raster)';

  @override
  String get description => 'Classic OpenStreetMap with raster tiles';

  @override
  Widget buildMap({
    required TrufiMapController controller,
    void Function(TrufiLatLng)? onMapClick,
    void Function(TrufiLatLng)? onMapLongClick,
  }) {
    return TrufiFlutterMap(
      controller: controller,
      tileUrl: tileUrl,
      onMapClick: onMapClick != null
          ? (point) => onMapClick(TrufiLatLng(point.latitude, point.longitude))
          : null,
      onMapLongClick: onMapLongClick != null
          ? (point) => onMapLongClick(TrufiLatLng(point.latitude, point.longitude))
          : null,
    );
  }
}
