import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:trufi_core_planner/trufi_core_planner.dart';

import '../../models/service_hours.dart';
import '../../models/service_hours_lookup.dart';
import 'planner_index_store.dart';
import 'trufi_planner_config.dart';

/// Status of the data source.
enum TrufiPlannerDataStatus { unloaded, loading, loaded, error }

/// Where the last local preload got its planner index from (#993).
enum PlannerIndexSource {
  /// Parsed the GTFS and built every index (first start, changed feed,
  /// unreadable or stale snapshot, or persistence disabled).
  built,

  /// Restored the snapshot written by an earlier start.
  cache,
}

/// Diagnostics of the last local preload — what the one-line log prints
/// and what tests assert on.
class PlannerIndexLoadInfo {
  final PlannerIndexSource source;

  /// Content fingerprint of the GTFS asset (the cache key).
  final String fingerprint;

  /// Wall-clock milliseconds inside the loading isolate.
  final int totalMs;

  /// [PlannerIndexBundle.build] split; null when loaded from the cache.
  final PlannerBuildTimings? buildTimings;

  /// Reading the snapshot file; 0 when there was none to read.
  final int readMs;

  /// Decoding the snapshot; 0 when none was decoded.
  final int decodeMs;

  /// Encoding the fresh build for the cache; 0 when nothing was encoded.
  final int encodeMs;

  /// Size of the snapshot read or written, bytes; 0 when neither happened.
  final int snapshotBytes;

  /// Why an existing snapshot was not used (stale fingerprint, other
  /// version, corrupt…); null when there was none or it was used.
  final String? rejectedBecause;

  const PlannerIndexLoadInfo({
    required this.source,
    required this.fingerprint,
    required this.totalMs,
    this.buildTimings,
    this.readMs = 0,
    this.decodeMs = 0,
    this.encodeMs = 0,
    this.snapshotBytes = 0,
    this.rejectedBecause,
  });

  String get _mb => (snapshotBytes / 1e6).toStringAsFixed(1);

  @override
  String toString() {
    switch (source) {
      case PlannerIndexSource.cache:
        return 'planner index loaded from cache in ${totalMs}ms '
            '(read ${readMs}ms, decode ${decodeMs}ms; snapshot $_mb MB, '
            'fingerprint $fingerprint)';
      case PlannerIndexSource.built:
        final why = rejectedBecause == null
            ? ''
            : '; cache rejected: $rejectedBecause';
        final cached = snapshotBytes == 0
            ? ''
            : '; snapshot $_mb MB encoded in ${encodeMs}ms';
        return 'planner index built in ${totalMs}ms '
            '($buildTimings$cached$why; fingerprint $fingerprint)';
    }
  }
}

/// Input for [_loadOrBuildInIsolate] (for isolate communication).
class _GtfsLoadRequest {
  final Uint8List bytes;
  final double transferRadiusMeters;
  final int sameNameRouteLimit;

  /// Snapshot file to read and, after a build, to refresh; null disables
  /// persistence (config opt-out, web, or no cache directory).
  final String? snapshotPath;

  const _GtfsLoadRequest({
    required this.bytes,
    required this.transferRadiusMeters,
    required this.sameNameRouteLimit,
    required this.snapshotPath,
  });
}

/// Result of loading GTFS data with indices (for isolate communication).
class _GtfsLoadResult {
  final PlannerIndexBundle bundle;
  final PlannerIndexLoadInfo info;

  /// Fresh snapshot to write to [_GtfsLoadRequest.snapshotPath]; null when
  /// the index came from the cache or is not persisted.
  final Uint8List? snapshot;

