import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trufi_core_utils/src/location_service.dart';

class _MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}

Position _fakePosition({double lat = -17.39, double lng = -66.16, double acc = 5}) {
  return Position(
    latitude: lat,
    longitude: lng,
    accuracy: acc,
    timestamp: DateTime(2026, 1, 1),
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

void main() {
  late _MockGeolocatorPlatform mockPlatform;
  late LocationService service;

  setUpAll(() {
    registerFallbackValue(const LocationSettings());
  });

  setUp(() {
    mockPlatform = _MockGeolocatorPlatform();
    service = LocationService(platform: mockPlatform);

    // Sensible defaults — individual tests override what they care about.
    when(() => mockPlatform.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(() => mockPlatform.checkPermission())
        .thenAnswer((_) async => LocationPermission.always);
    when(() => mockPlatform.requestPermission())
        .thenAnswer((_) async => LocationPermission.always);
    when(
      () => mockPlatform.getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) => const Stream<Position>.empty());
  });

  tearDown(() => service.dispose());

  group('checkPermission', () {
    test('returns serviceDisabled when location services are off', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      final status = await service.checkPermission();

      expect(status, LocationPermissionStatus.serviceDisabled);
      verifyNever(() => mockPlatform.checkPermission());
    });

    test('maps LocationPermission.always to granted', () async {
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);

      expect(await service.checkPermission(), LocationPermissionStatus.granted);
    });

    test('maps LocationPermission.whileInUse to granted', () async {
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);

      expect(await service.checkPermission(), LocationPermissionStatus.granted);
    });

    test('maps LocationPermission.denied to denied', () async {
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      expect(await service.checkPermission(), LocationPermissionStatus.denied);
    });

    test('maps LocationPermission.deniedForever to deniedForever', () async {
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      expect(
        await service.checkPermission(),
        LocationPermissionStatus.deniedForever,
      );
    });

    test('maps LocationPermission.unableToDetermine to denied', () async {
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.unableToDetermine);

      expect(await service.checkPermission(), LocationPermissionStatus.denied);
    });
  });

  group('requestPermission', () {
    test('returns serviceDisabled without prompting when services are off',
        () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      final status = await service.requestPermission();

      expect(status, LocationPermissionStatus.serviceDisabled);
      verifyNever(() => mockPlatform.requestPermission());
    });

    test('returns granted when the user accepts', () async {
      when(() => mockPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);

      expect(
        await service.requestPermission(),
        LocationPermissionStatus.granted,
      );
    });
  });

  group('getCurrentLocation', () {
    test('returns null when permission is denied', () async {
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      final result = await service.getCurrentLocation();

      expect(result, isNull);
      verifyNever(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      );
    });

    test('returns a LocationResult when permission is granted', () async {
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => _fakePosition(lat: 1, lng: 2, acc: 7));

      final result = await service.getCurrentLocation();

      expect(result, isNotNull);
      expect(result!.latitude, 1);
      expect(result.longitude, 2);
      expect(result.accuracy, 7);
    });

    test('propagates the provided timeout as timeLimit', () async {
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => _fakePosition());

      await service.getCurrentLocation(timeout: const Duration(seconds: 3));

      final captured = verify(
        () => mockPlatform.getCurrentPosition(
          locationSettings: captureAny(named: 'locationSettings'),
        ),
      ).captured.single as LocationSettings;
      expect(captured.timeLimit, const Duration(seconds: 3));
    });

    test('defaults to a 15-second timeLimit when none is provided', () async {
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => _fakePosition());

      await service.getCurrentLocation();

      final captured = verify(
        () => mockPlatform.getCurrentPosition(
          locationSettings: captureAny(named: 'locationSettings'),
        ),
      ).captured.single as LocationSettings;
      expect(captured.timeLimit, const Duration(seconds: 15));
    });

    test('wraps platform errors in LocationServiceException', () async {
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenThrow(TimeoutException('GPS timed out'));

      expect(
        () => service.getCurrentLocation(),
        throwsA(isA<LocationServiceException>()),
      );
    });
  });

  group('getLastKnownLocation', () {
    test('returns null when permission is denied', () async {
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      expect(await service.getLastKnownLocation(), isNull);
    });

    test('returns null when platform has no last position', () async {
      when(() => mockPlatform.getLastKnownPosition())
          .thenAnswer((_) async => null);

      expect(await service.getLastKnownLocation(), isNull);
    });

    test('returns a LocationResult when a last position is available',
        () async {
      when(() => mockPlatform.getLastKnownPosition())
          .thenAnswer((_) async => _fakePosition(lat: 5, lng: 6));

      final result = await service.getLastKnownLocation();

      expect(result?.latitude, 5);
      expect(result?.longitude, 6);
    });

    test('swallows platform errors and returns null', () async {
      when(() => mockPlatform.getLastKnownPosition())
          .thenThrow(Exception('boom'));

      expect(await service.getLastKnownLocation(), isNull);
    });
  });

  group('startTracking', () {
    test('returns false and does not subscribe when permission is denied',
        () async {
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      final started = await service.startTracking();

      expect(started, isFalse);
      expect(service.isTracking, isFalse);
      verifyNever(
        () => mockPlatform.getPositionStream(
          locationSettings: any(named: 'locationSettings'),
        ),
      );
    });

    test('returns true and flips isTracking when permission is granted',
        () async {
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => _fakePosition());

      final started = await service.startTracking();

      expect(started, isTrue);
      expect(service.isTracking, isTrue);
    });

    test('is a no-op when already tracking', () async {
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => _fakePosition());

      await service.startTracking();
      final secondStart = await service.startTracking();

      expect(secondStart, isTrue);
      verify(
        () => mockPlatform.getPositionStream(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).called(1);
    });

    test(
      'initial getCurrentPosition has a 10s timeLimit (issue #897 web freeze fix)',
      () async {
        when(
          () => mockPlatform.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          ),
        ).thenAnswer((_) async => _fakePosition());

        await service.startTracking();

        final captured = verify(
          () => mockPlatform.getCurrentPosition(
            locationSettings: captureAny(named: 'locationSettings'),
          ),
        ).captured.single as LocationSettings;
        expect(
          captured.timeLimit,
          const Duration(seconds: 10),
          reason:
              'Without a timeLimit, getCurrentPosition can hang indefinitely '
              'on web waiting for a high-accuracy fix.',
        );
      },
    );

    test('stays tracking even when initial fix times out', () async {
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenThrow(TimeoutException('no fix'));

      final started = await service.startTracking();

      expect(started, isTrue);
      expect(service.isTracking, isTrue);
      expect(service.currentLocation, isNull);
    });

    test('updates currentLocation as the position stream emits', () async {
      final controller = StreamController<Position>();
      addTearDown(controller.close);

      when(
        () => mockPlatform.getPositionStream(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) => controller.stream);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => _fakePosition());

      await service.startTracking();
      controller.add(_fakePosition(lat: 10, lng: 20));
      await Future<void>.delayed(Duration.zero);

      expect(service.currentLocation?.latitude, 10);
      expect(service.currentLocation?.longitude, 20);
    });
  });

  group('stopTracking', () {
    test('flips isTracking back to false', () async {
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => _fakePosition());

      await service.startTracking();
      expect(service.isTracking, isTrue);

      await service.stopTracking();
      expect(service.isTracking, isFalse);
    });
  });

  group('dispose', () {
    test('stops tracking', () async {
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => _fakePosition());

      await service.startTracking();
      service.dispose();

      expect(service.isTracking, isFalse);
    });
  });
}
