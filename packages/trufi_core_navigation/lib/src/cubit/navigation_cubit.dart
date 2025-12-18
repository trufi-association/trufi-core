import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../models/navigation_config.dart';
import '../models/navigation_instruction.dart';
import '../models/navigation_state.dart';

/// Cubit that manages turn-by-turn navigation state.
class NavigationCubit extends Cubit<NavigationState> {
  final LocationService _locationService;
  final NavigationConfig _config;

  NavigationCubit({
    required LocationService locationService,
    NavigationConfig config = const NavigationConfig(),
  })  : _locationService = locationService,
        _config = config,
        super(const NavigationState());

  /// Start navigation for a route.
  Future<void> startNavigation(NavigationRoute route) async {
    emit(state.copyWith(status: NavigationStatus.initializing));

    // Request location permission
    final permissionStatus = await _locationService.requestPermission();
    if (permissionStatus != LocationPermissionStatus.granted) {
      emit(state.copyWith(
        status: NavigationStatus.error,
        errorMessage: _getPermissionErrorMessage(permissionStatus),
      ));
      return;
    }

    // Start location tracking
    final trackingStarted = await _locationService.startTracking(
      distanceFilter: _config.locationDistanceFilter,
    );

    if (!trackingStarted) {
      emit(state.copyWith(
        status: NavigationStatus.error,
        errorMessage: 'Could not start location tracking',
      ));
      return;
    }

    // Get initial location
    final currentLocation = _locationService.currentLocation;

    // Find nearest stop to start from
    int startStopIndex = 0;
    if (currentLocation != null && route.stops.isNotEmpty) {
      startStopIndex = _findNearestStopIndex(route.stops, currentLocation);
    }

    final totalStops = route.stops.length;
    final remainingStops = totalStops - startStopIndex - 1;

    // Build initial instruction
    final instruction = _buildTransitInstruction(route, startStopIndex);
    final nextInstruction =
        remainingStops > 0 ? _buildNextStopPreview(route, startStopIndex + 1) : null;

    emit(state.copyWith(
      status: NavigationStatus.navigating,
      segmentType: NavigationSegmentType.transit,
      route: route,
      currentStopIndex: startStopIndex,
      totalStops: totalStops,
      remainingStops: remainingStops,
      currentInstruction: instruction,
      nextInstruction: nextInstruction,
      currentLocation: currentLocation,
      isMapFollowingUser: true,
    ));

    // Start listening to location updates
    _locationService.addListener(_onLocationUpdate);

    // Calculate initial distance if we have location
    if (currentLocation != null) {
      _updateDistanceAndEta(currentLocation);
    }
  }

  /// Stop navigation and clean up.
  Future<void> stopNavigation() async {
    _locationService.removeListener(_onLocationUpdate);
    await _locationService.stopTracking();

    emit(const NavigationState(status: NavigationStatus.idle));
  }

  /// Pause navigation (e.g., when app goes to background).
  void pauseNavigation() {
    if (state.status != NavigationStatus.navigating) return;
    emit(state.copyWith(status: NavigationStatus.paused));
  }

  /// Resume navigation after pause.
  void resumeNavigation() {
    if (state.status != NavigationStatus.paused) return;
    emit(state.copyWith(status: NavigationStatus.navigating));
  }

  /// Toggle whether map follows user location.
  void toggleMapFollow() {
    emit(state.copyWith(isMapFollowingUser: !state.isMapFollowingUser));
  }

  /// Re-center map on user location.
  void recenterMap() {
    emit(state.copyWith(isMapFollowingUser: true));
  }

  /// Set background mode (reduces GPS updates).
  Future<void> setBackgroundMode(bool isBackground) async {
    if (state.isInBackground == isBackground) return;

    emit(state.copyWith(isInBackground: isBackground));

    // Restart tracking with appropriate distance filter
    await _locationService.stopTracking();
    await _locationService.startTracking(
      distanceFilter: isBackground
          ? _config.backgroundDistanceFilter
          : _config.locationDistanceFilter,
    );
  }

  /// Manually advance to next stop (if auto-advance is disabled).
  void advanceToNextStop() {
    if (state.route == null) return;

    final nextIndex = state.currentStopIndex + 1;
    if (nextIndex >= state.route!.stops.length) {
      _completeNavigation();
      return;
    }

    _advanceToStop(nextIndex);
  }

