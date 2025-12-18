import 'package:equatable/equatable.dart';

/// Time mode for departure/arrival planning.
enum TimeMode {
  /// Leave now (default).
  leaveNow,

  /// Depart at a specific time.
  departAt,

  /// Arrive by a specific time.
  arriveBy,
}

/// User preferences for route planning.
///
/// These preferences map directly to OpenTripPlanner API parameters.
class RoutingPreferences extends Equatable {
  /// Whether the route must be wheelchair accessible.
  final bool wheelchair;

  /// Walking speed in meters per second (default: 1.33 m/s ≈ 4.8 km/h).
  final double walkSpeed;

  /// Maximum walking distance in meters (null = unlimited).
  final double? maxWalkDistance;

  /// How much to avoid walking compared to transit (range: 1.0 - 5.0).
  /// Higher values = prefer less walking.
  final double walkReluctance;

  /// Biking speed in meters per second (default: 5.0 m/s ≈ 18 km/h).
  final double bikeSpeed;

  /// Transport modes to consider for routing.
  final Set<RoutingMode> transportModes;

  /// Time mode for departure/arrival planning.
  final TimeMode timeMode;

  /// The specific date/time for departure or arrival.
  /// Only used when [timeMode] is not [TimeMode.leaveNow].
  final DateTime? dateTime;

  const RoutingPreferences({
    this.wheelchair = false,
    this.walkSpeed = 1.33,
    this.maxWalkDistance,
    this.walkReluctance = 2.0,
    this.bikeSpeed = 5.0,
    this.transportModes = const {RoutingMode.transit, RoutingMode.walk},
    this.timeMode = TimeMode.leaveNow,
    this.dateTime,
  });

  /// Default preferences for most users.
  static const defaultPreferences = RoutingPreferences();

  /// Preferences for slow walkers.
  static const slowWalker = RoutingPreferences(
    walkSpeed: 0.8, // ~2.9 km/h
    walkReluctance: 3.5,
    maxWalkDistance: 500,
  );

  /// Preferences for fast walkers.
  static const fastWalker = RoutingPreferences(
    walkSpeed: 1.8, // ~6.5 km/h
    walkReluctance: 1.5,
  );

  /// Preferences for wheelchair users.
  static const wheelchairUser = RoutingPreferences(
    wheelchair: true,
    walkSpeed: 0.8,
    walkReluctance: 3.0,
    maxWalkDistance: 400,
  );

  RoutingPreferences copyWith({
    bool? wheelchair,
    double? walkSpeed,
    double? maxWalkDistance,
    bool clearMaxWalkDistance = false,
    double? walkReluctance,
    double? bikeSpeed,
    Set<RoutingMode>? transportModes,
    TimeMode? timeMode,
    DateTime? dateTime,
    bool clearDateTime = false,
  }) {
    return RoutingPreferences(
      wheelchair: wheelchair ?? this.wheelchair,
      walkSpeed: walkSpeed ?? this.walkSpeed,
      maxWalkDistance:
          clearMaxWalkDistance ? null : (maxWalkDistance ?? this.maxWalkDistance),
      walkReluctance: walkReluctance ?? this.walkReluctance,
      bikeSpeed: bikeSpeed ?? this.bikeSpeed,
      transportModes: transportModes ?? this.transportModes,
      timeMode: timeMode ?? this.timeMode,
      dateTime: clearDateTime ? null : (dateTime ?? this.dateTime),
    );
  }

  /// Converts walk speed to a human-readable label.
  WalkSpeedLevel get walkSpeedLevel {
    if (walkSpeed <= 0.9) return WalkSpeedLevel.slow;
    if (walkSpeed <= 1.5) return WalkSpeedLevel.normal;
    return WalkSpeedLevel.fast;
  }

  @override
  List<Object?> get props => [
        wheelchair,
        walkSpeed,
        maxWalkDistance,
        walkReluctance,
        bikeSpeed,
        transportModes,
        timeMode,
        dateTime,
      ];
}

/// Simplified walk speed levels for UI.
enum WalkSpeedLevel {
  slow,
  normal,
  fast;

  double get speedValue {
    switch (this) {
      case WalkSpeedLevel.slow:
        return 0.8;
      case WalkSpeedLevel.normal:
        return 1.33;
      case WalkSpeedLevel.fast:
        return 1.8;
    }
  }

  double get reluctanceValue {
    switch (this) {
      case WalkSpeedLevel.slow:
        return 3.5;
      case WalkSpeedLevel.normal:
        return 2.0;
      case WalkSpeedLevel.fast:
        return 1.5;
    }
  }
}

/// Transport modes for routing configuration.
///
/// These are high-level modes that map to OTP TransportMode values.
enum RoutingMode {
  walk,
  transit,
  bicycle,
  car;

  /// Returns the OTP string representation.
  String get otpName {
    switch (this) {
      case RoutingMode.walk:
        return 'WALK';
      case RoutingMode.transit:
        return 'TRANSIT';
      case RoutingMode.bicycle:
        return 'BICYCLE';
      case RoutingMode.car:
        return 'CAR';
    }
  }
}
