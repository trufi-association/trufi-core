import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import 'data/geojson_loader.dart';
import 'layer/poi_category_layer.dart';
import 'models/poi.dart';
import 'models/poi_category.dart';

/// Manager class that encapsulates POI layers, loader, and state.
///
/// This class extends [ChangeNotifier] for automatic integration with
/// the home screen map via Provider.
///
/// It provides a unified interface for managing POI layers on the map:
/// - Handles GeoJSON loading from assets
/// - Creates and manages layer instances for each category
/// - Synchronizes layer visibility with internal state
/// - Notifies listeners when state changes
/// - Manages POI selection state for detail panel
///
/// Example usage:
/// ```dart
/// // In providers - just add the manager, home screen will auto-detect it
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(
///       create: (_) => POILayersManager(assetsBasePath: 'assets/pois'),
///     ),
///   ],
///   child: ...
/// )
///
/// // Watch for changes in settings
/// final poiManager = context.watch<POILayersManager>();
///
/// // Handle POI selection
/// if (poiManager.selectedPOI != null) {
///   // Show POI detail panel
/// }
/// ```
class POILayersManager extends ChangeNotifier {
  /// Storage key for persisting enabled subcategories
  static const _storageKey = 'trufi_poi_layers_enabled_subcategories';

  /// GeoJSON loader for loading POI data from assets
  final GeoJSONLoader _loader;

  /// Storage service for persisting preferences
  final StorageService _storage;

  /// Whether storage has been initialized
  bool _storageInitialized = false;

  /// Internal state for enabled subcategories
  Map<POICategory, Set<String>> _enabledSubcategories;

  /// POI layers, one per category
  final List<POICategoryLayer> _layers = [];

  /// Whether initialization is complete
  bool _initialized = false;

  /// Currently selected POI (for detail panel)
  POI? _selectedPOI;

  /// Creates a POILayersManager.
  ///
  /// Parameters:
  /// - [assetsBasePath]: Base path for POI GeoJSON assets (e.g., 'assets/pois')
  /// - [defaultEnabledSubcategories]: Optional initial enabled subcategories.
  ///   These are used if no saved preferences exist.
  /// - [storage]: Optional storage service. Defaults to [SharedPreferencesStorage].
  POILayersManager({
    required String assetsBasePath,
    Map<POICategory, Set<String>>? defaultEnabledSubcategories,
    StorageService? storage,
  })  : _loader = GeoJSONLoader(assetsBasePath: assetsBasePath),
        _storage = storage ?? SharedPreferencesStorage(),
        _enabledSubcategories = defaultEnabledSubcategories ?? {};

  /// Whether the manager has been initialized
  bool get isInitialized => _initialized;

  /// Initialize the layers with a dynamic map controller.
  /// Called automatically when the map is ready.
  Future<void> initializeLayers(dynamic mapController) async {
    if (mapController is TrufiMapController) {
      await initialize(mapController);
    }
  }

  /// Get the list of map layers to display.
  List<dynamic> get mapLayers => _layers;

  /// Get all POI layers
  List<POICategoryLayer> get layers => List.unmodifiable(_layers);

  /// Get currently selected POI (for detail panel)
  POI? get selectedPOI => _selectedPOI;

  /// Whether a POI is currently selected
  bool get hasSelectedPOI => _selectedPOI != null;

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

  /// The controller that layers are currently registered with
  TrufiMapController? _currentController;

  /// Initialize the manager by loading POI data and creating layers.
  ///
  /// This method:
  /// 1. Loads all POI categories in parallel from GeoJSON assets
  /// 2. Creates a POICategoryLayer for each category
  /// 3. Sets up layer visibility based on current state
  ///
  /// If called with a different controller after initial setup, it will
  /// re-create layers on the new controller.
  ///
  /// Parameters:
  /// - [mapController]: The TrufiMapController to create layers on
  ///
  /// Returns a Future that completes when initialization is done.
  Future<void> initialize(TrufiMapController mapController) async {
    // Check if we need to re-register layers on a new controller
    if (_initialized && _currentController != mapController) {
      await _reRegisterLayers(mapController);
      return;
    }

    if (_initialized) {
      debugPrint('⚠️ POILayersManager already initialized');
      return;
    }

    try {
      // Load saved preferences first
      await _loadSavedPreferences();

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
      _currentController = mapController;

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

  /// Re-register existing layers on a new controller.
  /// Called when the map controller changes (e.g., after navigation).
  Future<void> _reRegisterLayers(TrufiMapController newController) async {
    // Clear old layers and create new ones with the same data
    final oldLayers = List<POICategoryLayer>.from(_layers);
    _layers.clear();

    for (final oldLayer in oldLayers) {
      final newLayer = POICategoryLayer(
        controller: newController,
        category: oldLayer.category,
        pois: oldLayer.pois,
        poiFilter: (poi) => isPOIEnabled(poi),
      );
      _layers.add(newLayer);
    }

    // Apply visibility state
    _updateLayerVisibility();
    _currentController = newController;

    notifyListeners();
  }

  /// Update layer visibility based on current state
  void _updateLayerVisibility() {
    for (final layer in _layers) {
      layer.visible = isCategoryEnabled(layer.category);
      layer.poiFilter = (poi) => isPOIEnabled(poi);
      layer.updateMarkers();
    }
  }

  /// Initialize storage service.
  Future<void> _initializeStorage() async {
    if (_storageInitialized) return;
    await _storage.initialize();
    _storageInitialized = true;
  }

  /// Load saved preferences from storage.
  /// If no saved state exists, defaults are used.
  Future<void> _loadSavedPreferences() async {
    try {
      await _initializeStorage();
      final jsonString = await _storage.read(_storageKey);

      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final loaded = _fromJson(decoded);

        if (loaded.isNotEmpty) {
          _enabledSubcategories = loaded;

          // Update layers if already initialized
          if (_initialized) {
            _updateLayerVisibility();
          }

          notifyListeners();
          debugPrint('✅ POI layers preferences loaded from storage');
        }
      } else {
        debugPrint('ℹ️ No saved POI layers preferences, using defaults');
      }
    } catch (e) {
      debugPrint('⚠️ Error loading POI layers preferences: $e');
      // Keep using defaults on error
    }
  }

  /// Persist current preferences to storage.
  Future<void> _persistPreferences() async {
    try {
      await _initializeStorage();
      final json = _toJson(_enabledSubcategories);
      await _storage.write(_storageKey, jsonEncode(json));
      debugPrint('💾 POI layers preferences saved');
    } catch (e) {
      debugPrint('⚠️ Error saving POI layers preferences: $e');
    }
  }

  /// Convert enabled subcategories to JSON-serializable format.
  Map<String, dynamic> _toJson(Map<POICategory, Set<String>> data) {
    return {
      for (final entry in data.entries)
        entry.key.name: entry.value.toList(),
    };
  }

  /// Parse enabled subcategories from JSON.
  Map<POICategory, Set<String>> _fromJson(Map<String, dynamic> json) {
    final result = <POICategory, Set<String>>{};

    for (final entry in json.entries) {
      // Find the category by name
      final category = POICategory.values
          .where((c) => c.name == entry.key)
          .firstOrNull;

      if (category != null && entry.value is List) {
        result[category] = Set<String>.from(
          (entry.value as List).whereType<String>(),
        );
      }
    }

    return result;
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
    _persistPreferences(); // Fire and forget
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
    _persistPreferences(); // Fire and forget
    notifyListeners();
  }

  /// Enable all subcategories for a category
  void enableCategory(POICategory category, Set<String> subcategories) {
    if (subcategories.isEmpty) return;

    _enabledSubcategories = Map.from(_enabledSubcategories)
      ..[category] = Set.from(subcategories);

    _updateLayerVisibility();
    _persistPreferences(); // Fire and forget
    notifyListeners();
  }

  /// Disable all subcategories for a category
  void disableCategory(POICategory category) {
    _enabledSubcategories = Map.from(_enabledSubcategories)
      ..[category] = <String>{};

    _updateLayerVisibility();
    _persistPreferences(); // Fire and forget
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

  /// Select a POI to show in the detail panel.
  ///
  /// Pass null to clear the selection.
  /// Also highlights the POI's polygon if it's an area POI.
  void selectPOI(POI? poi) {
    if (_selectedPOI == poi) return;

    // Clear previous highlight
    if (_selectedPOI != null) {
      _updatePOIHighlight(_selectedPOI!, false);
    }

    _selectedPOI = poi;

    // Set new highlight
    if (poi != null) {
      _updatePOIHighlight(poi, true);
    }

    notifyListeners();
  }

  /// Update the highlight state for a POI's polygon
  void _updatePOIHighlight(POI poi, bool highlighted) {
    final layer = _layers.where((l) => l.category == poi.category).firstOrNull;
    if (layer != null) {
      layer.highlightedPOI = highlighted ? poi : null;
    }
  }

  /// Clear the currently selected POI.
  void clearSelection() {
    if (_selectedPOI == null) return;

    // Clear highlight
    _updatePOIHighlight(_selectedPOI!, false);

    _selectedPOI = null;
    notifyListeners();
  }

  /// Try to select a POI from a map tap position.
  ///
  /// Uses the map controller to find markers at the tap position,
  /// then looks up the corresponding POI.
  ///
  /// Returns true if a POI was selected, false otherwise.
  bool trySelectPOIAtPosition(TrufiMapController controller, dynamic position) {
    final markers = controller.pickMarkersAt(
      position,
      hitboxPx: 40.0,
      globalLimit: 1,
    );

    if (markers.isEmpty) {
      clearSelection();
      return false;
    }

    final poi = findPOIByMarkerId(markers.first.id);
    if (poi != null) {
      selectPOI(poi);
      return true;
    }

    return false;
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
    if (_storageInitialized) {
      _storage.dispose();
      _storageInitialized = false;
    }
    _initialized = false;
    debugPrint('🗑️ POILayersManager disposed');
    super.dispose();
  }
}