  /// Skip to a specific stop.
  void skipToStop(int stopIndex) {
    if (state.route == null) return;
    if (stopIndex < 0 || stopIndex >= state.route!.stops.length) return;

    _advanceToStop(stopIndex);
  }

  // Private methods

  void _onLocationUpdate() {
    final location = _locationService.currentLocation;
    if (location == null) return;

    // Check GPS accuracy
    final isGpsWeak = location.accuracy != null &&
        location.accuracy! > _config.gpsAccuracyWarningThreshold;

    // Calculate current leg index based on user position
    final currentLegIndex = _getCurrentLegIndex(location);

    emit(state.copyWith(
      currentLocation: location,
      currentLegIndex: currentLegIndex,
      isGpsWeak: isGpsWeak,
    ));

    if (state.status != NavigationStatus.navigating) return;

    // Check progress based on segment type
    if (state.segmentType == NavigationSegmentType.transit) {
      _checkTransitProgress(location);
    } else {
      _checkWalkingProgress(location);
    }

    _updateDistanceAndEta(location);
    _checkOffRoute(location);
  }

  void _checkTransitProgress(LocationResult location) {
    final route = state.route;
    if (route == null || route.stops.isEmpty) return;

    final currentIndex = state.currentStopIndex;

    // Check ALL remaining stops to find the furthest one the user has passed
    // This handles cases where user skips stops (e.g., GPS jumps)
    int furthestPassedIndex = currentIndex;

    for (int i = currentIndex + 1; i < route.stops.length; i++) {
      final stop = route.stops[i];
      final distanceToStop = _locationService.distanceBetween(
        location.latitude,
        location.longitude,
        stop.position.latitude,
        stop.position.longitude,
      );

      if (distanceToStop <= _config.stopArrivalThreshold) {
        // User is at or has passed this stop
        furthestPassedIndex = i;
      }
    }

    // If we found a stop the user has passed (beyond current), advance to it
    if (furthestPassedIndex > currentIndex && _config.autoAdvanceStops) {
      _advanceToStop(furthestPassedIndex);
    }
  }

  void _checkWalkingProgress(LocationResult location) {
    // For walking segments, we'd check step-by-step progress
    // This is a simplified implementation
    final nextStop = state.nextStop;
    if (nextStop == null) return;

    final distanceToNext = _locationService.distanceBetween(
      location.latitude,
      location.longitude,
      nextStop.position.latitude,
      nextStop.position.longitude,
    );

    if (distanceToNext <= _config.stopArrivalThreshold) {
      // Arrived at walking destination
      _advanceToStop(state.currentStopIndex + 1);
    }
  }

  void _advanceToStop(int stopIndex) {
    final route = state.route;
    if (route == null) return;

    // Check if we've reached the end
    if (stopIndex >= route.stops.length - 1) {
      _completeNavigation();
      return;
    }

    final remainingStops = route.stops.length - stopIndex - 1;

    final instruction = _buildTransitInstruction(route, stopIndex);
    final nextInstruction =
        remainingStops > 0 ? _buildNextStopPreview(route, stopIndex + 1) : null;

    emit(state.copyWith(
      currentStopIndex: stopIndex,
      remainingStops: remainingStops,
      currentInstruction: instruction,
      nextInstruction: nextInstruction,
    ));

    // Haptic feedback on stop arrival
    HapticFeedback.mediumImpact();
  }

  void _completeNavigation() {
    final route = state.route;

    emit(state.copyWith(
      status: NavigationStatus.completed,
      currentStopIndex: route?.stops.length ?? 0,
      remainingStops: 0,
      currentInstruction: NavigationInstruction(
        type: InstructionType.arriveDestination,
        primaryText: 'You have arrived',
        stopName: route?.stops.lastOrNull?.name,
      ),
      nextInstruction: null,
    ));

    HapticFeedback.heavyImpact();
  }

  void _updateDistanceAndEta(LocationResult location) {
    final nextStop = state.nextStop;
    if (nextStop == null) return;

    final distanceToNext = _locationService.distanceBetween(
      location.latitude,
      location.longitude,
      nextStop.position.latitude,
      nextStop.position.longitude,
    );

    // Estimate time based on average transit speed (30 km/h = 8.33 m/s)
    // For walking: ~1.4 m/s (5 km/h)
    final speedMs =
        state.segmentType == NavigationSegmentType.transit ? 8.33 : 1.4;
    final etaSeconds = distanceToNext / speedMs;

    // Estimate total ETA based on remaining stops
    // Assume average 2 minutes per stop for transit
    final remainingStopsEta = state.segmentType == NavigationSegmentType.transit
        ? Duration(minutes: state.remainingStops * 2)
        : Duration.zero;

    emit(state.copyWith(
      distanceToNextStop: distanceToNext,
      etaToNextStop: Duration(seconds: etaSeconds.round()),
      etaToDestination:
          Duration(seconds: etaSeconds.round()) + remainingStopsEta,
    ));
  }

