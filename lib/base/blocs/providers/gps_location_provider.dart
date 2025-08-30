import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/subjects.dart';

import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/alerts/alerts_location_denied.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class GPSLocationProvider {
  StreamSubscription<Position>? _locationStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  static final GPSLocationProvider _singleton = GPSLocationProvider._internal();

  factory GPSLocationProvider() => _singleton;

  GPSLocationProvider._internal();

  final _streamLocation = BehaviorSubject<TrufiLatLng?>.seeded(null);

  Stream<TrufiLatLng?> get streamLocation => _streamLocation.stream;
  TrufiLatLng? get myLocation => _streamLocation.value;

  Future<void> start() async {
    // GPS status reading
    // web platform no supported Geolocator.getServiceStatusStream()
    if (!kIsWeb) {
      _serviceStatusStreamSubscription ??=
          Geolocator.getServiceStatusStream().listen((serviceStatus) {
        if (serviceStatus == ServiceStatus.disabled) {
          _streamLocation.add(null);
          _locationStreamSubscription?.cancel();
          _locationStreamSubscription = null;
          return;
        } else {
          _locationStreamSubscription?.cancel();
          _locationStreamSubscription = null;
          _locationStreamSubscription ??= Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          )).listen((position) {
            _streamLocation
                .add(TrufiLatLng(position.latitude, position.longitude));
          });
        }
      });
    }

    // GPS read permission
    final LocationPermission status = await Geolocator.checkPermission();
    if (!(status == LocationPermission.always ||
        status == LocationPermission.whileInUse)) {
      _streamLocation.add(null);
      return;
    }

    // restart location if serviceStatus is disabled
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      _streamLocation.add(null);
      return;
    }

    // listen current location
    _locationStreamSubscription ??= Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    )).listen((position) {
      _streamLocation.add(TrufiLatLng(position.latitude, position.longitude));
    });
  }

  Future<TrufiLatLng?> startLocation(BuildContext context, bool mounted) async {
    final LocationPermission status = await Geolocator.checkPermission();
    // check GPS Permision Platform(Web, Android and iOS)
    if (!mounted) return null;
    await _checkGPSPermisionPlatform(context, status);

    // listen current location
    final locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );

    final firstPosition = await locationStream.first;
    final firstLocation =
        TrufiLatLng(firstPosition.latitude, firstPosition.longitude);

    _locationStreamSubscription ??= locationStream.listen((position) {
      final liveLocation = TrufiLatLng(position.latitude, position.longitude);
      _streamLocation.add(liveLocation);
    });

    return firstLocation;
  }

  Future<TrufiLatLng?> startCityLocation(
      BuildContext context, bool mounted) async {
    final LocationPermission status = await Geolocator.checkPermission();
    if ([
      LocationPermission.denied,
      LocationPermission.deniedForever,
      LocationPermission.unableToDetermine,
    ].contains(status)) {
      return null;
    }
    // listen current location
    final locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );

    final firstPosition = await locationStream.first;
    final firstLocation =
        TrufiLatLng(firstPosition.latitude, firstPosition.longitude);

    _locationStreamSubscription ??= locationStream.listen((position) {
      final liveLocation = TrufiLatLng(position.latitude, position.longitude);
      _streamLocation.add(liveLocation);
    });

    return firstLocation;
  }

  Future<void> _checkGPSPermisionPlatform(
    BuildContext context,
    LocationPermission status,
  ) async {
    if (kIsWeb) {
      await _checkWebPermision(context, status);
    } else if (Platform.isIOS) {
      await _checkIOSPermision(context, status);
    } else {
      await _checkAndroidPermision(context, status);
    }
  }

  Future<void> _checkAndroidPermision(
    BuildContext context,
    LocationPermission status,
  ) async {
    if (!(status == LocationPermission.always ||
        status == LocationPermission.whileInUse)) {
      final requestStatus = await Geolocator.requestPermission();
      if (requestStatus == LocationPermission.deniedForever) {
        await showTrufiDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => const AlertLocationServicesDenied(),
        );
        return;
      } else if (!(requestStatus == LocationPermission.always ||
          requestStatus == LocationPermission.whileInUse)) {
        return;
      }
    }
  }

  Future<void> _checkIOSPermision(
    BuildContext context,
    LocationPermission status,
  ) async {
    if (status == LocationPermission.deniedForever) {
      await showTrufiDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const AlertLocationServicesDenied(),
      );
      return;
    } else if (!(status == LocationPermission.always ||
        status == LocationPermission.whileInUse)) {
      final requestStatus = await Geolocator.requestPermission();
      if (!(requestStatus == LocationPermission.always ||
          requestStatus == LocationPermission.whileInUse)) {
        return;
      }
    }
  }

  Future<void> _checkWebPermision(
    BuildContext context,
    LocationPermission status,
  ) async {
    if (status == LocationPermission.deniedForever) {
      await showTrufiDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const AlertLocationServicesDeniedWeb(),
      );
      return;
    } else if (!(status == LocationPermission.always ||
        status == LocationPermission.whileInUse)) {
      final requestStatus = await Geolocator.requestPermission();
      if (!(requestStatus == LocationPermission.always ||
          requestStatus == LocationPermission.whileInUse)) {
        return;
      }
    }
  }

  void close() async {
    await _streamLocation.close();
  }

  void stop() async {
    if (_locationStreamSubscription != null) {
      await _locationStreamSubscription?.cancel();
      _locationStreamSubscription = null;
    }
    if (_serviceStatusStreamSubscription != null) {
      await _serviceStatusStreamSubscription?.cancel();
      _serviceStatusStreamSubscription = null;
    }
  }
}
