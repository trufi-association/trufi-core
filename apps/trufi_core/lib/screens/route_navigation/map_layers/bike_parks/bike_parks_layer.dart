import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trufi_core/consts.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/bike_parks/bike_feature_model.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/bike_parks/bike_marker_modal.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/bike_parks/images.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/sorted_list.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/tile_grid_layer.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

class BikeParksLayer extends TrufiLayer {
  static const String layerId = 'bike-parks-layer';
  late TileGrid tileGrid;

  final Set<String> _addedFeatureIds = <String>{};

  final SortedList<BikeParkFeature> bikeParkFeature = SortedList(
    compare: (a, b) => a.position.latitude.compareTo(b.position.latitude),
    getId: (f) => f.id,
  );

  BikeParksLayer(super.controller) : super(id: layerId, layerLevel: 1) {
    tileGrid = TileGrid<BikeParkFeature>(
      layer: this,
      uriTemplate:
          "https://${ApiConfig().baseDomain}/otp/routers/default/vectorTiles/parking/{z}/{x}/{y}.pbf",
      fromGeoJsonPoint: (geoJson) => BikeParkFeature.fromGeoJsonPoint(geoJson),
      onFetchElements: onFetchElements,
      granularityLevels: 3,
      color: Colors.red,
      showGrid: true,
    );
  }

  @override
  void dispose() {
    tileGrid.dispose();
    super.dispose();
  }

  void onFetchElements(List<BikeParkFeature> elements) {
    final markersToAdd = <TrufiMarker>[];
    for (final w in elements) {
      final fid = w.id;
      if (_addedFeatureIds.contains(fid)) continue;

      bikeParkFeature.add(w);
      _addedFeatureIds.add(fid);

      markersToAdd.add(_markerFromFeature(w));
    }

    if (markersToAdd.isNotEmpty) {
      addMarkers(markersToAdd);
    }
  }

  TrufiMarker _markerFromFeature(BikeParkFeature f) {
    return TrufiMarker(
      id: '$id:${f.id}',
      position: f.position,
      widget: bikeParkMarkerIcons[BikeParkLayerIds.covered]!,
      layerLevel: 1,
      size: const Size(20, 20),
      buildPanel: (context) {
        return BikeMarkerModal(bikeParkFeature: f);
      },
    );
  }
}
