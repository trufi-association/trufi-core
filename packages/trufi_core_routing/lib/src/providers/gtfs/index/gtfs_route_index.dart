import 'package:flutter/foundation.dart';

import '../models/gtfs_models.dart';

/// A stop along a route with sequence info.
class RouteStopInfo {
  final String stopId;
  final int sequence;
  final Duration? arrivalTime;
  final Duration? departureTime;

  const RouteStopInfo({
    required this.stopId,
    required this.sequence,
    this.arrivalTime,
    this.departureTime,
  });
}

/// Pattern for a route (sequence of stops).
class RoutePattern {
  final String routeId;
  final String tripId;
  final String? shapeId;
  final String? headsign;
  final List<RouteStopInfo> stops;

  const RoutePattern({
    required this.routeId,
    required this.tripId,
    this.shapeId,
    this.headsign,
    required this.stops,
  });

  /// Get the sequence of stop IDs.
  List<String> get stopIds => stops.map((s) => s.stopId).toList();
}

/// Connection between two routes at a stop.
class RouteConnection {
  final String stopId;
  final String fromRouteId;
  final String toRouteId;
  final int fromStopIndex;
  final int toStopIndex;

  const RouteConnection({
    required this.stopId,
    required this.fromRouteId,
    required this.toRouteId,
    required this.fromStopIndex,
    required this.toStopIndex,
  });
}

/// Index for route-based queries.
class GtfsRouteIndex {
  final Map<String, GtfsRoute> _routes;
  final Map<String, GtfsTrip> _trips;
  final List<GtfsStopTime> _stopTimes;

  /// Route patterns (one per route, using the most common trip pattern).
  late final Map<String, RoutePattern> _patterns;

  /// Routes that pass through each stop.
  late final Map<String, List<String>> _stopToRoutes;

  /// Connections between routes (where they share stops).
  late final Map<String, List<RouteConnection>> _routeConnections;

  GtfsRouteIndex({
    required Map<String, GtfsRoute> routes,
    required Map<String, GtfsTrip> trips,
    required List<GtfsStopTime> stopTimes,
  })  : _routes = routes,
        _trips = trips,
        _stopTimes = stopTimes {
    _buildIndex();
  }

  void _buildIndex() {
    final sw = Stopwatch()..start();

    _buildPatterns();
    _buildStopToRoutes();
    _buildConnections();

    sw.stop();
    debugPrint('GtfsRouteIndex: Built in ${sw.elapsedMilliseconds}ms');
    debugPrint('GtfsRouteIndex: ${_patterns.length} patterns, ${_routeConnections.length} route connections');
  }

  void _buildPatterns() {
    // Group stop times by trip
    final tripStopTimes = <String, List<GtfsStopTime>>{};
    for (final st in _stopTimes) {
      tripStopTimes.putIfAbsent(st.tripId, () => []).add(st);
    }

    // Sort each trip's stop times by sequence
    for (final stopTimes in tripStopTimes.values) {
      stopTimes.sort((a, b) => a.stopSequence.compareTo(b.stopSequence));
    }

    // Group trips by route
    final routeTrips = <String, List<String>>{};
    for (final trip in _trips.values) {
      routeTrips.putIfAbsent(trip.routeId, () => []).add(trip.id);
    }

    // Select representative trip for each route (one with most stops)
    _patterns = {};
    for (final routeEntry in routeTrips.entries) {
      final routeId = routeEntry.key;
      final tripIds = routeEntry.value;

      String? bestTripId;
      int maxStops = 0;

      for (final tripId in tripIds) {
        final stopCount = tripStopTimes[tripId]?.length ?? 0;
        if (stopCount > maxStops) {
          maxStops = stopCount;
          bestTripId = tripId;
        }
      }

      if (bestTripId != null) {
        final trip = _trips[bestTripId]!;
        final stopTimes = tripStopTimes[bestTripId]!;

        _patterns[routeId] = RoutePattern(
          routeId: routeId,
          tripId: bestTripId,
          shapeId: trip.shapeId,
          headsign: trip.headsign,
          stops: stopTimes
              .map((st) => RouteStopInfo(
                    stopId: st.stopId,
                    sequence: st.stopSequence,
                    arrivalTime: st.arrivalTime,
                    departureTime: st.departureTime,
                  ))
              .toList(),
        );
      }
    }
  }

  void _buildStopToRoutes() {
    _stopToRoutes = {};
    for (final pattern in _patterns.values) {
      for (final stop in pattern.stops) {
        _stopToRoutes.putIfAbsent(stop.stopId, () => []).add(pattern.routeId);
      }
    }

    // Remove duplicates
    for (final entry in _stopToRoutes.entries) {
      _stopToRoutes[entry.key] = entry.value.toSet().toList();
    }
  }

  void _buildConnections() {
    _routeConnections = {};

    // For each route, find stops where other routes also pass
    for (final pattern in _patterns.values) {
      final connections = <RouteConnection>[];

      for (var i = 0; i < pattern.stops.length; i++) {
        final stopId = pattern.stops[i].stopId;
        final otherRoutes = _stopToRoutes[stopId] ?? [];

        for (final otherRouteId in otherRoutes) {
          if (otherRouteId == pattern.routeId) continue;

          final otherPattern = _patterns[otherRouteId];
          if (otherPattern == null) continue;

          // Find index in other route
          final otherIndex = otherPattern.stops
              .indexWhere((s) => s.stopId == stopId);
          if (otherIndex == -1) continue;

          connections.add(RouteConnection(
            stopId: stopId,
            fromRouteId: pattern.routeId,
            toRouteId: otherRouteId,
            fromStopIndex: i,
            toStopIndex: otherIndex,
          ));
        }
      }

      _routeConnections[pattern.routeId] = connections;
    }
  }

  /// Get the pattern for a route.
  RoutePattern? getPattern(String routeId) => _patterns[routeId];

  /// Get all route patterns.
  Iterable<RoutePattern> get patterns => _patterns.values;

  /// Get routes that pass through a stop.
  List<String> getRoutesAtStop(String stopId) => _stopToRoutes[stopId] ?? [];

  /// Get connections from a route.
  List<RouteConnection> getConnections(String routeId) =>
      _routeConnections[routeId] ?? [];

  /// Get route by ID.
  GtfsRoute? getRoute(String routeId) => _routes[routeId];

  /// Get all routes.
  Iterable<GtfsRoute> get routes => _routes.values;
}
