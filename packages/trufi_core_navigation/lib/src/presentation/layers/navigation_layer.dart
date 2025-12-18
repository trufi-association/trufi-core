import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import '../../models/navigation_state.dart';

/// Layer for rendering navigation elements on the map.
class NavigationLayer extends TrufiLayer {
  NavigationLayer(super.controller)
      : super(
          id: 'navigation',
          layerLevel: 100,
        );

  /// Update the layer with current navigation state.
  void updateNavigation(NavigationState state) {
    clearMarkers();
    clearLines();

    final route = state.route;
    if (route == null || route.geometry.isEmpty) return;

    final currentStopIndex = state.currentStopIndex;
    final stops = route.stops;

    // Draw route lines
    _drawRouteLines(route, currentStopIndex);

    // Draw stop markers
    _drawStopMarkers(stops, currentStopIndex, route);

    // Draw user location marker
    _drawUserLocation(state);

    // Move camera to follow user if enabled
    if (state.isMapFollowingUser && state.currentLocation != null) {
      final userPos = LatLng(
        state.currentLocation!.latitude,
        state.currentLocation!.longitude,
      );
      controller.setCameraPosition(
        TrufiCameraPosition(target: userPos, zoom: 16),
      );
    }
  }

  void _drawUserLocation(NavigationState state) {
    final location = state.currentLocation;
    if (location == null) return;

    final userPosition = LatLng(location.latitude, location.longitude);

    // Add user location marker
    addMarker(TrufiMarker(
      id: 'user_location',
      position: userPosition,
      widget: _UserLocationMarker(isGpsWeak: state.isGpsWeak),
      size: const Size(48, 48),
      layerLevel: 100,
      imageKey: 'nav_user_location_${state.isGpsWeak}',
    ));
  }

  void _drawRouteLines(NavigationRoute route, int currentStopIndex) {
    final geometry = route.geometry;
    if (geometry.isEmpty) return;

    final routeColor = route.backgroundColor != null
        ? Color(route.backgroundColor!)
        : Colors.blue;

    // Find the geometry index closest to current stop
    int splitIndex = 0;
    if (route.stops.isNotEmpty && currentStopIndex < route.stops.length) {
      final currentStop = route.stops[currentStopIndex];
      double minDist = double.infinity;

      for (int i = 0; i < geometry.length; i++) {
        final point = geometry[i];
        final dist = _distanceBetween(
          point,
          currentStop.position,
        );
        if (dist < minDist) {
          minDist = dist;
          splitIndex = i;
        }
      }
    }

    // Draw passed route section (gray/dimmed)
    if (splitIndex > 0) {
      final passedPoints = geometry.sublist(0, splitIndex + 1);
      addLine(TrufiLine(
        id: 'passed_route',
        position: passedPoints,
        color: Colors.grey.withValues(alpha: 0.5),
        lineWidth: 4,
        layerLevel: 1,
      ));
    }

    // Draw remaining route section (highlighted)
    if (splitIndex < geometry.length - 1) {
      final remainingPoints = geometry.sublist(splitIndex);
      addLine(TrufiLine(
        id: 'remaining_route',
        position: remainingPoints,
        color: routeColor,
        lineWidth: 6,
        layerLevel: 2,
      ));
    }
  }

  void _drawStopMarkers(
    List<NavigationStop> stops,
    int currentStopIndex,
    NavigationRoute route,
  ) {
    if (stops.isEmpty) return;

    final routeColor = route.backgroundColor != null
        ? Color(route.backgroundColor!)
        : Colors.blue;

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final isPassed = i < currentStopIndex;
      final isCurrent = i == currentStopIndex;
      final isFirst = i == 0;
      final isLast = i == stops.length - 1;

      // Only show first, last, and passed stops as small markers
      // Current stop is shown via the user location marker
      if (!isFirst && !isLast && !isPassed) continue;

      addMarker(TrufiMarker(
        id: 'stop_$i',
        position: stop.position,
        widget: _StopMarkerWidget(
          isPassed: isPassed,
          isCurrent: isCurrent,
          isFirst: isFirst,
          isLast: isLast,
          routeColor: routeColor,
        ),
        size: const Size(12, 12),
        layerLevel: 5,
        imageKey: 'nav_stop_${isPassed}_${isCurrent}_${isFirst}_${isLast}_${routeColor.toARGB32()}',
      ));
    }
  }

  double _distanceBetween(LatLng a, LatLng b) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, a, b);
  }
}

/// Widget for rendering a stop marker.
class _StopMarkerWidget extends StatelessWidget {
  final bool isPassed;
  final bool isCurrent;
  final bool isFirst;
  final bool isLast;
  final Color routeColor;

  const _StopMarkerWidget({
    required this.isPassed,
    required this.isCurrent,
    required this.isFirst,
    required this.isLast,
    required this.routeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isFirst) {
      return _buildTerminalMarker(Colors.green);
    }

    if (isLast) {
      return _buildTerminalMarker(Colors.red);
    }

    return _buildRegularMarker();
  }

  Widget _buildTerminalMarker(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Icon(
        isFirst ? Icons.trip_origin_rounded : Icons.flag_rounded,
        color: Colors.white,
        size: 8,
      ),
    );
  }

  Widget _buildRegularMarker() {
    return Container(
      decoration: BoxDecoration(
        color: isPassed ? routeColor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: routeColor,
          width: 2,
        ),
      ),
    );
  }
}

/// Widget for rendering the user's current location.
class _UserLocationMarker extends StatelessWidget {
  final bool isGpsWeak;

  const _UserLocationMarker({
    this.isGpsWeak = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulse ring (accuracy indicator)
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: isGpsWeak ? 0.15 : 0.1),
            shape: BoxShape.circle,
          ),
        ),
        // Middle ring
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        // Inner dot (user position)
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isGpsWeak ? Colors.orange : Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isGpsWeak ? Colors.orange : Colors.blue)
                    .withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
