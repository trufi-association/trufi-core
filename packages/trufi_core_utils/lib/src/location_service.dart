import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Result of a location request.
class LocationResult {
  final double latitude;
  final double longitude;
  final double? accuracy;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  @override
  String toString() =>
      'LocationResult(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
}

/// Status of location permission.
enum LocationPermissionStatus {
  /// Permission granted.
  granted,

  /// Permission denied but can be requested again.
  denied,

  /// Permission permanently denied (user must go to settings).
  deniedForever,

  /// Location services are disabled on the device.
  serviceDisabled,
}

/// Service for accessing device location.
///
/// This service wraps the geolocator package and provides a simple API
/// for getting the current location and checking/requesting permissions.
///
/// Usage:
/// ```dart
/// final locationService = LocationService();
///
/// // Check if location is available
/// final status = await locationService.checkPermission();
/// if (status == LocationPermissionStatus.granted) {
///   final location = await locationService.getCurrentLocation();
///   print('Current location: ${location?.latitude}, ${location?.longitude}');
/// }
/// ```
class LocationService extends ChangeNotifier {
  Position? _lastKnownPosition;
  LocationPermissionStatus? _lastPermissionStatus;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTracking = false;
  LocationResult? _currentLocation;

  /// The last known position.
  Position? get lastKnownPosition => _lastKnownPosition;

  /// The last checked permission status.
  LocationPermissionStatus? get lastPermissionStatus => _lastPermissionStatus;

  /// Whether the service is currently tracking location.
  bool get isTracking => _isTracking;

  /// The current location (updated when tracking).
  LocationResult? get currentLocation => _currentLocation;

  /// Checks if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Checks the current permission status without requesting.
  Future<LocationPermissionStatus> checkPermission() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      _lastPermissionStatus = LocationPermissionStatus.serviceDisabled;
      notifyListeners();
      return LocationPermissionStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    _lastPermissionStatus = _mapPermission(permission);
    notifyListeners();
    return _lastPermissionStatus!;
  }

  /// Requests location permission from the user.
  ///
  /// Returns the new permission status after the request.
  Future<LocationPermissionStatus> requestPermission() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      _lastPermissionStatus = LocationPermissionStatus.serviceDisabled;
      notifyListeners();
      return LocationPermissionStatus.serviceDisabled;
    }

    final permission = await Geolocator.requestPermission();
    _lastPermissionStatus = _mapPermission(permission);
    notifyListeners();
    return _lastPermissionStatus!;
  }

  /// Gets the current device location.
  ///
  /// Returns null if permission is not granted or location services are disabled.
  /// Throws [LocationServiceException] if an error occurs.
  Future<LocationResult?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeout,
  }) async {
    final status = await checkPermission();
    if (status != LocationPermissionStatus.granted) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeout ?? const Duration(seconds: 15),
        ),
      );

      _lastKnownPosition = position;
      notifyListeners();

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (e) {
      throw LocationServiceException('Failed to get location: $e');
    }
  }

  /// Gets the last known location (faster, may be stale).
  ///
  /// Returns null if no last known position is available.
  Future<LocationResult?> getLastKnownLocation() async {
    final status = await checkPermission();
    if (status != LocationPermissionStatus.granted) {
      return null;
    }

    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      _lastKnownPosition = position;
      notifyListeners();

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (e) {
      return null;
    }
  }

  /// Opens the device's location settings.
  ///
  /// Use this when location services are disabled.
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  /// Opens the app's settings page.
  ///
  /// Use this when permission is permanently denied.
  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  /// Calculates the distance in meters between two points.
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Starts tracking the device location continuously.
  ///
  /// The [currentLocation] property will be updated as the device moves.
  /// Listen to this service via [addListener] to receive updates.
  ///
  /// [distanceFilter] - Minimum distance (in meters) before an update is sent.
  /// [accuracy] - The accuracy of the location data.
  ///
  /// Returns true if tracking started successfully, false otherwise.
  Future<bool> startTracking({
    int distanceFilter = 10,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    if (_isTracking) return true;

    final status = await checkPermission();
    if (status != LocationPermissionStatus.granted) {
      return false;
    }

    try {
      final locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _lastKnownPosition = position;
          _currentLocation = LocationResult(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
          );
          notifyListeners();
        },
        onError: (error) {
          // Handle stream errors silently, tracking continues
          debugPrint('Location stream error: $error');
        },
      );

      _isTracking = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to start location tracking: $e');
      return false;
    }
  }

  /// Stops tracking the device location.
  Future<void> stopTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  /// Disposes of the service and stops any active tracking.
  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }

  LocationPermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
    }
  }
}

/// Exception thrown by [LocationService].
class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
