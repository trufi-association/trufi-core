import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../utils/polyline_decoder.dart';
import '../../models/plan.dart';
import '../../models/routing_location.dart';
import '../../models/stop.dart';
import '../../models/transit_route.dart';
import '../../models/transport_mode.dart';
import '../routing_provider.dart';
import 'otp_15_preferences.dart';
import 'otp_1_5_response_parser.dart';

/// Routing provider for OpenTripPlanner 1.5.
///
/// OTP 1.5 uses the legacy REST API at /otp/routers/default/plan endpoint.
/// Location format: "lat,lon"
/// Times: milliseconds since epoch
///
/// Transit routes are fetched via the index API:
/// - /otp/routers/default/index/routes
/// - /otp/routers/default/index/patterns/{id}
///
/// Example:
/// ```dart
/// final provider = Otp15RoutingProvider(
///   endpoint: 'https://otp.example.com',
/// );
/// ```
class Otp15RoutingProvider implements IRoutingProvider {
  /// The OTP endpoint URL.
  ///
  /// Can be the base URL (e.g., "https://example.com/otp") or
  /// the full REST endpoint.
  final String endpoint;

  /// Custom display name for this provider.
  final String? displayName;

  /// Custom description for this provider.
  final String? displayDescription;

  /// Optional callback to provide extra HTTP headers per plan request.
  final PlanHeaderProvider? planHeaderProvider;

  /// Optional HTTP client, primarily for testing.
  final http.Client? _injectedHttpClient;

  /// Whether to show the wheelchair accessibility toggle in preferences UI.
  final bool showWheelchairOption;

  Otp15RoutingProvider({
    required this.endpoint,
    this.displayName,
    this.displayDescription,
    this.planHeaderProvider,
    this.showWheelchairOption = true,
    http.Client? httpClient,
  }) : _injectedHttpClient = httpClient;

  late final _prefs = Otp15PreferencesState();

  @override
  String get id => 'otp_1_5';

  @override
  String get name => displayName ?? 'OTP 1.5';

  @override
  String get description =>
      displayDescription ?? 'OpenTripPlanner 1.5 (Online)';

  @override
  bool get supportsTransitRoutes => true;

  @override
  bool get requiresInternet => true;

  @override
  Widget? buildPreferencesUI(BuildContext context) =>
      Otp15Preferences(state: _prefs, showWheelchair: showWheelchairOption);

  @override
  void resetPreferences() => _prefs.reset();

  @override
  Future<void> initialize() async {
    await _prefs.initialize();
  }

  late final http.Client _httpClient = _injectedHttpClient ?? http.Client();

  // --- Plan ---

