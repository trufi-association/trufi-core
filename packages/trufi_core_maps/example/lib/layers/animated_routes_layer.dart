import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// A route with an animated "pulse" effect
class AnimatedRoute {
  AnimatedRoute({
    required this.id,
    required this.points,
    required this.color,
    this.width = 4.0,
  });

  final String id;
  final List<latlng.LatLng> points;
  final Color color;
  final double width;
  double dashOffset = 0;
}

/// State holder that produces line and marker data for animated routes.
class AnimatedRoutesLayer {
  static const String layerId = 'animated-routes-layer';

  final List<AnimatedRoute> _routes = [];
  Timer? _animationTimer;

  /// Callback invoked after each animation tick so the host can call setState.
  VoidCallback? onUpdate;

  int get routeCount => _routes.length;

  /// Current line data to pass into a TrufiLayer.
  List<TrufiLine> get lines => _buildLines();

  /// Current marker data (route endpoints) to pass into a TrufiLayer.
  List<TrufiMarker> get markers => _buildMarkers();

  /// Generate random routes around a center point
  void generateRoutes({
    required latlng.LatLng center,
    required int count,
    double spreadRadius = 0.08,
    int pointsPerRoute = 20,
  }) {
    final random = Random();
    _routes.clear();

    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.indigo.shade600,
      Colors.pink.shade600,
      Colors.cyan.shade600,
      Colors.amber.shade600,
    ];

    for (var i = 0; i < count; i++) {
      final points = <latlng.LatLng>[];

      var lat =
          center.latitude + (random.nextDouble() - 0.5) * spreadRadius * 2;
      var lng =
          center.longitude + (random.nextDouble() - 0.5) * spreadRadius * 2;

      final direction = random.nextDouble() * 2 * pi;
      var currentDirection = direction;

      for (var j = 0; j < pointsPerRoute; j++) {
        points.add(latlng.LatLng(lat, lng));
        currentDirection += (random.nextDouble() - 0.5) * 0.5;
        final step = 0.002 + random.nextDouble() * 0.003;
        lat += sin(currentDirection) * step;
        lng += cos(currentDirection) * step;
      }

      final color = colors[i % colors.length];

      _routes.add(
        AnimatedRoute(
          id: 'route-$i',
          points: points,
          color: color,
          width: 3 + random.nextDouble() * 3,
        ),
      );
    }
  }

  List<TrufiLine> _buildLines() {
    return [
      for (final route in _routes)
        TrufiLine(
          id: route.id,
          position: route.points,
          color: route.color,
          lineWidth: route.width,
          activeDots: false,
          layerLevel: 4,
        ),
    ];
  }

  List<TrufiMarker> _buildMarkers() {
    final markers = <TrufiMarker>[];
    for (final route in _routes) {
      markers.add(
        TrufiMarker(
          id: 'route-start-${route.id}',
          position: route.points.first,
          widget: _RouteEndpointMarker(color: route.color, isStart: true),
          size: const Size(24, 24),
          alignment: Alignment.center,
          layerLevel: 5,
          imageCacheKey: 'route_start_${route.color.toARGB32()}',
        ),
      );
      markers.add(
        TrufiMarker(
          id: 'route-end-${route.id}',
          position: route.points.last,
          widget: _RouteEndpointMarker(color: route.color, isStart: false),
          size: const Size(24, 24),
          alignment: Alignment.center,
          layerLevel: 5,
          imageCacheKey: 'route_end_${route.color.toARGB32()}',
        ),
      );
    }
    return markers;
  }

  void startAnimation({int fps = 20}) {
    _animationTimer?.cancel();

    _animationTimer = Timer.periodic(
      Duration(milliseconds: (1000 / fps).round()),
      (_) => _tick(),
    );
  }

  void _tick() {
    for (final route in _routes) {
      route.dashOffset += 2;
      if (route.dashOffset > 20) {
        route.dashOffset = 0;
      }
    }
    onUpdate?.call();
  }

  void stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  void clearRoutes() {
    stopAnimation();
    _routes.clear();
  }

  void dispose() {
    stopAnimation();
  }
}

class _RouteEndpointMarker extends StatelessWidget {
  final Color color;
  final bool isStart;

  const _RouteEndpointMarker({required this.color, required this.isStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Icon(
          isStart ? Icons.play_arrow : Icons.stop,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }
}
