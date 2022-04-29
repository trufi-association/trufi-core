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

class MapTransportProvider {
  final ITrufiMapController trufiMapController;
  final MapTransportBuilder mapTransportBuilder;

  const MapTransportProvider({
    required this.trufiMapController,
    required this.mapTransportBuilder,
  });

  factory MapTransportProvider.providerByTypepProviderMap({
    required TypepProviderMap typeProviderMap,
  }) {
    switch (typeProviderMap) {
      case TypepProviderMap.lealetMap:
        return MapTransportProvider.leaftletMap();
      case TypepProviderMap.googleMap:
        return MapTransportProvider.googleMap();
      default:
        throw 'error TypeProviderMap not implement in MapTransportProvider';
    }
  }

  factory MapTransportProvider.googleMap() {
    final trufiMapController = TGoogleMapController();
    return MapTransportProvider(
      trufiMapController: trufiMapController,
      mapTransportBuilder: (mapContext, transportData) {
        return TGoogleMapTransport(
          trufiMapController: trufiMapController,
          transportData: transportData,
        );
      },
    );
  }
  factory MapTransportProvider.leaftletMap() {
    final trufiMapController = LeafletMapController();
    return MapTransportProvider(
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
