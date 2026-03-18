import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

void main() {
  group('TrufiLayer', () {
    test('creates with defaults', () {
      const layer = TrufiLayer(id: 'test');
      expect(layer.id, 'test');
      expect(layer.markers, isEmpty);
      expect(layer.lines, isEmpty);
      expect(layer.visible, true);
      expect(layer.layerLevel, 1);
      expect(layer.parentId, isNull);
    });

    test('creates with markers and lines', () {
      final markers = [
        TrufiMarker(
          id: 'm1',
          position: const latlng.LatLng(0, 0),
          widget: const SizedBox(),
        ),
      ];
      final lines = [
        TrufiLine(
          id: 'l1',
          position: const [latlng.LatLng(0, 0), latlng.LatLng(1, 1)],
        ),
      ];
      final layer = TrufiLayer(
        id: 'test',
        markers: markers,
        lines: lines,
        layerLevel: 5,
      );
      expect(layer.markers.length, 1);
      expect(layer.lines.length, 1);
      expect(layer.layerLevel, 5);
    });

    test('copyWith creates new instance with updated fields', () {
      const layer = TrufiLayer(id: 'test', visible: true, layerLevel: 1);
      final updated = layer.copyWith(visible: false, layerLevel: 3);
      expect(updated.id, 'test');
      expect(updated.visible, false);
      expect(updated.layerLevel, 3);
      // Original unchanged
      expect(layer.visible, true);
      expect(layer.layerLevel, 1);
    });

    test('copyWith preserves fields when not specified', () {
      final markers = [
        TrufiMarker(
          id: 'm1',
          position: const latlng.LatLng(0, 0),
          widget: const SizedBox(),
        ),
      ];
      final layer = TrufiLayer(id: 'test', markers: markers, parentId: 'parent');
      final updated = layer.copyWith(visible: false);
      expect(updated.markers, same(markers));
      expect(updated.parentId, 'parent');
    });
  });

  group('TrufiMarker', () {
    test('creates with required fields', () {
      final marker = TrufiMarker(
        id: 'test',
        position: const latlng.LatLng(10, 20),
        widget: const SizedBox(),
      );
      expect(marker.id, 'test');
      expect(marker.position.latitude, 10);
      expect(marker.position.longitude, 20);
      expect(marker.size, const Size(30, 30));
      expect(marker.rotation, 0);
      expect(marker.allowOverlap, false);
      expect(marker.layerLevel, 1);
    });

    test('copyWith updates fields', () {
      final marker = TrufiMarker(
        id: 'test',
        position: const latlng.LatLng(10, 20),
        widget: const SizedBox(),
      );
      final updated = marker.copyWith(
        position: const latlng.LatLng(30, 40),
        allowOverlap: true,
      );
      expect(updated.position.latitude, 30);
      expect(updated.allowOverlap, true);
      expect(updated.id, 'test'); // preserved
    });
  });

  group('TrufiLine', () {
    test('creates with defaults', () {
      final line = TrufiLine(
        id: 'test',
        position: const [latlng.LatLng(0, 0), latlng.LatLng(1, 1)],
      );
      expect(line.id, 'test');
      expect(line.color, Colors.black);
      expect(line.lineWidth, 2);
      expect(line.activeDots, false);
      expect(line.visible, true);
    });
  });

  group('TrufiMapController', () {
    test('returns null cameraPosition when not attached', () {
      final controller = TrufiMapController();
      expect(controller.cameraPosition, isNull);
    });

    test('returns empty list for pickMarkersAt when not attached', () {
      final controller = TrufiMapController();
      final markers = controller.pickMarkersAt(const latlng.LatLng(0, 0));
      expect(markers, isEmpty);
    });

    test('returns null for pickNearestMarkerAt when not attached', () {
      final controller = TrufiMapController();
      final marker = controller.pickNearestMarkerAt(const latlng.LatLng(0, 0));
      expect(marker, isNull);
    });
  });

  group('TrufiCameraPosition', () {
    test('creates with defaults', () {
      const cam = TrufiCameraPosition(target: latlng.LatLng(10, 20));
      expect(cam.target.latitude, 10);
      expect(cam.target.longitude, 20);
      expect(cam.zoom, 0);
      expect(cam.bearing, 0);
      expect(cam.viewportSize, isNull);
    });

    test('equality works', () {
      const cam1 = TrufiCameraPosition(target: latlng.LatLng(10, 20), zoom: 5);
      const cam2 = TrufiCameraPosition(target: latlng.LatLng(10, 20), zoom: 5);
      const cam3 = TrufiCameraPosition(target: latlng.LatLng(10, 20), zoom: 6);
      expect(cam1, equals(cam2));
      expect(cam1, isNot(equals(cam3)));
    });

    test('copyWith works', () {
      const cam = TrufiCameraPosition(target: latlng.LatLng(10, 20), zoom: 5);
      final updated = cam.copyWith(zoom: 10);
      expect(updated.zoom, 10);
      expect(updated.target, cam.target);
    });
  });

  group('WidgetMarker', () {
    test('creates with required fields', () {
      const marker = WidgetMarker(
        id: 'test',
        position: latlng.LatLng(10, 20),
        child: SizedBox(),
      );
      expect(marker.id, 'test');
      expect(marker.position.latitude, 10);
      expect(marker.alignment, Alignment.center);
      expect(marker.size, const Size(40, 40));
    });
  });

  group('MarkerIndex', () {
    test('builds and queries markers', () {
      final index = MarkerIndex();
      final markers = [
        TrufiMarker(
          id: 'm1',
          position: const latlng.LatLng(0, 0),
          widget: const SizedBox(),
        ),
        TrufiMarker(
          id: 'm2',
          position: const latlng.LatLng(0.001, 0.001),
          widget: const SizedBox(),
        ),
        TrufiMarker(
          id: 'm3',
          position: const latlng.LatLng(10, 10),
          widget: const SizedBox(),
        ),
      ];
      index.rebuild(markers);

      expect(index.isEmpty, false);

      // Query near (0,0) - should find m1 and m2
      final nearby = index.getMarkers(
        const latlng.LatLng(0, 0),
        500, // 500 meters
      );
      expect(nearby.length, 2);
      expect(nearby.any((m) => m.id == 'm1'), true);
      expect(nearby.any((m) => m.id == 'm2'), true);

      // m3 is far away
      expect(nearby.any((m) => m.id == 'm3'), false);
    });

    test('upsert adds and updates markers', () {
      final index = MarkerIndex();
      final m1 = TrufiMarker(
        id: 'm1',
        position: const latlng.LatLng(0, 0),
        widget: const SizedBox(),
      );
      index.upsert(m1);
      expect(index.isEmpty, false);

      final updated = m1.copyWith(position: const latlng.LatLng(1, 1));
      index.upsert(updated);

      // Should find at new position
      final nearby = index.getMarkers(const latlng.LatLng(1, 1), 500);
      expect(nearby.length, 1);
      expect(nearby.first.position.latitude, 1);
    });

    test('remove works', () {
      final index = MarkerIndex();
      index.upsert(TrufiMarker(
        id: 'm1',
        position: const latlng.LatLng(0, 0),
        widget: const SizedBox(),
      ));
      index.remove('m1');
      expect(index.isEmpty, true);
    });

    test('getNearest returns closest marker', () {
      final index = MarkerIndex();
      index.rebuild([
        TrufiMarker(
          id: 'm1',
          position: const latlng.LatLng(0, 0),
          widget: const SizedBox(),
        ),
        TrufiMarker(
          id: 'm2',
          position: const latlng.LatLng(0.0001, 0.0001),
          widget: const SizedBox(),
        ),
      ]);

      final nearest = index.getNearest(const latlng.LatLng(0, 0), 500);
      expect(nearest, isNotNull);
      expect(nearest!.id, 'm1');
    });
  });

  group('FitCameraUtil', () {
    test('cameraForPoints returns null for empty points', () {
      final util = FitCameraUtil();
      util.updateViewport(const Size(400, 800), EdgeInsets.zero);
      const cam = TrufiCameraPosition(target: latlng.LatLng(0, 0), zoom: 10);
      final result = util.cameraForPoints([], cam);
      expect(result, isNull);
    });

    test('cameraForPoints returns null when viewport not set', () {
      final util = FitCameraUtil();
      const cam = TrufiCameraPosition(target: latlng.LatLng(0, 0), zoom: 10);
      final result = util.cameraForPoints(
        [const latlng.LatLng(0, 0)],
        cam,
      );
      expect(result, isNull);
    });

    test('cameraForPoints returns camera for single point', () {
      final util = FitCameraUtil();
      util.updateViewport(const Size(400, 800), EdgeInsets.zero);
      const cam = TrufiCameraPosition(
        target: latlng.LatLng(0, 0),
        zoom: 10,
        viewportSize: Size(400, 800),
      );
      final result = util.cameraForPoints(
        [const latlng.LatLng(10, 20)],
        cam,
      );
      expect(result, isNotNull);
      // Should center roughly on the point
      expect(result!.target.latitude, closeTo(10, 1));
      expect(result.target.longitude, closeTo(20, 1));
    });

    test('isOutOfFocus returns false when no fit points set', () {
      final util = FitCameraUtil();
      util.updateViewport(const Size(400, 800), EdgeInsets.zero);
      const cam = TrufiCameraPosition(target: latlng.LatLng(0, 0), zoom: 10);
      expect(util.isOutOfFocus(cam), false);
    });
  });

  group('hitboxPxToMeters', () {
    test('converts pixels to meters at equator', () {
      final meters = hitboxPxToMeters(
        centerLatDeg: 0,
        zoomMapLibre: 10,
        hitboxPx: 24,
      );
      // At zoom 10 at equator, 1 pixel ≈ 152m
      // So 12px radius ≈ 1830m
      expect(meters, greaterThan(1000));
      expect(meters, lessThan(3000));
    });

    test('smaller at higher latitudes', () {
      final metersEquator = hitboxPxToMeters(
        centerLatDeg: 0,
        zoomMapLibre: 10,
        hitboxPx: 24,
      );
      final metersHigh = hitboxPxToMeters(
        centerLatDeg: 60,
        zoomMapLibre: 10,
        hitboxPx: 24,
      );
      expect(metersHigh, lessThan(metersEquator));
    });
  });
}
