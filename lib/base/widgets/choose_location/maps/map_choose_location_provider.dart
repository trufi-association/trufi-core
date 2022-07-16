import 'package:flutter/material.dart';

import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/choose_location/maps/i_map_choose_location.dart';
import 'package:trufi_core/base/widgets/choose_location/maps/leaflet_map_choose_location.dart';
import 'package:trufi_core/base/widgets/base_maps/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';

typedef MapChooseLocationBuilder = IMapChooseLocation Function(
  BuildContext context,
  void Function(TrufiLatLng?) onCenterChanged,
);

abstract class MapChooseLocationProvider {
  ITrufiMapController get trufiMapController;
  MapChooseLocationBuilder get mapChooseLocationBuilder;
}

class MapChooseLocationProviderImplementation
    implements MapChooseLocationProvider {
  @override
  final ITrufiMapController trufiMapController;
  @override
  final MapChooseLocationBuilder mapChooseLocationBuilder;

  const MapChooseLocationProviderImplementation({
    required this.trufiMapController,
    required this.mapChooseLocationBuilder,
  });

  factory MapChooseLocationProviderImplementation.providerByTypepProviderMap({
    required TypepProviderMap typeProviderMap,
  }) {
    switch (typeProviderMap) {
      case TypepProviderMap.leafletMap:
        return MapChooseLocationProviderImplementation.leaftletMap();
      default:
        throw 'error TypeProviderMap not implement in MapChooseLocationProvider';
    }
  }

  factory MapChooseLocationProviderImplementation.leaftletMap() {
    final trufiMapController = LeafletMapController();
    return MapChooseLocationProviderImplementation(
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
