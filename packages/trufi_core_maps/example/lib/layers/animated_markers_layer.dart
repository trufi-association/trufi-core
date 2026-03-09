import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// A vehicle marker that moves along a route in real-time
class VehicleMarker {
  VehicleMarker({
    required this.id,
    required this.route,
    required this.color,
    this.speed = 0.00005, // degrees per tick
    this.icon = Icons.directions_bus,
  }) : currentPosition = route.first;

  final String id;
  final List<latlng.LatLng> route;
  final Color color;
  final double speed;
  final IconData icon;
  latlng.LatLng currentPosition;
  int _currentSegment = 0;
  double _segmentProgress = 0.0;
  bool _forward = true;

  void tick() {
    if (route.length < 2) return;

    final from = route[_currentSegment];
    final to = route[_currentSegment + 1];

    // Calculate segment length
    final dx = to.longitude - from.longitude;
    final dy = to.latitude - from.latitude;
    final segmentLength = sqrt(dx * dx + dy * dy);

    // Progress along segment
    _segmentProgress += speed / max(segmentLength, 0.0001);

    if (_segmentProgress >= 1.0) {
      _segmentProgress = 0.0;
      if (_forward) {
        _currentSegment++;
        if (_currentSegment >= route.length - 1) {
          _currentSegment = route.length - 2;
          _forward = false;
        }
      } else {
        _currentSegment--;
        if (_currentSegment < 0) {
          _currentSegment = 0;
          _forward = true;
        }
      }
    }

    // Interpolate position
    final segFrom = _forward
        ? route[_currentSegment]
        : route[_currentSegment + 1];
    final segTo = _forward
        ? route[_currentSegment + 1]
        : route[_currentSegment];

    currentPosition = latlng.LatLng(
      segFrom.latitude + (segTo.latitude - segFrom.latitude) * _segmentProgress,
      segFrom.longitude +
          (segTo.longitude - segFrom.longitude) * _segmentProgress,
    );
  }
}

/// State holder that produces marker data for animated vehicles.
///
/// Call methods to generate/animate vehicles, then read [markers] to get
/// the current list of TrufiMarker data to pass to TrufiMap.
class AnimatedMarkersLayer {
  static const String layerId = 'animated-markers-layer';

  final List<VehicleMarker> _vehicles = [];
  Timer? _animationTimer;
  int _fps = 30;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();
  double _currentFps = 0.0;

  final ValueNotifier<PerformanceStats> statsNotifier = ValueNotifier(
    const PerformanceStats(),
  );

  /// Callback invoked after each animation tick so the host can call setState.
  VoidCallback? onUpdate;

  int get vehicleCount => _vehicles.length;
  double get currentFps => _currentFps;

  /// Current marker data to pass into a TrufiLayer.
  List<TrufiMarker> get markers => _buildMarkers();

  /// Generate random vehicles around a center point
  void generateVehicles({
    required latlng.LatLng center,
    required int count,
    double spreadRadius = 0.05,
  }) {
    final random = Random();
    _vehicles.clear();

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    final icons = [
      Icons.directions_bus,
      Icons.directions_car,
      Icons.local_taxi,
      Icons.two_wheeler,
      Icons.electric_car,
    ];

    for (var i = 0; i < count; i++) {
      final routeLength = 5 + random.nextInt(10);
      final route = <latlng.LatLng>[];

      var lat =
          center.latitude + (random.nextDouble() - 0.5) * spreadRadius * 2;
      var lng =
          center.longitude + (random.nextDouble() - 0.5) * spreadRadius * 2;

      for (var j = 0; j < routeLength; j++) {
        route.add(latlng.LatLng(lat, lng));
        lat += (random.nextDouble() - 0.5) * 0.01;
        lng += (random.nextDouble() - 0.5) * 0.01;
      }

      _vehicles.add(
        VehicleMarker(
          id: 'vehicle-$i',
          route: route,
          color: colors[random.nextInt(colors.length)],
          icon: icons[random.nextInt(icons.length)],
          speed: 0.00002 + random.nextDouble() * 0.00006,
        ),
      );
    }
  }

  List<TrufiMarker> _buildMarkers() {
    return [
      for (final vehicle in _vehicles)
        TrufiMarker(
          id: vehicle.id,
          position: vehicle.currentPosition,
          widget: _VehicleMarkerWidget(
            color: vehicle.color,
            icon: vehicle.icon,
          ),
          size: const Size(36, 36),
          alignment: Alignment.center,
          layerLevel: 7,
          imageCacheKey:
              'vehicle_${vehicle.color.toARGB32()}_${vehicle.icon.codePoint}',
        ),
    ];
  }

  void startAnimation({int fps = 30}) {
    _fps = fps;
    _animationTimer?.cancel();
    _lastFpsUpdate = DateTime.now();
    _frameCount = 0;

    _animationTimer = Timer.periodic(
      Duration(milliseconds: (1000 / _fps).round()),
      (_) => _tick(),
    );
  }

  void _tick() {
    final stopwatch = Stopwatch()..start();

    for (final vehicle in _vehicles) {
      vehicle.tick();
    }

    stopwatch.stop();
    _frameCount++;

    final now = DateTime.now();
    final elapsed = now.difference(_lastFpsUpdate).inMilliseconds;

    if (elapsed >= 1000) {
      _currentFps = _frameCount * 1000 / elapsed;
      _frameCount = 0;
      _lastFpsUpdate = now;

      statsNotifier.value = PerformanceStats(
        fps: _currentFps,
        markerCount: _vehicles.length,
        frameTimeMs: stopwatch.elapsedMilliseconds.toDouble(),
      );
    }

    onUpdate?.call();
  }

  void stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  void clearVehicles() {
    stopAnimation();
    _vehicles.clear();
    statsNotifier.value = const PerformanceStats();
  }

  void dispose() {
    stopAnimation();
    statsNotifier.dispose();
  }
}

class _VehicleMarkerWidget extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _VehicleMarkerWidget({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(child: Icon(icon, color: Colors.white, size: 18)),
    );
  }
}

class PerformanceStats {
  final double fps;
  final int markerCount;
  final double frameTimeMs;

  const PerformanceStats({
    this.fps = 0,
    this.markerCount = 0,
    this.frameTimeMs = 0,
  });
}
