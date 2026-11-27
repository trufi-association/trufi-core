import 'package:trufi_core_maps/trufi_core_maps.dart' show LatLngBounds;

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

  /// Whether the instruction card talks about the stops a transit leg passes:
  /// the name of the next one, the "`N` stops remaining" count, the distance
  /// to the next one and the "Next: …" preview. `false` names the stop where
  /// the current leg ends instead — the alighting stop while riding — with
  /// the distance left to it, and drops the other three. A stop counts as
  /// reached from [stopArrivalThreshold] (50 m) before it, so from there the
  /// card already names the end of the next leg — the same moment the
  /// default mode moves on to the next stop.
  ///
  /// Presentation only: the stops keep driving the progression either way
  /// (start index, auto-advance, ETA, progress bar, the ridden part of the
  /// line on the map).
  ///
  /// Same name and default as `HomeScreenConfig.showStops` (#1058) and
  /// `TransportDetailScreen.showStops` (#1014): a city whose feed carries no
  /// real stops (Sana'a's are OSM way nodes placed along each line,
  /// trufi-sanaa#18) turns the three off together.
  final bool showStops;

  /// Area the app serves. While the rider's position is outside it, the map
  /// shows the trip's first leg instead of the GPS fix, a notice names the
  /// area and the distance to the next stop (with the ETA) is hidden: both
  /// are meaningless from far away (trufi-lima#12). Null: no such handling.
  final LatLngBounds? serviceArea;

  /// Name of [serviceArea] for the notice; null reads "the service area".
  final String? serviceAreaName;

  const NavigationConfig({
    this.stopArrivalThreshold = 50.0,
    this.offRouteThreshold = 200.0,
    this.locationDistanceFilter = 10,
    this.autoAdvanceStops = true,
    this.walkingNavThreshold = 100.0,
    this.keepScreenOn = true,
    this.gpsAccuracyWarningThreshold = 100.0,
    this.backgroundDistanceFilter = 50,
    this.showStops = true,
    this.serviceArea,
    this.serviceAreaName,
  });

  /// Whether a position is inside [serviceArea] (edges included); always
  /// true without one.
  bool isInServiceArea(double latitude, double longitude) {
    final area = serviceArea;
    if (area == null) return true;
    return latitude >= area.southWest.latitude &&
        latitude <= area.northEast.latitude &&
        longitude >= area.southWest.longitude &&
        longitude <= area.northEast.longitude;
  }

  NavigationConfig copyWith({
    double? stopArrivalThreshold,
    double? offRouteThreshold,
    int? locationDistanceFilter,
    bool? autoAdvanceStops,
    double? walkingNavThreshold,
    bool? keepScreenOn,
    double? gpsAccuracyWarningThreshold,
    int? backgroundDistanceFilter,
    bool? showStops,
    LatLngBounds? serviceArea,
    String? serviceAreaName,
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
      showStops: showStops ?? this.showStops,
      serviceArea: serviceArea ?? this.serviceArea,
      serviceAreaName: serviceAreaName ?? this.serviceAreaName,
    );
  }
}
