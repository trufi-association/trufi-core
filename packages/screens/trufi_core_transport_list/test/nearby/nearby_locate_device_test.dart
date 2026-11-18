import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart' show LocationService;

import 'geolocator_mock.dart';

/// [locateDeviceOrThrow] over geolocator's (mocked) channel: which answer
/// of the device becomes which reason (trufi-app#78).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocationService service;
  setUp(() => service = LocationService());
  tearDown(() => service.dispose());

  /// The reason [locateDeviceOrThrow] gives; null when it found a position.
  Future<NearbyLocateFailure?> failure() async {
    try {
      await locateDeviceOrThrow(service);
      return null;
    } on NearbyLocateException catch (e) {
      return e.failure;
    }
  }

  test('a device that locates answers its position, without asking for a '
      'permission it already has', () async {
    final calls = mockGeolocator();
    expect(await locateDeviceOrThrow(service), deviceFix);
    expect(calls, isNot(contains('requestPermission')));
  });

  test('location switched off is the reason, and no permission is asked '
      'for while it could not be used', () async {
    final calls = mockGeolocator(
      serviceEnabled: false,
      checkPermission: GeoPermission.denied,
    );
    expect(await failure(), NearbyLocateFailure.serviceDisabled);
    expect(calls, isNot(contains('requestPermission')));
    expect(calls, isNot(contains('getCurrentPosition')));
  });

  test('a permission not granted yet is requested once; granted, the fix '
      'follows', () async {
    final calls = mockGeolocator(
      checkPermission: GeoPermission.denied,
      requestPermission: [GeoPermission.whileInUse],
    );
    expect(await locateDeviceOrThrow(service), deviceFix);
    expect(calls.where((method) => method == 'requestPermission'), [
      'requestPermission',
    ]);
  });

  test('"don\'t allow" on the prompt is permissionDenied: it can be asked '
      'again', () async {
    final calls = mockGeolocator(checkPermission: GeoPermission.denied);
    expect(await failure(), NearbyLocateFailure.permissionDenied);
    expect(calls, contains('requestPermission'));
    expect(calls, isNot(contains('getCurrentPosition')));
  });

  test('a request that comes back denied forever (Android, no prompt '
      'shown) is permissionDeniedForever', () async {
    mockGeolocator(
      checkPermission: GeoPermission.denied,
      requestPermission: [GeoPermission.deniedForever],
    );
    expect(await failure(), NearbyLocateFailure.permissionDeniedForever);
  });

  test('a check that already says denied forever (iOS) is not followed by '
      'a request', () async {
    final calls = mockGeolocator(checkPermission: GeoPermission.deniedForever);
    expect(await failure(), NearbyLocateFailure.permissionDeniedForever);
    expect(calls, isNot(contains('requestPermission')));
  });

  test('allowed and on, but the platform gives no position: noFix', () async {
    mockGeolocator(fix: GeoFix.fails);
    expect(await failure(), NearbyLocateFailure.noFix);
  });

  test('a platform that cannot even be asked is noFix, not an error', () async {
    const channel = MethodChannel('flutter.baseflow.com/geolocator');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      channel,
      (call) => Future.error(PlatformException(code: 'ERROR')),
    );
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    expect(await failure(), NearbyLocateFailure.noFix);
  });

  test('locateDevice keeps answering null, whatever the reason', () async {
    mockGeolocator(serviceEnabled: false);
    expect(await locateDevice(service), isNull);

    mockGeolocator(checkPermission: GeoPermission.deniedForever);
    expect(await locateDevice(service), isNull);

    mockGeolocator(fix: GeoFix.fails);
    expect(await locateDevice(service), isNull);

    mockGeolocator();
    expect(await locateDevice(service), deviceFix);
  });
}
