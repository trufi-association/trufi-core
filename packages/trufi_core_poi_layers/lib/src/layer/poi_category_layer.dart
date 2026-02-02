import 'package:flutter/material.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import '../models/poi.dart';
import '../models/poi_category.dart';

/// A TrufiLayer implementation for a single POI category.
///
/// This layer displays POIs for one specific category with:
/// - Pre-loaded data: Receives POIs directly at construction
/// - External visibility control: Use `visible` property to show/hide
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
/// );
///
/// // 3. Control visibility externally
/// foodLayer.visible = true;
/// foodLayer.updateMarkers(); // Call after changing visibility or filters
/// ```
class POICategoryLayer extends TrufiLayer {
  /// The POI category this layer displays
  final POICategory category;

  /// POIs for this category (pre-loaded)
  final List<POI> _pois;

  /// Optional filter to determine which POIs should be shown.
  /// If null, all POIs are shown when the layer is visible.
  bool Function(POI poi)? poiFilter;

  POICategoryLayer({
    required TrufiMapController controller,
    required this.category,
    required List<POI> pois,
    String? parentId,
    this.poiFilter,
  })  : _pois = pois,
        super(
          controller,
          id: 'poi_${category.name}',
          layerLevel: 100 + int.parse(category.weight),
          parentId: parentId,
        );

  /// Update markers based on current POI data and filter.
  /// Call this after changing visibility or poiFilter.
  void updateMarkers() {
    // Don't show markers if layer is not visible
    if (!visible) {
      setMarkers([]);
      return;
    }

    final filteredPOIs =
        poiFilter != null ? _pois.where(poiFilter!) : _pois;

    final markers = filteredPOIs
        .map((poi) => TrufiMarker(
              id: 'poi_${category.name}_${poi.id}',
              position: poi.position,
              size: const Size(30, 30),
              layerLevel: layerLevel,
              imageCacheKey: 'poi_${category.name}',
              allowOverlap: false,
              widget: _buildMarkerWidget(poi),
            ))
        .toList();

    setMarkers(markers);
    debugPrint(
        '📍 POICategoryLayer: ${category.name} - ${markers.length} markers');
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
