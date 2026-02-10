import 'package:latlong2/latlong.dart';

import '../models/gtfs_route.dart';
import '../models/gtfs_stop.dart';
import '../index/gtfs_route_index.dart';
import '../services/gtfs_routing_service.dart';

/// Abstract interface for routing operations.
///
/// This allows the same routing logic to work with both:
/// - Local GTFS data (mobile/offline)
/// - Remote trufi-server-planner API (web/online)
abstract class PlannerRoutingClient {
  /// Find routes between two locations.
  Future<List<RoutingPath>> findRoutes({
    required LatLng origin,
    required LatLng destination,
    double maxWalkDistance = 500,
    int maxResults = 5,
  });

  /// Get all transit routes.
  Future<List<GtfsRoute>> getRoutes();

  /// Get all stops (with optional limit).
  Future<List<GtfsStop>> getStops({int? limit});

  /// Find nearby stops.
  Future<List<NearbyStopResult>> findNearbyStops({
    required LatLng location,
    double maxDistance = 500,
    int maxResults = 10,
  });

  /// Get a route by ID.
  Future<GtfsRoute?> getRoute(String routeId);

  /// Get a stop by ID.
  Future<GtfsStop?> getStop(String stopId);

  /// Get route patterns for a route.
  Future<List<RoutePattern>> getPatternsForRoute(String routeId);

  /// Get route detail by ID (route metadata + geometry + stops).
  Future<RouteDetail?> getRouteDetail(String routeId);

  /// Whether the client is ready.
  bool get isReady;

  /// Initialize the client (load data, connect, etc.).
  Future<void> initialize();
}

/// Route detail with geometry and stops (for route detail screen).
class RouteDetail {
  final GtfsRoute route;
  final List<LatLng> geometry;
  final List<GtfsStop> stops;

  const RouteDetail({
    required this.route,
    required this.geometry,
    required this.stops,
  });
}

/// A nearby stop result with distance.
class NearbyStopResult {
  final GtfsStop stop;
  final double distance;

  const NearbyStopResult({required this.stop, required this.distance});

  factory NearbyStopResult.fromJson(Map<String, dynamic> json) {
    return NearbyStopResult(
      stop: GtfsStop.fromJson(json),
      distance: (json['distance'] as num).toDouble(),
    );
  }
}
