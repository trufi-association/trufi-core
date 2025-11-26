import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/localization/app_localization.dart';
import 'package:trufi_core/repositories/location/models/defaults_location.dart';
import 'package:trufi_core/screens/route_navigation/maps/image_tool.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/marker_list.dart';

class LatLngBounds {
  final latlng.LatLng southWest;
  final latlng.LatLng northEast;

  const LatLngBounds(this.southWest, this.northEast);
  factory LatLngBounds.fromPoints(List<latlng.LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('LatLngBounds.fromPoints requires a non-empty list');
    }
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      latlng.LatLng(minLat, minLng),
      latlng.LatLng(maxLat, maxLng),
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLngBounds &&
          southWest == other.southWest &&
          northEast == other.northEast;

  @override
  int get hashCode => Object.hash(southWest, northEast);

  @override
  String toString() =>
      'LatLngBounds(sw: ${southWest.latitude},${southWest.longitude}; ne: ${northEast.latitude},${northEast.longitude})';
}

class TrufiCameraPosition {
  const TrufiCameraPosition({
    required this.target,
    this.zoom = 0.0,
    this.bearing = 0.0,
    this.viewportSize,
    this.visibleRegion,
  });

  final latlng.LatLng target;
  final double zoom;
  final double bearing;
  final Size? viewportSize;
  final LatLngBounds? visibleRegion;

  TrufiCameraPosition copyWith({
    latlng.LatLng? target,
    double? zoom,
    double? bearing,
    Size? viewportSize,
    LatLngBounds? visibleRegion,
  }) => TrufiCameraPosition(
    target: target ?? this.target,
    zoom: zoom ?? this.zoom,
    bearing: bearing ?? this.bearing,
    viewportSize: viewportSize ?? Size(411.4, 923.4),
    visibleRegion: visibleRegion ?? this.visibleRegion,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrufiCameraPosition &&
          target == other.target &&
          zoom == other.zoom &&
          bearing == other.bearing &&
          viewportSize == other.viewportSize &&
          visibleRegion == other.visibleRegion;

  @override
  int get hashCode =>
      Object.hash(target, zoom, bearing, viewportSize, visibleRegion);

  @override
  String toString() =>
      'TrufiCameraPosition('
      'target: ${target.latitude},${target.longitude}, '
      'zoom: $zoom, '
      'bearing: $bearing, '
      'viewportSize: $viewportSize, '
      'visibleRegion: $visibleRegion)';
}

class TrufiMapController {
  TrufiMapController({required TrufiCameraPosition initialCameraPosition})
    : cameraPositionNotifier = ValueNotifier(initialCameraPosition),
      layersNotifier = ValueNotifier(<String, TrufiLayer>{});

  final ValueNotifier<TrufiCameraPosition> cameraPositionNotifier;
  final ValueNotifier<Map<String, TrufiLayer>> layersNotifier;

  List<TrufiLayer> get visibleLayers => layersNotifier.value.values
      .where((l) => l.visible)
      .toList(growable: false);

  bool setCameraPosition(TrufiCameraPosition position) {
    final prev = cameraPositionNotifier.value;
    if (position == prev) return false;
    final sameTarget = prev.target == position.target;
    final sameBearing = prev.bearing == position.bearing;
    final sameIntZoom = prev.zoom.floor() == position.zoom.floor();
    final tinyZoomDiff = (prev.zoom - position.zoom).abs() < 0.001;
    final sameVisibleRegion = prev.visibleRegion == position.visibleRegion;
    if (sameTarget &&
        sameBearing &&
        sameIntZoom &&
        tinyZoomDiff &&
        sameVisibleRegion) {
      return false;
    }
    cameraPositionNotifier.value = position;

    return true;
  }

  bool setViewportSize(Size size) {
    final cur = cameraPositionNotifier.value;
    if (cur.viewportSize == size) return false;
    return setCameraPosition(cur.copyWith(viewportSize: size));
  }

  bool updateCamera({
    latlng.LatLng? target,
    double? zoom,
    double? bearing,
    LatLngBounds? visibleRegion,
  }) {
    final next = cameraPositionNotifier.value.copyWith(
      target: target,
      zoom: zoom,
      bearing: bearing != null ? bearing % 360 : null,
      visibleRegion: visibleRegion,
    );
    return setCameraPosition(next);
  }

  void mutateLayers() {
    final layers = Map<String, TrufiLayer>.from(layersNotifier.value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layersNotifier.value = layers;
    });
  }

