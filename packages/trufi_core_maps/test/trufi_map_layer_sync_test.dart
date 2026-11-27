import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart' hide LatLngBounds;

/// trufi-lima#16: every rebuild of the home re-sent the GeoJSON of every
/// visible layer to MapLibre (816 "Paraderos" markers: 3.4 s of lag on a
/// mid-range phone). `TrufiMap` must send a layer only when its content
/// changed since the last send.
///
/// Drives the real [TrufiMap] over a fake [MapLibrePlatform] (same seam as
/// `trufi_map_idle_guard_test.dart`) and counts `setGeoJsonSource` per
/// source. Layers are rebuilt from scratch on every pump, as the home does:
/// new marker and line objects, new widgets, equal content.
class _FakePlatform extends MapLibrePlatform {
  bool _created = false;

  /// Every `setGeoJsonSource`: source id, in call order.
  final sent = <String>[];

  int sentCount(String id) => sent.where((s) => s == id).length;

  @override
  Widget buildView(
    Map<String, dynamic> creationParams,
    OnPlatformViewCreatedCallback onPlatformViewCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  ) {
    if (!_created) {
      _created = true;
      scheduleMicrotask(() => onPlatformViewCreated(0));
    }
    return const SizedBox.expand();
  }

  @override
  Future<void> initPlatform(int id) async {}

  @override
  Future<void> setGeoJsonSource(
    String sourceId,
    Map<String, dynamic> geojson,
  ) async {
    sent.add(sourceId);
  }

  @override
  Future<CameraPosition?> updateMapOptions(
    Map<String, dynamic> optionsUpdate,
  ) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

const _initial = TrufiCameraPosition(
  target: latlng.LatLng(-12.0464, -77.0428),
  zoom: 14,
);

// Pre-rendered image bytes: the test needs no widget-to-PNG rasterisation.
final _png = Uint8List.fromList(const [137, 80, 78, 71]);

/// [count] markers on a grid; [moved] shifts the marker with that index.
List<TrufiMarker> _markers(int count, {int? moved}) => [
  for (var i = 0; i < count; i++)
    TrufiMarker(
      id: 'stop-$i',
      position: latlng.LatLng(
        -12.0 - (i ~/ 40) * 0.001 - (i == moved ? 0.0005 : 0),
        -77.0 + (i % 40) * 0.001,
      ),
      widget: const SizedBox(width: 8, height: 8),
      widgetBytes: _png,
      imageCacheKey: 'stop',
    ),
];

TrufiLayer _stops({int count = 800, int? moved}) =>
    TrufiLayer(id: 'stops', markers: _markers(count, moved: moved));

TrufiLayer _route({double lastLat = -12.05}) => TrufiLayer(
  id: 'route',
  lines: [
    TrufiLine(
      id: 'leg-1',
      position: [
        const latlng.LatLng(-12.0464, -77.0428),
        latlng.LatLng(lastLat, -77.03),
      ],
      color: Colors.red,
    ),
  ],
);

class _Harness {
  _Harness(this.tester) {
    MapLibrePlatform.createInstance = () => platform;
  }

  final WidgetTester tester;
  final platform = _FakePlatform();

  Widget _build(List<TrufiLayer> layers) => MaterialApp(
    home: TrufiMap(
      styleString: 'asset://style.json',
      initialCamera: _initial,
      layers: layers,
    ),
  );

  /// Mounts the map, plays `map#onStyleLoaded` and lets the sync (and its 1 s
  /// retry) finish.
  Future<void> mount(List<TrufiLayer> layers) async {
    await tester.pumpWidget(_build(layers));
    await tester.pump(); // platform view created
    await styleLoaded();
  }

