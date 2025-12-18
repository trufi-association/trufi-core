/// Configuration for navigation behavior.
class NavigationConfig {
  /// Distance threshold to consider user "at" a stop (meters).
  final double stopArrivalThreshold;

  /// Distance threshold before showing "off route" warning (meters).
  final double offRouteThreshold;

  /// GPS update frequency for location service (meters).
  final int locationDistanceFilter;

  /// Auto-advance to next stop when within threshold.
  final bool autoAdvanceStops;

  /// Show walking turn-by-turn for segments greater than this distance (meters).
  final double walkingNavThreshold;

  /// Keep screen awake during navigation.
  final bool keepScreenOn;

  /// GPS accuracy threshold - show warning if accuracy is worse (meters).
  final double gpsAccuracyWarningThreshold;

  /// Distance filter when app is in background (meters).
  final int backgroundDistanceFilter;

  const NavigationConfig({
    this.stopArrivalThreshold = 50.0,
    this.offRouteThreshold = 200.0,
    this.locationDistanceFilter = 10,
    this.autoAdvanceStops = true,
    this.walkingNavThreshold = 100.0,
    this.keepScreenOn = true,
    this.gpsAccuracyWarningThreshold = 100.0,
    this.backgroundDistanceFilter = 50,
  });

  NavigationConfig copyWith({
    double? stopArrivalThreshold,
    double? offRouteThreshold,
    int? locationDistanceFilter,
    bool? autoAdvanceStops,
    double? walkingNavThreshold,
    bool? keepScreenOn,
    double? gpsAccuracyWarningThreshold,
    int? backgroundDistanceFilter,
  }) {
    return NavigationConfig(
      stopArrivalThreshold: stopArrivalThreshold ?? this.stopArrivalThreshold,
      offRouteThreshold: offRouteThreshold ?? this.offRouteThreshold,
      locationDistanceFilter:
          locationDistanceFilter ?? this.locationDistanceFilter,
      autoAdvanceStops: autoAdvanceStops ?? this.autoAdvanceStops,
      walkingNavThreshold: walkingNavThreshold ?? this.walkingNavThreshold,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      gpsAccuracyWarningThreshold:
          gpsAccuracyWarningThreshold ?? this.gpsAccuracyWarningThreshold,
      backgroundDistanceFilter:
          backgroundDistanceFilter ?? this.backgroundDistanceFilter,
    );
  }
}
