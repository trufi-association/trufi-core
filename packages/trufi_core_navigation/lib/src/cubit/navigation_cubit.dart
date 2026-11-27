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

  /// The trip started with the rider outside the service area, so its first
  /// stop stands in for the one nearest the GPS until a fix inside arrives.
  bool _startPendingInsideArea = false;

  NavigationCubit({
    required LocationService locationService,
    NavigationConfig config = const NavigationConfig(),
  }) : _locationService = locationService,
       _config = config,
       super(const NavigationState());

  /// Start navigation for a route.
  Future<void> startNavigation(NavigationRoute route) async {
    emit(state.copyWith(status: NavigationStatus.initializing));

    // Request location permission
    final permissionStatus = await _locationService.requestPermission();

    // The rider can leave the screen while the permission is being asked,
    // and NavigationScreen closes the cubit: nothing is left to start, and
    // emitting on a closed cubit throws.
    if (isClosed) return;

    if (permissionStatus != LocationPermissionStatus.granted) {
      emit(
        state.copyWith(
          status: NavigationStatus.error,
          errorType: _getPermissionError(permissionStatus),
        ),
      );
      return;
    }

    // Start location tracking
    final trackingStarted = await _locationService.startTracking(
      distanceFilter: _config.locationDistanceFilter,
    );

    // Same here: the tracking can take as long as the first position to
    // start, and the screen may be gone by then. Returning also keeps the
    // closed cubit from listening to the location service below.
    if (isClosed) {
      // The screen stopped the tracking while it was starting: what started
      // after that has nobody left to stop it.
      if (trackingStarted) await _locationService.stopTracking();
      return;
    }

    if (!trackingStarted) {
      emit(
        state.copyWith(
          status: NavigationStatus.error,
          errorType: NavigationError.trackingStartFailed,
        ),
      );
      return;
    }

    // Get initial location
    final currentLocation = _locationService.currentLocation;

    // Find nearest stop to start from. From outside the service area that is
    // a far stop of the trip (trufi-lima#12): start at the first one instead
    // and look again on the first fix inside.
    _startPendingInsideArea = _isOutsideServiceArea(currentLocation);
    int startStopIndex = 0;
    if (currentLocation != null &&
        route.stops.isNotEmpty &&
        !_startPendingInsideArea) {
      startStopIndex = _findNearestStopIndex(route.stops, currentLocation);
    }

    emit(
      _stateAtStop(route, startStopIndex, currentLocation).copyWith(
        status: NavigationStatus.navigating,
        segmentType: NavigationSegmentType.transit,
        route: route,
        totalStops: route.stops.length,
        currentLocation: currentLocation,
        isMapFollowingUser: true,
        // No etaToDestination seed: NavigationState derives the initial ETA
        // from route.duration, so it matches the route results without
        // storing a duplicate. See #917.
      ),
    );

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

    // NavigationScreen closes the cubit right after asking it to stop: by
    // the time the tracking has stopped there is nobody left to tell, and
    // emitting on a closed cubit throws.
    if (isClosed) return;

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
    final isGpsWeak =
        location.accuracy != null &&
        location.accuracy! > _config.gpsAccuracyWarningThreshold;

    // Calculate current leg index based on user position
    final currentLegIndex = _getCurrentLegIndex(location);

    emit(
      state.copyWith(
        currentLocation: location,
        currentLegIndex: currentLegIndex,
        isGpsWeak: isGpsWeak,
      ),
    );

    if (state.status != NavigationStatus.navigating) return;

    if (_startPendingInsideArea && !_isOutsideServiceArea(location)) {
      _startPendingInsideArea = false;
      final route = state.route;
      if (route != null && route.stops.isNotEmpty) {
        // A fix on the edge of the area is far from the trip: keep the first
        // stop and let forward progress take over.
        final nearest = _findNearestStopIndex(route.stops, location);
        final nearestStop = route.stops[nearest];
        final distance = _locationService.distanceBetween(
          location.latitude,
          location.longitude,
          nearestStop.position.latitude,
          nearestStop.position.longitude,
        );
        if (distance <= _config.offRouteThreshold) {
          emit(_stateAtStop(route, nearest, location));
        }
      }
    }

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

  /// [state] with the stop the rider is past at [stopIndex] and what the
  /// instruction says about it.
  NavigationState _stateAtStop(
    NavigationRoute route,
    int stopIndex,
    LocationResult? location,
  ) {
    final remainingStops = route.stops.length - stopIndex - 1;
    return state.copyWith(
      currentStopIndex: stopIndex,
      remainingStops: remainingStops,
      currentInstruction: _buildTransitInstruction(
        route,
        stopIndex,
        location: location,
      ),
      nextInstruction: remainingStops > 0 && _config.showStops
          ? _buildNextStopPreview(route, stopIndex + 1)
          : null,
    );
  }

  bool _isOutsideServiceArea(LocationResult? location) =>
      location != null &&
      !_config.isInServiceArea(location.latitude, location.longitude);

  void _advanceToStop(int stopIndex) {
    final route = state.route;
    if (route == null) return;

    // Check if we've reached the end
    if (stopIndex >= route.stops.length - 1) {
      _completeNavigation();
      return;
    }

    final remainingStops = route.stops.length - stopIndex - 1;

    final instruction = _buildTransitInstruction(
      route,
      stopIndex,
      location: state.currentLocation,
    );
    final nextInstruction = remainingStops > 0 && _config.showStops
        ? _buildNextStopPreview(route, stopIndex + 1)
        : null;

    emit(
      state.copyWith(
        currentStopIndex: stopIndex,
        remainingStops: remainingStops,
        currentInstruction: instruction,
        nextInstruction: nextInstruction,
      ),
    );

    // Haptic feedback on stop arrival
    HapticFeedback.mediumImpact();
  }

  void _completeNavigation() {
    final route = state.route;

    emit(
      state.copyWith(
        status: NavigationStatus.completed,
        currentStopIndex: route?.stops.length ?? 0,
        remainingStops: 0,
        currentInstruction: NavigationInstruction(
          type: InstructionType.arriveDestination,
          primaryTextKey: InstructionTextKey.youHaveArrived,
          stopName: route?.stops.lastOrNull?.name,
        ),
        nextInstruction: null,
      ),
    );

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

    // Estimate time to the next stop based on average transit speed
    // (30 km/h = 8.33 m/s); walking: ~1.4 m/s (5 km/h).
    final speedMs = state.segmentType == NavigationSegmentType.transit
        ? 8.33
        : 1.4;
    final etaSeconds = distanceToNext / speedMs;

    // Remaining trip time: anchor to the itinerary's planned duration (the
    // value shown in the route results) and scale it by how many stops are
    // left, instead of the previous fixed "2 minutes per remaining stop"
    // guess that inflated long routes to ~1h. See #917.
    // state.route is non-null here: nextStop above already requires it.
    final rideStops = state.totalStops - 1; // stops after the origin
    final Duration etaToDestination;
    if (state.route!.duration > Duration.zero && rideStops > 0) {
      final fraction = (state.remainingStops / rideStops).clamp(0.0, 1.0);
      etaToDestination = Duration(
        seconds: (state.route!.duration.inSeconds * fraction).round(),
      );
    } else {
      // No planned duration available: fall back to the leg-pace estimate.
      etaToDestination = Duration(seconds: etaSeconds.round());
    }

    emit(
      state.copyWith(
        distanceToNextStop: distanceToNext,
        etaToNextStop: Duration(seconds: etaSeconds.round()),
        etaToDestination: etaToDestination,
        // Without the stops the instruction carries a distance, which moves
        // with every fix and not only when a stop is reached (#1059). With
        // them it is left as it is (null keeps the current one).
        currentInstruction: _config.showStops
            ? null
            : _buildTransitInstruction(
                state.route!,
                state.currentStopIndex,
                location: location,
              ),
      ),
    );
  }

  void _checkOffRoute(LocationResult location) {
    final route = state.route;
    if (route == null || route.geometry.isEmpty) return;

    // Outside the service area the notice replaces the off-route warning and
    // its vibration: the rider is not on the route, and knows it.
    if (_isOutsideServiceArea(location)) {
      if (state.isOffRoute) {
        emit(state.copyWith(isOffRoute: false, distanceFromRoute: null));
      }
      return;
    }

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
      emit(state.copyWith(isOffRoute: true, distanceFromRoute: minDistance));
      HapticFeedback.heavyImpact();
    } else if (!isOffRoute && state.isOffRoute) {
      // Back on route
      emit(state.copyWith(isOffRoute: false, distanceFromRoute: null));
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

  int _findNearestStopIndex(
    List<NavigationStop> stops,
    LocationResult location,
  ) {
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

  /// The instruction for a rider past the stop at [stopIndex]. [location] is
  /// only read when [NavigationConfig.showStops] is off, to measure the
  /// distance the instruction then carries.
  NavigationInstruction _buildTransitInstruction(
    NavigationRoute route,
    int stopIndex, {
    LocationResult? location,
  }) {
    final stops = route.stops;
    final remainingStops = stops.length - stopIndex - 1;

    if (remainingStops <= 0) {
      return NavigationInstruction(
        type: InstructionType.exitTransport,
        // English fallback for context-less consumers; widgets render the
        // localized navExitAt via primaryTextKey.
        primaryText: 'Exit at ${stops.last.name}',
        primaryTextKey: InstructionTextKey.exitAtStop,
        stopName: stops.last.name,
        routeColor: route.backgroundColor != null
            ? Color(route.backgroundColor!)
            : null,
        routeShortName: route.shortName,
      );
    }

    if (!_config.showStops) {
      // The stops the vehicle only passes keep driving the progression, but
      // the rider reads about the stop where this leg ends and how far it
      // is, never about them or how many are left (#1059).
      final legEndIndex = _legEndStopIndex(stops, stopIndex);
      final legEnd = stops[legEndIndex];
      // From outside the service area the distance is meaningless (#12).
      if (_isOutsideServiceArea(location)) {
        return NavigationInstruction(
          type: InstructionType.rideTransport,
          primaryText: legEnd.name,
          stopName: legEnd.name,
          routeColor: route.backgroundColor != null
              ? Color(route.backgroundColor!)
              : null,
          routeShortName: route.shortName,
        );
      }
      final distance = _distanceAlongStops(
        stops,
        stopIndex,
        legEndIndex,
        location,
      );

      return NavigationInstruction(
        type: InstructionType.rideTransport,
        primaryText: legEnd.name,
        // English fallback; widgets render the localized navDistanceMeters /
        // navDistanceKilometers via secondaryTextKey.
        secondaryText: distance < 1000
            ? '${distance.round()} m'
            : '${(distance / 1000).toStringAsFixed(1)} km',
        secondaryTextKey: InstructionTextKey.distanceToStop,
        distance: distance,
        stopName: legEnd.name,
        routeColor: route.backgroundColor != null
            ? Color(route.backgroundColor!)
            : null,
        routeShortName: route.shortName,
      );
    }

    final nextStop = stops[stopIndex + 1];
    final stopsText = remainingStops == 1 ? '1 stop' : '$remainingStops stops';

    return NavigationInstruction(
      type: InstructionType.rideTransport,
      primaryText: nextStop.name,
      // English fallback; widgets render the localized plural-aware
      // navStopsRemaining via secondaryTextKey.
      secondaryText: '$stopsText remaining',
      secondaryTextKey: InstructionTextKey.stopsRemaining,
      remainingStops: remainingStops,
      stopName: nextStop.name,
      routeColor: route.backgroundColor != null
          ? Color(route.backgroundColor!)
          : null,
      routeShortName: route.shortName,
    );
  }

  /// Index of the stop where the leg a rider past [stopIndex] is on ends: the
  /// first later stop that is not [NavigationStop.isIntermediate] — the
  /// boarding stop on the walk to it, the alighting stop while riding, the
  /// destination on the last leg. Falls back to the last stop.
  int _legEndStopIndex(List<NavigationStop> stops, int stopIndex) {
    for (int i = stopIndex + 1; i < stops.length; i++) {
      if (!stops[i].isIntermediate) return i;
    }
    return stops.length - 1;
  }

  /// Meters left to `stops[targetIndex]` for a rider past [stopIndex]: from
  /// [location] to the next stop and then stop by stop, which follows the
  /// line instead of cutting straight to the target. Before the first fix
  /// it is measured from the stop at [stopIndex].
  double _distanceAlongStops(
    List<NavigationStop> stops,
    int stopIndex,
    int targetIndex,
    LocationResult? location,
  ) {
    double latitude = location?.latitude ?? stops[stopIndex].position.latitude;
    double longitude =
        location?.longitude ?? stops[stopIndex].position.longitude;
    double meters = 0;

    for (int i = stopIndex + 1; i <= targetIndex; i++) {
      final position = stops[i].position;
      meters += _locationService.distanceBetween(
        latitude,
        longitude,
        position.latitude,
        position.longitude,
      );
      latitude = position.latitude;
      longitude = position.longitude;
    }

    return meters;
  }

  NavigationInstruction _buildNextStopPreview(
    NavigationRoute route,
    int stopIndex,
  ) {
    if (stopIndex >= route.stops.length) {
      return const NavigationInstruction(
        type: InstructionType.arriveDestination,
        primaryTextKey: InstructionTextKey.finalDestination,
      );
    }

    final stop = route.stops[stopIndex];
    return NavigationInstruction(
      type: InstructionType.arriveStop,
      primaryText: stop.name,
      stopName: stop.name,
    );
  }

  NavigationError? _getPermissionError(LocationPermissionStatus status) {
    return switch (status) {
      LocationPermissionStatus.denied => NavigationError.permissionDenied,
      LocationPermissionStatus.deniedForever =>
        NavigationError.permissionDeniedForever,
      LocationPermissionStatus.serviceDisabled =>
        NavigationError.serviceDisabled,
      LocationPermissionStatus.granted => null,
    };
  }

  @override
  Future<void> close() {
    _locationService.removeListener(_onLocationUpdate);
    return super.close();
  }
}
