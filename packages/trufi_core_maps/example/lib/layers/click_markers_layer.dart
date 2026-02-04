import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

class ClickMarkersLayer extends TrufiLayer {
  static const String layerId = 'click-markers-layer';

  final List<latlng.LatLng> _points = [];
  int _markerCounter = 0;

  ClickMarkersLayer(super.controller) : super(id: layerId, layerLevel: 8);

  List<latlng.LatLng> getPoints() => List.unmodifiable(_points);

  void addMarkerAt(latlng.LatLng position) {
    _points.add(position);
    _markerCounter++;

    addMarkers([
      TrufiMarker(
        id: 'click-marker-$_markerCounter',
        position: position,
        widget: _clickMarkerWidget,
        size: const Size(32, 32),
        alignment: Alignment.center,
        layerLevel: layerLevel,
        // All click markers look identical, share the same cached image
        imageCacheKey: 'click_marker_orange',
      ),
    ]);
  }

  // Single widget instance reused for all click markers
  static final Widget _clickMarkerWidget = Container(
    decoration: BoxDecoration(
      color: Colors.orange.shade600,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: const Center(
      child: Icon(
        Icons.touch_app,
        color: Colors.white,
        size: 16,
      ),
    ),
  );

  void clearClickMarkers() {
    _points.clear();
    _markerCounter = 0;
    clearMarkers();
  }
}
