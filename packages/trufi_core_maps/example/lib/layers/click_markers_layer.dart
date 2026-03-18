import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// State holder that produces marker data for user-clicked positions.
class ClickMarkersLayer {
  static const String layerId = 'click-markers-layer';

  final List<latlng.LatLng> _points = [];

  /// Callback invoked when markers change so the host can call setState.
  VoidCallback? onUpdate;

  List<latlng.LatLng> getPoints() => List.unmodifiable(_points);

  /// Current marker data to pass into a TrufiLayer.
  List<TrufiMarker> get markers => _buildMarkers();

  void addMarkerAt(latlng.LatLng position) {
    _points.add(position);
    onUpdate?.call();
  }

  List<TrufiMarker> _buildMarkers() {
    return [
      for (var i = 0; i < _points.length; i++)
        TrufiMarker(
          id: 'click-marker-${i + 1}',
          position: _points[i],
          widget: _clickMarkerWidget,
          size: const Size(32, 32),
          alignment: Alignment.center,
          layerLevel: 8,
          // All click markers look identical, share the same cached image
          imageCacheKey: 'click_marker_orange',
        ),
    ];
  }

  // Single widget instance reused for all click markers
  static final Widget _clickMarkerWidget = Container(
    decoration: BoxDecoration(
      color: Colors.orange.shade600,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: const Center(
      child: Icon(Icons.touch_app, color: Colors.white, size: 16),
    ),
  );

  void clearClickMarkers() {
    _points.clear();
    onUpdate?.call();
  }
}
