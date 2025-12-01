part of 'marker_configuration.dart';

class DefaultMarkerConfiguration implements MarkerConfiguration {
  const DefaultMarkerConfiguration();

  @override
  Widget get fromMarker => const FromMarker();

  @override
  Widget get toMarker => const ToMarker();

  @override
  Widget get yourLocationMarker => const MyLocationMarker();
}
