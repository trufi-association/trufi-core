import 'dart:typed_data';

import 'package:latlong2/latlong.dart';

import '../index/gtfs_route_index.dart';
import '../index/gtfs_spatial_index.dart';
import '../models/gtfs_route.dart';
import '../models/gtfs_stop.dart';
import '../parser/gtfs_parser.dart';
import '../services/gtfs_routing_service.dart';
import 'planner_routing_client.dart';

/// Local routing client that uses in-memory GTFS data.
///
/// Used on mobile platforms where GTFS data is loaded from an asset file.
/// The actual loading of bytes is left to the caller (since it may use
/// Flutter's rootBundle or other platform-specific mechanisms).
class LocalPlannerClient implements PlannerRoutingClient {
  GtfsData? _data;
  GtfsSpatialIndex? _spatialIndex;
  GtfsRouteIndex? _routeIndex;
  GtfsRoutingService? _routingService;

  /// Load from raw GTFS ZIP bytes.
  void loadFromBytes(Uint8List bytes) {
    _data = GtfsParser.parseFromBytes(bytes);
    _spatialIndex = GtfsSpatialIndex(_data!.stops);
    _routeIndex = GtfsRouteIndex(_data!);
    _routingService = GtfsRoutingService(
      data: _data!,
      spatialIndex: _spatialIndex!,
      routeIndex: _routeIndex!,
    );
  }

  /// Load from pre-parsed data and indices.
  void loadFromParsed({
    required GtfsData data,
    required GtfsSpatialIndex spatialIndex,
    required GtfsRouteIndex routeIndex,
  }) {
    _data = data;
    _spatialIndex = spatialIndex;
    _routeIndex = routeIndex;
    _routingService = GtfsRoutingService(
      data: data,
      spatialIndex: spatialIndex,
      routeIndex: routeIndex,
    );
  }

  @override
  bool get isReady => _routingService != null;

  @override
  Future<void> initialize() async {
    // No-op for local client - data is loaded via loadFromBytes/loadFromParsed
  }

  /// Raw GTFS data.
  GtfsData? get data => _data;

  /// Spatial index.
  GtfsSpatialIndex? get spatialIndex => _spatialIndex;

  /// Route index.
  GtfsRouteIndex? get routeIndex => _routeIndex;

  @override
  Future<List<RoutingPath>> findRoutes({
    required LatLng origin,
    required LatLng destination,
    double maxWalkDistance = 500,
    int maxResults = 5,
  }) async {
    if (_routingService == null) return [];
    return _routingService!.findRoutes(
      origin: origin,
      destination: destination,
      maxWalkDistance: maxWalkDistance,
      maxResults: maxResults,
    );
  }

  @override
  Future<List<GtfsRoute>> getRoutes() async {
    return _data?.routes.values.toList() ?? [];
  }

  @override
  Future<List<GtfsStop>> getStops({int? limit}) async {
    final stops = _data?.stops.values.toList() ?? [];
    if (limit != null && limit < stops.length) {
      return stops.sublist(0, limit);
    }
    return stops;
  }

  @override
  Future<List<NearbyStopResult>> findNearbyStops({
    required LatLng location,
    double maxDistance = 500,
    int maxResults = 10,
  }) async {
    if (_spatialIndex == null) return [];
    final nearby = _spatialIndex!.findNearestStops(
      location,
      maxResults: maxResults,
      maxDistance: maxDistance,
    );
    return nearby
        .map((n) => NearbyStopResult(stop: n.stop, distance: n.distance))
        .toList();
  }

  @override
  Future<GtfsRoute?> getRoute(String routeId) async {
    return _data?.routes[routeId];
  }

  @override
  Future<GtfsStop?> getStop(String stopId) async {
    return _data?.stops[stopId];
  }

  @override
  Future<List<RoutePattern>> getPatternsForRoute(String routeId) async {
    return _routeIndex?.getPatternsForRoute(routeId) ?? [];
  }

  @override
  Future<RouteDetail?> getRouteDetail(String routeId) async {
    final route = _data?.routes[routeId];
    if (route == null) return null;

    final pattern = _routeIndex?.getPattern(routeId);

    final geometry = <LatLng>[];
    if (pattern?.shapeId != null) {
      final shape = _data?.shapes[pattern!.shapeId!];
      if (shape != null) {
        geometry.addAll(shape.polyline);
      }
    }

    final stops = <GtfsStop>[];
    if (pattern != null) {
      for (final stopId in pattern.stopIds) {
        final stop = _data?.stops[stopId];
        if (stop != null) stops.add(stop);
      }
    }

    return RouteDetail(route: route, geometry: geometry, stops: stops);
  }

  /// Clear all loaded data.
  void clear() {
    _data = null;
    _spatialIndex = null;
    _routeIndex = null;
    _routingService = null;
  }
}
