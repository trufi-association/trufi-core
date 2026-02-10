import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart';

import 'trufi_planner_config.dart';

/// Status of the data source.
enum TrufiPlannerDataStatus {
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

/// Data source for TrufiPlannerProvider.
///
/// Manages a [PlannerRoutingClient] that can be either local or remote,
/// and provides convenience methods for accessing data.
class TrufiPlannerDataSource {
  final TrufiPlannerConfig config;
  late final PlannerRoutingClient _client;

  // Local-only state (for schedule index, shapes, etc.)
  GtfsData? _localData;
  GtfsScheduleIndex? _scheduleIndex;

  TrufiPlannerDataStatus _status = TrufiPlannerDataStatus.unloaded;
  String? _errorMessage;
  Completer<void>? _preloadCompleter;

  TrufiPlannerDataSource({required this.config}) {
    if (config.isRemote) {
      _client = RemotePlannerClient(serverUrl: config.serverUrl!);
    } else {
      _client = LocalPlannerClient();
    }
  }

  /// The underlying routing client.
  PlannerRoutingClient get client => _client;

  /// Current loading status.
  TrufiPlannerDataStatus get status => _status;

  /// Whether data is loaded and ready.
  bool get isLoaded => _status == TrufiPlannerDataStatus.loaded;

  /// Whether data is currently loading.
  bool get isLoading => _status == TrufiPlannerDataStatus.loading;

  /// Error message if loading failed.
  String? get errorMessage => _errorMessage;

  /// Schedule index (local mode only).
  GtfsScheduleIndex? get scheduleIndex => _scheduleIndex;

  /// Route index (local mode only).
  GtfsRouteIndex? get routeIndex {
    final client = _client;
    return client is LocalPlannerClient ? client.routeIndex : null;
  }

  /// Spatial index (local mode only).
  GtfsSpatialIndex? get spatialIndex {
    final client = _client;
    return client is LocalPlannerClient ? client.spatialIndex : null;
  }

  /// Raw GTFS data (local mode only).
  GtfsData? get data => _localData;

  /// Preload data. Call at app startup.
  Future<void> preload() async {
    if (_status == TrufiPlannerDataStatus.loaded) return;

    if (_status == TrufiPlannerDataStatus.loading && _preloadCompleter != null) {
      return _preloadCompleter!.future;
    }

    _status = TrufiPlannerDataStatus.loading;
    _errorMessage = null;
    _preloadCompleter = Completer<void>();

    try {
      if (config.isLocal) {
        await _preloadLocal();
      } else {
        await _preloadRemote();
      }

      _status = TrufiPlannerDataStatus.loaded;
      _preloadCompleter!.complete();
    } catch (e, st) {
      debugPrint('TrufiPlannerDataSource: Error loading: $e');
      debugPrint('$st');
      _errorMessage = e.toString();
      _status = TrufiPlannerDataStatus.error;
      _preloadCompleter!.completeError(e, st);
    }
  }

  Future<void> _preloadLocal() async {
    debugPrint('TrufiPlannerDataSource: Preloading local from ${config.gtfsAsset}');
    final sw = Stopwatch()..start();

    final bytes = await rootBundle.load(config.gtfsAsset!);
    final assetData = bytes.buffer.asUint8List();

    final result = await compute(_loadAndBuildInIsolate, assetData);

    _localData = result.data;
    _scheduleIndex = result.scheduleIndex;

    final localClient = _client as LocalPlannerClient;
    localClient.loadFromParsed(
      data: result.data,
      spatialIndex: result.spatialIndex,
      routeIndex: result.routeIndex,
    );

    sw.stop();
    debugPrint('TrufiPlannerDataSource: Preloaded in ${sw.elapsedMilliseconds}ms');
  }

  Future<void> _preloadRemote() async {
    debugPrint('TrufiPlannerDataSource: Connecting to ${config.serverUrl}');
    await _client.initialize();
    debugPrint('TrufiPlannerDataSource: Remote server ready');
  }

  static _GtfsLoadResult _loadAndBuildInIsolate(Uint8List assetData) {
    final data = GtfsParser.parseFromBytes(assetData);
    final spatialIndex = GtfsSpatialIndex(data.stops);
    final routeIndex = GtfsRouteIndex(data);
    final scheduleIndex = GtfsScheduleIndex(
      trips: data.trips,
      stopTimes: data.stopTimes,
      calendars: data.calendars,
      calendarDates: data.calendarDates,
      frequencies: data.frequencies,
    );

    return _GtfsLoadResult(
      data: data,
      spatialIndex: spatialIndex,
      routeIndex: routeIndex,
      scheduleIndex: scheduleIndex,
    );
  }

  // === Convenience methods ===

  GtfsStop? getStop(String stopId) => _localData?.stops[stopId];

  GtfsRoute? getRoute(String routeId) => _localData?.routes[routeId];

  GtfsShape? getShape(String shapeId) => _localData?.shapes[shapeId];

  List<NearbyStop> findNearestStops(
    LatLng location, {
    int maxResults = 10,
    double maxDistance = 500,
  }) {
    return spatialIndex?.findNearestStops(
          location,
          maxResults: maxResults,
          maxDistance: maxDistance,
        ) ??
        [];
  }

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

  RouteFrequencyInfo? getRouteFrequency(String routeId) {
    return _scheduleIndex?.getRouteFrequency(routeId);
  }

  /// Clear all loaded data.
  void clear() {
    final client = _client;
    if (client is LocalPlannerClient) {
      client.clear();
    }
    _localData = null;
    _scheduleIndex = null;
    _status = TrufiPlannerDataStatus.unloaded;
    _errorMessage = null;
  }
}
