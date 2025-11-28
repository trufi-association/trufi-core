import 'dart:collection';

import 'package:latlong2/latlong.dart' as latlng;

import '../../map/controller.dart';
import '../../models/marker.dart';
import '../../models/marker_index.dart';
import '../../models/line.dart';

abstract class TrufiLayer {
  TrufiLayer(
    this.controller, {
    required this.id,
    required this.layerLevel,
    this.visible = true,
  }) {
    controller.addLayer(this);
  }

  final TrufiMapController controller;
  String id;
  final int layerLevel;
  bool visible;
  final MarkerIndex markerIndex = MarkerIndex();
  final List<TrufiMarker> _markers = <TrufiMarker>[];
  final List<TrufiLine> _lines = <TrufiLine>[];

  List<TrufiMarker> get markers => UnmodifiableListView(_markers);
  List<TrufiLine> get lines => UnmodifiableListView(_lines);

  void mutateLayers() => controller.mutateLayers();

  void setMarkers(Iterable<TrufiMarker> items) {
    _markers
      ..clear()
      ..addAll(items);
    markerIndex.rebuild(_markers);
    mutateLayers();
  }

  void addMarker(TrufiMarker m) {
    _markers.add(m);
    markerIndex.upsert(m);
    mutateLayers();
  }

  void addMarkers(Iterable<TrufiMarker> list) {
    if (list.isEmpty) return;
    _markers.addAll(list);
    markerIndex.upsertMany(list);
    mutateLayers();
  }

  bool upsertMarker(TrufiMarker m) {
    final i = _markers.indexWhere((x) => x.id == m.id);
    final updated = i >= 0;
    if (updated) {
      _markers[i] = m;
    } else {
      _markers.add(m);
    }
    markerIndex.upsert(m);
    mutateLayers();
    return updated;
  }

  bool removeMarker(TrufiMarker m) {
    final removed = _markers.remove(m);
    if (removed) {
      markerIndex.remove(m.id);
      mutateLayers();
    }
    return removed;
  }

  bool removeMarkerById(String markerId) {
    final i = _markers.indexWhere((x) => x.id == markerId);
    if (i >= 0) {
      _markers.removeAt(i);
      markerIndex.remove(markerId);
      mutateLayers();
      return true;
    }
    return false;
  }

  void clearMarkers() {
    if (_markers.isEmpty) return;
    _markers.clear();
    markerIndex.rebuild(const []);
    mutateLayers();
  }

  void setLines(Iterable<TrufiLine> items) {
    _lines
      ..clear()
      ..addAll(items);
    mutateLayers();
  }

  void addLine(TrufiLine l) {
    _lines.add(l);
    mutateLayers();
  }

  void addLines(Iterable<TrufiLine> list) {
    if (list.isEmpty) return;
    _lines.addAll(list);
    mutateLayers();
  }

  bool upsertLine(TrufiLine l) {
    final i = _lines.indexWhere((x) => x.id == l.id);
    final updated = i >= 0;
    if (updated) {
      _lines[i] = l;
    } else {
      _lines.add(l);
    }
    mutateLayers();
    return updated;
  }

  bool removeLine(TrufiLine l) {
    final removed = _lines.remove(l);
    if (removed) mutateLayers();
    return removed;
  }

  bool removeLineById(String lineId) {
    final i = _lines.indexWhere((x) => x.id == lineId);
    if (i >= 0) {
      _lines.removeAt(i);
      mutateLayers();
      return true;
    }
    return false;
  }

  void clearLines() {
    if (_lines.isEmpty) return;
    _lines.clear();
    mutateLayers();
  }

  List<TrufiMarker> pickMarkers(
    latlng.LatLng target,
    double radiusMeters, {
    int? limit,
  }) {
    return markerIndex.getMarkers(target, radiusMeters, limit: limit);
  }

  TrufiMarker? pickNearest(latlng.LatLng target, double radiusMeters) {
    return markerIndex.getNearest(target, radiusMeters);
  }

  void dispose() {
    _markers.clear();
    _lines.clear();
    markerIndex.rebuild(const []);
  }
}
