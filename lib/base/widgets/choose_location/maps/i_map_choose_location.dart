import 'package:flutter/material.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/base_maps/i_trufi_map_controller.dart';

abstract class IMapChooseLocation extends Widget {
  const IMapChooseLocation({Key? key}) : super(key: key);

  ITrufiMapController get trufiMapController;
  Function(TrufiLatLng?) get onCenterChanged;
}
