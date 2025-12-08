import 'package:flutter/material.dart';

import 'markers/from_marker.dart';
import 'markers/to_marker.dart';
import 'markers/my_location_marker.dart';

/// Abstract class for marker configuration.
abstract class MarkerConfiguration {
  Widget get toMarker;
  Widget get fromMarker;
  Widget get yourLocationMarker;
}

/// Default marker configuration with standard markers.
class DefaultMarkerConfiguration implements MarkerConfiguration {
  const DefaultMarkerConfiguration();

  @override
  Widget get fromMarker => const FromMarker();

  @override
  Widget get toMarker => const ToMarker();

  @override
  Widget get yourLocationMarker => const MyLocationMarker();
}
