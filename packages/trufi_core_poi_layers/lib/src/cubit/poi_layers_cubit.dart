import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import '../config/poi_layer_config.dart';
import '../data/geojson_loader.dart';
import '../data/models/poi.dart';
import '../data/models/poi_category.dart';
import '../layers/poi_map_layer.dart';

/// State for POI layers
class POILayersState {
  /// Enabled state for each category
  final Map<POICategory, bool> enabledCategories;

  /// Loaded layers
  final Map<POICategory, POIMapLayer> layers;

  /// Whether layers are initialized
  final bool isInitialized;

  const POILayersState({
    this.enabledCategories = const {},
    this.layers = const {},
    this.isInitialized = false,
  });

  POILayersState copyWith({
    Map<POICategory, bool>? enabledCategories,
    Map<POICategory, POIMapLayer>? layers,
    bool? isInitialized,
  }) {
    return POILayersState(
      enabledCategories: enabledCategories ?? this.enabledCategories,
      layers: layers ?? this.layers,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  /// Get list of enabled categories
  Set<POICategory> get enabledCategoriesSet =>
      enabledCategories.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toSet();

  /// Check if any category is enabled
  bool get hasEnabledCategories =>
      enabledCategories.values.any((enabled) => enabled);

  /// Get enabled layers
  List<POIMapLayer> get enabledLayers =>
      enabledCategoriesSet
          .map((cat) => layers[cat])
          .whereType<POIMapLayer>()
          .toList();

  /// Get all layers
  List<POIMapLayer> get allLayers => layers.values.toList();
}

/// Cubit for managing POI layer visibility and state.
///
/// This cubit manages POI layer data and enabled state.
/// Use with MapLayersCubit to control visibility on the map via
/// [changeCustomMapLayerState] method.
class POILayersCubit extends Cubit<POILayersState> {
  final POILayerConfig config;
  final GeoJSONLoader _loader;
  final void Function(POI poi)? onPOITapped;
  final MapLayersCubit? mapLayersCubit;

  POILayersCubit({
    required this.config,
    this.onPOITapped,
    this.mapLayersCubit,
    Set<POICategory>? defaultEnabledCategories,
  })  : _loader = GeoJSONLoader(assetsBasePath: config.assetsBasePath),
        super(POILayersState(
          enabledCategories: {
            for (final cat in POICategory.values)
              cat: defaultEnabledCategories?.contains(cat) ?? false,
          },
        ));

  /// Initialize all POI layers
  Future<void> initialize() async {
    if (state.isInitialized) return;

    final layers = <POICategory, POIMapLayer>{};

    for (final category in POICategory.values) {
      final layer = POIMapLayer(
        category: category,
        config: config,
        loader: _loader,
        onPOITapped: onPOITapped,
      );
      await layer.initialize();
      layers[category] = layer;
    }

    emit(state.copyWith(
      layers: layers,
      isInitialized: true,
    ));

    // Sync with MapLayersCubit if available
    _syncWithMapLayersCubit();
  }

  /// Toggle a category on/off
  void toggleCategory(POICategory category, bool enabled) {
    final newEnabled = Map<POICategory, bool>.from(state.enabledCategories);
    newEnabled[category] = enabled;
    emit(state.copyWith(enabledCategories: newEnabled));

    // Update MapLayersCubit if available
    final layer = state.layers[category];
    if (mapLayersCubit != null && layer != null) {
      mapLayersCubit!.changeCustomMapLayerState(
        customLayer: layer,
        newState: enabled,
      );
    }
  }

  /// Enable multiple categories
  void enableCategories(Set<POICategory> categories) {
    final newEnabled = Map<POICategory, bool>.from(state.enabledCategories);
    for (final cat in categories) {
      newEnabled[cat] = true;
    }
    emit(state.copyWith(enabledCategories: newEnabled));
    _syncWithMapLayersCubit();
  }

  /// Disable all categories
  void disableAll() {
    final newEnabled = {
      for (final cat in POICategory.values) cat: false,
    };
    emit(state.copyWith(enabledCategories: newEnabled));
    _syncWithMapLayersCubit();
  }

  /// Enable all categories
  void enableAll() {
    final newEnabled = {
      for (final cat in POICategory.values) cat: true,
    };
    emit(state.copyWith(enabledCategories: newEnabled));
    _syncWithMapLayersCubit();
  }

  /// Sync all layer states with MapLayersCubit
  void _syncWithMapLayersCubit() {
    if (mapLayersCubit == null || !state.isInitialized) return;

    for (final entry in state.enabledCategories.entries) {
      final layer = state.layers[entry.key];
      if (layer != null) {
        mapLayersCubit!.changeCustomMapLayerState(
          customLayer: layer,
          newState: entry.value,
        );
      }
    }
  }

  /// Get layer for a specific category
  POIMapLayer? getLayer(POICategory category) => state.layers[category];

  /// Get MapLayerContainers for all POI layers (for use when creating MapLayersCubit)
  List<MapLayerContainer> getAllLayerContainers() {
    return state.allLayers.map((layer) {
      return MapLayerContainer(
        layers: [layer],
        icon: (context) => Icon(layer.category.icon, color: layer.category.color),
        name: (context) => layer.name(context),
      );
    }).toList();
  }

  /// Clear cached POI data
  void clearCache() {
    _loader.clearCache();
  }

  @override
  Future<void> close() {
    clearCache();
    return super.close();
  }
}

/// Extension to provide easy access to POILayersCubit
extension POILayersCubitContext on BuildContext {
  POILayersCubit get poiLayersCubit => read<POILayersCubit>();
  POILayersCubit? get poiLayersCubitOrNull {
    try {
      return read<POILayersCubit>();
    } catch (_) {
      return null;
    }
  }
}
