import 'package:flutter/material.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import 'config/poi_layer_config.dart';
import 'data/geojson_loader.dart';
import 'data/models/poi.dart';
import 'data/models/poi_category.dart';
import 'layers/poi_map_layer.dart';

/// Manager for all POI layers.
/// Creates and manages POI layers for each category.
class POILayerManager {
  final POILayerConfig config;
  final GeoJSONLoader _loader;
  final Map<POICategory, POIMapLayer> _layers = {};
  final void Function(POI poi)? onPOITapped;

  /// Categories to enable by default
  final Set<POICategory> defaultEnabledCategories;

  POILayerManager({
    required this.config,
    this.onPOITapped,
    this.defaultEnabledCategories = const {},
  }) : _loader = GeoJSONLoader(assetsBasePath: config.assetsBasePath);

  /// Get all available POI layers
  List<POIMapLayer> get layers => _layers.values.toList();

  /// Get layer for a specific category
  POIMapLayer? getLayer(POICategory category) => _layers[category];

  /// Create layers for specified categories
  Future<List<POIMapLayer>> createLayers({
    Set<POICategory>? categories,
  }) async {
    final targetCategories = categories ?? POICategory.values.toSet();

    for (final category in targetCategories) {
      if (!_layers.containsKey(category)) {
        final layer = POIMapLayer(
          category: category,
          config: config,
          loader: _loader,
          onPOITapped: onPOITapped,
        );
        _layers[category] = layer;
      }
    }

    return _layers.values.toList();
  }

  /// Initialize all layers (load POI data)
  Future<void> initializeLayers() async {
    for (final layer in _layers.values) {
      await layer.initialize();
    }
  }

  /// Get map layer containers for use with MapLayersCubit
  List<MapLayerContainer> getLayerContainers() {
    return _layers.entries.map((entry) {
      return MapLayerContainer(
        layers: [entry.value],
        icon: (context) => Icon(
          entry.key.icon,
          color: entry.key.color,
        ),
        name: (context) => entry.value.name(context),
      );
    }).toList();
  }

  /// Clear cached POI data
  void clearCache() {
    _loader.clearCache();
  }

  /// Dispose of all layers
  void dispose() {
    _layers.clear();
    clearCache();
  }
}

/// Factory function to create POI layers for all categories
Future<List<MapLayerContainer>> createPOILayerContainers({
  required String assetsBasePath,
  int minZoom = 14,
  double markerSize = 32,
  void Function(POI poi)? onPOITapped,
  Set<POICategory>? enabledCategories,
}) async {
  final config = POILayerConfig(
    assetsBasePath: assetsBasePath,
    minZoom: minZoom,
    markerSize: markerSize,
  );

  final manager = POILayerManager(
    config: config,
    onPOITapped: onPOITapped,
    defaultEnabledCategories: enabledCategories ?? {},
  );

  final categories = enabledCategories ?? POICategory.values.toSet();
  await manager.createLayers(categories: categories);
  await manager.initializeLayers();

  return manager.getLayerContainers();
}
