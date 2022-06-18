import 'package:flutter/material.dart';

import 'package:trufi_core/base/pages/transport_list/services/models.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list_detail/maps/google_map_transport.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list_detail/maps/leaflet_map_transport.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/i_trufi_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';

typedef MapTransportBuilder = Widget Function(
  BuildContext,
  PatternOtp? transportData,
);

abstract class MapTransportProvider {
  ITrufiMapController get trufiMapController;
  MapTransportBuilder get mapTransportBuilder;
}

class MapTransportProviderImplementation implements MapTransportProvider {
  @override
  final ITrufiMapController trufiMapController;
  @override
  final MapTransportBuilder mapTransportBuilder;

  const MapTransportProviderImplementation({
    required this.trufiMapController,
    required this.mapTransportBuilder,
  });

  factory MapTransportProviderImplementation.providerByTypepProviderMap({
    required TypepProviderMap typeProviderMap,
  }) {
    switch (typeProviderMap) {
      case TypepProviderMap.lealetMap:
        return MapTransportProviderImplementation.leaftletMap();
      case TypepProviderMap.googleMap:
        return MapTransportProviderImplementation.googleMap();
      default:
        throw 'error TypeProviderMap not implement in MapTransportProvider';
    }
  }

  factory MapTransportProviderImplementation.googleMap() {
    final trufiMapController = TGoogleMapController();
    return MapTransportProviderImplementation(
      trufiMapController: trufiMapController,
      mapTransportBuilder: (mapContext, transportData) {
        return TGoogleMapTransport(
          trufiMapController: trufiMapController,
          transportData: transportData,
        );
      },
    );
  }
  factory MapTransportProviderImplementation.leaftletMap() {
    final trufiMapController = LeafletMapController();
    return MapTransportProviderImplementation(
      trufiMapController: trufiMapController,
      mapTransportBuilder: (mapContext, transportData) {
        return LeafletMapTransport(
          trufiMapController: trufiMapController,
          transportData: transportData,
        );
      },
    );
  }
}
