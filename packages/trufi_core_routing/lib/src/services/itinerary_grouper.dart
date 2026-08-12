import 'package:latlong2/latlong.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show stripGtfsFeedPrefix;

import '../models/itinerary.dart';
import '../models/itinerary_group.dart';
import '../models/leg.dart';
import '../models/route.dart';

/// Groups near-duplicate itineraries the way Google Maps does (#737).
///
/// Transfer searches return many combinations that are really one decision:
/// take route A, then reach the destination with B, C or D — the shared leg
/// is identical and only the other slot differs (or the mirrored case). Each
/// combination rendered as its own row makes the list read as "many variants"
/// when the interchangeable options belong on a single row ("A → B / C").
///
/// Two itineraries belong to the same group when they have the same sequence
/// of transit slots and each slot covers the same segment: boarding and
/// alighting points within a walking tolerance. The tolerance is wider when
/// the slot is served by the same route on both sides (staying on the same
/// bus a couple more stops is still the same option) and narrower across
/// different routes (they must truly share the transfer point). Routes are
/// compared feed-prefix-agnostically ([stripGtfsFeedPrefix]) because the
/// providers disagree on the prefix: OTP emits `1:route_123` while the local
/// planner emits raw GTFS ids (the exact mismatch behind PR #982).
///
/// Grouping only changes presentation, never ranking (#965): groups keep the
/// incoming order of their best member, and `groups.first.representative` is
/// always `itineraries.first` so the cubit's initial selection still points
/// at the first card.
List<ItineraryGroup> groupItineraries(
  List<Itinerary> itineraries, {
  double sameRouteToleranceMeters = 500,
  // Calibrated against real OTP 1.5 plans over the Cochabamba GTFS: 300 m
  // merges the corridor cases (P+106 / P+120 / 138+120 sharing every stop
  // area) while boarding points a block apart (~304 m) stay separate.
  double differentRouteToleranceMeters = 300,
}) {
  if (itineraries.isEmpty) return const [];

  final profiles = itineraries.map(_TransitProfile.of).toList(growable: false);

  // Pairwise matching with union-find: the metric tolerance is not
  // transitive, union-find absorbs that (A~B and B~C chain into one group).
  final parent = List<int>.generate(itineraries.length, (i) => i);
  int find(int i) {
    var root = i;
    while (parent[root] != root) {
      root = parent[root];
    }
    while (parent[i] != root) {
      final next = parent[i];
      parent[i] = root;
      i = next;
    }
    return root;
  }

  for (var a = 0; a < profiles.length; a++) {
    for (var b = a + 1; b < profiles.length; b++) {
      if (find(a) == find(b)) continue;
      if (profiles[a].matches(
        profiles[b],
        sameRouteToleranceMeters: sameRouteToleranceMeters,
        differentRouteToleranceMeters: differentRouteToleranceMeters,
      )) {
        parent[find(b)] = find(a);
      }
    }
  }

  // Collect members per root, keeping the incoming (ranked) order.
  final membersByRoot = <int, List<int>>{};
  for (var i = 0; i < itineraries.length; i++) {
    membersByRoot.putIfAbsent(find(i), () => []).add(i);
  }
  final orderedGroups = membersByRoot.values.toList()
    ..sort((a, b) => a.first.compareTo(b.first));

  final seenSignatures = <String>{};
  return orderedGroups.map((memberIndices) {
    final representative = itineraries[memberIndices.first];
    final others =
        memberIndices.skip(1).map((i) => itineraries[i]).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final slotRoutes = _collectSlotRoutes(
      memberIndices.map((i) => profiles[i]).toList(growable: false),
    );

    var signature = _signature(profiles[memberIndices.first], slotRoutes);
    // Same structure can repeat when stops sit beyond tolerance but share
    // rounded coordinates — disambiguate so the UI's expansion Set (keyed
    // by signature) never toggles two groups at once.
    while (!seenSignatures.add(signature)) {
      signature = '$signature+';
    }

    return ItineraryGroup(
      representative: representative,
      alternatives: [representative, ...others],
      signature: signature,
      slotRoutes: slotRoutes,
    );
  }).toList(growable: false);
}

