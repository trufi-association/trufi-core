import 'package:latlong2/latlong.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show stripGtfsFeedPrefix;

import '../models/itinerary.dart';
import '../models/itinerary_group.dart';
import '../models/leg.dart';
import '../models/route.dart';
import '../models/transport_mode.dart';

/// Groups redundant itineraries the way Google Maps does (#737).
///
/// The redundancy that matters to a rider is **the same main bus**: transfer
/// searches return many combinations that are really one decision — board
/// route A, then reach the destination with B, C or D. Each combination
/// rendered as its own row makes the list read as "many variants" when the
/// interchangeable connections belong on a single row ("A → B / C").
///
/// Two itineraries belong to the same group when they have the same number
/// of transit legs and the **same first (main) leg**: same route
/// (feed-prefix-agnostic, [stripGtfsFeedPrefix] — OTP emits `1:route_123`
/// while the local planner emits raw GTFS ids, the exact mismatch behind
/// PR #982) boarding and alighting within a walking tolerance (staying on
/// the same bus a couple more stops is still the same option). The legs
/// after the main one are the group's interchangeable options — no further
/// constraint on them: they board where the main leg drops you and end near
/// the destination by construction. Itineraries with a different main route
/// never merge, even from the same stop (product rule, Sam 2026-08-12:
/// "agrupar las redundantes, o sea que tienen el mismo bus principal").
///
/// Grouping only changes presentation, never ranking (#965): groups keep the
/// incoming order of their best member, and `groups.first.representative` is
/// always `itineraries.first` so the cubit's initial selection still points
/// at the first card.
List<ItineraryGroup> groupItineraries(
  List<Itinerary> itineraries, {
  double sameRouteToleranceMeters = 500,
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
    // Ranked order breaks startTime ties so the result is deterministic
    // (Dart's sort is not stable).
    final others =
        memberIndices.skip(1).toList()
          ..sort((a, b) {
            final byTime = itineraries[a].startTime.compareTo(
              itineraries[b].startTime,
            );
            return byTime != 0 ? byTime : a.compareTo(b);
          });
    final othersItineraries = others
        .map((i) => itineraries[i])
        .toList(growable: false);

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
      alternatives: [representative, ...othersItineraries],
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
      // short name — "106 / 106" would be nonsense to a rider. Legs with
      // no display name at all collapse into a single entry too: counting
      // them as distinct would flip the group to "+N options" (and its
      // alt-route badge) on feeds that simply lack route names.
      final key = leg.displayName.isNotEmpty
          ? leg.displayName
          : (_routeKey(leg) ?? '');
      if (seen.add(key)) {
        final route = leg.route ?? Route(shortName: leg.shortName);
        routes.add(route);
      }
    }
    return routes;
  }, growable: false);
}

String _signature(_TransitProfile representative, List<List<Route>> slotRoutes) {
  if (representative.slots.isEmpty) {
    final modes = representative.nonTransitModes.map((m) => m.name).toList()
      ..sort();
    return modes.isEmpty ? 'walk' : modes.join('+');
  }
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
  _TransitProfile(this.slots, this.nonTransitModes);

  factory _TransitProfile.of(Itinerary itinerary) => _TransitProfile(
    itinerary.legs.where((l) => l.transitLeg).toList(),
    itinerary.legs
        .where((l) => !l.transitLeg)
        .map((l) => l.transportMode)
        .toSet(),
  );

  final List<Leg> slots;

  /// Modes of the non-transit legs. Only consulted for zero-slot
  /// itineraries: "walk there" and "bike there" are different options,
  /// not two departures of the same one.
  final Set<TransportMode> nonTransitModes;

  bool matches(
    _TransitProfile other, {
    required double sameRouteToleranceMeters,
  }) {
    if (slots.length != other.slots.length) return false;
    if (slots.isEmpty) {
      return nonTransitModes.length == other.nonTransitModes.length &&
          nonTransitModes.containsAll(other.nonTransitModes);
    }
    // Same main bus = same group. The connections after it are the group's
    // interchangeable options — no constraint on them: they board where the
    // main leg drops you and end near the destination by construction.
    return _mainLegMatches(
      slots.first,
      other.slots.first,
      toleranceMeters: sameRouteToleranceMeters,
    );
  }

  static bool _mainLegMatches(
    Leg a,
    Leg b, {
    required double toleranceMeters,
  }) {
    if (a.transportMode != b.transportMode) return false;

    final keyA = _routeKey(a);
    final keyB = _routeKey(b);
    // A different main route is a different decision — never merged, no
    // matter how close the stops are. Unknown routes fail closed.
    if (keyA == null || keyA != keyB) return false;

    final fromA = a.fromPlace?.latLng;
    final toA = a.toPlace?.latLng;
    final fromB = b.fromPlace?.latLng;
    final toB = b.toPlace?.latLng;
    if (fromA == null || toA == null || fromB == null || toB == null) {
      // Without endpoints the same route is the best evidence available.
      return true;
    }

    // Boarding a couple stops earlier/later is still the same bus.
    return _distance.as(LengthUnit.Meter, fromA, fromB) <= toleranceMeters &&
        _distance.as(LengthUnit.Meter, toA, toB) <= toleranceMeters;
  }
}
