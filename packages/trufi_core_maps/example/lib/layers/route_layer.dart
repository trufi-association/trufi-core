import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

class RouteLayer extends TrufiLayer {
  static const String layerId = 'route-layer';

  final List<latlng.LatLng> _routePoints = [];

  RouteLayer(super.controller) : super(id: layerId, layerLevel: 3);

  List<latlng.LatLng> getRoutePoints() => List.unmodifiable(_routePoints);

  void addSampleRoute(List<latlng.LatLng> points) {
    if (points.length < 2) return;

    _routePoints.addAll(points);

    // Add route line
    addLine(
      TrufiLine(
        id: 'route-line',
        position: points,
        color: Colors.green.shade600,
        lineWidth: 5,
        activeDots: false,
        layerLevel: layerLevel,
      ),
    );

    // Add start marker
    addMarker(
      TrufiMarker(
        id: 'route-start',
        position: points.first,
        widget: _buildEndpointMarker(Colors.green, Icons.trip_origin),
        size: const Size(36, 36),
        alignment: Alignment.center,
        layerLevel: layerLevel + 1,
      ),
    );

    // Add end marker
    addMarker(
      TrufiMarker(
        id: 'route-end',
        position: points.last,
        widget: _buildEndpointMarker(Colors.red, Icons.flag),
        size: const Size(36, 36),
        alignment: Alignment.center,
        layerLevel: layerLevel + 1,
      ),
    );
  }

  Widget _buildEndpointMarker(Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: color,
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
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  void clearRoute() {
    _routePoints.clear();
    clearMarkers();
    clearLines();
  }
}
