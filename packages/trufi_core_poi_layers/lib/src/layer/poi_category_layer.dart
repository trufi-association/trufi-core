import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart' as latlng;
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
/// - Polygon rendering: Shows outlines for area POIs
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

  /// Currently highlighted POI (for selection styling)
  POI? _highlightedPOI;

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

  /// Set the highlighted POI (for selection styling)
  set highlightedPOI(POI? poi) {
    if (_highlightedPOI == poi) return;
    _highlightedPOI = poi;
    _updatePolygons();
  }

  /// Get currently highlighted POI
  POI? get highlightedPOI => _highlightedPOI;

  /// Update markers and polygons based on current POI data and filter.
  /// Call this after changing visibility or poiFilter.
  void updateMarkers() {
    // Don't show markers if layer is not visible
    if (!visible) {
      setMarkers([]);
      setLines([]);
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
              // Cache by POI type to reuse same icon for same type
              imageCacheKey: 'poi_icon_${poi.type.name}',
              allowOverlap: false,
              widget: _buildMarkerWidget(poi),
            ))
        .toList();

    setMarkers(markers);

    // Update polygon outlines for area POIs
    _updatePolygons();
  }

  /// Update polygon outlines for area POIs
  void _updatePolygons() {
    if (!visible) {
      setLines([]);
      return;
    }

    final filteredPOIs =
        poiFilter != null ? _pois.where(poiFilter!) : _pois;

    final polygonLines = <TrufiLine>[];

    for (final poi in filteredPOIs) {
      if (poi.isArea && poi.polygonPoints != null && poi.polygonPoints!.isNotEmpty) {
        final isHighlighted = _highlightedPOI?.id == poi.id;

        // Convert LatLng to latlng.LatLng for TrufiLine
        final points = poi.polygonPoints!
            .map((p) => latlng.LatLng(p.latitude, p.longitude))
            .toList();

        // Create polygon outline
        polygonLines.add(TrufiLine(
          id: 'poi_polygon_${category.name}_${poi.id}',
          position: points,
          color: isHighlighted
              ? category.color
              : category.color.withValues(alpha: 0.6),
          lineWidth: isHighlighted ? 4.0 : 2.0,
          layerLevel: isHighlighted ? layerLevel + 1 : layerLevel - 1,
        ));
      }
    }

    setLines(polygonLines);
  }

  /// Build marker widget for a POI using its SVG icon if available
  Widget _buildMarkerWidget(POI poi) {
    final svgString = poi.properties['icon'] as String?;

    if (svgString != null && svgString.isNotEmpty) {
      return SvgPicture.string(
        svgString,
        width: 30,
        height: 30,
      );
    }

    // Fallback to category icon if no SVG available
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
