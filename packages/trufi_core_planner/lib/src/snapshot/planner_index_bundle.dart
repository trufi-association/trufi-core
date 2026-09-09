import 'dart:typed_data';

import '../index/gtfs_route_index.dart';
import '../index/gtfs_schedule_index.dart';
import '../index/gtfs_spatial_index.dart';
import '../parser/gtfs_parser.dart';

/// Wall-clock split of [PlannerIndexBundle.build], in milliseconds.
class PlannerBuildTimings {
  /// Zip inflate + CSV parsing into [GtfsData].
  final int parseMs;

  /// [GtfsSpatialIndex] (KD-tree over the stops).
  final int spatialMs;

  /// [GtfsRouteIndex] (patterns, line keys, transfer connections).
  final int routeIndexMs;

  /// [GtfsScheduleIndex] (stop times per stop, trips per route).
  final int scheduleMs;

  const PlannerBuildTimings({
    required this.parseMs,
    required this.spatialMs,
    required this.routeIndexMs,
    required this.scheduleMs,
  });

  int get totalMs => parseMs + spatialMs + routeIndexMs + scheduleMs;

  @override
  String toString() =>
      'parse ${parseMs}ms, spatial ${spatialMs}ms, '
      'index ${routeIndexMs}ms, schedule ${scheduleMs}ms';
}

/// Everything the local planner keeps in memory for one GTFS feed: the
/// parsed data and the three indices built over it.
///
/// [build] is the cold path (parse the zip, build every index — what
/// `TrufiPlannerDataSource` did on every start before #993). A bundle can
/// also come back from a snapshot written by `PlannerIndexCodec`, in which
/// case [buildTimings] is null.
class PlannerIndexBundle {
  final GtfsData data;
  final GtfsSpatialIndex spatialIndex;
  final GtfsRouteIndex routeIndex;
  final GtfsScheduleIndex scheduleIndex;

  /// How long each build phase took; null for a bundle restored from a
  /// snapshot.
  final PlannerBuildTimings? buildTimings;

  const PlannerIndexBundle({
    required this.data,
    required this.spatialIndex,
    required this.routeIndex,
    required this.scheduleIndex,
    this.buildTimings,
  });

  /// Parses [gtfsZip] and builds every index with the given knobs (see
  /// [GtfsRouteIndex.transferRadiusMeters] and
  /// [GtfsRouteIndex.sameNameRouteLimit]).
  static PlannerIndexBundle build(
    Uint8List gtfsZip, {
    double transferRadiusMeters = GtfsRouteIndex.defaultTransferRadiusMeters,
    int sameNameRouteLimit = GtfsRouteIndex.defaultSameNameRouteLimit,
  }) {
    final sw = Stopwatch()..start();
    final data = GtfsParser.parseFromBytes(gtfsZip);
    final parseMs = sw.elapsedMilliseconds;
    sw.reset();
    final spatialIndex = GtfsSpatialIndex(data.stops);
    final spatialMs = sw.elapsedMilliseconds;
    sw.reset();
    final routeIndex = GtfsRouteIndex(
      data,
      spatialIndex: spatialIndex,
      transferRadiusMeters: transferRadiusMeters,
      sameNameRouteLimit: sameNameRouteLimit,
    );
    final routeIndexMs = sw.elapsedMilliseconds;
    sw.reset();
    final scheduleIndex = GtfsScheduleIndex(
      trips: data.trips,
      stopTimes: data.stopTimes,
      calendars: data.calendars,
      calendarDates: data.calendarDates,
      frequencies: data.frequencies,
    );
    final scheduleMs = sw.elapsedMilliseconds;
    return PlannerIndexBundle(
      data: data,
      spatialIndex: spatialIndex,
      routeIndex: routeIndex,
      scheduleIndex: scheduleIndex,
      buildTimings: PlannerBuildTimings(
        parseMs: parseMs,
        spatialMs: spatialMs,
        routeIndexMs: routeIndexMs,
        scheduleMs: scheduleMs,
      ),
    );
  }
}
