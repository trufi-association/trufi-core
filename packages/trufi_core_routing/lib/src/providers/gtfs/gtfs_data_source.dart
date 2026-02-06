import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

/// Result of loading GTFS data with indices (for isolate communication).
class _GtfsLoadResult {
  final GtfsData data;
  final GtfsSpatialIndex spatialIndex;
  final GtfsRouteIndex routeIndex;
  final GtfsScheduleIndex scheduleIndex;

  const _GtfsLoadResult({
    required this.data,
    required this.spatialIndex,
    required this.routeIndex,
    required this.scheduleIndex,
  });
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

  /// Completer to track ongoing preload operation.
  Completer<void>? _preloadCompleter;

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
  ///
  /// If already loading, waits for the ongoing operation to complete.
  /// If already loaded, returns immediately.
  Future<void> preload() async {
    // Already loaded
    if (_status == GtfsDataStatus.loaded) {
      return;
    }

    // Already loading - wait for it to complete
    if (_status == GtfsDataStatus.loading && _preloadCompleter != null) {
      return _preloadCompleter!.future;
    }

    // Start loading
    _status = GtfsDataStatus.loading;
    _errorMessage = null;
    _preloadCompleter = Completer<void>();

    try {
      debugPrint('GtfsDataSource: Preloading from $assetPath');
      final sw = Stopwatch()..start();

      // Load asset bytes on main thread (required by rootBundle)
      final bytes = await rootBundle.load(assetPath);
      final assetData = bytes.buffer.asUint8List();

      // Parse GTFS and build ALL indices in isolate to avoid blocking UI
      final result = await compute(_loadAndBuildInIsolate, assetData);

      _data = result.data;
      _spatialIndex = result.spatialIndex;
      _routeIndex = result.routeIndex;
      _scheduleIndex = result.scheduleIndex;

      sw.stop();
      debugPrint('GtfsDataSource: Preloaded in ${sw.elapsedMilliseconds}ms');

      _status = GtfsDataStatus.loaded;
      _preloadCompleter!.complete();
    } catch (e, st) {
      debugPrint('GtfsDataSource: Error loading: $e');
      debugPrint('$st');
      _errorMessage = e.toString();
      _status = GtfsDataStatus.error;
      _preloadCompleter!.completeError(e, st);
    }
  }

  /// Load and build all indices in an isolate to avoid blocking the UI thread.
  static _GtfsLoadResult _loadAndBuildInIsolate(Uint8List assetData) {
    final totalSw = Stopwatch()..start();

    // Parse GTFS
    final data = GtfsParser.parseFromBytes(assetData);

    // Build indices
    final spatialIndex = GtfsSpatialIndex(data.stops);
    final routeIndex = GtfsRouteIndex(
      routes: data.routes,
      trips: data.trips,
      stopTimes: data.stopTimes,
    );
    final scheduleIndex = GtfsScheduleIndex(
      trips: data.trips,
      stopTimes: data.stopTimes,
      calendars: data.calendars,
      calendarDates: data.calendarDates,
      frequencies: data.frequencies,
    );

    totalSw.stop();
    debugPrint('GtfsDataSource: Total isolate work in ${totalSw.elapsedMilliseconds}ms');

    return _GtfsLoadResult(
      data: data,
      spatialIndex: spatialIndex,
      routeIndex: routeIndex,
      scheduleIndex: scheduleIndex,
    );
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