  bool addLayer(TrufiLayer layer) {
    final layers = Map<String, TrufiLayer>.from(layersNotifier.value);
    if (layers.containsKey(layer.id)) return false;
    layers[layer.id] = layer;
    layersNotifier.value = layers;
    return true;
  }

  TrufiLayer? getLayerById(String layerId) => layersNotifier.value[layerId];

  bool removeLayer(String layerId) {
    final layers = Map<String, TrufiLayer>.from(layersNotifier.value);
    final layer = layers[layerId];
    if (layer == null) return false;
    layer.dispose();
    layers.remove(layerId);
    layersNotifier.value = layers;
    return true;
  }

  bool toggleLayer(String layerId, bool visible) {
    final layers = Map<String, TrufiLayer>.from(layersNotifier.value);
    final layer = layers[layerId];
    if (layer == null || layer.visible == visible) return false;
    layer.visible = visible;
    layersNotifier.value = layers;
    return true;
  }

  List<TrufiMarker> pickMarkersAt(
    latlng.LatLng tap, {
    double hitboxPx = 24.0,
    int? perLayerLimit,
    int? globalLimit,
  }) {
    final leafletZoom = cameraPositionNotifier.value.zoom;
    final mapLibreZoom = leafletZoom - 1.0;
    final radiusMeters = _hitboxPxToMeters(
      centerLatDeg: tap.latitude,
      zoomMapLibre: mapLibreZoom,
      hitboxPx: hitboxPx,
    );
    final dist = const latlng.Distance();
    final all = <TrufiMarker>[];
    for (final layer in visibleLayers) {
      final local = layer.markerIndex.getMarkers(
        tap,
        radiusMeters,
        limit: perLayerLimit,
      );
      all.addAll(local);
    }
    if (all.isEmpty) return const [];
    all.sort(
      (a, b) => dist
          .distance(tap, a.position)
          .compareTo(dist.distance(tap, b.position)),
    );
    if (globalLimit != null && globalLimit > 0 && all.length > globalLimit) {
      return all.take(globalLimit).toList(growable: false);
    }
    return all;
  }

  TrufiMarker? pickNearestMarkerAt(
    latlng.LatLng tap, {
    double hitboxPx = 24.0,
  }) {
    final picks = pickMarkersAt(tap, hitboxPx: hitboxPx, globalLimit: 1);
    return picks.isEmpty ? null : picks.first;
  }

  double _hitboxPxToMeters({
    required double centerLatDeg,
    required double zoomMapLibre,
    required double hitboxPx,
  }) {
    const earthCircumference = 40075016.68557849;
    final metersPerPixel =
        (earthCircumference * math.cos(centerLatDeg * math.pi / 180.0)) /
        (256.0 * math.pow(2.0, zoomMapLibre));
    return metersPerPixel * (hitboxPx * 0.5);
  }

  void dispose() {
    for (final layer in layersNotifier.value.values.toList()) {
      layer.dispose();
    }
    layersNotifier.value = <String, TrufiLayer>{};
    cameraPositionNotifier.dispose();
    layersNotifier.dispose();
  }
}

class TrufiMarker {
  TrufiMarker({
    required this.id,
    required this.position,
    required this.widget,
    this.buildPanel,
    this.widgetBytes,
    this.layerLevel = 1,
    this.size = const Size(30, 30),
    this.rotation = 0,
    this.alignment = Alignment.center,
  });

  final String id;
  final latlng.LatLng position;
  final Widget widget;
  final WidgetBuilder? buildPanel;
  Uint8List? widgetBytes;
  final int layerLevel;
  final Size size;
  final double rotation;
  final Alignment alignment;

  Future<void> generateBytes(BuildContext context) async {
    widgetBytes = await ImageTool.widgetToBytes(this, context);
  }

  TrufiLocation toLocation() => TrufiLocation(
        description: '',
        position: position,
        type: TrufiLocationType.selectedOnMap,
      );
}

class TrufiLine {
  TrufiLine({
    required this.id,
    required this.position,
    this.color = Colors.black,
    this.layerLevel = 1,
    this.lineWidth = 2,
    this.activeDots = false,
    this.visible = true,
  });

  final String id;
  final List<latlng.LatLng> position;
  final Color color;
  final int layerLevel;
  final double lineWidth;
  final bool activeDots;
  final bool visible;
}

/// Enum representing the type of a location
enum TrufiLocationType {
  /// Origin location for a route
  origin('origin_location'),
  
