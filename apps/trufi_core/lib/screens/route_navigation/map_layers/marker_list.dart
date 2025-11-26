import 'dart:math' as math;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class MarkersContainer {
  final Map<String, MarkerLayers> _markersByLayer = {};

  void setLayerMarkers(String layerId, List<TrufiMarker> markers) {
    _markersByLayer[layerId] = MarkerLayers()..rebuild(markers);
  }

  void upsert(String layerId, TrufiMarker marker) {
    final layer = _markersByLayer.putIfAbsent(layerId, () => MarkerLayers());
    layer.upsert(marker);
  }

  void remove(String layerId, String markerId) {
    _markersByLayer[layerId]?.remove(markerId);
  }

  void clearLayer(String layerId) {
    _markersByLayer.remove(layerId);
  }

  void rebuildLayer(String layerId) {
    final layer = _markersByLayer[layerId];
    if (layer != null) layer.rebuild(layer.all());
  }

  List<TrufiMarker> getMakers(
    String layerId,
    latlng.LatLng target,
    double radiusMeters, {
    int? limit,
  }) => getMarkers(layerId, target, radiusMeters, limit: limit);

  List<TrufiMarker> getMarkers(
    String layerId,
    latlng.LatLng target,
    double radiusMeters, {
    int? limit,
  }) {
    final layer = _markersByLayer[layerId];
    if (layer == null || layer.isEmpty) return const [];
    return layer.getMarkers(target, radiusMeters, limit: limit);
  }

  TrufiMarker? getNearest(
    String layerId,
    latlng.LatLng target,
    double radiusMeters,
  ) {
    final layer = _markersByLayer[layerId];
    if (layer == null || layer.isEmpty) return null;
    return layer.getNearest(target, radiusMeters);
  }

  List<TrufiMarker> getNearestMany(
    String layerId,
    latlng.LatLng target,
    double radiusMeters, {
    int? limitPerLayer,
  }) {
    final layer = _markersByLayer[layerId];
    if (layer == null || layer.isEmpty) return const [];
    return layer.getMarkers(target, radiusMeters, limit: limitPerLayer);
  }
}

class MarkerLayers {
  final List<_Keyed> _byLat = <_Keyed>[];
  final List<double> _latKeys = <double>[];
  final Map<String, TrufiMarker> _byId = <String, TrufiMarker>{};

  bool get isEmpty => _byLat.isEmpty;

  void rebuild(List<TrufiMarker> markers) {
    _byId
      ..clear()
      ..addEntries(markers.map((m) => MapEntry(m.id, m)));

    _byLat
      ..clear()
      ..addAll(markers.map((m) => _Keyed(key: m.position.latitude, marker: m)))
      ..sort((a, b) => a.key.compareTo(b.key));

    _latKeys
      ..clear()
      ..addAll(_byLat.map((e) => e.key));
  }

  void upsert(TrufiMarker marker) {
    final old = _byId[marker.id];
    _byId[marker.id] = marker;

    if (old == null) {
      final key = marker.position.latitude;
      final idx = _lowerBound(_latKeys, key);
      _byLat.insert(idx, _Keyed(key: key, marker: marker));
      _latKeys.insert(idx, key);
      return;
    }

    final oldLat = old.position.latitude;
    final newLat = marker.position.latitude;
    if (oldLat != newLat) {
      _removeFromByLat(marker.id, oldLat);
      final idx = _lowerBound(_latKeys, newLat);
      _byLat.insert(idx, _Keyed(key: newLat, marker: marker));
      _latKeys.insert(idx, newLat);
    }
  }

  void upsertMany(Iterable<TrufiMarker> markers) {
    for (final m in markers) {
      upsert(m);
    }
  }

  void remove(String markerId) {
    final m = _byId.remove(markerId);
    if (m == null) return;
    _removeFromByLat(markerId, m.position.latitude);
  }

  List<TrufiMarker> all() => _byId.values.toList(growable: false);

  List<TrufiMarker> getMarkers(
    latlng.LatLng target,
    double radiusMeters, {
    int? limit,
  }) {
    if (isEmpty) return const [];

    final (dLat, dLng) = _metersToDegreeDeltas(target.latitude, radiusMeters);
    final lat0 = target.latitude;
    final lng0 = target.longitude;

    final pivot = _lowerBound(_latKeys, lat0);
    final dist = const latlng.Distance();
    final List<_Scored> hits = [];

    for (var i = pivot - 1; i >= 0; i--) {
      final e = _byLat[i];
      final latDelta = lat0 - e.key;
      if (latDelta > dLat) break;
      final lngDelta = (e.marker.position.longitude - lng0).abs();
      if (lngDelta > dLng) continue;
      final d = dist.distance(target, e.marker.position);
      if (d <= radiusMeters) hits.add(_Scored(e.marker, d));
    }

    for (var i = pivot; i < _byLat.length; i++) {
      final e = _byLat[i];
      final latDelta = e.key - lat0;
      if (latDelta > dLat) break;
      final lngDelta = (e.marker.position.longitude - lng0).abs();
      if (lngDelta > dLng) continue;
      final d = dist.distance(target, e.marker.position);
      if (d <= radiusMeters) hits.add(_Scored(e.marker, d));
    }

    if (hits.isEmpty) return const [];

    hits.sort((a, b) => a.d.compareTo(b.d));
    if (limit != null && limit > 0 && hits.length > limit) {
      return hits.take(limit).map((s) => s.m).toList(growable: false);
    }
    return hits.map((s) => s.m).toList(growable: false);
  }

  TrufiMarker? getNearest(latlng.LatLng target, double radiusMeters) {
    final list = getMarkers(target, radiusMeters, limit: 1);
    return list.isEmpty ? null : list.first;
  }

  void _removeFromByLat(String markerId, double latKey) {
    if (_byLat.isEmpty) return;
    final i0 = _lowerBound(_latKeys, latKey);
    final i1 = _upperBound(_latKeys, latKey);
    for (var i = i0; i < i1; i++) {
      if (_byLat[i].marker.id == markerId) {
        _byLat.removeAt(i);
        _latKeys.removeAt(i);
        return;
      }
    }
  }

  int _lowerBound(List<double> a, double key) {
    var lo = 0, hi = a.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (a[mid] < key) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  int _upperBound(List<double> a, double key) {
    var lo = 0, hi = a.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (a[mid] <= key) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  (double, double) _metersToDegreeDeltas(double latDeg, double radiusMeters) {
    const metersPerDegLat = 111320.0;
    final metersPerDegLng =
        metersPerDegLat * math.cos(latDeg * math.pi / 180.0);
    final dLat = radiusMeters / metersPerDegLat;
    final dLng = metersPerDegLng > 1e-9
        ? (radiusMeters / metersPerDegLng)
        : 180.0;
    return (dLat, dLng);
  }
}

class _Keyed {
  final double key;
  final TrufiMarker marker;
  _Keyed({required this.key, required this.marker});
}

class _Scored {
  final TrufiMarker m;
  final double d;
  _Scored(this.m, this.d);
}
