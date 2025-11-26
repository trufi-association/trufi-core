import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trufi_core/consts.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/sorted_list.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/tile_grid_layer.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/weather_stations/image.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/weather_stations/weather_feature_model.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/weather_stations/weather_marker_modal.dart';

class WeatherStationsLayer extends TrufiLayer {
  static const String layerId = 'weather-stations-layer';
  late TileGrid tileGrid;

  final Set<String> _addedFeatureIds = <String>{};

  final SortedList<WeatherFeature> weatherFeature = SortedList(
    compare: (a, b) => a.position.latitude.compareTo(b.position.latitude),
    getId: (f) => f.address,
  );

  // Icono SVG para el marker
  final Widget _markerIcon = SizedBox(
    width: 20,
    height: 20,
    child: SvgPicture.string(weatherImage),
  );

  WeatherStationsLayer(super.controller) : super(id: layerId, layerLevel: 1) {
    tileGrid = TileGrid<WeatherFeature>(
      layer: this,
      uriTemplate:
          "https://${ApiConfig().baseDomain}/map/v1/weather-stations/{z}/{x}/{y}.pbf",
      fromGeoJsonPoint: (geoJson) => WeatherFeature.fromGeoJsonPoint(geoJson),
      onFetchElements: onFetchElements,
      granularityLevels: 3,
      color: Colors.red,
      showGrid: false,
    );
  }

  @override
  void dispose() {
    tileGrid.dispose();
    super.dispose();
  }

  void onFetchElements(List<WeatherFeature> elements) {
    final markersToAdd = <TrufiMarker>[];

    for (final w in elements) {
      final fid = w.address;
      if (_addedFeatureIds.contains(fid)) continue;

      weatherFeature.add(w);
      _addedFeatureIds.add(fid);

      markersToAdd.add(_markerFromFeature(w));
    }

    if (markersToAdd.isNotEmpty) {
      addMarkers(markersToAdd);
    }
  }

  TrufiMarker _markerFromFeature(WeatherFeature f) {
    return TrufiMarker(
      id: '$id:${f.address}',
      position: f.position,
      widget: _markerIcon,
      layerLevel: 1,
      size: const Size(20, 20),
      buildPanel: (context) {
        return WeatherMarkerModal(weatherFeature: f, icon: _markerIcon);
      },
    );
  }
}
