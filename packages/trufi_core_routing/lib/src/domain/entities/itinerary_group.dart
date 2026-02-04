import 'package:equatable/equatable.dart';

import 'itinerary.dart';

/// A group of itineraries that share the same route pattern.
///
/// Itineraries in the same group use the same buses, stops, and transfers
/// but may differ in departure/arrival times.
class ItineraryGroup extends Equatable {
  /// Creates an itinerary group.
  ///
  /// [representative] is the main itinerary shown in the list (usually the earliest).
  /// [alternatives] includes all itineraries in the group, including the representative.
  /// [signature] is the shared route pattern signature.
  const ItineraryGroup({
    required this.representative,
    required this.alternatives,
    required this.signature,
  });

  /// The representative itinerary (usually earliest or fastest).
  /// This is the one displayed in the main list.
  final Itinerary representative;

  /// All itineraries in this group (including representative).
  /// Sorted by start time.
  final List<Itinerary> alternatives;

  /// The shared route pattern signature.
  final String signature;

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
  }) {
    return ItineraryGroup(
      representative: representative ?? this.representative,
      alternatives: alternatives ?? this.alternatives,
      signature: signature ?? this.signature,
    );
  }

  @override
  List<Object?> get props => [representative, alternatives, signature];
}
