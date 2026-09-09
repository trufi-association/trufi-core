import 'package:trufi_core_planner/trufi_core_planner.dart';

/// The shared-stop connection table computed by brute force from the
/// public API, independently of [GtfsRouteIndex]'s build: for every pattern
/// P and every position of P, one entry per other pattern Q serving that
/// stop whose line differs from P's — the table the planner has always had.
///
/// Sorted `'P myStopIdx Q otherStopIdx'` lines, so two tables compare with
/// plain list equality (missing, extra and duplicate entries all fail).
List<String> sharedStopTable(GtfsRouteIndex index) {
  final table = <String>[];
  for (var p = 0; p < index.patternCount; p++) {
    final pattern = index.patternById(p);
    final line = index.lineKeyForRoute(pattern.routeId);
    for (var idx = 0; idx < pattern.stopIds.length; idx++) {
      final stopId = pattern.stopIds[idx];
      for (final other in index.getPatternsAtStop(stopId)) {
        if (other.id == p) continue;
        if (index.lineKeyForRoute(other.routeId) == line) continue;
        table.add('$p $idx ${other.id} ${other.indexOfStop(stopId)}');
      }
    }
  }
  return table..sort();
}

/// The walk-0 entries of the index's connection table, in the same format
/// as [sharedStopTable].
List<String> walkZeroTable(GtfsRouteIndex index) {
  final table = <String>[];
  for (var p = 0; p < index.patternCount; p++) {
    for (final c in index.getConnectionsFor(p)) {
      if (c.walkMeters == 0) {
        table.add('$p ${c.myStopIdx} ${c.otherPatternId} ${c.otherStopIdx}');
      }
    }
  }
  return table..sort();
}
