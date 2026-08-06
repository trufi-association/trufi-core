import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide LatLngBounds;
import 'package:trufi_core_maps/src/presentation/map/trufi_map.dart';

void main() {
  const base = CameraPosition(
    target: LatLng(15.3584, 44.2035),
    zoom: 14.0,
    bearing: 0.0,
    tilt: 0.0,
  );

  CameraPosition vary({
    double? lat,
    double? lng,
    double? zoom,
    double? bearing,
    double? tilt,
  }) =>
      CameraPosition(
        target: LatLng(lat ?? base.target.latitude, lng ?? base.target.longitude),
        zoom: zoom ?? base.zoom,
        bearing: bearing ?? base.bearing,
        tilt: tilt ?? base.tilt,
      );

  group('camerasEffectivelyEqual', () {
    test('identical cameras are equal', () {
      expect(camerasEffectivelyEqual(base, vary()), isTrue);
    });

    test('tiny floating-point drift stays equal', () {
      expect(
        camerasEffectivelyEqual(base, vary(lat: 15.3584 + 1e-12)),
        isTrue,
      );
    });

    test('latitude difference is detected', () {
      expect(camerasEffectivelyEqual(base, vary(lat: 15.3585)), isFalse);
    });

    test('longitude difference is detected', () {
      expect(camerasEffectivelyEqual(base, vary(lng: 44.2036)), isFalse);
    });

    test('zoom difference is detected', () {
      expect(camerasEffectivelyEqual(base, vary(zoom: 14.5)), isFalse);
    });

    test('bearing difference is detected', () {
      expect(camerasEffectivelyEqual(base, vary(bearing: 90.0)), isFalse);
    });

    test('tilt difference is detected', () {
      expect(camerasEffectivelyEqual(base, vary(tilt: 30.0)), isFalse);
    });

    test('bearing wrap-around: 270° equals -90° (web vs native convention)',
        () {
      expect(
        camerasEffectivelyEqual(vary(bearing: 270.0), vary(bearing: -90.0)),
        isTrue,
      );
    });

    test('bearing wrap-around: 0° equals 360°', () {
      expect(
        camerasEffectivelyEqual(vary(bearing: 0.0), vary(bearing: 360.0)),
        isTrue,
      );
    });

    test('bearing wrap-around: 359.9° differs from 0.2° by 0.3°, not 359.7°',
        () {
      expect(
        camerasEffectivelyEqual(vary(bearing: 359.9), vary(bearing: 0.2)),
        isFalse, // 0.3° apart — real difference, but computed the short way
      );
    });
  });
}
