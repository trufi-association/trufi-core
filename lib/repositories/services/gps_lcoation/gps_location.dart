import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rxdart/rxdart.dart';

// Note: static texts; ignore translation system.
import 'alerts_location_denied.dart';

// Optional helpers (you can replace with your own snackbar implementation)
class ScreenHelpers {
  static void showSnackBar(BuildContext context, {required String text}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

/// GPS Provider:
/// - Well-thought permission request flow (disabled/denied/deniedForever)
/// - Safe retries
/// - Pausable/resumable streams
/// - Singleton API
class GPSLocationProvider {
  // Singleton
  static final GPSLocationProvider _singleton = GPSLocationProvider._internal();
  factory GPSLocationProvider() => _singleton;
  GPSLocationProvider._internal();

  // ---- Internal state ----
  final BehaviorSubject<LatLng?> _location$ = BehaviorSubject.seeded(null);
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<ServiceStatus>? _serviceStatusSub; // not available on web

  // Last raw position (from geolocator)
  Position? _lastRaw;

  // Expose read-only values
  Stream<LatLng?> get stream => _location$.stream.distinct();
  LatLng? get current => _location$.valueOrNull;
  Position? get lastRaw => _lastRaw;

  bool get _isListening => _positionSub != null;

  /// Starts continuous monitoring (if already running, restarts it).
  Future<void> start({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 10,
    Duration? timeLimit,
    BuildContext? context, // optional, to show alerts if something fails
  }) async {
    // 1) Ensure service and permission before subscribing
    final ok = await ensureServiceAndPermission(context: context);
    if (!ok) return;

    // 2) Cancel previous subscriptions for safety
    await _positionSub?.cancel();
    _positionSub = null;

    // 3) Listen to service status (Android/iOS). Not available on web.
    if (!kIsWeb) {
      await _serviceStatusSub?.cancel();
      _serviceStatusSub = Geolocator.getServiceStatusStream().listen(
        (status) async {
          if (status == ServiceStatus.disabled) {
            await _stopPositionStream();
            _location$.add(null);
          } else {
            // Retry listening
            await start(
              accuracy: accuracy,
              distanceFilterMeters: distanceFilterMeters,
              timeLimit: timeLimit,
              context: context,
            );
          }
        },
        onError: (_) {},
      );
    }

    // 4) Subscribe to position updates
    final settings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilterMeters,
      timeLimit: timeLimit,
    );

    _positionSub =
        Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        _lastRaw = pos;
        _location$.add(LatLng(pos.latitude, pos.longitude));
      },
      onError: (err) async {
        _location$.add(null);
        if (context != null) {
          await _handleError(err, context);
        }
      },
      cancelOnError: false,
    );
  }

  /// Stops monitoring (does not close the BehaviorSubject).
  Future<void> stop() async {
    await _stopPositionStream();
    await _serviceStatusSub?.cancel();
    _serviceStatusSub = null;
  }

  Future<void> _stopPositionStream() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  /// Completely disposes the provider (closes the stream as well).
  Future<void> dispose() async {
    await stop();
    await _location$.close();
  }

  // ---- Requests and checks ----

  /// Ensures service is enabled and permission is granted.
  /// Returns true if the app can access location right now.
  Future<bool> ensureServiceAndPermission({BuildContext? context}) async {
    // 1) Check if location service is enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context != null) {
        await _showServiceDisabledAlert(context);
      }
      return false;
    }

    // 2) Check and request permissions
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (context != null) {
        await _showPermissionDeniedOnceAlert(context);
      }
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      if (context != null) {
        await _showPermissionDeniedForeverAlert(context);
      }
      return false;
    }

    // iOS: accept both whenInUse and always
    return true;
  }

  /// Gets the position once, requesting permission if needed.
  /// Returns `LatLng?` (null if not possible).
  Future<LatLng?> getOnce({
    BuildContext? context,
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final ok = await ensureServiceAndPermission(context: context);
    if (!ok) return null;

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeout,
      );
      _lastRaw = pos;
      final ll = LatLng(pos.latitude, pos.longitude);
      _location$.add(ll);
      return ll;
    } on TimeoutException {
      if (context != null) {
        ScreenHelpers.showSnackBar(
          context,
          text: 'Could not get location in time.',
        );
      }
      return null;
    } catch (e) {
      if (context != null) {
        await _handleError(e, context);
      }
      return null;
    }
  }

  // ---- UI helpers (alerts) ----

  Future<void> _showServiceDisabledAlert(BuildContext context) async {
    if (kIsWeb) {
      await showDialog<void>(
        context: context,
        builder: (_) => const AlertLocationServicesDeniedWeb(),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertLocationServicesDenied(
          onOpenSettings: () async {
            await Geolocator.openLocationSettings();
          },
        ),
      );
    }
  }

  Future<void> _showPermissionDeniedOnceAlert(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location permission required'),
        content: const Text(
          'To show your location on the map, we need access to the GPS. '
          'Please grant the permission when requested.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDeniedForeverAlert(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location permission blocked'),
        content: const Text(
          'You have permanently denied location permission. '
          'To enable it, open the app settings and allow “Location”.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleError(Object err, BuildContext context) async {
    final msg = switch (err) {
      LocationServiceDisabledException _ =>
        'Location services are disabled.',
      PermissionDeniedException _ =>
        'Location permission was denied.',
      _ => 'An error occurred while reading your location.',
    };
    ScreenHelpers.showSnackBar(context, text: msg);
  }
}