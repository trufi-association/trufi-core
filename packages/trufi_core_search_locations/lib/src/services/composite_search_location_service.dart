import 'dart:async';

import '../models/search_location.dart';
import 'search_location_service.dart';

/// Runs several search services together and merges their results.
///
/// The point is that they answer different questions: the offline street
/// data knows the city's streets and the corners between them, while an
/// online geocoder knows places, businesses and addresses and stays
/// fresher. Cities that have both should offer both — that's what this
/// composes (trufi-core#745).
///
/// Behaviour worth knowing:
/// - services are queried **concurrently**; a service that fails or times
///   out is skipped, so losing the network degrades to offline results
///   instead of an error screen;
/// - results keep the order of [services] (put the offline one first if
///   junctions should lead), deduplicated by coordinates so the same
///   place found twice appears once;
/// - [reverse] returns the first non-null answer, in order.
class CompositeSearchLocationService
    with SearchLocationDrillDown
    implements SearchLocationService {
  final List<SearchLocationService> services;

  /// How long to wait for each service before dropping its results.
  final Duration timeout;

  /// Coordinates closer than this (in degrees, ~1e-5 ≈ 1 m) are treated as
  /// the same place when merging.
  final double dedupeEpsilon;

  CompositeSearchLocationService({
    required this.services,
    this.timeout = const Duration(seconds: 8),
    this.dedupeEpsilon = 1e-5,
  }) : assert(services.isNotEmpty, 'at least one service is required');

  @override
  Future<List<SearchLocation>> search(String query) async {
    final futures = services.map((s) async {
      try {
        return await s.search(query).timeout(timeout);
      } catch (_) {
        // One source failing must not take the whole search down.
        return const <SearchLocation>[];
      }
    });

    final perService = await Future.wait(futures);
    final merged = <SearchLocation>[];
    for (final results in perService) {
      for (final result in results) {
        if (!_alreadyPresent(merged, result)) merged.add(result);
      }
    }
    return merged;
  }

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) async {
    for (final service in services) {
      try {
        final result = await service.reverse(latitude, longitude).timeout(
          timeout,
        );
        if (result != null) return result;
      } catch (_) {
        // Try the next one.
      }
    }
    return null;
  }

  /// Forwards the street → corners flow (#745) to whichever child
  /// service knows the location's inner points; results keep working
  /// unchanged when no child does.
  @override
  bool canDrillDown(SearchLocation location) =>
      _drillDownServiceFor(location) != null;

  @override
  Future<List<SearchLocation>> drillDown(SearchLocation location) {
    final service = _drillDownServiceFor(location);
    if (service == null) return Future.value(const <SearchLocation>[]);
    return service.drillDown(location);
  }

  SearchLocationDrillDown? _drillDownServiceFor(SearchLocation location) {
    for (final service in services) {
      if (service is SearchLocationDrillDown) {
        final candidate = service as SearchLocationDrillDown;
        if (candidate.canDrillDown(location)) return candidate;
      }
    }
    return null;
  }

  @override
  void dispose() {
    for (final service in services) {
      service.dispose();
    }
  }

  bool _alreadyPresent(List<SearchLocation> merged, SearchLocation candidate) {
    for (final existing in merged) {
      if (existing.id == candidate.id) return true;
      final sameSpot =
          (existing.latitude - candidate.latitude).abs() < dedupeEpsilon &&
          (existing.longitude - candidate.longitude).abs() < dedupeEpsilon;
      if (sameSpot &&
          existing.displayName.toLowerCase() ==
              candidate.displayName.toLowerCase()) {
        return true;
      }
    }
    return false;
  }
}
