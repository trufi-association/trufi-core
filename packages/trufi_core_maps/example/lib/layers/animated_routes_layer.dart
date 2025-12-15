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

/// Layer that displays many polylines with animated effects
class AnimatedRoutesLayer extends TrufiLayer {
  static const String layerId = 'animated-routes-layer';

  AnimatedRoutesLayer(super.controller) : super(id: layerId, layerLevel: 4);

  final List<AnimatedRoute> _routes = [];
  Timer? _animationTimer;
  int _lineCount = 0;

  final ValueNotifier<int> lineCountNotifier = ValueNotifier(0);

  int get routeCount => _routes.length;

  /// Generate random routes around a center point
  void generateRoutes({
    required latlng.LatLng center,
    required int count,
    double spreadRadius = 0.08,
    int pointsPerRoute = 20,
  }) {
    final random = Random();
    _routes.clear();
    clearLines();
    clearMarkers();

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

      // Start point
      var lat = center.latitude + (random.nextDouble() - 0.5) * spreadRadius * 2;
      var lng = center.longitude + (random.nextDouble() - 0.5) * spreadRadius * 2;

      // Generate wandering path
      final direction = random.nextDouble() * 2 * pi;
      var currentDirection = direction;

      for (var j = 0; j < pointsPerRoute; j++) {
        points.add(latlng.LatLng(lat, lng));

        // Random walk with smooth direction changes
        currentDirection += (random.nextDouble() - 0.5) * 0.5;
        final step = 0.002 + random.nextDouble() * 0.003;

        lat += sin(currentDirection) * step;
        lng += cos(currentDirection) * step;
      }

      final color = colors[i % colors.length];

      _routes.add(AnimatedRoute(
        id: 'route-$i',
        points: points,
        color: color,
        width: 3 + random.nextDouble() * 3,
      ));

      // Add start marker
      addMarker(
        TrufiMarker(
          id: 'route-start-$i',
          position: points.first,
          widget: _RouteEndpointMarker(color: color, isStart: true),
          size: const Size(24, 24),
          alignment: Alignment.center,
          layerLevel: layerLevel + 1,
          imageKey: 'route_start_${color.toARGB32()}',
        ),
      );

      // Add end marker
      addMarker(
        TrufiMarker(
          id: 'route-end-$i',
          position: points.last,
          widget: _RouteEndpointMarker(color: color, isStart: false),
          size: const Size(24, 24),
          alignment: Alignment.center,
          layerLevel: layerLevel + 1,
          imageKey: 'route_end_${color.toARGB32()}',
        ),
      );
    }

    _updateLines();
    _lineCount = _routes.length;
    lineCountNotifier.value = _lineCount;
  }

  void _updateLines() {
    final lines = <TrufiLine>[];

    for (final route in _routes) {
      lines.add(
        TrufiLine(
          id: route.id,
          position: route.points,
          color: route.color,
          lineWidth: route.width,
          activeDots: false,
          layerLevel: layerLevel,
        ),
      );
    }

    setLines(lines);
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
    // Note: For true dash animation we'd need to rebuild lines
    // This is a simplified version that just tracks the offset
    mutateLayers();
  }

  void stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  void clearRoutes() {
    stopAnimation();
    _routes.clear();
    clearLines();
    clearMarkers();
    _lineCount = 0;
    lineCountNotifier.value = 0;
  }

  @override
  void dispose() {
    stopAnimation();
    lineCountNotifier.dispose();
    super.dispose();
  }
}

class _RouteEndpointMarker extends StatelessWidget {
  final Color color;
  final bool isStart;

  const _RouteEndpointMarker({
    required this.color,
    required this.isStart,
  });

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
