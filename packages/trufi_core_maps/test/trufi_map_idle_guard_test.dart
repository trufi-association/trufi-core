import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart' hide LatLngBounds;

/// #995 / #946: a controlled camera set before the map's style has loaded is
/// held and replayed on `onStyleLoaded`. Android fires a `camera#onIdle` for
/// the initial position before the style is ready; recording it as the
/// current camera turned that replay into an "already there" no-op.
///
/// Drives the real [TrufiMap] over a fake [MapLibrePlatform] (the plugin's
/// `MapLibrePlatform.createInstance` seam, no platform view) and plays the
/// native event order by hand: `onCameraIdlePlatform` is `camera#onIdle`,
/// `onMapStyleLoadedPlatform` is `map#onStyleLoaded`.
class _FakePlatform extends MapLibrePlatform {
  bool _created = false;
  final moves = <CameraPosition>[];
  final visible = LatLngBounds(
    southwest: const LatLng(15.30, 44.15),
    northeast: const LatLng(15.40, 44.25),
  );

  @override
  Widget buildView(
    Map<String, dynamic> creationParams,
    OnPlatformViewCreatedCallback onPlatformViewCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  ) {
    // Exactly once: a second call would complete the plugin's controller
    // future twice and attach duplicate controllers.
    if (!_created) {
      _created = true;
      scheduleMicrotask(() => onPlatformViewCreated(0));
    }
    return const SizedBox.expand();
  }

  @override
  Future<void> initPlatform(int id) async {}

  @override
  Future<bool?> moveCamera(CameraUpdate cameraUpdate) async {
    final json = cameraUpdate.toJson() as List<dynamic>;
    if (json.first != 'newCameraPosition') {
      throw StateError('unexpected camera update $json');
    }
    final map = json[1] as Map<String, dynamic>;
    final target = map['target'] as List<dynamic>;
    moves.add(
      CameraPosition(
        target: LatLng(
          (target[0] as num).toDouble(),
          (target[1] as num).toDouble(),
        ),
        zoom: (map['zoom'] as num).toDouble(),
        bearing: (map['bearing'] as num).toDouble(),
        tilt: (map['tilt'] as num).toDouble(),
      ),
    );
    return true;
  }

  @override
  Future<LatLngBounds> getVisibleRegion() async => visible;

  @override
  Future<CameraPosition?> updateMapOptions(
    Map<String, dynamic> optionsUpdate,
  ) async => null;

  // Every other platform call made while syncing layers or initialising the
  // annotation managers returns a completed Future<void>.
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

const _initial = TrufiCameraPosition(
  target: latlng.LatLng(15.347, 44.205),
  zoom: 14,
);
// TrufiMap converts Leaflet zoom levels to MapLibre ones (one level apart).
const _initialNative = CameraPosition(target: LatLng(15.347, 44.205), zoom: 13);
const _fitted = TrufiCameraPosition(
  target: latlng.LatLng(15.3244, 44.2205),
  zoom: 12.31,
);
const _fittedNative = CameraPosition(
  target: LatLng(15.3244, 44.2205),
  zoom: 11.31,
);
const _panned = CameraPosition(target: LatLng(15.30, 44.26), zoom: 15.5);

class _Harness {
  _Harness(this.tester) {
    MapLibrePlatform.createInstance = () => platform;
  }

  final WidgetTester tester;
  final platform = _FakePlatform();
  final reports = <TrufiCameraPosition>[];

  Widget _build(TrufiCameraPosition? camera) => MaterialApp(
    home: TrufiMap(
      styleString: 'asset://style.json',
      initialCamera: _initial,
      camera: camera,
      onCameraChanged: reports.add,
    ),
  );

  Future<void> mount() async {
    await tester.pumpWidget(_build(null));
    await tester.pump(); // platform view "created" → controller handed over
  }

  Future<void> setControlledCamera(TrufiCameraPosition camera) async {
    await tester.pumpWidget(_build(camera));
  }

  /// camera#onIdle from the native side.
  Future<void> nativeIdle(CameraPosition position) async {
    platform.onCameraIdlePlatform(position);
    await tester.pump();
    await tester.pump();
  }