  Future<void> styleLoaded() async {
    platform.onMapStyleLoadedPlatform(null);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  /// A rebuild of the parent with [layers] (fresh objects, as the home does).
  Future<void> rebuild(List<TrufiLayer> layers) async {
    await tester.pumpWidget(_build(layers));
    await tester.pumpAndSettle();
  }
}

void main() {
  tearDown(() {
    MapLibrePlatform.createInstance = () => MapLibreMethodChannel();
  });

  group('TrufiMap sends a layer to MapLibre only when it changed', () {
    testWidgets('known positive: the first sync sends each layer', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.mount([_stops(), _route()]);

      expect(h.platform.sentCount('stops'), greaterThanOrEqualTo(1));
      expect(h.platform.sentCount('route'), greaterThanOrEqualTo(1));
    });

    testWidgets('10 rebuilds with an unchanged 800-marker layer: 0 more sends '
        'for it (nor for the unchanged line layer)', (tester) async {
      final h = _Harness(tester);
      await h.mount([_stops(), _route()]);
      final stopsBefore = h.platform.sentCount('stops');
      final routeBefore = h.platform.sentCount('route');

      for (var i = 0; i < 10; i++) {
        await h.rebuild([_stops(), _route()]);
      }

      expect(
        h.platform.sentCount('stops') - stopsBefore,
        0,
        reason: 'equal markers (new objects, same content) must not be re-sent',
      );
      expect(h.platform.sentCount('route') - routeBefore, 0);
    });

    testWidgets('one marker of the 800 moves: that layer is sent again, once, '
        'and the other layer is not', (tester) async {
      final h = _Harness(tester);
      await h.mount([_stops(), _route()]);
      final stopsBefore = h.platform.sentCount('stops');
      final routeBefore = h.platform.sentCount('route');

      await h.rebuild([_stops(moved: 123), _route()]);

      expect(
        h.platform.sentCount('stops') - stopsBefore,
        1,
        reason: 'same count, one position changed: still a change',
      );
      expect(h.platform.sentCount('route') - routeBefore, 0);
    });

    testWidgets('one layer changes (the line): only that layer is sent', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.mount([_stops(), _route()]);
      final stopsBefore = h.platform.sentCount('stops');
      final routeBefore = h.platform.sentCount('route');

      await h.rebuild([_stops(), _route(lastLat: -12.06)]);

      expect(h.platform.sentCount('route') - routeBefore, 1);
      expect(
        h.platform.sentCount('stops') - stopsBefore,
        0,
        reason: 'the 800-marker layer did not change',
      );
    });

    testWidgets('a marker removed from the layer: it is sent again', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.mount([_stops()]);
      final before = h.platform.sentCount('stops');

      await h.rebuild([_stops(count: 799)]);

      expect(h.platform.sentCount('stops') - before, 1);
    });

    testWidgets('a new layer is sent; the existing ones are not', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.mount([_stops()]);
      final stopsBefore = h.platform.sentCount('stops');
      expect(h.platform.sentCount('route'), 0);

      await h.rebuild([_stops(), _route()]);

      expect(h.platform.sentCount('route'), 1, reason: 'new layer: sent');
      expect(h.platform.sentCount('stops') - stopsBefore, 0);
    });

    testWidgets('hidden then shown again (removed, re-added): sent again', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.mount([_stops(), _route()]);
      final before = h.platform.sentCount('stops');

      await h.rebuild([_stops().copyWith(visible: false), _route()]);
      await h.rebuild([_stops(), _route()]);

      expect(
        h.platform.sentCount('stops') - before,
        greaterThanOrEqualTo(1),
        reason: 'the source was removed and re-created: it needs its data',
      );
    });

    testWidgets('after a style reload every layer is sent again', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.mount([_stops(), _route()]);
      final stopsBefore = h.platform.sentCount('stops');
      final routeBefore = h.platform.sentCount('route');

      await h.styleLoaded();

      expect(
        h.platform.sentCount('stops') - stopsBefore,
        greaterThanOrEqualTo(1),
        reason: 'the new style has empty sources',
      );
      expect(h.platform.sentCount('route') - routeBefore, greaterThanOrEqualTo(1));
    });
  });
}
