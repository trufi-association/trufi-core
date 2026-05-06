import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../utils/polyline_decoder.dart';
import '../../models/itinerary.dart';
import '../../models/leg.dart';
import '../../models/place.dart';
import '../../models/plan.dart';
import '../../models/plan_location.dart';
import '../../models/route.dart' as domain;
import '../../models/routing_location.dart';
import '../../models/stop.dart';
import '../../models/transit_route.dart';
import '../../models/transport_mode.dart';
import '../routing_provider.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';
import 'trufi_planner_config.dart';
import 'trufi_planner_data_source.dart';

/// Below this straight-line distance (meters), offer a walk-only itinerary
/// alongside transit options. The tier-ordering in the home screen lifts it
/// to the top of the list as the preferred option.
const double _walkOnlyThresholdMeters = 1500;

/// Walking speed used to estimate walk durations (m/s). 1.2 m/s ≈ 4.3 km/h
/// matches the existing per-leg walk timing in this provider.
const double _walkSpeedMps = 1.2;

/// Routing provider using TrufiPlanner.
///
/// Supports two modes:
/// - **Local** (mobile): Loads GTFS ZIP from Flutter assets for offline routing
/// - **Remote** (web): Calls trufi-server-planner HTTP API for online routing
///
/// Example (mobile):
/// ```dart
/// TrufiPlannerProvider(
///   config: TrufiPlannerConfig.local(
///     gtfsAsset: 'assets/routing/gtfs.zip',
///   ),
/// )
/// ```
///
/// Example (web):
/// ```dart
/// TrufiPlannerProvider(
///   config: TrufiPlannerConfig.remote(
///     serverUrl: 'https://planner.trufi.dev',
///   ),
/// )
/// ```
class TrufiPlannerProvider extends IRoutingProvider {
  final TrufiPlannerConfig config;
  late final TrufiPlannerDataSource _dataSource;

  TrufiPlannerProvider({required this.config})
    : _dataSource = TrufiPlannerDataSource(config: config);

  @override
  String get id => config.providerId ?? 'trufi_planner';

  @override
  String get name => config.displayName ?? 'Trufi Planner';

  @override
  String get description =>
      config.description ??
      (config.isLocal
          ? 'Funciona offline con datos GTFS empacados en la app'
          : 'Motor de rutas propio servido desde nuestro backend');

  @override
  bool get supportsTransitRoutes => true;

  @override
  bool get requiresInternet => config.isRemote;

  @override
  Widget? buildPreferencesUI(BuildContext context) =>
      _TrufiPlannerInfo(isLocal: config.isLocal);

  @override
  void resetPreferences() {}

  /// Whether data is loaded and ready.
  bool get isLoaded => _dataSource.isLoaded;

  /// Whether data is currently loading.
  bool get isLoading => _dataSource.isLoading;

  /// Status of the data source.
  TrufiPlannerDataStatus get status => _dataSource.status;

  /// Error message if loading failed.
  String? get errorMessage => _dataSource.errorMessage;

  @override
  Future<void> initialize() async {
    await _dataSource.preload();
  }

  /// Access to the underlying data source for advanced queries.
  TrufiPlannerDataSource get dataSource => _dataSource;

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
    if (!_dataSource.isLoaded) {
      await _dataSource.preload();
    }

    if (!_dataSource.isLoaded) {
      return Plan(
        from: _createPlanLocation(from),
        to: _createPlanLocation(to),
        itineraries: [],
        type: 'PLANNER_ERROR',
      );
    }

    final sw = Stopwatch()..start();

    final paths = await _dataSource.client.findRoutes(
      origin: from.position,
      destination: to.position,
      maxWalkDistance: 500.0,
      maxResults: numItineraries,
    );

    sw.stop();
    debugPrint(
      'TrufiPlannerProvider: Found ${paths.length} paths in ${sw.elapsedMilliseconds}ms',
    );

    // Backend ranks transit paths by total distance and applies the
    // direct-vs-transfer bucket rule. Provider only handles walk-only
    // injection; otherwise we trust the backend order.
    final itineraries = paths
        .map((path) => _convertToItinerary(path, from, to, dateTime))
        .toList();

    final straightDistance = _haversineMeters(from.position, to.position);
    if (straightDistance <= _walkOnlyThresholdMeters) {
      itineraries.insert(
        0,
        _buildWalkOnlyItinerary(from, to, dateTime, straightDistance),
      );
    }

