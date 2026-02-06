import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../domain/entities/stop.dart';
import '../../domain/entities/transit_route.dart';
import '../../domain/entities/transport_mode.dart';
import '../../domain/repositories/transit_route_repository.dart';
import '../graphql/polyline_decoder.dart';

/// OTP 1.5 implementation of [TransitRouteRepository] using REST API.
///
/// OTP 1.5 REST API endpoints used:
/// - `/otp/routers/default/index/routes` - list all routes
/// - `/otp/routers/default/index/patterns` - list all patterns
/// - `/otp/routers/default/index/patterns/{patternId}` - pattern details
/// - `/otp/routers/default/index/patterns/{patternId}/geometry` - geometry
/// - `/otp/routers/default/index/patterns/{patternId}/stops` - stops
///
/// [fetchPatterns] makes 2 parallel requests (routes + patterns).
/// [fetchPatternById] makes 4 requests (pattern + geometry + stops + route).
class Otp15TransitRouteRepository implements TransitRouteRepository {
  Otp15TransitRouteRepository({
    required String endpoint,
    http.Client? httpClient,
  })  : _baseEndpoint = _normalizeEndpoint(endpoint),
        _httpClient = httpClient ?? http.Client();

  final String _baseEndpoint;
  final http.Client _httpClient;

  static String _normalizeEndpoint(String endpoint) {
    // Remove trailing slash
    var base = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;

    // Remove /plan suffix if present (convert plan endpoint to index endpoint)
    if (base.endsWith('/plan')) {
      base = base.substring(0, base.length - 5);
    }

    // Ensure we have the index path
    if (!base.endsWith('/index')) {
      if (base.endsWith('/otp/routers/default')) {
        base = '$base/index';
      } else if (base.contains('/otp/')) {
        // Try to find the router path and append index
        final routerIdx = base.indexOf('/otp/routers/');
        if (routerIdx >= 0) {
          final afterRouter = base.substring(routerIdx + '/otp/routers/'.length);
          final routerName = afterRouter.split('/').first;
          base = '${base.substring(0, routerIdx)}/otp/routers/$routerName/index';
        } else {
          base = '$base/otp/routers/default/index';
        }
      } else {
        base = '$base/otp/routers/default/index';
      }
    }

    return base;
  }

  @override
  Future<List<TransitRoute>> fetchPatterns() async {
    // Fetch routes and patterns in parallel (2 requests total)
    final results = await Future.wait([
      _get('$_baseEndpoint/routes'),
      _get('$_baseEndpoint/patterns'),
    ]);

    final routesData = results[0] as List<dynamic>;
    final patternsData = results[1] as List<dynamic>;

    // Build route lookup map
    final routeMap = <String, Map<String, dynamic>>{};
    for (final route in routesData) {
      final routeData = route as Map<String, dynamic>;
      final routeId = routeData['id'] as String?;
      if (routeId != null) {
        routeMap[routeId] = routeData;
      }
    }

    // Map patterns to TransitRoute with route info
    final allPatterns = <TransitRoute>[];
    for (final pattern in patternsData) {
      final patternData = pattern as Map<String, dynamic>;
      final patternId = patternData['id'] as String?;
      if (patternId == null) continue;

      // Get routeId from pattern data or extract from pattern ID
      var routeId = patternData['routeId'] as String?;
      if (routeId == null) {
        // Pattern ID format: "routeId:patternIndex" - extract routeId
        final parts = patternId.split(':');
        if (parts.length >= 2) {
          routeId = parts.sublist(0, parts.length - 1).join(':');
        }
      }
      final routeData = routeId != null ? routeMap[routeId] : null;

      allPatterns.add(TransitRoute(
        id: patternId,
        name: patternData['desc'] as String? ?? routeData?['longName'] as String? ?? '',
        code: patternId,
        route: routeData != null ? _parseRouteInfo(routeData) : null,
      ));
    }

    return allPatterns;
  }

  @override
  Future<TransitRoute> fetchPatternById(String id) async {
    // Fetch pattern info, geometry and stops in parallel
    final patternUrl = '$_baseEndpoint/patterns/$id';
    final geometryUrl = '$_baseEndpoint/patterns/$id/geometry';
    final stopsUrl = '$_baseEndpoint/patterns/$id/stops';

    final results = await Future.wait([
      _get(patternUrl),
      _get(geometryUrl),
      _get(stopsUrl),
    ]);

    final patternData = results[0] as Map<String, dynamic>;
    final geometryData = results[1] as Map<String, dynamic>;
    final stopsData = results[2] as List<dynamic>;

    // Parse geometry (encoded polyline)
    final encodedPoints = geometryData['points'] as String?;
    final geometry = encodedPoints != null
        ? PolylineDecoder.decode(encodedPoints)
        : <LatLng>[];

    // Parse stops
    final stops = _parseStops(stopsData);

    // Get route info (need to fetch from route endpoint)
    // In OTP 1.5, routeId may be in pattern data or extracted from pattern ID
    // Pattern ID format is typically: "routeId:patternIndex" (e.g., "1:102:0")
    TransitRouteInfo? routeInfo;
    var routeId = patternData['routeId'] as String?;
    if (routeId == null) {
      // Extract routeId from pattern ID by removing the last segment
      final parts = id.split(':');
      if (parts.length >= 2) {
        routeId = parts.sublist(0, parts.length - 1).join(':');
      }
    }
    if (routeId != null) {
      try {
        final routeUrl = '$_baseEndpoint/routes/$routeId';
        final routeData = await _get(routeUrl) as Map<String, dynamic>;
        routeInfo = _parseRouteInfo(routeData);
      } catch (e) {
        // Route info is optional
      }
    }

    // Remove duplicate adjacent stops (same workaround as OTP 2.4)
    final newListStops = <Stop>[];
    if (stops.isNotEmpty) {
      newListStops.add(stops.first);
      for (final stop in stops) {
        if (stop.name != newListStops.last.name) {
          newListStops.add(stop);
        }
      }
    }

    return TransitRoute(
      id: id,
      name: patternData['desc'] as String? ?? '',
      code: id,
      route: routeInfo,
      geometry: geometry,
      stops: newListStops,
    );
  }

  TransitRouteInfo _parseRouteInfo(Map<String, dynamic> json) {
    final modeStr = json['mode'] as String?;
    return TransitRouteInfo(
      shortName: json['shortName'] as String?,
      longName: json['longName'] as String?,
      mode: modeStr != null ? TransportModeExtension.fromString(modeStr) : null,
      color: json['color'] as String?,
      textColor: json['textColor'] as String?,
    );
  }

  List<Stop> _parseStops(List<dynamic> stopsData) {
    return stopsData.map((s) {
      final json = s as Map<String, dynamic>;
      return Stop(
        name: json['name'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lon: (json['lon'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  Future<dynamic> _get(String url) async {
    final response = await _httpClient.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }

    return jsonDecode(response.body);
  }

  /// Closes the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
