import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Trufi Tec vehicle-telemetry client: asks an external fleet-tracking
/// service for the next-vehicle ETA of a set of routes at the rider's origin.
///
/// **CONTRACT NOT CONFIRMED.** Trufi Tec publishes no API documentation (as
/// of 2026-10-13 the only source is issue #1004), so this class implements
/// the request/response below as a documented, configurable guess. Align it
/// with the Trufi Tec team before shipping it to a city; the tolerant parser
/// and the [VehicleEtaProvider] abstraction keep that rework local.
///
/// Request:
/// `GET {endpoint}/eta?lat=<lat>&lon=<lon>&routes=<id,id,...>[&stops=<id,...>]`
/// with `Accept: application/json`, `X-Api-Key: <apiKey>` when set, then the
/// caller's [headers] (caller wins).
///
/// Response (every field but `etas[].routeId` and one of
/// `etaSeconds`/`etaMinutes` is optional; snake_case twins and numeric
/// strings are accepted, see [parseSnapshot]):
/// ```json
/// {
///   "etas": [
///     {
///       "routeId": "1132",
///       "etaSeconds": 240,
///       "vehicleId": "ANH-817",
///       "distanceMeters": 1200,
///       "stopId": "S42",
///       "timestamp": "2026-10-13T10:30:00Z"
///     }
///   ],
///   "timestamp": "2026-10-13T10:30:02Z"
/// }
/// ```
///
/// Every failure (non-2xx status, timeout, network error, non-JSON body)
/// surfaces as a [VehicleEtaException]; the UI maps it to its fallback.
class TrufiTecEtaProvider implements VehicleEtaProvider {
  TrufiTecEtaProvider({
    required this.endpoint,
    this.apiKey,
    this.headers = const {},
    this.timeout = defaultTimeout,
    http.Client? client,
    DateTime Function()? now,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       _now = now ?? DateTime.now;

  static const Duration defaultTimeout = Duration(seconds: 8);

  /// Diagnostic tag written into [VehicleEtaSnapshot.source].
  static const String source = 'trufi_tec';

  /// Header carrying [apiKey].
  static const String apiKeyHeader = 'X-Api-Key';

  /// Path appended to [endpoint].
  static const String etaPath = 'eta';

  /// Epoch values above this are milliseconds, below it seconds (a seconds
  /// epoch stays under 1e12 until the year 33658). A double literal on
  /// purpose: dart2js has no 64-bit integers.
  static const double _epochMillisThreshold = 1e12;

  /// Base URL of the service, e.g. `https://api.trufitec.example/v1`. A
  /// trailing slash is tolerated.
  final String endpoint;

  /// Sent as [apiKeyHeader] when set.
  final String? apiKey;

  /// Extra headers; override the defaults (including `Accept`) on conflict.
  final Map<String, String> headers;

  final Duration timeout;

  final http.Client _client;
  final bool _ownsClient;
  final DateTime Function() _now;

  /// Request URL for [request]. Route and stop ids are sorted so equal
  /// requests produce equal URLs (cache-friendly, deterministic tests).
  Uri buildUri(VehicleEtaRequest request) {
    final base = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;
    final routes = request.routeIds.toList()..sort();
    final stops = request.stopIds?.toList();
    stops?.sort();
    return Uri.parse('$base/$etaPath').replace(
      queryParameters: {
        'lat': request.origin.latitude.toString(),
        'lon': request.origin.longitude.toString(),
        'routes': routes.join(','),
        if (stops != null && stops.isNotEmpty) 'stops': stops.join(','),
      },
    );
  }

  Map<String, String> get _requestHeaders => {
    'Accept': 'application/json',
    apiKeyHeader: ?apiKey,
    ...headers,
  };

  @override
  Future<VehicleEtaSnapshot> fetchEtas(VehicleEtaRequest request) async {
    final uri = buildUri(request);
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: _requestHeaders)
          .timeout(timeout);
    } on TimeoutException catch (e) {
      throw VehicleEtaException(
        'Trufi Tec did not answer within ${timeout.inMilliseconds} ms',
        cause: e,
      );
    } catch (e) {
      throw VehicleEtaException('Trufi Tec request failed', cause: e);
    }
    if (response.statusCode < 200 || response.statusCode > 299) {
      throw VehicleEtaException(
        'Trufi Tec answered HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (e) {
      throw VehicleEtaException(
        'Trufi Tec body is not JSON',
        statusCode: response.statusCode,
        cause: e,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw VehicleEtaException(
        'Trufi Tec body is not a JSON object',
        statusCode: response.statusCode,
      );
    }
    return parseSnapshot(decoded, now: _now());
  }

  /// Closes the HTTP client, only when this instance created it.
  void dispose() {
    if (_ownsClient) _client.close();
  }

  /// Tolerant parser of the response body. Public for tests.
  ///
  /// | field | accepted |
  /// |---|---|
  /// | `etas` | list; missing/null → no estimates |
  /// | `routeId` | also `route_id`, `route`; String or number; missing → item skipped |
  /// | `etaSeconds` | also `eta_seconds`; number or numeric String; else `etaMinutes`/`eta_minutes` × 60; missing or negative → item skipped |
  /// | `vehicleId`, `stopId` | also snake_case; String or number; optional |
  /// | `distanceMeters` | also `distance_meters`; number or numeric String; optional |
  /// | `timestamp` (item) | ISO-8601 String or epoch number (> 1e12 → millis, else seconds); fallback: top-level `timestamp`, then [now] |
  /// | `timestamp` (top) | same rules; fallback [now] → `fetchedAt` |
  static VehicleEtaSnapshot parseSnapshot(
    Map<String, dynamic> json, {
    required DateTime now,
  }) {
    final fetchedAt = _asDateTime(json['timestamp']) ?? now;
    final rawEtas = json['etas'];
    final etas = <VehicleEta>[];
    if (rawEtas is List) {
      for (final item in rawEtas) {
        if (item is! Map) continue;
        final eta = _parseEta(item, fallbackTimestamp: fetchedAt);
        if (eta != null) etas.add(eta);
      }
    }
    return VehicleEtaSnapshot(etas: etas, fetchedAt: fetchedAt, source: source);
  }

  static const _routeKeys = ['routeId', 'route_id', 'route'];
  static const _secondsKeys = ['etaSeconds', 'eta_seconds'];
  static const _minutesKeys = ['etaMinutes', 'eta_minutes'];
  static const _vehicleKeys = ['vehicleId', 'vehicle_id'];
  static const _stopKeys = ['stopId', 'stop_id'];
  static const _distanceKeys = ['distanceMeters', 'distance_meters'];

  static VehicleEta? _parseEta(
    Map<dynamic, dynamic> item, {
    required DateTime fallbackTimestamp,
  }) {
    final routeId = _asString(_firstOf(item, _routeKeys));
    if (routeId == null || routeId.isEmpty) return null;
    final seconds =
        _asNum(_firstOf(item, _secondsKeys)) ??
        _minutesToSeconds(_asNum(_firstOf(item, _minutesKeys)));
    if (seconds == null || seconds < 0) return null;
    return VehicleEta(
      routeId: routeId,
      eta: Duration(milliseconds: (seconds * 1000).round()),
      timestamp: _asDateTime(item['timestamp']) ?? fallbackTimestamp,
      vehicleId: _asString(_firstOf(item, _vehicleKeys)),
      distanceMeters: _asNum(_firstOf(item, _distanceKeys))?.toDouble(),
      stopId: _asString(_firstOf(item, _stopKeys)),
    );
  }

  static num? _minutesToSeconds(num? minutes) =>
      minutes == null ? null : minutes * 60;

  /// First non-null value among [keys], in order of preference.
  static Object? _firstOf(Map<dynamic, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value != null) return value;
    }
    return null;
  }

  /// Number coercion in one place: numbers pass through, numeric strings
  /// are parsed, anything else is null.
  static num? _asNum(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.trim());
    return null;
  }

  static String? _asString(Object? value) {
    if (value is String) return value;
    if (value is num) return value.toString();
    return null;
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is String) return DateTime.tryParse(value);
    if (value is num) {
      if (value <= 0) return null;
      final millis = value > _epochMillisThreshold ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis.round(), isUtc: true);
    }
    return null;
  }
}
