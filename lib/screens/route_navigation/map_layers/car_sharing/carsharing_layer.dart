// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:trufi_core/consts.dart';
// import 'package:trufi_core/screens/route_navigation/map_layers/bike_parks/bike_feature_model.dart';
// import 'package:trufi_core/screens/route_navigation/map_layers/bike_parks/bike_marker_modal.dart';
// import 'package:trufi_core/screens/route_navigation/map_layers/bike_parks/images.dart';
// import 'package:trufi_core/screens/route_navigation/map_layers/car_sharing/carsharing_feature_model.dart';
// import 'package:trufi_core/screens/route_navigation/map_layers/sorted_list.dart';
// import 'package:trufi_core/screens/route_navigation/map_layers/tile_grid_layer.dart';
// import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

// class CarsharingLayer extends TrufiLayer {
//   static const String layerId = 'carsharing-layer';
//   late TileGrid tileGrid;

//   final Set<String> _addedFeatureIds = <String>{};

//   final SortedList<CarSharingFeature> carSharingFeature = SortedList(
//     compare: (a, b) => a.position.latitude.compareTo(b.position.latitude),
//     getId: (f) => f.id,
//   );

//   CarsharingLayer(super.controller) : super(id: layerId, layerLevel: 1) {
//     tileGrid = TileGrid<CarSharingFeature>(
//       layer: this,
//       uriTemplate:
//           "https://${ApiConfig().baseDomain}/otp/routers/default/vectorTiles/realtimeRentalStations/{z}/{x}/{y}.pbf",
//       fromGeoJsonPoint: (geoJson) => CarSharingFeature.fromGeoJsonPoint(geoJson),
//       onFetchElements: onFetchElements,
//       granularityLevels: 3,
//       color: Colors.red,
//       showGrid: true,
//     );
//   }

//   @override
//   void dispose() {
//     tileGrid.dispose();
//     super.dispose();
//   }

//   void onFetchElements(List<CarSharingFeature> elements) {
//     final markersToAdd = <TrufiMarker>[];
//     for (final w in elements) {
//       final fid = w.id;
//       if (_addedFeatureIds.contains(fid)) continue;

//       carSharingFeature.add(w);
//       _addedFeatureIds.add(fid);

//       markersToAdd.add(_markerFromFeature(w));
//     }

//     if (markersToAdd.isNotEmpty) {
//       addMarkers(markersToAdd.take(10));
//     }
//   }

//   TrufiMarker _markerFromFeature(CarSharingFeature f) {
//     final icon = mapCategory.properties?.iconSvgMenu ??
//         mapCategory.categories.first.properties?.iconSvgMenu;
//     return TrufiMarker(
//       id: '$id:${f.id}',
//       position: f.position,
//       widget: SvgPicture.string(bikeParkMarkerIcons[f.type] ?? ''),
//       layerLevel: 1,
//       size: const Size(20, 20),
//       buildPanel: (context) {
//         return BikeMarkerModal(bikeParkFeature: f);
//       },
//     );
//   }
// }
