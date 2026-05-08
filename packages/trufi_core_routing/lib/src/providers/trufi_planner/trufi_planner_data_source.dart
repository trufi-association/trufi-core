import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:trufi_core_planner/trufi_core_planner.dart';

import '../../models/service_hours.dart';
import '../../models/service_hours_lookup.dart';
import 'trufi_planner_config.dart';

/// Status of the data source.
enum TrufiPlannerDataStatus { unloaded, loading, loaded, error }

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
class TrufiPlannerDataSource implements ServiceHoursLookup {
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

  /// Resolve [routeId] → [ServiceHours] using the bundled GTFS feed.
  ///
  /// Tolerant of OTP-style `feedId:routeId` ids: tries the literal id
  /// first, then falls back to the suffix after `:`. Returns null when
  /// the route, its calendar, or its frequencies are missing — the UI
  /// then suppresses the indicator instead of rendering half-empty.
  @override
  ServiceHours? serviceHoursForRouteId(String routeId) {
    final data = _localData;
    if (data == null) return null;
    final candidates = <String>{
      routeId,
      if (routeId.contains(':')) routeId.split(':').last,
    };
    GtfsTrip? trip;
    for (final t in data.trips.values) {
      if (candidates.contains(t.routeId)) {
        trip = t;
        break;
      }
    }
    if (trip == null) return null;
    final calendar = data.calendars[trip.serviceId];
    if (calendar == null) return null;
    final days = <int>{
      if (calendar.monday) DateTime.monday,
      if (calendar.tuesday) DateTime.tuesday,
      if (calendar.wednesday) DateTime.wednesday,
      if (calendar.thursday) DateTime.thursday,
      if (calendar.friday) DateTime.friday,
      if (calendar.saturday) DateTime.saturday,
      if (calendar.sunday) DateTime.sunday,
    };
    if (days.isEmpty) return null;

    Duration? minStart;
    Duration? maxEnd;
    for (final f in data.frequencies) {
      if (f.tripId != trip.id) continue;
      if (minStart == null || f.startTime < minStart) minStart = f.startTime;
      if (maxEnd == null || f.endTime > maxEnd) maxEnd = f.endTime;
    }
    if (minStart == null || maxEnd == null) return null;

    return ServiceHours(
      daysOfWeek: days,
      startTime: TimeOfDay(
        hour: minStart.inHours % 24,
        minute: minStart.inMinutes % 60,
      ),
      endTime: TimeOfDay(
        hour: maxEnd.inHours % 24,
        minute: maxEnd.inMinutes % 60,
      ),
    );
  }

  /// Preload data. Call at app startup.
  Future<void> preload() async {
    if (_status == TrufiPlannerDataStatus.loaded) return;

    if (_status == TrufiPlannerDataStatus.loading &&
        _preloadCompleter != null) {
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
    debugPrint(
      'TrufiPlannerDataSource: Preloading local from ${config.gtfsAsset}',
    );
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
    debugPrint(
      'TrufiPlannerDataSource: Preloaded in ${sw.elapsedMilliseconds}ms',
    );
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
