import 'package:flutter/foundation.dart';

import '../../../domain/entities/stop.dart';
import '../../../domain/entities/transit_route.dart';
import '../../../domain/entities/transport_mode.dart';
import '../../../domain/repositories/transit_route_repository.dart';
import '../models/trufi_planner_models.dart';
import '../trufi_planner_data_source.dart';

/// TransitRouteRepository implementation using TrufiPlanner (local or remote).
class TrufiPlannerTransitRouteRepository implements TransitRouteRepository {
  final TrufiPlannerDataSource _dataSource;

  TrufiPlannerTransitRouteRepository(
      {required TrufiPlannerDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<TransitRoute>> fetchPatterns() async {
    if (!_dataSource.isLoaded) {
      await _dataSource.preload();
    }

    if (!_dataSource.isLoaded) return [];

    if (_dataSource.config.isLocal) {
      return _fetchPatternsLocal();
    } else {
      return _fetchPatternsRemote();
    }
  }

  Future<List<TransitRoute>> _fetchPatternsLocal() async {
    final routeIndex = _dataSource.routeIndex;
    if (routeIndex == null) return [];

    final patterns = <TransitRoute>[];

    for (final pattern in routeIndex.patterns) {
      final route = _dataSource.getRoute(pattern.routeId);
      if (route == null) continue;

      String? generatedLongName;
      if (pattern.stopIds.length >= 2) {
        final firstStop = _dataSource.getStop(pattern.stopIds.first);
        final lastStop = _dataSource.getStop(pattern.stopIds.last);
        if (firstStop != null && lastStop != null) {
          generatedLongName = '${firstStop.name} → ${lastStop.name}';
        }
      }

      final effectiveLongName = generatedLongName ?? route.longName;

      patterns.add(TransitRoute(
        id: pattern.routeId,
        name: pattern.headsign ?? route.longName,
        code: pattern.routeId,
        route: TransitRouteInfo(
          shortName: route.shortName,
          longName: effectiveLongName,
          mode: _routeTypeToMode(route.type),
          color: route.colorHex,
          textColor: route.textColorHex,
        ),
      ));
    }

    patterns.sort((a, b) => _compareRouteNames(
          a.route?.shortName ?? a.code,
          b.route?.shortName ?? b.code,
        ));

    return patterns;
  }

  Future<List<TransitRoute>> _fetchPatternsRemote() async {
    final routes = await _dataSource.client.getRoutes();

    final patterns = routes
        .map((route) => TransitRoute(
              id: route.id,
              name: route.longName,
              code: route.id,
              route: TransitRouteInfo(
                shortName: route.shortName,
                longName: route.longName,
                mode: _routeTypeToMode(route.type),
                color: route.colorHex,
                textColor: route.textColorHex,
              ),
            ))
        .toList();

    patterns.sort((a, b) => _compareRouteNames(
          a.route?.shortName ?? a.code,
          b.route?.shortName ?? b.code,
        ));

    return patterns;
  }

  @override
  Future<TransitRoute> fetchPatternById(String id) async {
    debugPrint(
        'TrufiPlannerTransitRouteRepository.fetchPatternById: Looking for id=$id');

    if (!_dataSource.isLoaded) {
      await _dataSource.preload();
    }

    if (!_dataSource.isLoaded) {
      throw Exception('Planner data not loaded');
    }

    if (_dataSource.config.isLocal) {
      return _fetchPatternByIdLocal(id);
    } else {
      return _fetchPatternByIdRemote(id);
    }
  }

  Future<TransitRoute> _fetchPatternByIdLocal(String id) async {
    final routeIndex = _dataSource.routeIndex;
    if (routeIndex == null) throw Exception('Route index not available');

    final pattern = routeIndex.getPattern(id);
    final route = _dataSource.getRoute(id);

    if (pattern == null || route == null) {
      throw Exception('Route not found: $id');
    }

    final shape = pattern.shapeId != null
        ? _dataSource.getShape(pattern.shapeId!)
        : null;

    final stops = pattern.stopIds
        .map((stopId) => _dataSource.getStop(stopId))
        .whereType<GtfsStop>()
        .map((s) => Stop(name: s.name, lat: s.lat, lon: s.lon))
        .toList();

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
        color: route.colorHex,
        textColor: route.textColorHex,
      ),
      geometry: shape?.polyline,
      stops: stops,
    );
  }

  Future<TransitRoute> _fetchPatternByIdRemote(String id) async {
    final detail = await _dataSource.client.getRouteDetail(id);
    if (detail == null) throw Exception('Route not found: $id');

    final route = detail.route;
    final stops = detail.stops
        .map((s) => Stop(name: s.name, lat: s.lat, lon: s.lon))
        .toList();

    String? generatedLongName;
    if (stops.length >= 2) {
      generatedLongName = '${stops.first.name} → ${stops.last.name}';
    }

    final effectiveLongName = generatedLongName ?? route.longName;

    return TransitRoute(
      id: route.id,
      name: route.longName,
      code: route.id,
      route: TransitRouteInfo(
        shortName: route.shortName,
        longName: effectiveLongName,
        mode: _routeTypeToMode(route.type),
        color: route.colorHex,
        textColor: route.textColorHex,
      ),
      geometry: detail.geometry,
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

  int _compareRouteNames(String a, String b) {
    final numA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), ''));
    final numB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), ''));

    if (numA != null && numB != null) {
      return numA.compareTo(numB);
    }

    return a.compareTo(b);
  }
}
