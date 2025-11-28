import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

class PointsLayer extends TrufiLayer {
  static const String layerId = 'points-layer';

  final List<latlng.LatLng> _points = [];

  PointsLayer(super.controller) : super(id: layerId, layerLevel: 5);

  List<latlng.LatLng> getPoints() => List.unmodifiable(_points);

  void addSamplePoints(List<latlng.LatLng> points) {
    _points.addAll(points);

    final markers = <TrufiMarker>[];
    for (var i = 0; i < points.length; i++) {
      markers.add(
        TrufiMarker(
          id: 'point-$i',
          position: points[i],
          widget: _buildMarkerWidget(i),
          size: const Size(40, 40),
          alignment: Alignment.center,
          layerLevel: layerLevel,
        ),
      );
    }
    addMarkers(markers);
  }

  Widget _buildMarkerWidget(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
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
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void clearPoints() {
    _points.clear();
    clearMarkers();
  }
}