    return Plan(
      from: _createPlanLocation(from),
      to: _createPlanLocation(to),
      itineraries: itineraries,
    );
  }

  Itinerary _buildWalkOnlyItinerary(
    RoutingLocation from,
    RoutingLocation to,
    DateTime startTime,
    double distance,
  ) {
    final duration = Duration(seconds: (distance / _walkSpeedMps).round());
    final points = [from.position, to.position];
    final leg = Leg(
      mode: 'WALK',
      distance: distance,
      duration: duration,
      transitLeg: false,
      fromPlace: Place(
        name: from.description,
        lat: from.position.latitude,
        lon: from.position.longitude,
      ),
      toPlace: Place(
        name: to.description,
        lat: to.position.latitude,
        lon: to.position.longitude,
      ),
      encodedPoints: PolylineCodec.encode(points),
      decodedPoints: points,
      startTime: startTime,
      endTime: startTime.add(duration),
    );
    return Itinerary(
      legs: [leg],
      startTime: startTime,
      endTime: startTime.add(duration),
      duration: duration,
      walkDistance: distance,
      walkTime: duration,
      transfers: 0,
    );
  }

  static double _haversineMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * asin(sqrt(h));
  }

  Itinerary _convertToItinerary(
    RoutingPath path,
    RoutingLocation from,
    RoutingLocation to,
    DateTime startTime,
  ) {
    final legs = <Leg>[];
    var currentTime = startTime;

    // Walk to first stop
    if (path.originWalkDistance > 0) {
      final walkDuration = Duration(
        seconds: (path.originWalkDistance / 1.2).round(),
      );
      final walkPoints = [from.position, path.originStop.position];
      legs.add(
        Leg(
          mode: 'WALK',
          distance: path.originWalkDistance,
          duration: walkDuration,
          transitLeg: false,
          fromPlace: Place(
            name: from.description,
            lat: from.position.latitude,
            lon: from.position.longitude,
          ),
          toPlace: Place(
            name: path.originStop.name,
            lat: path.originStop.lat,
            lon: path.originStop.lon,
            stopId: path.originStop.id,
          ),
          encodedPoints: PolylineCodec.encode(walkPoints),
          decodedPoints: walkPoints,
          startTime: currentTime,
          endTime: currentTime.add(walkDuration),
        ),
      );
      currentTime = currentTime.add(walkDuration);
    }

    // Transit segments
    for (final segment in path.segments) {
      final points = segment.shapePoints.isNotEmpty
          ? segment.shapePoints
          : segment.stops.map((s) => s.position).toList();

      final duration =
          segment.scheduledDuration ?? Duration(minutes: segment.stopCount * 2);

      final intermediatePlaces = segment.stops
          .skip(1)
          .take(segment.stops.length - 2)
          .map(
            (stop) => Place(
              name: stop.name,
              lat: stop.lat,
              lon: stop.lon,
              stopId: stop.id,
            ),
          )
          .toList();

      legs.add(
        Leg(
          mode: _routeTypeToMode(segment.route.type).otpName,
          distance: _estimateDistance(points),
          duration: duration,
          transitLeg: true,
          fromPlace: Place(
            name: segment.fromStop.name,
            lat: segment.fromStop.lat,
            lon: segment.fromStop.lon,
            stopId: segment.fromStop.id,
          ),
          toPlace: Place(
            name: segment.toStop.name,
            lat: segment.toStop.lat,
            lon: segment.toStop.lon,
            stopId: segment.toStop.id,
          ),
          encodedPoints: PolylineCodec.encode(points),
          decodedPoints: points,
          startTime: currentTime,
          endTime: currentTime.add(duration),
          route: domain.Route(
            id: segment.route.id,
            gtfsId: segment.route.id,
            shortName: segment.route.shortName,
            longName: segment.route.longName,
            color: segment.route.colorHex,
            textColor: segment.route.textColorHex,
            type: segment.route.type.value,
            mode: _routeTypeToMode(segment.route.type),
          ),
          shortName: segment.route.shortName,
          routeLongName: segment.route.longName,
          headsign: segment.headsign,
          intermediatePlaces: intermediatePlaces,
        ),
      );

      currentTime = currentTime.add(duration);
    }

    // Walk from last stop to destination
    if (path.destinationWalkDistance > 0) {
      final walkDuration = Duration(
        seconds: (path.destinationWalkDistance / 1.2).round(),
      );
      final walkPoints = [path.destinationStop.position, to.position];
      legs.add(
        Leg(
          mode: 'WALK',
          distance: path.destinationWalkDistance,
          duration: walkDuration,
          transitLeg: false,
          fromPlace: Place(
            name: path.destinationStop.name,
            lat: path.destinationStop.lat,
            lon: path.destinationStop.lon,
            stopId: path.destinationStop.id,
          ),
          toPlace: Place(
            name: to.description,
            lat: to.position.latitude,
            lon: to.position.longitude,
          ),
          encodedPoints: PolylineCodec.encode(walkPoints),
          decodedPoints: walkPoints,
          startTime: currentTime,
          endTime: currentTime.add(walkDuration),
        ),
      );
    }

    final totalDuration = legs.fold<Duration>(
      Duration.zero,
      (sum, leg) => sum + leg.duration,
    );

    final totalWalkDistance = legs
        .where((leg) => !leg.transitLeg)
        .fold<double>(0, (sum, leg) => sum + leg.distance);

    final walkTime = Duration(seconds: (totalWalkDistance / 1.2).round());

    return Itinerary(
      legs: legs,
      startTime: startTime,
      endTime: startTime.add(totalDuration),
      duration: totalDuration,
      walkDistance: totalWalkDistance,
      walkTime: walkTime,
      transfers: path.transfers,
    );
  }

  // --- Transit routes ---

  @override
  Future<List<TransitRoute>> fetchTransitRoutes() async {
    if (!_dataSource.isLoaded) {
      await _dataSource.preload();
    }

    if (!_dataSource.isLoaded) return [];

    if (_dataSource.config.isLocal) {
      return _fetchTransitRoutesLocal();
    } else {
      return _fetchTransitRoutesRemote();
    }
  }

  Future<List<TransitRoute>> _fetchTransitRoutesLocal() async {
    final routeIndex = _dataSource.routeIndex;
    if (routeIndex == null) return [];

    final agencyNames = _buildAgencyNameMap();
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

      patterns.add(
        TransitRoute(
          id: pattern.routeId,
          name: pattern.headsign ?? route.longName,
          code: pattern.routeId,
          route: TransitRouteInfo(
            shortName: route.shortName,
            longName: effectiveLongName,
            mode: _routeTypeToMode(route.type),
            color: route.colorHex,
            textColor: route.textColorHex,
            agencyName: agencyNames[route.agencyId],
          ),
        ),
      );
    }

    patterns.sort(
      (a, b) => _compareRouteNames(
        a.route?.shortName ?? a.code,
        b.route?.shortName ?? b.code,
      ),
    );

    return patterns;
  }

  Future<List<TransitRoute>> _fetchTransitRoutesRemote() async {
    final routes = await _dataSource.client.getRoutes();

    final patterns = routes
        .map(
          (route) => TransitRoute(
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
          ),
        )
        .toList();

    patterns.sort(
      (a, b) => _compareRouteNames(
        a.route?.shortName ?? a.code,
        b.route?.shortName ?? b.code,
      ),
    );

    return patterns;
  }

  @override
  Future<TransitRoute?> fetchTransitRouteById(String id) async {
    debugPrint(
      'TrufiPlannerProvider.fetchTransitRouteById: Looking for id=$id',
    );

    if (!_dataSource.isLoaded) {
      await _dataSource.preload();
    }

    if (!_dataSource.isLoaded) {
      throw Exception('Planner data not loaded');
    }

    if (_dataSource.config.isLocal) {
      return _fetchTransitRouteByIdLocal(id);
    } else {
      return _fetchTransitRouteByIdRemote(id);
    }
  }

  Future<TransitRoute> _fetchTransitRouteByIdLocal(String id) async {
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
        agencyName: _buildAgencyNameMap()[route.agencyId],
      ),
      geometry: shape?.polyline,
      stops: stops,
    );
  }

  Map<String, String> _buildAgencyNameMap() {
    final agencies = _dataSource.data?.agencies ?? const [];
    return {for (final a in agencies) a.id: a.name};
  }

  Future<TransitRoute> _fetchTransitRouteByIdRemote(String id) async {
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

  // --- Shared helpers ---

  PlanLocation _createPlanLocation(RoutingLocation location) {
    return PlanLocation(
      name: location.description,
      latitude: location.position.latitude,
      longitude: location.position.longitude,
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

  double _estimateDistance(List<LatLng> points) {
    if (points.length < 2) return 0;
    const distance = Distance();
    double total = 0;
    for (var i = 0; i < points.length - 1; i++) {
      total += distance.as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return total;
  }

  int _compareRouteNames(String a, String b) {
    final numA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), ''));
    final numB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), ''));
    if (numA != null && numB != null) {
      return numA.compareTo(numB);
    }
    return a.compareTo(b);
  }

  /// Clear all loaded data from memory.
  void clear() {
    _dataSource.clear();
  }
}

/// Info card explaining what Trufi Planner is and why its results may differ
/// from OTP-based engines. Shown in the routing settings sheet in place of
/// configurable preferences.
class _TrufiPlannerInfo extends StatelessWidget {
  final bool isLocal;

  const _TrufiPlannerInfo({required this.isLocal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final lines = isLocal
        ? const [
            'Trufi Planner es nuestro motor de rutas propio (no OTP).',
            'En esta versión móvil corre 100% offline, usando los datos GTFS empacados con la app — por eso los resultados pueden diferir de motores online.',
          ]
        : const [
            'Trufi Planner es nuestro motor de rutas propio (no OTP).',
            'Esta versión web consulta nuestro servidor; los resultados pueden diferir de OTP por usar un algoritmo y datos distintos.',
          ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLocal
                    ? Icons.offline_bolt_rounded
                    : Icons.cloud_rounded,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Acerca de Trufi Planner',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final line in lines) ...[
            Text(
              line,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