  /// Destination location for a route
  destination('destination_location'),
  
  /// Location selected directly on the map
  selectedOnMap('selected_on_map'),
  
  /// Current GPS location
  currentLocation('current_location'),
  
  /// Location from search results (Photon, etc.)
  searchResult('search_result'),
  
  /// Default saved location (home, work, etc.)
  defaultLocation('default_location'),
  
  /// Custom saved place
  customPlace('custom_place'),
  
  /// Location from OpenStreetMap data
  osmLocation('osm_location'),
  
  /// Unknown or unspecified type
  unknown('unknown');

  const TrufiLocationType(this.value);
  final String value;

  static TrufiLocationType fromString(String? value) {
    if (value == null) return TrufiLocationType.unknown;
    return TrufiLocationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TrufiLocationType.unknown,
    );
  }
}

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
  final MarkerLayers markerIndex = MarkerLayers();
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

class TrufiLocation {
  final String description;
  final latlng.LatLng position;
  final List<String>? alternativeNames;
  final Map<String, String>? localizedNames;
  final String? address;
  final TrufiLocationType type;

  TrufiLocation({
    required this.description,
    required this.position,
    this.alternativeNames,
    this.localizedNames,
    this.address,
    this.type = TrufiLocationType.unknown,
  });

  TrufiLocation copyWith({
    String? description,
    latlng.LatLng? position,
    List<String>? alternativeNames,
    Map<String, String>? localizedNames,
    String? address,
    TrufiLocationType? type,
  }) {
    return TrufiLocation(
      description: description ?? this.description,
      position: position ?? this.position,
      alternativeNames: alternativeNames ?? this.alternativeNames,
      localizedNames: localizedNames ?? this.localizedNames,
      address: address ?? this.address,
      type: type ?? this.type,
    );
  }

  factory TrufiLocation.fromLocationsJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['name'],
      position: latlng.LatLng(json['coords']['lat'], json['coords']['lng']),
    );
  }

  factory TrufiLocation.fromSearchPlacesJson(List<dynamic> json) {
    return TrufiLocation(
      description: json[0].toString(),
      alternativeNames: json[1].cast<String>() as List<String>?,
      localizedNames: json[2].cast<String, String>() as Map<String, String>?,
      position: latlng.LatLng(json[3][1], json[3][0]),
      address: json[4] as String?,
      type: TrufiLocationType.fromString(json[5] as String?),
    );
  }

  factory TrufiLocation.fromSearch(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['description'] as String,
      position: latlng.LatLng(json["latitude"], json["longitude"]),
    );
  }

  factory TrufiLocation.fromJson(Map<String, dynamic> json) {
    return TrufiLocation(
      description: json['description'] as String,
      position: latlng.LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      type: TrufiLocationType.fromString(json['type'] as String?),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'description': description,
    'latitude': position.latitude,
    'longitude': position.longitude,
    'type': type.value,
    'address': address ?? '',
  };

  String displayName(AppLocalization localization) {
    // Solo mostrar "Selected on map" si el tipo es específicamente 'selectedOnMap'
    // y la descripción está vacía
    if (type == TrufiLocationType.selectedOnMap && description.isEmpty) {
      return localization.translate(LocalizationKey.selectedOnMap);
    }

    // Si hay descripción, usarla (incluso si está vacía pero no es selectedOnMap)
    if (description.isNotEmpty) {
      final detected = DefaultLocationExt.detect(this);
      if (detected != null) {
        final base = localization.translate(detected.l10nKey);
        return isLatLngDefined
            ? base
            : localization.translateWithParams(
                '${LocalizationKey.defaultLocationAdd.key}:$base',
              );
      }
      return [description, if (address?.isNotEmpty ?? false) address].join(', ');
    }

    // Fallback: si no hay descripción y no es selectedOnMap, mostrar coordenadas
    return "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}";
  }

  @override
  bool operator ==(Object other) =>
      other is TrufiLocation &&
      other.description == description &&
      other.position.latitude == position.latitude &&
      other.position.longitude == position.longitude &&
      other.type == type;

  @override
  int get hashCode =>
      Object.hash(description, position.latitude, position.longitude, type);

  @override
  String toString() => '${position.latitude},${position.longitude}';

  bool get isLatLngDefined => position.latitude != 0 && position.longitude != 0;

  String get subTitle => address != null && address!.isNotEmpty
      ? address!
      : "${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}";
}