/// The distinct routes serving each transit slot across the group's members,
/// in member (ranked) order — what the card renders as "106 / 120".
List<List<Route>> _collectSlotRoutes(List<_TransitProfile> members) {
  if (members.first.slots.isEmpty) return const [];
  return List.generate(members.first.slots.length, (slot) {
    final routes = <Route>[];
    final seen = <String>{};
    for (final member in members) {
      final leg = member.slots[slot];
      // Dedup by what the chip will show: GTFS feeds commonly model one
      // line as several route_ids (direction/service variants) sharing a
      // short name — "106 / 106" would be nonsense to a rider.
      final key = leg.displayName.isNotEmpty
          ? leg.displayName
          : (_routeKey(leg) ?? '');
      if (key.isEmpty || seen.add(key)) {
        final route = leg.route ?? Route(shortName: leg.shortName);
        routes.add(route);
      }
    }
    return routes;
  }, growable: false);
}

String _signature(_TransitProfile representative, List<List<Route>> slotRoutes) {
  if (representative.slots.isEmpty) return 'walk';
  return List.generate(representative.slots.length, (i) {
    final leg = representative.slots[i];
    final routes = slotRoutes[i]
        .map((r) => stripGtfsFeedPrefix(r.gtfsId ?? r.id ?? r.shortName ?? ''))
        .join('/');
    return '${leg.transportMode.name}:$routes'
        ':${_placeKey(leg.fromPlace?.stopId, leg.fromPlace?.latLng)}'
        ':${_placeKey(leg.toPlace?.stopId, leg.toPlace?.latLng)}';
  }).join('|');
}

String _placeKey(String? stopId, LatLng? position) {
  if (stopId != null && stopId.isNotEmpty) return stripGtfsFeedPrefix(stopId);
  if (position == null) return '?';
  return '${position.latitude.toStringAsFixed(4)},'
      '${position.longitude.toStringAsFixed(4)}';
}

String? _routeKey(Leg leg) {
  final id = leg.route?.gtfsId ?? leg.route?.id;
  if (id != null && id.isNotEmpty) return stripGtfsFeedPrefix(id);
  final shortName = leg.route?.shortName ?? leg.shortName;
  if (shortName != null && shortName.isNotEmpty) return shortName;
  return null;
}

const _distance = Distance();

/// An itinerary reduced to its transit legs (walk legs carry no identity
/// for grouping — they only connect the slots).
class _TransitProfile {
  _TransitProfile(this.slots);

  factory _TransitProfile.of(Itinerary itinerary) =>
      _TransitProfile(itinerary.legs.where((l) => l.transitLeg).toList());

  final List<Leg> slots;

  bool matches(
    _TransitProfile other, {
    required double sameRouteToleranceMeters,
    required double differentRouteToleranceMeters,
  }) {
    if (slots.length != other.slots.length) return false;
    // Zero transit slots = walk-only: one option regardless of path.
    for (var i = 0; i < slots.length; i++) {
      if (!_slotMatches(
        slots[i],
        other.slots[i],
        sameRouteToleranceMeters: sameRouteToleranceMeters,
        differentRouteToleranceMeters: differentRouteToleranceMeters,
      )) {
        return false;
      }
    }
    return true;
  }

  static bool _slotMatches(
    Leg a,
    Leg b, {
    required double sameRouteToleranceMeters,
    required double differentRouteToleranceMeters,
  }) {
    if (a.transportMode != b.transportMode) return false;

    final keyA = _routeKey(a);
    final keyB = _routeKey(b);
    final sameRoute = keyA != null && keyA == keyB;

    final fromA = a.fromPlace?.latLng;
    final toA = a.toPlace?.latLng;
    final fromB = b.fromPlace?.latLng;
    final toB = b.toPlace?.latLng;
    if (fromA == null || toA == null || fromB == null || toB == null) {
      // Without both endpoints the segment can't be compared — only the
      // exact same route is safe to call the same option.
      return sameRoute;
    }

    final tolerance = sameRoute
        ? sameRouteToleranceMeters
        : differentRouteToleranceMeters;
    return _distance.as(LengthUnit.Meter, fromA, fromB) <= tolerance &&
        _distance.as(LengthUnit.Meter, toA, toB) <= tolerance;
  }
}
