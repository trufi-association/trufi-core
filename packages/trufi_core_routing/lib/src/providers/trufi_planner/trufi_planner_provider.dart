import 'package:flutter/widgets.dart';
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
import 'trufi_planner_preferences.dart';

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
class TrufiPlannerProvider implements IRoutingProvider {
  final TrufiPlannerConfig config;
  late final TrufiPlannerDataSource _dataSource;

  TrufiPlannerProvider({required this.config})
    : _dataSource = TrufiPlannerDataSource(config: config);

  late final _prefs = TrufiPlannerPreferencesState();

  @override
  String get id => config.providerId ?? 'trufi_planner';

  @override
  String get name =>
      config.displayName ??
      (config.isLocal ? 'Offline (GTFS)' : 'Online (Planner)');

  @override
  String get description =>
      config.description ??
      (config.isLocal
          ? 'Routing sin conexión usando datos GTFS'
          : 'Routing en línea usando Trufi Planner');

  @override
  bool get supportsTransitRoutes => true;

  @override
  bool get requiresInternet => config.isRemote;

  @override
  Widget? buildPreferencesUI(BuildContext context) =>
      TrufiPlannerPreferences(state: _prefs);

  @override
  void resetPreferences() => _prefs.reset();

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
    await _prefs.initialize();
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
    final maxWalkDistance = _prefs.maxWalkDistance ?? 500.0;

    final paths = await _dataSource.client.findRoutes(
      origin: from.position,
      destination: to.position,
      maxWalkDistance: maxWalkDistance,
      maxResults: numItineraries,
    );

    sw.stop();
    debugPrint(
      'TrufiPlannerProvider: Found ${paths.length} paths in ${sw.elapsedMilliseconds}ms',
    );

    if (paths.isEmpty) {
      return Plan(
        from: _createPlanLocation(from),
        to: _createPlanLocation(to),
        itineraries: [],
      );
    }

    final itineraries = paths
        .map((path) => _convertToItinerary(path, from, to, dateTime))
        .toList();

    return Plan(
      from: _createPlanLocation(from),
      to: _createPlanLocation(to),
      itineraries: itineraries,
    );
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
      ),
      geometry: shape?.polyline,
      stops: stops,
    );
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
