import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import '../config/poi_layer_config.dart';
import '../data/geojson_loader.dart';
import '../data/models/poi.dart';
import '../data/models/poi_category.dart';
import '../l10n/poi_layers_localizations.dart';
import '../widgets/poi_marker_widget.dart';

/// Map layer for displaying POIs of a specific category
class POIMapLayer extends MapLayer {
  /// The POI category this layer displays
  final POICategory category;

  /// Configuration for this layer
  final POILayerConfig config;

  /// Loader for GeoJSON data
  final GeoJSONLoader loader;

  /// Loaded POIs (cached after first load)
  List<POI> _pois = [];

  /// Whether POIs have been loaded
  bool _initialized = false;

  /// Callback when a POI is tapped
  final void Function(POI poi)? onPOITapped;

  POIMapLayer({
    required this.category,
    required this.config,
    required this.loader,
    this.onPOITapped,
  }) : super(
          'poi_${category.name}',
          category.weight,
        );

  /// Initialize by loading POIs from assets
  Future<void> initialize() async {
    if (_initialized) return;

    _pois = await loader.loadCategory(category);
    _initialized = true;
    refresh();
  }

  /// Get all loaded POIs
  List<POI> get pois => _pois;

  @override
  Widget buildLayerOptions(int zoom) {
    // Don't show if not initialized or zoom is too low
    if (!_initialized || zoom < config.minZoom) {
      return const SizedBox.shrink();
    }

    // Return empty widget - we use buildLayerMarkers for markers
    return const SizedBox.shrink();
  }

  @override
  Widget? buildLayerOptionsBackground(int zoom) {
    return null;
  }

  @override
  List<Marker>? buildLayerMarkers(int zoom) {
    if (!_initialized || zoom < config.minZoom) {
      return null;
    }

    // Use smaller markers when zoomed out
    final useSmallMarkers = zoom < 16;
    final markerSize = useSmallMarkers ? 16.0 : config.markerSize;

    return _pois.map((poi) {
      return Marker(
        point: poi.position,
        width: markerSize,
        height: markerSize,
        child: GestureDetector(
          onTap: () => onPOITapped?.call(poi),
          child: useSmallMarkers
              ? POIMarkerDot(category: category, size: markerSize)
              : POIMarkerWidget(poi: poi, size: markerSize),
        ),
      );
    }).toList();
  }

  @override
  String name(BuildContext context) {
    return POILayersLocalizations.of(context).categoryName(category);
  }

  @override
  Widget icon(BuildContext context) {
    return Icon(
      category.icon,
      color: category.color,
    );
  }
}
