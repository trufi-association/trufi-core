import 'package:flutter/foundation.dart';

import 'search_location.dart';

/// Holds the state for origin and destination locations in a search bar.
@immutable
class SearchLocationState {
  /// The origin/from location.
  final SearchLocation? origin;

  /// The destination/to location.
  final SearchLocation? destination;

  const SearchLocationState({
    this.origin,
    this.destination,
  });

  /// Returns true if both origin and destination are defined.
  bool get isComplete => origin != null && destination != null;

  /// Returns true if at least one location is defined.
  bool get hasAnyLocation => origin != null || destination != null;

  /// Creates a copy with updated values.
  SearchLocationState copyWith({
    SearchLocation? origin,
    SearchLocation? destination,
    bool clearOrigin = false,
    bool clearDestination = false,
  }) {
    return SearchLocationState(
      origin: clearOrigin ? null : (origin ?? this.origin),
      destination: clearDestination ? null : (destination ?? this.destination),
    );
  }

  /// Creates a new state with swapped origin and destination.
  SearchLocationState swapped() {
    return SearchLocationState(
      origin: destination,
      destination: origin,
    );
  }

  /// Creates an empty state.
  const SearchLocationState.empty()
      : origin = null,
        destination = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchLocationState &&
          runtimeType == other.runtimeType &&
          origin == other.origin &&
          destination == other.destination;

  @override
  int get hashCode => Object.hash(origin, destination);

  @override
  String toString() =>
      'SearchLocationState(origin: $origin, destination: $destination)';
}
