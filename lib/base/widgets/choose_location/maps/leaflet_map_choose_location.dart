import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/map_provider/trufi_map_definition.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';

class LeaftletMapChooseLocation extends StatelessWidget
    implements IMapChooseLocation {
  @override
  final LeafletMapController trufiMapController;
  @override
  final Function(TrufiLatLng?) onCenterChanged;

  const LeaftletMapChooseLocation({
    Key? key,
    required this.trufiMapController,
    required this.onCenterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LeafletMap(
      trufiMapController: trufiMapController,
      layerOptionsBuilder: (context) => [],
      onPositionChanged: (mapPosition, hasGesture) {
        onCenterChanged(TrufiLatLng.fromLatLng(mapPosition.center!));
      },
    );
  }
}
