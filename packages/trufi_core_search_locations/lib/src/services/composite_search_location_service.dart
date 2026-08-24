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
/// - results are **interleaved** round-robin across [services] (first
///   result of each, then second of each, …) so no source can push the
///   others below the fold — with streets offline and places online, the
///   old source-by-source concatenation buried every place under up to
///   ten street rows on a phone screen (#984). Ties inside a round keep
///   the order of [services] (put the offline one first if junctions
///   should lead);
/// - duplicates are merged: same id, or same display name within
///   `max(`[nearDuplicateEpsilon]`, `[dedupeEpsilon]`)` per axis —
///   geocoders return the same POI or street several times a few blocks
///   apart, and those near-copies used to eat the result budget (#984).
///   The earliest arrival keeps the slot, except that a drillable row
///   (an offline street with corners) always wins over a plain pin;
/// - [reverse] returns the first non-null answer, in order.
class CompositeSearchLocationService
    with SearchLocationDrillDown, LanguageAwareSearch
    implements SearchLocationService {
  final List<SearchLocationService> services;

  /// How long to wait for each service before dropping its results.
  final Duration timeout;

  /// Legacy floor for the near-duplicate radius: the effective radius is
  /// `max(nearDuplicateEpsilon, dedupeEpsilon)` per axis, so with the
  /// defaults this field is inert. Passing `nearDuplicateEpsilon: 0`
  /// restores the old exact-spot-only merging (~1e-5 ≈ 1 m).
  final double dedupeEpsilon;

  /// Results with the same display name closer than this (in degrees,
  /// ~2e-3 ≈ 220 m) are treated as near-copies of one place and merged.
  final double nearDuplicateEpsilon;

  CompositeSearchLocationService({
    required this.services,
    this.timeout = const Duration(seconds: 8),
    this.dedupeEpsilon = 1e-5,
    this.nearDuplicateEpsilon = 2e-3,
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
    var round = 0;
    var anyRemaining = true;
    while (anyRemaining) {
      anyRemaining = false;
      for (final results in perService) {
        if (round >= results.length) continue;
        anyRemaining = true;
        final result = results[round];
        final dup = _indexOfDuplicate(merged, result);
        if (dup < 0) {
          merged.add(result);
        } else if (canDrillDown(result) && !canDrillDown(merged[dup])) {
          // Keep the richer row: a drillable street (with its corners)
          // must not be swallowed by a plain pin for the same place that
          // happened to arrive in an earlier round.
          merged[dup] = result;
        }
      }
      round++;
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

  /// Forwards the app language to every child that can localize its
  /// results (#945); language-unaware children are left alone.
  @override
  set searchLanguage(String? languageCode) {
    for (final service in services) {
      if (service is LanguageAwareSearch) {
        (service as LanguageAwareSearch).searchLanguage = languageCode;
      }
    }
  }

  @override
  void dispose() {
    for (final service in services) {
      service.dispose();
    }
  }

  /// Index in [merged] of an entry this candidate duplicates, or -1.
  int _indexOfDuplicate(List<SearchLocation> merged, SearchLocation candidate) {
    for (var i = 0; i < merged.length; i++) {
      final existing = merged[i];
      if (existing.id == candidate.id) return i;
      final sameName =
          existing.displayName.trim().toLowerCase() ==
          candidate.displayName.trim().toLowerCase();
      if (!sameName) continue;
      final epsilon = nearDuplicateEpsilon > dedupeEpsilon
          ? nearDuplicateEpsilon
          : dedupeEpsilon;
      final nearby =
          (existing.latitude - candidate.latitude).abs() < epsilon &&
          (existing.longitude - candidate.longitude).abs() < epsilon;
      if (nearby) return i;
    }
    return -1;
  }
}
