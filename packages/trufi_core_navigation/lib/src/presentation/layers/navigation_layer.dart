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

    // Get user position if available
    final userPosition = state.currentLocation != null
        ? LatLng(
            state.currentLocation!.latitude,
            state.currentLocation!.longitude,
          )
        : null;

    // Determine current leg index based on user position
    final currentLegIndex = route.legs.isNotEmpty
        ? _getCurrentLegIndex(route, currentStopIndex, userPosition)
        : 0;

    // Draw route lines
    _drawRouteLinesWithProgress(route, currentLegIndex, currentStopIndex, userPosition);

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

  void _drawRouteLinesWithProgress(
    NavigationRoute route,
    int currentLegIndex,
    int currentStopIndex,
    LatLng? userPosition,
  ) {
    // Use legs for proper rendering with colors and styles
    if (route.legs.isNotEmpty) {
      _drawLegsWithStyles(
        route,
        currentLegIndex,
        currentStopIndex,
        userPosition: userPosition,
      );
    } else {
      // Fallback to simple geometry rendering
      _drawSimpleGeometry(route, currentStopIndex);
    }
  }

  /// Determines which leg index the user is currently on based on their position.
  /// Also calculates progress within the current leg to determine what's "passed".
  int _getCurrentLegIndex(
    NavigationRoute route,
    int currentStopIndex,
    LatLng? userPosition,
  ) {
    if (route.legs.isEmpty) return 0;

    // If we have user position, find which leg they're on
    if (userPosition != null) {
      double minDist = double.infinity;
      int closestLegIndex = 0;

      for (int i = 0; i < route.legs.length; i++) {
        final leg = route.legs[i];
        for (int j = 0; j < leg.points.length; j++) {
          final dist = _distanceBetween(leg.points[j], userPosition);
          if (dist < minDist) {
            minDist = dist;
            closestLegIndex = i;
          }
        }
      }

      return closestLegIndex;
    }

    // Fallback: use stop index to estimate leg
    if (route.stops.isEmpty) return 0;
    if (currentStopIndex >= route.stops.length) {
      return route.legs.length - 1;
    }

    final currentStop = route.stops[currentStopIndex];

    // Find which leg contains this stop
    double minDist = double.infinity;
    int closestLegIndex = 0;

    for (int i = 0; i < route.legs.length; i++) {
      final leg = route.legs[i];
      for (final point in leg.points) {
        final dist = _distanceBetween(point, currentStop.position);
        if (dist < minDist) {
          minDist = dist;
          closestLegIndex = i;
        }
      }
    }

    return closestLegIndex;
  }

  /// Draws each leg with its own color and style.
  /// Legs that have been passed are shown in gray.
  /// The current leg is split at user position: passed portion in gray, remaining in color.
  void _drawLegsWithStyles(
    NavigationRoute route,
    int currentLegIndex,
    int currentStopIndex, {
    LatLng? userPosition,
  }) {
    for (int i = 0; i < route.legs.length; i++) {
      final leg = route.legs[i];
      if (leg.points.isEmpty) continue;

      // Check if this leg has been completely passed
      final isCompletelyPassed = i < currentLegIndex;
      final isCurrentLeg = i == currentLegIndex;

      // Determine the active color for this leg type
      final Color activeColor;
      final double lineWidth;
      final bool useDots;

      if (leg.isTransit) {
        activeColor = leg.color != null ? Color(leg.color!) : Colors.blue;
        lineWidth = 6;
        useDots = false;
      } else if (leg.isBicycle) {
        activeColor = const Color(0xFF4CAF50);
        lineWidth = 5;
        useDots = false;
      } else {
        // Walking legs
        activeColor = Colors.grey;
        lineWidth = 4;
        useDots = true;
      }

      if (isCompletelyPassed) {
        // Entire leg is passed - draw in gray
        addLine(TrufiLine(
          id: 'leg-$i',
          position: leg.points,
          color: Colors.grey.withValues(alpha: 0.5),
          lineWidth: 4,
          activeDots: false,
          layerLevel: 0,
        ));
      } else if (isCurrentLeg && userPosition != null) {
        // Current leg - split at user position
        final splitIndex = _findClosestPointIndex(leg.points, userPosition);

        // Draw passed portion (gray)
        if (splitIndex > 0) {
          final passedPoints = leg.points.sublist(0, splitIndex + 1);
          addLine(TrufiLine(
            id: 'leg-$i-passed',
            position: passedPoints,
            color: Colors.grey.withValues(alpha: 0.5),
            lineWidth: 4,
            activeDots: false,
            layerLevel: 0,
          ));
        }

        // Draw remaining portion (active color)
        if (splitIndex < leg.points.length - 1) {
          final remainingPoints = leg.points.sublist(splitIndex);
          addLine(TrufiLine(
            id: 'leg-$i-remaining',
            position: remainingPoints,
            color: activeColor,
            lineWidth: lineWidth,
            activeDots: useDots,
            layerLevel: 1,
          ));
        }
      } else {
        // Future leg - draw in active color
        addLine(TrufiLine(
          id: 'leg-$i',
          position: leg.points,
          color: activeColor,
          lineWidth: lineWidth,
          activeDots: useDots,
          layerLevel: 1,
        ));
      }
    }

    // Add origin marker always (at start of route)
    if (route.legs.isNotEmpty) {
      final firstLegPoints = route.legs.first.points;
      if (firstLegPoints.isNotEmpty) {
        addMarker(TrufiMarker(
          id: 'origin-marker',
          position: firstLegPoints.first,
          widget: const _OriginMarkerWidget(),
          size: const Size(24, 24),
          layerLevel: 3,
          imageKey: 'nav_origin_marker',
        ));
      }
    }

    // Add destination marker at the last point of the last leg
    if (route.legs.isNotEmpty) {
      final lastLegPoints = route.legs.last.points;
      if (lastLegPoints.isNotEmpty) {
        addMarker(TrufiMarker(
          id: 'destination-marker',
          position: lastLegPoints.last,
          widget: const _DestinationMarkerWidget(),
          size: const Size(32, 32),
          alignment: Alignment.topCenter,
          layerLevel: 3,
          imageKey: 'nav_destination_marker',
        ));
      }
    }
  }

  /// Finds the index of the closest point in a list to the given position.
  int _findClosestPointIndex(List<LatLng> points, LatLng position) {
    double minDist = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < points.length; i++) {
      final dist = _distanceBetween(points[i], position);
      if (dist < minDist) {
        minDist = dist;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  /// Fallback simple geometry rendering.
  void _drawSimpleGeometry(NavigationRoute route, int currentStopIndex) {
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
        final dist = _distanceBetween(point, currentStop.position);
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

  double _distanceBetween(LatLng a, LatLng b) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, a, b);
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

/// Origin marker - green circle (matches home screen style).
class _OriginMarkerWidget extends StatelessWidget {
  const _OriginMarkerWidget();

  static const _color = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// Destination marker - red pin icon (matches home screen style).
class _DestinationMarkerWidget extends StatelessWidget {
  const _DestinationMarkerWidget();

  static const _color = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.place_rounded,
      color: _color,
      size: 32,
      shadows: [
        Shadow(
          color: Colors.black38,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}
