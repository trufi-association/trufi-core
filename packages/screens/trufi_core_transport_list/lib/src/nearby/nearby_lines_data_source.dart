import 'package:latlong2/latlong.dart';
import 'package:trufi_core_planner/trufi_core_planner.dart' show GtfsData;
import 'package:trufi_core_routing/trufi_core_routing.dart';

import 'nearby_line.dart';
import 'nearby_lines_service.dart';
import 'nearby_radius.dart';

/// Whether a [NearbyLinesDataSource] can answer right now.
enum NearbyAvailability {
  available,

  /// The feed is being read; [NearbyLinesDataSource.ensureLoaded] completes
  /// when it is ready (or has failed).
  loading,

  /// No offline feed: nothing registered, remote-only planner, or a failed
  /// preload. The screen explains instead of querying.
  missing,
}

/// Where the nearby-lines screen gets its rows from. Implement it to plug a
/// feed that is not the Trufi planner's; the contract is "no network".
abstract class NearbyLinesDataSource {
  NearbyAvailability get availability;

  /// Kicks the load when needed; completes when [availability] is settled
  /// (available or missing). Never throws.
  Future<void> ensureLoaded();

  NearbyLinesResult findNearby(
    LatLng anchor, {
    double maxRadiusMeters = NearbyRadius.maxMeters,
  });

  NearbyLineGeometry? geometryOf(NearbyLine line);
}

/// Default source: the local `TrufiPlannerProvider`'s already-loaded GTFS.
class GtfsNearbyLinesDataSource implements NearbyLinesDataSource {
  GtfsNearbyLinesDataSource({required this.plannerDataSource});

  final TrufiPlannerDataSource plannerDataSource;

  NearbyLinesService? _service;
  GtfsData? _serviceData;

  /// The first local planner among [engines], or null when the app has
  /// none (remote-only or no planner at all).
  static GtfsNearbyLinesDataSource? fromEngines(
    Iterable<IRoutingProvider> engines,
  ) {
    for (final engine in engines) {
      if (engine is TrufiPlannerProvider && engine.config.isLocal) {
        return GtfsNearbyLinesDataSource(plannerDataSource: engine.dataSource);
      }
    }
    return null;
  }

  static const Map<TrufiPlannerDataStatus, NearbyAvailability> _byStatus = {
    TrufiPlannerDataStatus.unloaded: NearbyAvailability.loading,
    TrufiPlannerDataStatus.loading: NearbyAvailability.loading,
    TrufiPlannerDataStatus.loaded: NearbyAvailability.available,
    TrufiPlannerDataStatus.error: NearbyAvailability.missing,
  };

  @override
  NearbyAvailability get availability {
    if (!plannerDataSource.config.isLocal) return NearbyAvailability.missing;
    final byStatus = _byStatus[plannerDataSource.status]!;
    if (byStatus != NearbyAvailability.available) return byStatus;
    return _hasIndexes
        ? NearbyAvailability.available
        : NearbyAvailability.missing;
  }

  bool get _hasIndexes =>
      plannerDataSource.data != null &&
      plannerDataSource.spatialIndex != null &&
      plannerDataSource.routeIndex != null;

  @override
  Future<void> ensureLoaded() async {
    if (!plannerDataSource.config.isLocal || plannerDataSource.isLoaded) return;
    try {
      // Idempotent: joins an in-flight preload started by the routing
      // manager, and loads the feed even when another engine is current.
      await plannerDataSource.preload();
    } catch (_) {
      // Reported through `availability` (status is `error` now).
    }
  }

  @override
  NearbyLinesResult findNearby(
    LatLng anchor, {
    double maxRadiusMeters = NearbyRadius.maxMeters,
  }) {
    final service = _serviceFor(plannerDataSource);
    if (service == null) {
      return NearbyLinesResult(
        anchor: anchor,
        maxRadiusMeters: maxRadiusMeters,
        lines: const [],
      );
    }
    return service.find(anchor, maxRadiusMeters: maxRadiusMeters);
  }

  @override
  NearbyLineGeometry? geometryOf(NearbyLine line) =>
      _serviceFor(plannerDataSource)?.geometryOf(line);

  /// Rebuilt whenever the planner swaps its feed (`clear()` + preload), so a
  /// stale service never answers for data that is gone.
  NearbyLinesService? _serviceFor(TrufiPlannerDataSource source) {
    final data = source.data;
    final spatialIndex = source.spatialIndex;
    final routeIndex = source.routeIndex;
    if (data == null || spatialIndex == null || routeIndex == null) {
      _service = null;
      _serviceData = null;
      return null;
    }
    if (_service == null || !identical(_serviceData, data)) {
      _service = NearbyLinesService(
        data: data,
        spatialIndex: spatialIndex,
        routeIndex: routeIndex,
      );
      _serviceData = data;
    }
    return _service;
  }
}
