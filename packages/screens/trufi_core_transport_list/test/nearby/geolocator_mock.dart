import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

/// The position the mocked device reports.
const deviceFix = LatLng(-17.40, -66.16);

/// Indexes of geolocator's `LocationPermission`: what its channel answers
/// to `checkPermission` and `requestPermission`.
abstract final class GeoPermission {
  static const int denied = 0;
  static const int deniedForever = 1;
  static const int whileInUse = 2;
}

/// How the mocked device answers `getCurrentPosition`.
enum GeoFix {
  /// With [deviceFix].
  found,

  /// With a platform error.
  fails,

  /// Not at all: the caller's time limit decides.
  never,
}

/// Answers geolocator's method channel in-process: without a handler the
/// real channel never replies under the test's fake async, so the screen
/// would spin on "locating" forever.
///
/// The defaults are a device that locates. [serviceEnabled] false is
/// location switched off. [checkPermission] is the [GeoPermission] the
/// device starts with and [requestPermission] what the rider answers to
/// each prompt in turn (the last answer repeats; by default the prompt
/// changes nothing). As on a device, a prompt answered "allow" is what
/// later checks report; a denial is not — Android keeps answering
/// "denied" to a check even after a request came back "denied forever",
/// while iOS reports "denied forever" on the check itself.
/// [settingsFail] makes both settings pages fail to open.
///
/// Returns the methods the code under test called, in order.
List<String> mockGeolocator({
  bool serviceEnabled = true,
  int checkPermission = GeoPermission.whileInUse,
  List<int> requestPermission = const [],
  GeoFix fix = GeoFix.found,
  bool settingsFail = false,
}) {
  const channel = MethodChannel('flutter.baseflow.com/geolocator');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <String>[];
  var permission = checkPermission;
  var prompts = 0;

  messenger.setMockMethodCallHandler(channel, (call) {
    calls.add(call.method);
    switch (call.method) {
      case 'isLocationServiceEnabled':
        return Future.value(serviceEnabled);
      case 'checkPermission':
        return Future.value(permission);
      case 'requestPermission':
        if (requestPermission.isEmpty) return Future.value(permission);
        final answer = prompts < requestPermission.length
            ? requestPermission[prompts]
            : requestPermission.last;
        prompts++;
        if (answer == GeoPermission.whileInUse) permission = answer;
        return Future.value(answer);
      case 'getCurrentPosition':
        return switch (fix) {
          GeoFix.found => Future.value({
            'latitude': deviceFix.latitude,
            'longitude': deviceFix.longitude,
            'timestamp': 0,
            'accuracy': 10.0,
          }),
          GeoFix.fails => Future.error(
            PlatformException(code: 'LOCATION_UPDATE_FAILURE'),
          ),
          GeoFix.never => Completer<Object?>().future,
        };
      case 'openAppSettings':
      case 'openLocationSettings':
        return settingsFail
            ? Future.error(PlatformException(code: 'ERROR'))
            : Future.value(true);
    }
    return Future.value(null);
  });
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  return calls;
}
