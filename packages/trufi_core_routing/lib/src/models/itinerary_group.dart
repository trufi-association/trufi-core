import 'package:equatable/equatable.dart';

import 'itinerary.dart';
import 'route.dart';

/// A group of itineraries that ride the same main bus.
///
/// Members board the same first (main) transit leg — same route, same
/// boarding area — and differ in departure times and/or in the connections
/// after it, which carry no constraint of their own: interchangeable
/// options ("106 / 120") that Google Maps renders as a single row.
class ItineraryGroup extends Equatable {
  /// Creates an itinerary group.
  ///
  /// [representative] is the main itinerary shown in the list (the group's
  /// best-ranked member).
  /// [alternatives] includes all itineraries in the group; the first entry is
  /// always the representative, the rest are sorted by start time.
  /// [signature] is the shared route pattern signature.
  const ItineraryGroup({
    required this.representative,
    required this.alternatives,
    required this.signature,
    this.slotRoutes = const [],
  });

  /// The representative itinerary (the group's best-ranked member).
  /// This is the one displayed in the main list.
  final Itinerary representative;

  /// All itineraries in this group (including representative).
  /// The representative comes first; the rest are sorted by start time.
  final List<Itinerary> alternatives;

  /// The shared route pattern signature.
  final String signature;

  /// The distinct routes serving each transit slot across the group, in
  /// the same member order as [alternatives] (representative first, then
  /// departure order) so the card and the detail switcher list the options
  /// identically — what the UI joins as "106 / 120". Empty for walk-only
  /// groups (and for groups built without slot analysis).
  final List<List<Route>> slotRoutes;

  /// True when at least one slot is served by more than one route — the
  /// group merges different-route options, not just departure times.
  bool get hasRouteAlternatives =>
      slotRoutes.any((routes) => routes.length > 1);

  /// Returns the number of alternatives (including the representative).
  int get alternativeCount => alternatives.length;

  /// Returns true if there are alternative departure times.
  bool get hasAlternatives => alternatives.length > 1;

  /// Returns the number of additional departure times (excluding representative).
  int get additionalCount => alternatives.length - 1;

  /// Gets all departure times, sorted.
  List<DateTime> get departureTimes {
    final times = alternatives.map((i) => i.startTime).toList();
    times.sort();
    return times;
  }

  /// Gets all arrival times, sorted.
  List<DateTime> get arrivalTimes {
    final times = alternatives.map((i) => i.endTime).toList();
    times.sort();
    return times;
  }

  /// Creates a copy with the given fields replaced.
  ItineraryGroup copyWith({
    Itinerary? representative,
    List<Itinerary>? alternatives,
    String? signature,
    List<List<Route>>? slotRoutes,
  }) {
    return ItineraryGroup(
      representative: representative ?? this.representative,
      alternatives: alternatives ?? this.alternatives,
      signature: signature ?? this.signature,
      slotRoutes: slotRoutes ?? this.slotRoutes,
    );
  }

  @override
  List<Object?> get props => [
    representative,
    alternatives,
    signature,
    slotRoutes,
  ];
}