  const _GtfsLoadResult({
    required this.bundle,
    required this.info,
    this.snapshot,
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
  PlannerIndexLoadInfo? _lastIndexLoad;
  Future<void>? _pendingSnapshotWrite;

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

  /// How the last local preload obtained its index (built or from the
  /// persisted snapshot) and how long each step took; null before the first
  /// local preload and in remote mode.
  PlannerIndexLoadInfo? get lastIndexLoad => _lastIndexLoad;

  /// The snapshot write started by the last preload, if any. The planner is
  /// ready before the write finishes; await this to know the file is on
  /// disk (tests, or a caller that wants to measure).
  Future<void>? get pendingSnapshotWrite => _pendingSnapshotWrite;

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
    final assetData = bytes.buffer.asUint8List(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );

    // The snapshot lives in the app's cache directory (#993). Resolving the
    // path is a platform-channel call, so it happens here on the root
    // isolate and travels to the worker as a plain string.
    String? snapshotPath;
    if (config.persistIndex) {
      try {
        snapshotPath = await plannerIndexCachePath(config.gtfsAsset!);
      } catch (e) {
        debugPrint(
          'TrufiPlannerDataSource: no cache directory for the planner '
          'index ($e); building without persistence',
        );
      }
    }

    final result = await compute(
      _loadOrBuildInIsolate,
      _GtfsLoadRequest(
        bytes: assetData,
        transferRadiusMeters: config.transferRadiusMeters,
        sameNameRouteLimit: config.sameNameRouteLimit,
        snapshotPath: snapshotPath,
      ),
    );

    final bundle = result.bundle;
    _localData = bundle.data;
    _scheduleIndex = bundle.scheduleIndex;
    _lastIndexLoad = result.info;

    final localClient = _client as LocalPlannerClient;
    localClient.loadFromParsed(
      data: bundle.data,
      spatialIndex: bundle.spatialIndex,
      routeIndex: bundle.routeIndex,
    );

    sw.stop();
    debugPrint(
      'TrufiPlannerDataSource: Preloaded in ${sw.elapsedMilliseconds}ms — '
      '${result.info}',
    );

    // Persist the fresh build without holding the planner back: the write
    // is asynchronous file I/O and its failure only costs the next start a
    // rebuild.
    final snapshot = result.snapshot;
    if (snapshot != null && snapshotPath != null) {
      _pendingSnapshotWrite = _writeSnapshot(snapshotPath, snapshot);
    }
  }

  Future<void> _writeSnapshot(String path, Uint8List snapshot) async {
    final sw = Stopwatch()..start();
    try {
      await writePlannerIndex(path, snapshot);
      debugPrint(
        'TrufiPlannerDataSource: planner index snapshot written '
        '(${(snapshot.length / 1e6).toStringAsFixed(1)} MB in '
        '${sw.elapsedMilliseconds}ms) to $path',
      );
    } catch (e) {
      debugPrint(
        'TrufiPlannerDataSource: could not write the planner index snapshot '
        '($e); the next start will build again',
      );
    }
  }

  Future<void> _preloadRemote() async {
    debugPrint('TrufiPlannerDataSource: Connecting to ${config.serverUrl}');
    await _client.initialize();
    debugPrint('TrufiPlannerDataSource: Remote server ready');
  }

  /// Worker-isolate body: restore the snapshot when it matches this GTFS
  /// and these knobs, otherwise parse + build (and encode the result so the
  /// root isolate can persist it). Never throws because of the cache.
  static _GtfsLoadResult _loadOrBuildInIsolate(_GtfsLoadRequest request) {
    final sw = Stopwatch()..start();
    final fingerprint = PlannerIndexCodec.fingerprint(request.bytes);
    final path = request.snapshotPath;

    var readMs = 0;
    String? rejectedBecause;
    if (path != null) {
      final readSw = Stopwatch()..start();
      final snapshot = readPlannerIndexSync(path);
      readMs = readSw.elapsedMilliseconds;
      if (snapshot != null) {
        final decodeSw = Stopwatch()..start();
        final bundle = PlannerIndexCodec.decode(
          snapshot,
          fingerprint: fingerprint,
          transferRadiusMeters: request.transferRadiusMeters,
          sameNameRouteLimit: request.sameNameRouteLimit,
          onReject: (reason) => rejectedBecause = reason,
        );
        if (bundle != null) {
          return _GtfsLoadResult(
            bundle: bundle,
            info: PlannerIndexLoadInfo(
              source: PlannerIndexSource.cache,
              fingerprint: fingerprint,
              totalMs: sw.elapsedMilliseconds,
              readMs: readMs,
              decodeMs: decodeSw.elapsedMilliseconds,
              snapshotBytes: snapshot.length,
            ),
          );
        }
      }
    }

    final bundle = PlannerIndexBundle.build(
      request.bytes,
      transferRadiusMeters: request.transferRadiusMeters,
      sameNameRouteLimit: request.sameNameRouteLimit,
    );

    Uint8List? snapshot;
    var encodeMs = 0;
    if (path != null) {
      final encodeSw = Stopwatch()..start();
      try {
        snapshot = PlannerIndexCodec.encode(bundle, fingerprint: fingerprint);
      } on PlannerIndexEncodeException catch (e) {
        // Not representable — keep the in-memory build, skip the cache.
        rejectedBecause = 'not cacheable: ${e.message}';
      }
      encodeMs = encodeSw.elapsedMilliseconds;
    }

    return _GtfsLoadResult(
      bundle: bundle,
      snapshot: snapshot,
      info: PlannerIndexLoadInfo(
        source: PlannerIndexSource.built,
        fingerprint: fingerprint,
        totalMs: sw.elapsedMilliseconds,
        buildTimings: bundle.buildTimings,
        readMs: readMs,
        encodeMs: encodeMs,
        snapshotBytes: snapshot?.length ?? 0,
        rejectedBecause: rejectedBecause,
      ),
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
    _lastIndexLoad = null;
  }
}
