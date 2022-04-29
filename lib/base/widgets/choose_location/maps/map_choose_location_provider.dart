import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/choose_location/maps/google_map_choose_location.dart';
import 'package:trufi_core/base/widgets/choose_location/maps/i_map_choose_location.dart';
import 'package:trufi_core/base/widgets/choose_location/maps/leaflet_map_choose_location.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';

typedef MapChooseLocationBuilder = IMapChooseLocation Function(
  BuildContext context,
  void Function(TrufiLatLng?) onCenterChanged,
);

class MapChooseLocationProvider {
  final ITrufiMapController trufiMapController;
  final MapChooseLocationBuilder mapChooseLocationBuilder;

  const MapChooseLocationProvider({
    required this.trufiMapController,
    required this.mapChooseLocationBuilder,
  });

  factory MapChooseLocationProvider.providerByTypepProviderMap({
    required TypepProviderMap typeProviderMap,
  }) {
    switch (typeProviderMap) {
      case TypepProviderMap.lealetMap:
        return MapChooseLocationProvider.leaftletMap();
      case TypepProviderMap.googleMap:
        return MapChooseLocationProvider.googleMap();
      default:
        throw 'error TypeProviderMap not implement in MapChooseLocationProvider';
    }
  }

  factory MapChooseLocationProvider.googleMap() {
    final trufiMapController = TGoogleMapController();
    return MapChooseLocationProvider(
      trufiMapController: trufiMapController,
      mapChooseLocationBuilder: (mapContext, onCenterChanged) {
        return GoogleMapChooseLocation(
          trufiMapController: trufiMapController,
          onCenterChanged: onCenterChanged,
        );
      },
    );
  }
  factory MapChooseLocationProvider.leaftletMap() {
    final trufiMapController = LeafletMapController();
    return MapChooseLocationProvider(
      trufiMapController: trufiMapController,
      mapChooseLocationBuilder: (mapContext, onCenterChanged) {
        return LeaftletMapChooseLocation(
          trufiMapController: trufiMapController,
          onCenterChanged: onCenterChanged,
        );
      },
    );
  }
}
