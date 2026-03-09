import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

import '../models/poi.dart';
import '../models/poi_category_config.dart';

/// A POI category that holds marker/line data and can produce a [TrufiLayer].
///
/// This is a regular class (not extending TrufiLayer). It manages POI data for
/// one category and exposes a [toTrufiLayer] method that builds a declarative
/// [TrufiLayer] from the current state.
///
/// Example usage:
/// ```dart
/// final foodLayer = POICategoryLayer(
///   category: foodCategory,
///   pois: foodPOIs,
/// );
///
/// // Control visibility
/// foodLayer.visible = true;
///
/// // Get declarative layer for the map
/// final trufiLayer = foodLayer.toTrufiLayer();
/// ```
class POICategoryLayer {
  /// The POI category configuration this layer displays
  final POICategoryConfig category;

  /// POIs for this category (pre-loaded)
  final List<POI> _pois;

  /// Optional filter to determine which POIs should be shown.
  /// If null, all POIs are shown when the layer is visible.
  bool Function(POI poi)? poiFilter;

  /// Whether this layer is visible
  bool visible;

  /// The layer ID
  String get id => 'poi_${category.name}';

  /// The layer level for z-ordering
  int get layerLevel => 100 + category.weight;

  /// Optional parent layer ID
  final String? parentId;

  /// Currently highlighted POI (for selection styling)
  POI? _highlightedPOI;

  POICategoryLayer({
    required this.category,
    required List<POI> pois,
    this.parentId,
    this.poiFilter,
    this.visible = false,
  }) : _pois = pois;

  /// Set the highlighted POI (for selection styling)
  set highlightedPOI(POI? poi) {
    _highlightedPOI = poi;
  }

  /// Get currently highlighted POI
  POI? get highlightedPOI => _highlightedPOI;

  /// Build a [TrufiLayer] from current state.
  TrufiLayer toTrufiLayer() {
    if (!visible) {
      return TrufiLayer(
        id: id,
        visible: false,
        layerLevel: layerLevel,
        parentId: parentId,
      );
    }

    final filteredPOIs = poiFilter != null ? _pois.where(poiFilter!) : _pois;

    const markerSize = 24.0;
    final markers = filteredPOIs
        .map(
          (poi) => TrufiMarker(
            id: 'poi_${category.name}_${poi.id}',
            position: poi.position,
            size: const Size(markerSize, markerSize),
            layerLevel: layerLevel,
            imageCacheKey:
                'poi_icon_${category.name}_${poi.subcategory ?? "default"}',
            allowOverlap: false,
            widget: _buildMarkerWidget(poi, markerSize),
          ),
        )
        .toList();

    final lines = _buildPolygons(filteredPOIs);

    return TrufiLayer(
      id: id,
      markers: markers,
      lines: lines,
      visible: true,
      layerLevel: layerLevel,
      parentId: parentId,
    );
  }

  /// Build polygon outlines for area POIs
  List<TrufiLine> _buildPolygons(Iterable<POI> filteredPOIs) {
    final polygonLines = <TrufiLine>[];

    for (final poi in filteredPOIs) {
      if (poi.isArea &&
          poi.polygonPoints != null &&
          poi.polygonPoints!.isNotEmpty) {
        final isHighlighted = _highlightedPOI?.id == poi.id;

        final points = poi.polygonPoints!
            .map((p) => latlng.LatLng(p.latitude, p.longitude))
            .toList();

        final color = poi.color;

        polygonLines.add(
          TrufiLine(
            id: 'poi_polygon_${category.name}_${poi.id}',
            position: points,
            color: isHighlighted ? color : color.withValues(alpha: 0.6),
            lineWidth: isHighlighted ? 4.0 : 2.0,
            layerLevel: isHighlighted ? layerLevel + 1 : layerLevel - 1,
          ),
        );
      }
    }

    return polygonLines;
  }

  /// Build marker widget for a POI using its SVG icon if available
  Widget _buildMarkerWidget(POI poi, double size) {
    final color = poi.color;
    final iconSize = size;

    // First try POI's own icon from properties
    final poiSvgString = poi.properties['icon'] as String?;
    if (poiSvgString != null && poiSvgString.isNotEmpty) {
      return SvgPicture.string(poiSvgString, width: iconSize, height: iconSize);
    }

    // Then try subcategory icon from metadata
    final subConfig = poi.subcategoryConfig;
    if (subConfig?.iconSvg != null && subConfig!.iconSvg!.isNotEmpty) {
      return SvgPicture.string(
        subConfig.iconSvg!,
        width: iconSize,
        height: iconSize,
      );
    }

    // Then try category icon from metadata
    if (category.iconSvg != null && category.iconSvg!.isNotEmpty) {
      return SvgPicture.string(
        category.iconSvg!,
        width: iconSize,
        height: iconSize,
      );
    }

    // Fallback to category fallback icon (Material icon)
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Icon(category.fallbackIcon, color: color, size: iconSize * 0.6),
    );
  }

  /// Get the number of POIs in this layer
  int get poiCount => _pois.length;

  /// Get the number of visible markers (from the last built layer)
  int get visibleMarkerCount {
    if (!visible) return 0;
    final filteredPOIs = poiFilter != null ? _pois.where(poiFilter!) : _pois;
    return filteredPOIs.length;
  }

  /// Get all POIs in this layer
  List<POI> get pois => _pois;
}
