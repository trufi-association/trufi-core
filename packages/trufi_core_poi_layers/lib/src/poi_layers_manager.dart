import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import 'data/geojson_loader.dart';
import 'layer/poi_category_layer.dart';
import 'models/poi.dart';
import 'models/poi_category.dart';

/// Manager class that encapsulates POI layers, loader, and state.
///
/// This class extends [ChangeNotifier] and provides a unified interface for
/// managing POI layers on the map:
/// - Handles GeoJSON loading from assets
/// - Creates and manages layer instances for each category
/// - Synchronizes layer visibility with internal state
/// - Notifies listeners when state changes
///
/// Example usage:
/// ```dart
/// // In providers
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(
///       create: (_) => POILayersManager(assetsBasePath: 'assets/pois'),
///     ),
///   ],
///   child: ...
/// )
///
/// // In widget - initialize with map controller
/// final poiManager = context.read<POILayersManager>();
/// await poiManager.initialize(mapController);
///
/// // Watch for changes
/// final poiManager = context.watch<POILayersManager>();
/// ```
class POILayersManager extends ChangeNotifier {
  /// GeoJSON loader for loading POI data from assets
  final GeoJSONLoader _loader;

  /// Internal state for enabled subcategories
  Map<POICategory, Set<String>> _enabledSubcategories;

  /// POI layers, one per category
  final List<POICategoryLayer> _layers = [];

  /// Whether initialization is complete
  bool _initialized = false;

  /// Creates a POILayersManager.
  ///
  /// Parameters:
  /// - [assetsBasePath]: Base path for POI GeoJSON assets (e.g., 'assets/pois')
  /// - [defaultEnabledSubcategories]: Optional initial enabled subcategories
  POILayersManager({
    required String assetsBasePath,
    Map<POICategory, Set<String>>? defaultEnabledSubcategories,
  })  : _loader = GeoJSONLoader(assetsBasePath: assetsBasePath),
        _enabledSubcategories = defaultEnabledSubcategories ?? {};

  /// Whether the manager has been initialized
  bool get isInitialized => _initialized;

  /// Get all POI layers
  List<POICategoryLayer> get layers => List.unmodifiable(_layers);

  /// Get current enabled subcategories (for settings UI)
  Map<POICategory, Set<String>> get enabledSubcategories =>
      Map.unmodifiable(_enabledSubcategories);

  /// Get available subcategories per category (for settings UI)
  Map<POICategory, Set<String>> get availableSubcategories {
    return {
      for (final layer in _layers)
        layer.category: layer.pois
            .where((poi) => poi.subcategory != null)
            .map((poi) => poi.subcategory!)
            .toSet(),
    };
  }

  /// Get the loader for statistics and cache management
  GeoJSONLoader get loader => _loader;

  /// Check if a category is enabled (has any subcategories enabled)
  bool isCategoryEnabled(POICategory category) {
    final subcats = _enabledSubcategories[category];
    return subcats != null && subcats.isNotEmpty;
  }

  /// Check if a POI is enabled based on its subcategory
  bool isPOIEnabled(POI poi) {
    final subcats = _enabledSubcategories[poi.category];
    if (subcats == null || subcats.isEmpty) return false;
    if (poi.subcategory == null) return subcats.isNotEmpty;
    return subcats.contains(poi.subcategory);
  }

  /// Initialize the manager by loading POI data and creating layers.
  ///
  /// This method:
  /// 1. Loads all POI categories in parallel from GeoJSON assets
  /// 2. Creates a POICategoryLayer for each category
  /// 3. Sets up layer visibility based on current state
  ///
  /// Parameters:
  /// - [mapController]: The TrufiMapController to create layers on
  ///
  /// Returns a Future that completes when initialization is done.
  Future<void> initialize(TrufiMapController mapController) async {
    if (_initialized) {
      debugPrint('⚠️ POILayersManager already initialized');
      return;
    }

    try {
      // Load all categories in parallel
      final loadingFutures = POICategory.values
          .map((category) => _loader
              .loadCategory(category)
              .then((pois) => MapEntry(category, pois)))
          .toList();

      final loadedData = await Future.wait(loadingFutures);

      // Create one layer per category
      for (final entry in loadedData) {
        final layer = POICategoryLayer(
          controller: mapController,
          category: entry.key,
          pois: entry.value,
          poiFilter: (poi) => isPOIEnabled(poi),
        );
        _layers.add(layer);
      }

      // Apply initial state
      _updateLayerVisibility();

      _initialized = true;

      debugPrint(
          '✅ POILayersManager initialized with ${_layers.length} layers');
      for (final layer in _layers) {
        debugPrint(
            '  - ${layer.category.name}: ${layer.poiCount} POIs, visible: ${layer.visible}');
      }

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ POILayersManager initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Update layer visibility based on current state
  void _updateLayerVisibility() {
    for (final layer in _layers) {
      layer.visible = isCategoryEnabled(layer.category);
      layer.poiFilter = (poi) => isPOIEnabled(poi);
      layer.updateMarkers();
    }
  }

  /// Toggle a subcategory on/off within a category
  void toggleSubcategory(
      POICategory category, String subcategory, bool enabled) {
    final currentSubcats = _enabledSubcategories[category] ?? <String>{};
    final updatedSubcats = Set<String>.from(currentSubcats);

    if (enabled) {
      updatedSubcats.add(subcategory);
    } else {
      updatedSubcats.remove(subcategory);
    }

    _enabledSubcategories = Map.from(_enabledSubcategories)
      ..[category] = updatedSubcats;

    _updateLayerVisibility();
    notifyListeners();
  }

  /// Toggle a category on/off.
  ///
  /// When enabling, all subcategories for the category are enabled.
  /// When disabling, all subcategories are disabled.
  void toggleCategory(POICategory category, bool enabled) {
    if (enabled) {
      final subcats = getSubcategoriesForCategory(category);
      _enabledSubcategories = Map.from(_enabledSubcategories)
        ..[category] = subcats;
    } else {
      _enabledSubcategories = Map.from(_enabledSubcategories)
        ..[category] = <String>{};
    }

    _updateLayerVisibility();
    notifyListeners();
  }

  /// Enable all subcategories for a category
  void enableCategory(POICategory category, Set<String> subcategories) {
    if (subcategories.isEmpty) return;

    _enabledSubcategories = Map.from(_enabledSubcategories)
      ..[category] = Set.from(subcategories);

    _updateLayerVisibility();
    notifyListeners();
  }

  /// Disable all subcategories for a category
  void disableCategory(POICategory category) {
    _enabledSubcategories = Map.from(_enabledSubcategories)
      ..[category] = <String>{};

    _updateLayerVisibility();
    notifyListeners();
  }

  /// Find a POI by its marker ID.
  ///
  /// Marker IDs follow the format: `poi_<category>_<poi_id>`
  POI? findPOIByMarkerId(String markerId) {
    final parts = markerId.split('_');
    if (parts.length < 3) return null;

    final categoryName = parts[1];
    final poiId = parts.sublist(2).join('_');

    final layer =
        _layers.where((l) => l.category.name == categoryName).firstOrNull;
    if (layer == null) return null;

    return layer.pois.where((p) => p.id == poiId).firstOrNull;
  }

  /// Find multiple POIs from a list of markers.
  ///
  /// Useful for handling multiple overlapping markers.
  List<POI> findPOIsFromMarkers(List<TrufiMarker> markers) {
    final pois = <POI>[];
    for (final marker in markers) {
      final poi = findPOIByMarkerId(marker.id);
      if (poi != null) {
        pois.add(poi);
      }
    }
    return pois;
  }

  /// Get subcategories for a specific category.
  Set<String> getSubcategoriesForCategory(POICategory category) {
    final layer = _layers.where((l) => l.category == category).firstOrNull;
    if (layer == null) return {};

    return layer.pois
        .where((poi) => poi.subcategory != null)
        .map((poi) => poi.subcategory!)
        .toSet();
  }

  /// Get layer statistics for debugging.
  Map<String, dynamic> getStats() {
    return {
      'initialized': _initialized,
      'layer_count': _layers.length,
      'loader_stats': _loader.getStats(),
      'layers': {
        for (final layer in _layers)
          layer.category.name: {
            'poi_count': layer.poiCount,
            'visible_markers': layer.visibleMarkerCount,
            'visible': layer.visible,
          },
      },
    };
  }

  @override
  void dispose() {
    _layers.clear();
    _loader.clearCache();
    _initialized = false;
    debugPrint('🗑️ POILayersManager disposed');
    super.dispose();
  }
}
