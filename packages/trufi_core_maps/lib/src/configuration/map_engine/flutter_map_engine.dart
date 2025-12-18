import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/controller/map_controller.dart';
import '../../presentation/map/flutter_map.dart';
import 'trufi_map_engine.dart';

/// FlutterMap (OpenStreetMap raster tiles) engine implementation.
///
/// Provides classic raster tile rendering using flutter_map.
///
/// Example:
/// ```dart
/// FlutterMapEngine(
///   tileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
///   darkTileUrl: 'https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
/// )
/// ```
class FlutterMapEngine implements ITrufiMapEngine {
  /// Tile URL template (light mode).
  ///
  /// Common templates:
  /// - OSM Standard: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
  /// - OSM Humanitarian: 'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png'
  final String tileUrl;

  /// Tile URL template for dark mode (optional).
  ///
  /// If not provided, a color filter will be applied to simulate dark mode.
  ///
  /// Common dark tile templates:
  /// - CartoDB Dark Matter: 'https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png'
  /// - Stamen Toner: 'https://tiles.stadiamaps.com/tiles/stamen_toner/{z}/{x}/{y}.png'
  final String? darkTileUrl;

  /// User agent package name for tile requests.
  final String? userAgentPackageName;

  /// Custom display name (optional).
  final String? displayName;

  /// Custom description (optional).
  final String? displayDescription;

  /// Custom preview widget (optional).
  final Widget? preview;

  const FlutterMapEngine({
    this.tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.darkTileUrl,
    this.userAgentPackageName,
    this.displayName,
    this.displayDescription,
    this.preview,
  });

  @override
  String get id => 'fluttermap';

  @override
  String get name => displayName ?? 'OSM (Raster)';

  @override
  String get description =>
      displayDescription ?? 'Classic OpenStreetMap with raster tiles';

  @override
  Widget? get previewWidget =>
      preview ??
      Container(
        color: Colors.green.shade100,
        child: const Center(
          child: Icon(Icons.map_outlined, size: 40, color: Colors.green),
        ),
      );

  @override
  Widget buildMap({
    required TrufiMapController controller,
    void Function(LatLng)? onMapClick,
    void Function(LatLng)? onMapLongClick,
    bool isDarkMode = false,
  }) {
    final effectiveTileUrl = isDarkMode && darkTileUrl != null
        ? darkTileUrl!
        : tileUrl;
    final useDarkFilter = isDarkMode && darkTileUrl == null;

    return TrufiFlutterMap(
      controller: controller,
      tileUrl: effectiveTileUrl,
      userAgentPackageName: userAgentPackageName,
      onMapClick: onMapClick,
      onMapLongClick: onMapLongClick,
      useDarkModeFilter: useDarkFilter,
    );
  }
}
