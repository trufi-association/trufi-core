/// Real-time state of a trip leg.
enum RealtimeState {
  /// The trip information is based on real-time data.
  updated,

  /// The trip information is based on schedule.
  scheduled,

  /// The trip has been canceled.
  canceled,

  /// The trip was added in real-time.
  added,

  /// The trip was modified in real-time.
  modified,

  /// Unknown state.
  unknown,
}

/// Extension methods for [RealtimeState].
extension RealtimeStateExtension on RealtimeState {
  /// Creates a [RealtimeState] from a string value.
  static RealtimeState fromString(String? value) {
    if (value == null) return RealtimeState.unknown;
    return RealtimeState.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => RealtimeState.unknown,
    );
  }
}
