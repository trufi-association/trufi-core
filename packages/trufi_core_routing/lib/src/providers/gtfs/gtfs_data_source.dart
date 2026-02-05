import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'index/gtfs_route_index.dart';
import 'index/gtfs_schedule_index.dart';
import 'index/gtfs_spatial_index.dart';
import 'models/gtfs_models.dart';
import 'parser/gtfs_parser.dart';

/// Status of the GTFS data source.
enum GtfsDataStatus {
  unloaded,
  loading,
  loaded,
  error,
}

/// Main data source for GTFS data.
/// Handles loading, indexing, and provides unified access to all GTFS data.
class GtfsDataSource {
  final String assetPath;

  GtfsData? _data;
  GtfsSpatialIndex? _spatialIndex;
  GtfsRouteIndex? _routeIndex;
  GtfsScheduleIndex? _scheduleIndex;

  GtfsDataStatus _status = GtfsDataStatus.unloaded;
  String? _errorMessage;

  GtfsDataSource({required this.assetPath});

  /// Current loading status.
  GtfsDataStatus get status => _status;

  /// Whether data is loaded and ready.
  bool get isLoaded => _status == GtfsDataStatus.loaded;

  /// Whether data is currently loading.
  bool get isLoading => _status == GtfsDataStatus.loading;

  /// Error message if loading failed.
  String? get errorMessage => _errorMessage;

  /// Raw GTFS data.
  GtfsData? get data => _data;

  /// Spatial index for stop queries.
  GtfsSpatialIndex? get spatialIndex => _spatialIndex;

  /// Route index for route queries.
  GtfsRouteIndex? get routeIndex => _routeIndex;

  /// Schedule index for time-based queries.
  GtfsScheduleIndex? get scheduleIndex => _scheduleIndex;

  /// Preload GTFS data. Call this at app startup for offline routing.
  Future<void> preload() async {
    if (_status == GtfsDataStatus.loaded || _status == GtfsDataStatus.loading) {
      return;
    }

    _status = GtfsDataStatus.loading;
    _errorMessage = null;

    try {
      debugPrint('GtfsDataSource: Preloading from $assetPath');
      final sw = Stopwatch()..start();

      // Parse GTFS
      _data = await GtfsParser.parseFromAsset(assetPath);

      // Build indices
      _buildIndices();

      sw.stop();
      debugPrint('GtfsDataSource: Preloaded in ${sw.elapsedMilliseconds}ms');

      _status = GtfsDataStatus.loaded;
    } catch (e, st) {
      debugPrint('GtfsDataSource: Error loading: $e');
      debugPrint('$st');
      _errorMessage = e.toString();
      _status = GtfsDataStatus.error;
    }
  }

  void _buildIndices() {
    if (_data == null) return;

    final sw = Stopwatch()..start();

    // Build spatial index
    _spatialIndex = GtfsSpatialIndex(_data!.stops);
    debugPrint('GtfsDataSource: Spatial index built');

    // Build route index
    _routeIndex = GtfsRouteIndex(
      routes: _data!.routes,
      trips: _data!.trips,
      stopTimes: _data!.stopTimes,
    );
    debugPrint('GtfsDataSource: Route index built');

    // Build schedule index
    _scheduleIndex = GtfsScheduleIndex(
      trips: _data!.trips,
      stopTimes: _data!.stopTimes,
      calendars: _data!.calendars,
      calendarDates: _data!.calendarDates,
      frequencies: _data!.frequencies,
    );
    debugPrint('GtfsDataSource: Schedule index built');

    sw.stop();
    debugPrint('GtfsDataSource: All indices built in ${sw.elapsedMilliseconds}ms');
  }

  // === Convenience methods ===

  /// Get a stop by ID.
  GtfsStop? getStop(String stopId) => _data?.stops[stopId];

  /// Get a route by ID.
  GtfsRoute? getRoute(String routeId) => _data?.routes[routeId];

  /// Get a trip by ID.
  GtfsTrip? getTrip(String tripId) => _data?.trips[tripId];

  /// Get a shape by ID.
  GtfsShape? getShape(String shapeId) => _data?.shapes[shapeId];

  /// Get all routes.
  Iterable<GtfsRoute> get routes => _data?.routes.values ?? [];

  /// Get all stops.
  Iterable<GtfsStop> get stops => _data?.stops.values ?? [];

  /// Find nearest stops to a location.
  List<NearbyStop> findNearestStops(
    LatLng location, {
    int maxResults = 10,
    double maxDistance = 500,
  }) {
    return _spatialIndex?.findNearestStops(
          location,
          maxResults: maxResults,
          maxDistance: maxDistance,
        ) ??
        [];
  }

  /// Get routes at a stop.
  List<GtfsRoute> getRoutesAtStop(String stopId) {
    final routeIds = _routeIndex?.getRoutesAtStop(stopId) ?? [];
    return routeIds
        .map((id) => _data?.routes[id])
        .whereType<GtfsRoute>()
        .toList();
  }

  /// Get next departures from a stop.
  List<StopDeparture> getNextDepartures(
    String stopId, {
    DateTime? atTime,
    int limit = 5,
  }) {
    return _scheduleIndex?.getNextDepartures(
          stopId,
          atTime: atTime,
          limit: limit,
        ) ??
        [];
  }

  /// Get frequency info for a route.
  RouteFrequencyInfo? getRouteFrequency(String routeId) {
    return _scheduleIndex?.getRouteFrequency(routeId);
  }

  /// Clear all loaded data.
  void clear() {
    _data = null;
    _spatialIndex = null;
    _routeIndex = null;
    _scheduleIndex = null;
    _status = GtfsDataStatus.unloaded;
    _errorMessage = null;
  }
}
