import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import 'navigation_instruction.dart';

/// Status of the navigation session.
enum NavigationStatus {
  /// Not navigating.
  idle,

  /// Getting initial GPS fix.
  initializing,

  /// Active navigation.
  navigating,

  /// User paused or app backgrounded.
  paused,

  /// Reached destination.
  completed,

  /// GPS lost, route deviation, or other error.
  error,
}

/// Type of the current navigation segment.
enum NavigationSegmentType {
  /// On public transport.
  transit,

  /// Walking between stops or to destination.
  walking,
}

/// Represents a stop in navigation context.
class NavigationStop extends Equatable {
  final String id;
  final String name;
  final LatLng position;

  const NavigationStop({
    required this.id,
    required this.name,
    required this.position,
  });

  @override
  List<Object?> get props => [id, name, position];
}

/// Route information for navigation.
class NavigationRoute extends Equatable {
  final String id;
  final String code;
  final String name;
  final String? shortName;
  final String? longName;
  final int? backgroundColor;
  final int? textColor;
  final List<LatLng> geometry;
  final List<NavigationStop> stops;
  final String? modeName;

  const NavigationRoute({
    required this.id,
    required this.code,
    required this.name,
    this.shortName,
    this.longName,
    this.backgroundColor,
    this.textColor,
    required this.geometry,
    required this.stops,
    this.modeName,
  });

  String get displayName => shortName ?? name;

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        shortName,
        longName,
        backgroundColor,
        textColor,
        geometry,
        stops,
        modeName,
      ];
}

/// The state of navigation.
class NavigationState extends Equatable {
  /// Current navigation status.
  final NavigationStatus status;

  /// Type of current segment (transit or walking).
  final NavigationSegmentType segmentType;

  /// The route being navigated.
  final NavigationRoute? route;

  /// Index of current/last passed stop.
  final int currentStopIndex;

  /// Total number of stops.
  final int totalStops;

  /// Remaining stops to destination.
  final int remainingStops;

  /// Current instruction to display.
  final NavigationInstruction? currentInstruction;

  /// Preview of next instruction.
  final NavigationInstruction? nextInstruction;

  /// Current user location.
  final LocationResult? currentLocation;

  /// Distance to next stop in meters.
  final double? distanceToNextStop;

  /// Estimated time to next stop.
  final Duration? etaToNextStop;

  /// Estimated time to final destination.
  final Duration? etaToDestination;

  /// Error message if status is error.
  final String? errorMessage;

  /// Whether user is off the route.
  final bool isOffRoute;

  /// Distance from route in meters (when off route).
  final double? distanceFromRoute;

  /// Whether GPS signal is weak.
  final bool isGpsWeak;

  /// Whether map should follow user location.
  final bool isMapFollowingUser;

  /// Whether app is in background mode.
  final bool isInBackground;

  const NavigationState({
    this.status = NavigationStatus.idle,
    this.segmentType = NavigationSegmentType.transit,
    this.route,
    this.currentStopIndex = 0,
    this.totalStops = 0,
    this.remainingStops = 0,
    this.currentInstruction,
    this.nextInstruction,
    this.currentLocation,
    this.distanceToNextStop,
    this.etaToNextStop,
    this.etaToDestination,
    this.errorMessage,
    this.isOffRoute = false,
    this.distanceFromRoute,
    this.isGpsWeak = false,
    this.isMapFollowingUser = true,
    this.isInBackground = false,
  });

  /// Whether navigation is active.
  bool get isNavigating => status == NavigationStatus.navigating;

  /// Whether navigation has completed.
  bool get isCompleted => status == NavigationStatus.completed;

  /// Whether there's an error.
  bool get hasError => status == NavigationStatus.error;

  /// Progress percentage (0.0 to 1.0).
  double get progress {
    if (totalStops <= 1) return 0.0;
    return currentStopIndex / (totalStops - 1);
  }

  /// The next stop to arrive at.
  NavigationStop? get nextStop {
    if (route == null) return null;
    final nextIndex = currentStopIndex + 1;
    if (nextIndex >= route!.stops.length) return null;
    return route!.stops[nextIndex];
  }

  /// The destination stop.
  NavigationStop? get destinationStop {
    if (route == null || route!.stops.isEmpty) return null;
    return route!.stops.last;
  }

  NavigationState copyWith({
    NavigationStatus? status,
    NavigationSegmentType? segmentType,
    NavigationRoute? route,
    int? currentStopIndex,
    int? totalStops,
    int? remainingStops,
    NavigationInstruction? currentInstruction,
    NavigationInstruction? nextInstruction,
    LocationResult? currentLocation,
    double? distanceToNextStop,
    Duration? etaToNextStop,
    Duration? etaToDestination,
    String? errorMessage,
    bool? isOffRoute,
    double? distanceFromRoute,
    bool? isGpsWeak,
    bool? isMapFollowingUser,
    bool? isInBackground,
  }) {
    return NavigationState(
      status: status ?? this.status,
      segmentType: segmentType ?? this.segmentType,
      route: route ?? this.route,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      totalStops: totalStops ?? this.totalStops,
      remainingStops: remainingStops ?? this.remainingStops,
      currentInstruction: currentInstruction ?? this.currentInstruction,
      nextInstruction: nextInstruction ?? this.nextInstruction,
      currentLocation: currentLocation ?? this.currentLocation,
      distanceToNextStop: distanceToNextStop ?? this.distanceToNextStop,
      etaToNextStop: etaToNextStop ?? this.etaToNextStop,
      etaToDestination: etaToDestination ?? this.etaToDestination,
      errorMessage: errorMessage ?? this.errorMessage,
      isOffRoute: isOffRoute ?? this.isOffRoute,
      distanceFromRoute: distanceFromRoute ?? this.distanceFromRoute,
      isGpsWeak: isGpsWeak ?? this.isGpsWeak,
      isMapFollowingUser: isMapFollowingUser ?? this.isMapFollowingUser,
      isInBackground: isInBackground ?? this.isInBackground,
    );
  }

  /// Create a copy with cleared error state.
  NavigationState clearError() {
    return copyWith(
      status: NavigationStatus.navigating,
      errorMessage: null,
      isOffRoute: false,
      distanceFromRoute: null,
      isGpsWeak: false,
    );
  }

  @override
  List<Object?> get props => [
        status,
        segmentType,
        route,
        currentStopIndex,
        totalStops,
        remainingStops,
        currentInstruction,
        nextInstruction,
        currentLocation,
        distanceToNextStop,
        etaToNextStop,
        etaToDestination,
        errorMessage,
        isOffRoute,
        distanceFromRoute,
        isGpsWeak,
        isMapFollowingUser,
        isInBackground,
      ];
}