  /// map#onStyleLoaded from the native side.
  Future<void> styleLoaded() async {
    platform.onMapStyleLoadedPlatform(null);
    await tester.pumpAndSettle();
    // TrufiMap schedules a 1 s retry of the layer sync after the style load.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }
}

void main() {
  tearDown(() {
    MapLibrePlatform.createInstance = () => MapLibreMethodChannel();
  });

  group('TrufiMap controlled camera vs the pre-style camera idle', () {
    testWidgets('#995 order: controlled camera → initial idle → style loaded: '
        'the idle is ignored and the camera is replayed on style load', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.mount();
      await h.setControlledCamera(_fitted);
      expect(h.platform.moves, isEmpty, reason: 'style not loaded yet');

      // Android: camera#onIdle for the initial position before the style.
      await h.nativeIdle(_initialNative);
      expect(
        h.reports,
        isEmpty,
        reason:
            'the initial idle must not be reported while a controlled '
            'camera is pending (it would also overwrite the pending camera)',
      );

      await h.styleLoaded();
      expect(h.platform.moves, hasLength(1), reason: 'replay on style load');
      final move = h.platform.moves.single;
      expect(
        move.target.latitude,
        closeTo(_fittedNative.target.latitude, 1e-9),
      );
      expect(
        move.target.longitude,
        closeTo(_fittedNative.target.longitude, 1e-9),
      );
      expect(move.zoom, closeTo(_fittedNative.zoom, 1e-9));

      // The idle produced by that programmatic move is swallowed (callback
      // suppression, as on the normal path)…
      await h.nativeIdle(_fittedNative);
      expect(h.reports, isEmpty);
      // …and the guard is not stuck: the next gesture is reported.
      await h.nativeIdle(_panned);
      expect(h.reports, hasLength(1));
      expect(h.reports.single.target.latitude, closeTo(15.30, 1e-9));
      expect(h.reports.single.zoom, closeTo(16.5, 1e-9)); // 15.5 + 1
    });

    testWidgets('#946 order: initial idle → controlled camera → style loaded: '
        'still replayed (unchanged)', (tester) async {
      final h = _Harness(tester);
      await h.mount();
      await h.nativeIdle(_initialNative);
      expect(h.reports, hasLength(1), reason: 'nothing pending: reported');

      await h.setControlledCamera(_fitted);
      await h.styleLoaded();
      expect(h.platform.moves, hasLength(1));
      expect(h.platform.moves.single.zoom, closeTo(_fittedNative.zoom, 1e-9));
    });

    testWidgets(
      'a pan during the style load loses against the pending controlled '
      'camera (documented semantics of the guard)',
      (tester) async {
        final h = _Harness(tester);
        await h.mount();
        await h.setControlledCamera(_fitted);
        await h.nativeIdle(_initialNative);
        await h.nativeIdle(_panned); // user pans the blank map
        expect(h.reports, isEmpty);

        await h.styleLoaded();
        expect(h.platform.moves, hasLength(1));
        expect(h.platform.moves.single.zoom, closeTo(_fittedNative.zoom, 1e-9));
      },
    );

    testWidgets(
      'pending camera and the map already there (user panned to it during '
      'the style load): no move, no suppression, the next gesture is reported',
      (tester) async {
        final h = _Harness(tester);
        await h.mount();
        await h.setControlledCamera(_fitted);
        await h.nativeIdle(_initialNative);
        await h.nativeIdle(_fittedNative); // the user happens to pan there
        expect(h.reports, isEmpty);
        await h.styleLoaded();
        expect(h.platform.moves, isEmpty, reason: 'already there');

        await h.nativeIdle(_panned);
        expect(h.reports, hasLength(1), reason: 'no suppression armed');
      },
    );

    testWidgets(
      'no controlled camera: idles are reported before and after the style '
      'load (the guard is inert)',
      (tester) async {
        final h = _Harness(tester);
        await h.mount();
        await h.nativeIdle(_initialNative);
        await h.styleLoaded();
        await h.nativeIdle(_panned);
        expect(h.reports, hasLength(2));
        expect(h.platform.moves, isEmpty);
      },
    );

    testWidgets(
      'a controlled camera set AFTER the style loaded moves immediately and '
      'its own idle is swallowed',
      (tester) async {
        final h = _Harness(tester);
        await h.mount();
        await h.nativeIdle(_initialNative);
        await h.styleLoaded();
        await h.setControlledCamera(_fitted);
        expect(h.platform.moves, hasLength(1));
        await h.nativeIdle(_fittedNative);
        expect(h.reports, hasLength(1), reason: 'only the first idle');
        await h.nativeIdle(_panned);
        expect(h.reports, hasLength(2));
      },
    );
  });
}
