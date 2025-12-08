import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/map_provider_collection/map_engine.dart';
import 'package:trufi_core/base/models/map_provider_collection/trufi_map_definition.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/base_maps/trufi_core_maps/trufi_core_maps_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/trufi_core_maps/trufi_core_maps_widget.dart';

class TrufiCoreMapsChooseLocation extends StatelessWidget
    implements IMapChooseLocation {
  @override
  final TrufiCoreMapsController trufiMapController;
  @override
  final Function(TrufiLatLng?) onCenterChanged;

  final ITrufiMapEngine mapEngine;

  const TrufiCoreMapsChooseLocation({
    super.key,
    required this.trufiMapController,
    required this.onCenterChanged,
    required this.mapEngine,
  });

  @override
  Widget build(BuildContext context) {
    return TrufiCoreMapsWidget(
      trufiMapController: trufiMapController,
      mapEngine: mapEngine,
      onCameraChanged: (cameraPosition) {
        onCenterChanged(TrufiLatLng(
          cameraPosition.target.latitude,
          cameraPosition.target.longitude,
        ));
      },
    );
  }
}
