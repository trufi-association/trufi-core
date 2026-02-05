import 'dart:ui' show Color;

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

      patterns.add(TransitRoute(
        id: pattern.routeId,
        name: pattern.headsign ?? route.longName,
        code: route.shortName,
        route: TransitRouteInfo(
          shortName: route.shortName,
          longName: route.longName,
          mode: _routeTypeToMode(route.type),
          color: _colorToHex(route.color),
          textColor: _colorToHex(route.textColor),
        ),
      ));
    }

    // Sort by route short name
    patterns.sort((a, b) => _compareRouteNames(a.code, b.code));

    return patterns;
  }

  @override
  Future<TransitRoute> fetchPatternById(String id) async {
    // Ensure data is loaded
    if (!_dataSource.isLoaded) {
      await _dataSource.preload();
    }

    if (!_dataSource.isLoaded || _dataSource.routeIndex == null) {
      throw Exception('GTFS data not loaded');
    }

    final routeIndex = _dataSource.routeIndex!;
    final pattern = routeIndex.getPattern(id);
    final route = _dataSource.getRoute(id);

    if (pattern == null || route == null) {
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

    return TransitRoute(
      id: pattern.routeId,
      name: pattern.headsign ?? route.longName,
      code: route.shortName,
      route: TransitRouteInfo(
        shortName: route.shortName,
        longName: route.longName,
        mode: _routeTypeToMode(route.type),
        color: _colorToHex(route.color),
        textColor: _colorToHex(route.textColor),
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
