import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart' as interfaces;
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// Interface for map engines that use TrufiMapController.
///
/// Extends the base ITrufiMapEngine interface with concrete controller type.
abstract class ITrufiMapEngine implements interfaces.ITrufiMapEngine {
  const ITrufiMapEngine();

  /// Build the map widget with concrete controller type
  Widget buildMapWithController({
    required TrufiMapController controller,
    void Function(TrufiLatLng)? onMapClick,
    void Function(TrufiLatLng)? onMapLongClick,
  });

  @override
  Widget buildMap({
    required dynamic controller,
    void Function(interfaces.TrufiLatLng)? onMapClick,
    void Function(interfaces.TrufiLatLng)? onMapLongClick,
  }) {
    return buildMapWithController(
      controller: controller as TrufiMapController,
      onMapClick: onMapClick != null
          ? (p) => onMapClick(interfaces.TrufiLatLng(p.latitude, p.longitude))
          : null,
      onMapLongClick: onMapLongClick != null
          ? (p) => onMapLongClick(interfaces.TrufiLatLng(p.latitude, p.longitude))
          : null,
    );
  }
}

/// MapLibre GL engine implementation
class MapLibreEngine extends ITrufiMapEngine {
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
  Widget buildMapWithController({
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
class FlutterMapEngine extends ITrufiMapEngine {
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
  Widget buildMapWithController({
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