  @override
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
  }) async {
    final date =
        '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}-${dateTime.year}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    final modes = _prefs.transportModes.map((m) => m.otpName).join(',');

    final queryParams = <String, String>{
      'fromPlace': _formatPlanLocation(from),
      'toPlace': _formatPlanLocation(to),
      'numItineraries': numItineraries.toString(),
      'mode': modes,
      'date': date,
      'time': time,
      if (arriveBy) 'arriveBy': 'true',
    };

    if (_prefs.wheelchair) {
      queryParams['wheelchair'] = 'true';
    }
    queryParams['walkSpeed'] = _prefs.walkSpeed.toString();
    queryParams['walkReluctance'] = _prefs.walkReluctance.toString();
    if (_prefs.maxWalkDistance != null) {
      queryParams['maxWalkDistance'] = _prefs.maxWalkDistance.toString();
    }
    if (_prefs.transportModes.contains(RoutingMode.bicycle)) {
      queryParams['bikeSpeed'] = _prefs.bikeSpeed.toString();
    }

    if (locale != null) {
      queryParams['locale'] = locale;
    }

    final uri = Uri.parse(_restEndpoint).replace(queryParameters: queryParams);

    try {
      final headers = <String, String>{'Accept': 'application/json'};
      if (planHeaderProvider != null) {
        headers.addAll(await planHeaderProvider!(from, to));
      }

      final response = await _httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw Otp15Exception(
          'HTTP error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final error = json['error'] as Map<String, dynamic>?;
      if (error != null) {
        final errorId = error['id'] as int?;
        final errorMsg = error['msg'] as String? ?? 'Unknown error';
        throw Otp15Exception('OTP Error ($errorId): $errorMsg');
      }

      return Otp15ResponseParser.parsePlan(json);
    } on TimeoutException {
      throw Otp15Exception('Request timeout');
    } on FormatException catch (e) {
      throw Otp15Exception('Invalid response format: ${e.message}');
    } on http.ClientException catch (e) {
      throw Otp15Exception('Network error: ${e.message}');
    }
  }

  String _formatPlanLocation(RoutingLocation location) {
    return '${location.position.latitude},${location.position.longitude}';
  }

  // --- Transit routes ---

  @override
  Future<List<TransitRoute>> fetchTransitRoutes() async {
    final results = await Future.wait([
      _getJson('$_indexEndpoint/routes'),
      _getJson('$_indexEndpoint/patterns'),
    ]);

    final routesData = results[0] as List<dynamic>;
    final patternsData = results[1] as List<dynamic>;

    final routeMap = <String, Map<String, dynamic>>{};
    for (final route in routesData) {
      final routeData = route as Map<String, dynamic>;
      final routeId = routeData['id'] as String?;
      if (routeId != null) {
        routeMap[routeId] = routeData;
      }
    }

    final allPatterns = <TransitRoute>[];
    for (final pattern in patternsData) {
      final patternData = pattern as Map<String, dynamic>;
      final patternId = patternData['id'] as String?;
      if (patternId == null) continue;

      var routeId = patternData['routeId'] as String?;
      if (routeId == null) {
        final parts = patternId.split(':');
        if (parts.length >= 2) {
          routeId = parts.sublist(0, parts.length - 1).join(':');
        }
      }
      final routeData = routeId != null ? routeMap[routeId] : null;

      allPatterns.add(
        TransitRoute(
          id: patternId,
          name:
              patternData['desc'] as String? ??
              routeData?['longName'] as String? ??
              '',
          code: patternId,
          route: routeData != null ? _parseRouteInfo(routeData) : null,
        ),
      );
    }

    return allPatterns;
  }

  @override
  Future<TransitRoute?> fetchTransitRouteById(String id) async {
    final patternUrl = '$_indexEndpoint/patterns/$id';
    final geometryUrl = '$_indexEndpoint/patterns/$id/geometry';
    final stopsUrl = '$_indexEndpoint/patterns/$id/stops';

    final results = await Future.wait([
      _getJson(patternUrl),
      _getJson(geometryUrl),
      _getJson(stopsUrl),
    ]);

    final patternData = results[0] as Map<String, dynamic>;
    final geometryData = results[1] as Map<String, dynamic>;
    final stopsData = results[2] as List<dynamic>;

    final encodedPoints = geometryData['points'] as String?;
    final geometry = encodedPoints != null
        ? PolylineDecoder.decode(encodedPoints)
        : <LatLng>[];

    final stops = _parseStops(stopsData);

    TransitRouteInfo? routeInfo;
    var routeId = patternData['routeId'] as String?;
    if (routeId == null) {
      final parts = id.split(':');
      if (parts.length >= 2) {
        routeId = parts.sublist(0, parts.length - 1).join(':');
      }
    }
    if (routeId != null) {
      try {
        final routeUrl = '$_indexEndpoint/routes/$routeId';
        final routeData = await _getJson(routeUrl) as Map<String, dynamic>;
        routeInfo = _parseRouteInfo(routeData);
      } catch (e) {
        // Route info is optional
      }
    }

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

  Future<dynamic> _getJson(String url) async {
    final response = await _httpClient
        .get(Uri.parse(url), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }

    return jsonDecode(response.body);
  }

  // --- Endpoint helpers ---

  String get _restEndpoint {
    if (endpoint.contains('/plan')) {
      return endpoint;
    }
    final base = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;
    return '$base/otp/routers/default/plan';
  }

  late final String _indexEndpoint = _buildIndexEndpoint();

  String _buildIndexEndpoint() {
    var base = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;

    if (base.endsWith('/plan')) {
      base = base.substring(0, base.length - 5);
    }

    if (!base.endsWith('/index')) {
      if (base.endsWith('/otp/routers/default')) {
        base = '$base/index';
      } else if (base.contains('/otp/')) {
        final routerIdx = base.indexOf('/otp/routers/');
        if (routerIdx >= 0) {
          final afterRouter = base.substring(
            routerIdx + '/otp/routers/'.length,
          );
          final routerName = afterRouter.split('/').first;
          base =
              '${base.substring(0, routerIdx)}/otp/routers/$routerName/index';
        } else {
          base = '$base/otp/routers/default/index';
        }
      } else {
        base = '$base/otp/routers/default/index';
      }
    }

    return base;
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Exception thrown by OTP 1.5 operations.
class Otp15Exception implements Exception {
  Otp15Exception(this.message);

  final String message;

  @override
  String toString() => 'Otp15Exception: $message';
}
