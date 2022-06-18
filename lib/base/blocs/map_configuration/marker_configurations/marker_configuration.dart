import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/map_configuration/marker_configurations/base_marker/from_marker.dart';
import 'package:trufi_core/base/blocs/map_configuration/marker_configurations/base_marker/my_location_marker.dart';
import 'package:trufi_core/base/blocs/map_configuration/marker_configurations/base_marker/to_marker.dart';
part 'marker_configuration_default.dart';

abstract class MarkerConfiguration {
  Widget get toMarker;
  Widget get fromMarker;
  Widget get yourLocationMarker;
}
