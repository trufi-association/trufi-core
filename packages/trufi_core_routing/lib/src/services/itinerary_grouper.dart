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
/// of transit legs and the **same main bus**: the first transit leg carries
/// the same rider-facing route name (GTFS models one line as several
/// route_ids — to the rider the 110 is the 110; unnamed feeds fall back to
/// the feed-prefix-agnostic route id, [stripGtfsFeedPrefix], the mismatch
/// behind PR #982) boarding within a walking tolerance. Only the BOARDING
/// identifies the main bus — where you get off it belongs to the connection
/// you chose, and the legs after the main one are the group's
/// interchangeable options with no constraint of their own: they board
/// where the main bus drops you and end near the destination by
/// construction. Itineraries with a different main route never merge, even
/// from the same stop (product rule, Sam 2026-08-12: "agrupar las
/// redundantes, o sea que tienen el mismo bus principal").
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

  // Mirror pass (Sam 2026-08-12, seeing the live list: "también se pueden
  // agrupar por el segundo en transbordo — tienen en común el 120"):
  // itineraries STILL alone after the main-bus pass merge when they share
  // the same final connection — same rider-facing name, alighting within
  // tolerance (the mirror of the main rule: what identifies the last bus
  // is where it drops you). Main-bus groups keep priority and are never
  // chained into a mirror group.
  final sizeByRoot = <int, int>{};
  for (var i = 0; i < profiles.length; i++) {
    sizeByRoot.update(find(i), (n) => n + 1, ifAbsent: () => 1);
  }
  String? mainKeyOf(int i) =>
      profiles[i].slots.isEmpty ? null : _mainBusKey(profiles[i].slots.first);
  // Unidentifiable main buses stay out of the mirror pass entirely:
  // two unknown buses sharing a connection could be the SAME line kept
  // apart by the main pass — fail closed, like everywhere else.
  final candidates = <int>[
    for (var i = 0; i < profiles.length; i++)
      if (sizeByRoot[find(i)] == 1 &&
          profiles[i].slots.length > 1 &&
          mainKeyOf(i) != null)
        i,
  ];
  // Each mirror group may hold every main-bus name at most ONCE: two
  // singletons sharing a name exist only because the main pass kept them
  // apart (boarding beyond tolerance — a pinned product rule), and the
  // pairwise guard alone is bridgeable by union-find transitivity (a
  // third bus sharing the connection would chain them back together).
  final mainKeysByRoot = <int, Set<String>>{
    for (final i in candidates) i: {mainKeyOf(i)!},
  };
  for (final a in candidates) {
    for (final b in candidates) {
      if (b <= a) continue;
      final rootA = find(a);
      final rootB = find(b);
      if (rootA == rootB) continue;
      if (!profiles[a].mirrorMatches(
        profiles[b],
        sameRouteToleranceMeters: sameRouteToleranceMeters,
      )) {
        continue;
      }
      final keysA = mainKeysByRoot[rootA]!;
      final keysB = mainKeysByRoot[rootB]!;
      if (keysA.any(keysB.contains)) continue;
      parent[rootB] = rootA;
      keysA.addAll(keysB);
      mainKeysByRoot.remove(rootB);
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
    // rounded coordinates — disambiguate so any consumer keying on the
    // signature can tell the groups apart.
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
      // short name — two segments both reading "106" would be nonsense to
      // a rider. Legs with no display name at all collapse into a single
      // entry too, so nameless feeds never fake route alternatives.
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

/// The rider-facing identity of a bus: its display name, falling back to
/// the route id for unnamed feeds.
String? _mainBusKey(Leg leg) {
  final name = leg.displayName;
  if (name.isNotEmpty) return name;
  return _routeKey(leg);
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

  /// The mirror of [matches]: same number of legs and the same FINAL
  /// connection — same rider-facing name, alighting within tolerance.
  /// What identifies the last bus is where it drops you; where you caught
  /// it belongs to the option (the main bus you rode first).
  bool mirrorMatches(
    _TransitProfile other, {
    required double sameRouteToleranceMeters,
  }) {
    if (slots.length != other.slots.length || slots.length < 2) return false;

    // Same-named main buses are the MAIN pass's jurisdiction: if it kept
    // them apart (boarding beyond tolerance = different lines/directions,
    // a pinned product rule) the mirror pass must not sneak them back
    // together through the shared connection.
    final mainA = _mainBusKey(slots.first);
    if (mainA != null && mainA == _mainBusKey(other.slots.first)) {
      return false;
    }

    // Every slot after the main bus must be the same connection: same
    // rider-facing name, alighting within tolerance (what identifies a
    // connection is where it drops you; where you caught it belongs to
    // the option — the main bus you rode first).
    for (var i = 1; i < slots.length; i++) {
      final a = slots[i];
      final b = other.slots[i];
      if (a.transportMode != b.transportMode) return false;

      final keyA = _mainBusKey(a);
      final keyB = _mainBusKey(b);
      if (keyA == null || keyA != keyB) return false;

      final toA = a.toPlace?.latLng;
      final toB = b.toPlace?.latLng;
      if (toA != null &&
          toB != null &&
          _distance.as(LengthUnit.Meter, toA, toB) >
              sameRouteToleranceMeters) {
        return false;
      }
    }
    return true;
  }

  static bool _mainLegMatches(
    Leg a,
    Leg b, {
    required double toleranceMeters,
  }) {
    if (a.transportMode != b.transportMode) return false;

    // The main bus is identified by what the RIDER sees — the route name.
    // GTFS feeds commonly model one line as several route_ids (direction/
    // service variants): to the rider the 110 is the 110, and comparing by
    // route_id split those into separate rows (caught live on Cochabamba's
    // OTP 1.5). The stop-proximity check below guards same-named-but-
    // different lines. Unknown routes fail closed.
    final keyA = _mainBusKey(a);
    final keyB = _mainBusKey(b);
    if (keyA == null || keyA != keyB) return false;

    // Only the BOARDING identifies the main bus: where you get off it
    // belongs to the connection you chose (riding the P five blocks
    // farther to catch the 120 instead of the 106 is still "take the P" —
    // caught live: 529 m between alightings split the canonical group).
    final fromA = a.fromPlace?.latLng;
    final fromB = b.fromPlace?.latLng;
    if (fromA == null || fromB == null) {
      // Without endpoints the same route is the best evidence available.
      return true;
    }

    // Boarding a couple stops earlier/later is still the same bus.
    return _distance.as(LengthUnit.Meter, fromA, fromB) <= toleranceMeters;
  }
}
