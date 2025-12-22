import 'package:flutter/material.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import '../cubit/poi_layers_cubit.dart';
import '../data/models/poi.dart';
import '../data/models/poi_category.dart';

/// A TrufiLayer implementation for a single POI category.
///
/// This layer displays POIs for one specific category with:
/// - Pre-loaded data: Receives POIs directly at construction
/// - Automatic visibility: Syncs with POILayersCubit category state
/// - Independent lifecycle: Each category is a separate layer instance
/// - Hierarchical support: Can have a parent layer for UI organization
///
/// Example usage:
/// ```dart
/// // 1. Load POIs first
/// final loader = GeoJSONLoader(assetsBasePath: 'assets/pois');
/// final foodPOIs = await loader.loadCategory(POICategory.food);
///
/// // 2. Create layer with pre-loaded data
/// final foodLayer = POICategoryLayer(
///   controller: mapController,
///   category: POICategory.food,
///   pois: foodPOIs,
///   cubit: poiLayersCubit,
/// );
/// ```
class POICategoryLayer extends TrufiLayer {
  /// The POI category this layer displays
  final POICategory category;

  /// POI layers cubit for state management
  final POILayersCubit cubit;

  /// POIs for this category (pre-loaded)
  final List<POI> _pois;

  /// Callback when a POI is tapped
  ///
  /// @deprecated This parameter is deprecated and has no effect because markers
  /// are rendered as images. Use TrufiMapController.pickMarkersAt() in your
  /// map's onMapClick callback to handle marker taps instead.
  ///
  /// Example:
  /// ```dart
  /// engine.buildMap(
  ///   controller: mapController,
  ///   onMapClick: (pos) {
  ///     final markers = mapController.pickMarkersAt(pos, hitboxPx: 40.0);
  ///     if (markers.isNotEmpty) {
  ///       // Find POI by marker ID and handle tap
  ///     }
  ///   },
  /// )
  /// ```
  @Deprecated('Use TrufiMapController.pickMarkersAt() instead')
  final void Function(POI poi)? onPOITapped;

  POICategoryLayer({
    required TrufiMapController controller,
    required this.category,
    required List<POI> pois,
    required this.cubit,
    String? parentId,
    this.onPOITapped,
  })  : _pois = pois,
        super(
          controller,
          id: 'poi_${category.name}',
          layerLevel: 100 + int.parse(category.weight),
          parentId: parentId,
        ) {
    // Set initial visibility based on subcategories state
    visible = cubit.state.isCategoryEnabled(category);

    // Update markers initially if visible
    if (visible) {
      _updateMarkers();
    }

    // Listen to subcategory changes for this category
    cubit.stream
        .map((state) => state.enabledSubcategories[category])
        .distinct()
        .listen((enabledSubcategories) {
      // Category is visible if it has any enabled subcategories
      final shouldBeVisible = enabledSubcategories != null && enabledSubcategories.isNotEmpty;
      visible = shouldBeVisible;

      if (shouldBeVisible) {
        _updateMarkers();
      }
    });
  }

  /// Update markers based on current POI data and filters
  void _updateMarkers() {
    final markers = _pois
        .where((poi) => cubit.state.isPOIEnabled(poi))
        .map((poi) => TrufiMarker(
              id: 'poi_${category.name}_${poi.id}',
              position: poi.position,
              size: const Size(30, 30),
              layerLevel: layerLevel,
              imageKey: 'poi_${category.name}',
              widget: _buildMarkerWidget(poi),
            ))
        .toList();

    setMarkers(markers);
    debugPrint(
        '📍 POICategoryLayer: ${category.name} - ${markers.length} markers visible');
  }

  /// Build marker widget for a POI
  Widget _buildMarkerWidget(POI poi) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: category.color, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        category.icon,
        color: category.color,
        size: 17,
      ),
    );
  }

  /// Get the number of POIs in this layer
  int get poiCount => _pois.length;

  /// Get the number of visible markers
  int get visibleMarkerCount => markers.length;

  /// Get all POIs in this layer
  List<POI> get pois => _pois;
}
