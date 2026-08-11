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
  final Future<String?> Function()? deviceIdProvider;
  final http.Client _httpClient;
  bool _isReady = false;

  RemotePlannerClient({
    required this.serverUrl,
    this.deviceIdProvider,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _buildHeaders([Map<String, String>? base]) async {
    final headers = <String, String>{...?base};
    final provider = deviceIdProvider;
    if (provider != null) {
      final deviceId = await provider();
      if (deviceId != null && deviceId.isNotEmpty) {
        headers['X-Device-Id'] = deviceId;
      }
    }
    return headers;
  }

  String get _baseUrl => serverUrl.endsWith('/')
      ? serverUrl.substring(0, serverUrl.length - 1)
      : serverUrl;

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/health'),
      headers: await _buildHeaders(),
    );
    if (response.statusCode == 200) {
      _isReady = true;
    } else {
      throw Exception('Server health check failed: ${response.statusCode}');
    }
  }

  @override
  Future<List<RoutingPath>> findRoutes({
    required LatLng origin,
    required LatLng destination,
    double maxWalkDistance = 800,
    int maxResults = 5,
    int maxStopCandidates = 150,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/plan'),
      headers: await _buildHeaders({'Content-Type': 'application/json'}),
      body: jsonEncode({
        'from': {'lat': origin.latitude, 'lon': origin.longitude},
        'to': {'lat': destination.latitude, 'lon': destination.longitude},
        // Forward the requested result count so an app-level override
        // reaches the server (older servers ignore unknown fields; the
        // planner server clamps it to its own limits).
        'maxResults': maxResults,
        'maxWalkDistance': maxWalkDistance,
        'maxStopCandidates': maxStopCandidates,
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
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/routes'),
      headers: await _buildHeaders(),
    );
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List;
    return routes
        .map((r) => GtfsRoute.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Fetch routes along with their patterns and resolved agency name.
  ///
  /// Backends that haven't been updated yet still respond to /routes with
  /// only the base GtfsRoute fields — in that case the returned entries
  /// have an empty `patterns` list and `agencyName: null`, so callers can
  /// gracefully fall back to one-entry-per-route behavior.
  Future<List<RouteWithPatterns>> getRoutesWithPatterns() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/routes'),
      headers: await _buildHeaders(),
    );
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List;
    return routes.map((raw) {
      final r = raw as Map<String, dynamic>;
      final route = GtfsRoute.fromJson(r);
      final patternsJson = r['patterns'] as List? ?? const [];
      final patterns = patternsJson
          .map(
            (p) => RemoteRoutePatternInfo.fromJson(p as Map<String, dynamic>),
          )
          .toList();
      return RouteWithPatterns(
        route: route,
        agencyName: r['agencyName'] as String?,
        patterns: patterns,
      );
    }).toList();
  }

  @override
  Future<List<GtfsStop>> getStops({int? limit}) async {
    final uri = limit != null
        ? Uri.parse('$_baseUrl/stops?limit=$limit')
        : Uri.parse('$_baseUrl/stops');
    final response = await _httpClient.get(uri, headers: await _buildHeaders());
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
    final response = await _httpClient.get(
      Uri.parse(
        '$_baseUrl/stops/nearby'
        '?lat=${location.latitude}'
        '&lon=${location.longitude}'
        '&maxDistance=$maxDistance'
        '&maxResults=$maxResults',
      ),
      headers: await _buildHeaders(),
    );
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
      headers: await _buildHeaders(),
    );
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final route = GtfsRoute.fromJson(data);

    final geometryList = data['geometry'] as List? ?? [];
    final geometry = geometryList
        .map(
          (p) => LatLng(
            (p['lat'] as num).toDouble(),
            (p['lon'] as num).toDouble(),
          ),
        )
        .toList();

    final stopsList = data['stops'] as List? ?? [];
    final stops = stopsList
        .map(
          (s) => GtfsStop.fromJson({
            'id': s['name'] as String? ?? '',
            'name': s['name'] as String? ?? '',
            'lat': s['lat'] as num,
            'lon': s['lon'] as num,
          }),
        )
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

/// One pattern of a route as exposed by trufi-server-planner's /routes
/// endpoint (after the agencyName/patterns enrichment).
class RemoteRoutePatternInfo {
  final int id;
  final String? headsign;
  final String? firstStop;
  final String? lastStop;

  const RemoteRoutePatternInfo({
    required this.id,
    this.headsign,
    this.firstStop,
    this.lastStop,
  });

  factory RemoteRoutePatternInfo.fromJson(Map<String, dynamic> json) {
    return RemoteRoutePatternInfo(
      id: (json['id'] as num).toInt(),
      headsign: json['headsign'] as String?,
      firstStop: json['firstStop'] as String?,
      lastStop: json['lastStop'] as String?,
    );
  }
}

/// A route plus the extra metadata trufi-server-planner can attach
/// when it has been updated: resolved agency name and per-route trip
/// patterns. Older backends return entries with `patterns: []` and
/// `agencyName: null`, which callers should treat as the legacy
/// "one entry per route" mode.
class RouteWithPatterns {
  final GtfsRoute route;
  final String? agencyName;
  final List<RemoteRoutePatternInfo> patterns;

  const RouteWithPatterns({
    required this.route,
    this.agencyName,
    required this.patterns,
  });
}
