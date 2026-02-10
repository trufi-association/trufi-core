import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../index/gtfs_route_index.dart';
import '../models/gtfs_route.dart';
import '../models/gtfs_stop.dart';
import '../services/gtfs_routing_service.dart';
import 'planner_routing_client.dart';

/// Remote routing client that calls trufi-server-planner HTTP API.
///
/// Used on web platforms where GTFS data is processed server-side.
class RemotePlannerClient implements PlannerRoutingClient {
  final String serverUrl;
  final http.Client _httpClient;
  bool _isReady = false;

  RemotePlannerClient({
    required this.serverUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  String get _baseUrl => serverUrl.endsWith('/')
      ? serverUrl.substring(0, serverUrl.length - 1)
      : serverUrl;

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    final response = await _httpClient.get(Uri.parse('$_baseUrl/health'));
    if (response.statusCode == 200) {
      _isReady = true;
    } else {
      throw Exception(
          'Server health check failed: ${response.statusCode}');
    }
  }

  @override
  Future<List<RoutingPath>> findRoutes({
    required LatLng origin,
    required LatLng destination,
    double maxWalkDistance = 500,
    int maxResults = 5,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/plan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'from': {'lat': origin.latitude, 'lon': origin.longitude},
        'to': {'lat': destination.latitude, 'lon': destination.longitude},
      }),
    );

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true || data['paths'] == null) {
      return [];
    }

    final paths = data['paths'] as List;
    return paths
        .map((p) => RoutingPath.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GtfsRoute>> getRoutes() async {
    final response = await _httpClient.get(Uri.parse('$_baseUrl/routes'));
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List;
    return routes
        .map((r) => GtfsRoute.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GtfsStop>> getStops({int? limit}) async {
    final uri = limit != null
        ? Uri.parse('$_baseUrl/stops?limit=$limit')
        : Uri.parse('$_baseUrl/stops');
    final response = await _httpClient.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final stops = data['stops'] as List;
    return stops
        .map((s) => GtfsStop.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<NearbyStopResult>> findNearbyStops({
    required LatLng location,
    double maxDistance = 500,
    int maxResults = 10,
  }) async {
    final response = await _httpClient.get(Uri.parse(
      '$_baseUrl/stops/nearby'
      '?lat=${location.latitude}'
      '&lon=${location.longitude}'
      '&maxDistance=$maxDistance'
      '&maxResults=$maxResults',
    ));
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final stops = data['stops'] as List;
    return stops
        .map((s) => NearbyStopResult.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GtfsRoute?> getRoute(String routeId) async {
    final detail = await getRouteDetail(routeId);
    return detail?.route;
  }

  @override
  Future<RouteDetail?> getRouteDetail(String routeId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/routes/$routeId'),
    );
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final route = GtfsRoute.fromJson(data);

    final geometryList = data['geometry'] as List? ?? [];
    final geometry = geometryList
        .map((p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lon'] as num).toDouble(),
            ))
        .toList();

    final stopsList = data['stops'] as List? ?? [];
    final stops = stopsList
        .map((s) => GtfsStop.fromJson({
              'id': s['name'] as String? ?? '',
              'name': s['name'] as String? ?? '',
              'lat': s['lat'] as num,
              'lon': s['lon'] as num,
            }))
        .toList();

    return RouteDetail(route: route, geometry: geometry, stops: stops);
  }

  @override
  Future<GtfsStop?> getStop(String stopId) async {
    final stops = await getStops();
    return stops.where((s) => s.id == stopId).firstOrNull;
  }

  @override
  Future<List<RoutePattern>> getPatternsForRoute(String routeId) async {
    // The server doesn't expose a patterns endpoint directly.
    // This is used for transit route detail which is handled differently
    // in the remote case.
    return [];
  }

  /// Close the HTTP client.
  void close() {
    _httpClient.close();
  }
}
