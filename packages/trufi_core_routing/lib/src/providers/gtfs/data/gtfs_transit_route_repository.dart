import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

import '../../../domain/entities/stop.dart';
import '../../../domain/entities/transit_route.dart';
import '../../../domain/entities/transport_mode.dart';
import '../../../domain/repositories/transit_route_repository.dart';
import '../gtfs_data_source.dart';
import '../models/gtfs_models.dart';

/// TransitRouteRepository implementation using GTFS data.
class GtfsTransitRouteRepository implements TransitRouteRepository {
  final GtfsDataSource _dataSource;

  GtfsTransitRouteRepository({required GtfsDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<TransitRoute>> fetchPatterns() async {
    // Ensure data is loaded
    if (!_dataSource.isLoaded) {
      await _dataSource.preload();
    }

    if (!_dataSource.isLoaded || _dataSource.routeIndex == null) {
      return [];
    }

    final routeIndex = _dataSource.routeIndex!;
    final patterns = <TransitRoute>[];

    for (final pattern in routeIndex.patterns) {
      final route = _dataSource.getRoute(pattern.routeId);
      if (route == null) continue;

      // Generate origin → destination from stops
      String? generatedLongName;
      if (pattern.stopIds.length >= 2) {
        final firstStop = _dataSource.getStop(pattern.stopIds.first);
        final lastStop = _dataSource.getStop(pattern.stopIds.last);
        if (firstStop != null && lastStop != null) {
          generatedLongName = '${firstStop.name} → ${lastStop.name}';
        }
      }

      // Use headsign, generated name, or route longName
      final effectiveLongName = generatedLongName ?? route.longName;

      patterns.add(TransitRoute(
        id: pattern.routeId,
        name: pattern.headsign ?? route.longName,
        code: pattern.routeId,
        route: TransitRouteInfo(
          shortName: route.shortName,
          longName: effectiveLongName,
          mode: _routeTypeToMode(route.type),
          color: _colorToHex(route.flutterColor),
          textColor: _colorToHex(route.flutterTextColor),
        ),
      ));
    }

    // Sort by route short name
    patterns.sort((a, b) => _compareRouteNames(
      a.route?.shortName ?? a.code,
      b.route?.shortName ?? b.code,
    ));

    return patterns;
  }

  @override
  Future<TransitRoute> fetchPatternById(String id) async {
    debugPrint('GtfsTransitRouteRepository.fetchPatternById: Looking for id=$id');

    // Ensure data is loaded
    if (!_dataSource.isLoaded) {
      debugPrint('GtfsTransitRouteRepository.fetchPatternById: Data not loaded, preloading...');
      await _dataSource.preload();
    }

    if (!_dataSource.isLoaded || _dataSource.routeIndex == null) {
      debugPrint('GtfsTransitRouteRepository.fetchPatternById: GTFS data not loaded!');
      throw Exception('GTFS data not loaded');
    }

    final routeIndex = _dataSource.routeIndex!;
    final pattern = routeIndex.getPattern(id);
    final route = _dataSource.getRoute(id);

    debugPrint('GtfsTransitRouteRepository.fetchPatternById: pattern=${pattern != null}, route=${route != null}');

    if (pattern == null || route == null) {
      // Debug: list available patterns
      debugPrint('GtfsTransitRouteRepository.fetchPatternById: Available patterns: ${routeIndex.patterns.map((p) => p.routeId).take(10).toList()}');
      throw Exception('Route not found: $id');
    }

    // Get shape geometry if available
    final shape = pattern.shapeId != null
        ? _dataSource.getShape(pattern.shapeId!)
        : null;

    // Get stops for this pattern
    final stops = pattern.stopIds
        .map((stopId) => _dataSource.getStop(stopId))
        .whereType<GtfsStop>()
        .map((s) => Stop(name: s.name, lat: s.lat, lon: s.lon))
        .toList();

    // Generate origin → destination from stops
    String? generatedLongName;
    if (stops.length >= 2) {
      generatedLongName = '${stops.first.name} → ${stops.last.name}';
    }

    final effectiveLongName = generatedLongName ?? route.longName;

    return TransitRoute(
      id: pattern.routeId,
      name: pattern.headsign ?? route.longName,
      code: pattern.routeId,
      route: TransitRouteInfo(
        shortName: route.shortName,
        longName: effectiveLongName,
        mode: _routeTypeToMode(route.type),
        color: _colorToHex(route.flutterColor),
        textColor: _colorToHex(route.flutterTextColor),
      ),
      geometry: shape?.polyline,
      stops: stops,
    );
  }

  TransportMode _routeTypeToMode(GtfsRouteType type) {
    switch (type) {
      case GtfsRouteType.tram:
        return TransportMode.tram;
      case GtfsRouteType.subway:
        return TransportMode.subway;
      case GtfsRouteType.rail:
        return TransportMode.rail;
      case GtfsRouteType.bus:
        return TransportMode.bus;
      case GtfsRouteType.ferry:
        return TransportMode.ferry;
      case GtfsRouteType.cableTram:
        return TransportMode.cableCar;
      case GtfsRouteType.aerialLift:
        return TransportMode.gondola;
      case GtfsRouteType.funicular:
        return TransportMode.funicular;
      case GtfsRouteType.trolleybus:
        return TransportMode.bus;
      case GtfsRouteType.monorail:
        return TransportMode.rail;
    }
  }

  String? _colorToHex(Color? color) {
    if (color == null) return null;
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '$r$g$b'.toUpperCase();
  }

  /// Compare route names, handling numeric prefixes.
  int _compareRouteNames(String a, String b) {
    // Try to parse as numbers for natural sorting
    final numA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), ''));
    final numB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), ''));

    if (numA != null && numB != null) {
      return numA.compareTo(numB);
    }

    return a.compareTo(b);
  }
}
