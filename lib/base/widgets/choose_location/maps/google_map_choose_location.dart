import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/choose_location/maps/i_map_choose_location.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map_controller.dart';

class GoogleMapChooseLocation extends StatelessWidget
    implements IMapChooseLocation {
  @override
  final TGoogleMapController trufiMapController;
  @override
  final Function(TrufiLatLng?) onCenterChanged;

  const GoogleMapChooseLocation({
    Key? key,
    required this.trufiMapController,
    required this.onCenterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TGoogleMap(
      trufiMapController: trufiMapController,
      onCameraMove: (cameraPosition) {
        onCenterChanged(TrufiLatLng.fromGoogleLatLng(cameraPosition.target));
      },
    );
  }
}
