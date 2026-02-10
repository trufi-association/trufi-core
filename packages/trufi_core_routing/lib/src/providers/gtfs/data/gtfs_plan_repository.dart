import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/graphql/polyline_decoder.dart';
import '../../../domain/entities/itinerary.dart';
import '../../../domain/entities/leg.dart';
import '../../../domain/entities/place.dart';
import '../../../domain/entities/plan.dart';
import '../../../domain/entities/plan_location.dart';
import '../../../domain/entities/route.dart' as domain;
import '../../../domain/entities/routing_location.dart';
import '../../../domain/entities/routing_preferences.dart';
import '../../../domain/entities/transport_mode.dart';
import '../../../domain/repositories/plan_repository.dart';
import '../gtfs_data_source.dart';
import '../models/gtfs_models.dart';

/// PlanRepository implementation using GTFS data.
class GtfsPlanRepository implements PlanRepository {
  final GtfsDataSource _dataSource;
  GtfsRoutingService? _routingService;

  GtfsPlanRepository({required GtfsDataSource dataSource})
      : _dataSource = dataSource {
    _initRoutingService();
  }

  void _initRoutingService() {
    if (_dataSource.isLoaded &&
        _dataSource.spatialIndex != null &&
        _dataSource.routeIndex != null) {
      _routingService = GtfsRoutingService(
        data: _dataSource.data!,
        spatialIndex: _dataSource.spatialIndex!,
        routeIndex: _dataSource.routeIndex!,
      );
    }
  }

  /// Whether data is loaded.
  bool get isLoaded => _dataSource.isLoaded;

  /// Whether data is loading.
  bool get isLoading => _dataSource.isLoading;

  /// Preload data.
  Future<void> preload() => _dataSource.preload();

  @override
  Future<Plan> fetchPlan({
    required RoutingLocation from,
    required RoutingLocation to,
    int numItineraries = 5,
    String? locale,
    required DateTime dateTime,
    bool arriveBy = false,
    RoutingPreferences? preferences,
  }) async {
    // Ensure data is loaded
    if (!_dataSource.isLoaded) {
      await _dataSource.preload();
    }

    if (!_dataSource.isLoaded) {
      return Plan(
        from: _createPlanLocation(from),
        to: _createPlanLocation(to),
        itineraries: [],
        type: 'GTFS_ERROR',
      );
    }

    // Ensure routing service is initialized after preload
    if (_routingService == null) {
      _initRoutingService();
    }

    if (_routingService == null) {
      debugPrint('GtfsPlanRepository: ERROR - routing service not initialized');
      return Plan(
        from: _createPlanLocation(from),
        to: _createPlanLocation(to),
        itineraries: [],
        type: 'GTFS_ERROR',
      );
    }

    final sw = Stopwatch()..start();

    final maxWalkDistance = preferences?.maxWalkDistance ?? 500.0;

    final paths = _routingService!.findRoutes(
      origin: from.position,
      destination: to.position,
      maxWalkDistance: maxWalkDistance,
      maxResults: numItineraries,
    );

    sw.stop();
    debugPrint(
        'GtfsPlanRepository: Found ${paths.length} paths in ${sw.elapsedMilliseconds}ms');

    if (paths.isEmpty) {
      return Plan(
        from: _createPlanLocation(from),
        to: _createPlanLocation(to),
        itineraries: [],
      );
    }

    // Convert paths to itineraries
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
      final walkDuration =
          Duration(seconds: (path.originWalkDistance / 1.2).round());
      final walkPoints = [from.position, path.originStop.position];
      legs.add(Leg(
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
      ));
      currentTime = currentTime.add(walkDuration);
    }

    // Transit segments
    for (final segment in path.segments) {
      // Use shape from segment (resolved by routing service),
      // fallback to stop positions
      final points = segment.shapePoints.isNotEmpty
          ? segment.shapePoints
          : segment.stops.map((s) => s.position).toList();

      // Use scheduled duration from GTFS, fallback to estimation
      final duration = segment.scheduledDuration ??
          Duration(minutes: segment.stopCount * 2);

      // Get intermediate places (stops between from and to)
      final intermediatePlaces = segment.stops
          .skip(1) // Skip first stop
          .take(segment.stops.length - 2) // Skip last stop
          .map((stop) => Place(
                name: stop.name,
                lat: stop.lat,
                lon: stop.lon,
                stopId: stop.id,
              ))
          .toList();

      legs.add(Leg(
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
          color: _colorToHex(segment.route.flutterColor),
          textColor: _colorToHex(segment.route.flutterTextColor),
          type: segment.route.type.value,
          mode: _routeTypeToMode(segment.route.type),
        ),
        shortName: segment.route.shortName,
        routeLongName: segment.route.longName,
        headsign: segment.headsign,
        intermediatePlaces: intermediatePlaces,
      ));

      currentTime = currentTime.add(duration);
    }

    // Walk from last stop to destination
    if (path.destinationWalkDistance > 0) {
      final walkDuration =
          Duration(seconds: (path.destinationWalkDistance / 1.2).round());
      final walkPoints = [path.destinationStop.position, to.position];
      legs.add(Leg(
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
      ));
    }

    // Calculate totals
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

  PlanLocation _createPlanLocation(RoutingLocation location) {
    return PlanLocation(
      name: location.description,
      latitude: location.position.latitude,
      longitude: location.position.longitude,
    );
  }

  String? _colorToHex(Color? color) {
    if (color == null) return null;
    // Convert ARGB to RGB hex string (without alpha)
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '$r$g$b'.toUpperCase();
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

  /// Calculate total distance along a path of points (in meters).
  double _estimateDistance(List<LatLng> points) {
    if (points.length < 2) return 0;

    const distance = Distance();
    double total = 0;
    for (var i = 0; i < points.length - 1; i++) {
      total += distance.as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return total;
  }

}