  void _checkOffRoute(LocationResult location) {
    final route = state.route;
    if (route == null || route.geometry.isEmpty) return;

    // Find minimum distance to any point on route
    double minDistance = double.infinity;
    for (final point in route.geometry) {
      final dist = _locationService.distanceBetween(
        location.latitude,
        location.longitude,
        point.latitude,
        point.longitude,
      );
      if (dist < minDistance) minDistance = dist;
    }

    final isOffRoute = minDistance > _config.offRouteThreshold;

    if (isOffRoute && !state.isOffRoute) {
      // Just went off route
      emit(state.copyWith(
        isOffRoute: true,
        distanceFromRoute: minDistance,
      ));
      HapticFeedback.heavyImpact();
    } else if (!isOffRoute && state.isOffRoute) {
      // Back on route
      emit(state.copyWith(
        isOffRoute: false,
        distanceFromRoute: null,
      ));
    }
  }

  /// Determines which leg index the user is currently on based on their position.
  int _getCurrentLegIndex(LocationResult location) {
    final route = state.route;
    if (route == null || route.legs.isEmpty) return 0;

    double minDist = double.infinity;
    int closestLegIndex = 0;

    for (int i = 0; i < route.legs.length; i++) {
      final leg = route.legs[i];
      for (final point in leg.points) {
        final dist = _locationService.distanceBetween(
          location.latitude,
          location.longitude,
          point.latitude,
          point.longitude,
        );
        if (dist < minDist) {
          minDist = dist;
          closestLegIndex = i;
        }
      }
    }

    return closestLegIndex;
  }

  int _findNearestStopIndex(List<NavigationStop> stops, LocationResult location) {
    if (stops.isEmpty) return 0;

    int nearestIndex = 0;
    double nearestDistance = double.infinity;

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final distance = _locationService.distanceBetween(
        location.latitude,
        location.longitude,
        stop.position.latitude,
        stop.position.longitude,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    return nearestIndex;
  }

  NavigationInstruction _buildTransitInstruction(
      NavigationRoute route, int stopIndex) {
    final stops = route.stops;
    final remainingStops = stops.length - stopIndex - 1;

    if (remainingStops <= 0) {
      return NavigationInstruction(
        type: InstructionType.exitTransport,
        primaryText: 'Exit at ${stops.last.name}',
        stopName: stops.last.name,
        routeColor:
            route.backgroundColor != null ? Color(route.backgroundColor!) : null,
        routeShortName: route.shortName,
      );
    }

    final nextStop = stops[stopIndex + 1];
    final stopsText = remainingStops == 1 ? '1 stop' : '$remainingStops stops';

    return NavigationInstruction(
      type: InstructionType.rideTransport,
      primaryText: nextStop.name,
      secondaryText: '$stopsText remaining',
      stopName: nextStop.name,
      routeColor:
          route.backgroundColor != null ? Color(route.backgroundColor!) : null,
      routeShortName: route.shortName,
    );
  }

  NavigationInstruction _buildNextStopPreview(
      NavigationRoute route, int stopIndex) {
    if (stopIndex >= route.stops.length) {
      return NavigationInstruction(
        type: InstructionType.arriveDestination,
        primaryText: 'Final destination',
      );
    }

    final stop = route.stops[stopIndex];
    return NavigationInstruction(
      type: InstructionType.arriveStop,
      primaryText: stop.name,
      stopName: stop.name,
    );
  }

  String _getPermissionErrorMessage(LocationPermissionStatus status) {
    return switch (status) {
      LocationPermissionStatus.denied => 'Location permission denied',
      LocationPermissionStatus.deniedForever =>
        'Location permission permanently denied. Please enable in settings.',
      LocationPermissionStatus.serviceDisabled =>
        'Location services are disabled. Please enable them.',
      LocationPermissionStatus.granted => '',
    };
  }

  @override
  Future<void> close() {
    _locationService.removeListener(_onLocationUpdate);
    return super.close();
  }
}
