part of 'marker_configuration.dart';

class DefaultMarkerConfiguration implements MarkerConfiguration {
  const DefaultMarkerConfiguration();

  @override
  Widget get fromMarker => const FromMarker();

  @override
  Widget get toMarker => const ToMarker();

  @override
  Widget get yourLocationMarker => const MyLocationMarker();

  @override
  Marker buildFromMarker(LatLng point) {
    return Marker(
      point: point,
      width: 24.0,
      height: 24.0,
      alignment: Alignment.center,
      child: fromMarker,
    );
  }

  @override
  Marker buildToMarker(LatLng point) {
    return Marker(
      point: point,
      alignment: Alignment.topCenter,
      child: toMarker,
    );
  }

  @override
  Marker buildYourLocationMarker(LatLng? point) {
    return (point != null)
        ? Marker(
            width: 50.0,
            height: 50.0,
            point: point,
            alignment: Alignment.center,
            child: toMarker,
          )
        : Marker(
            width: 0,
            height: 0,
            point: LatLng(0, 0),
            child: Container(),
          );
  }

  @override
  MarkerLayer buildFromMarkerLayerOptions(LatLng point) {
    return MarkerLayer(markers: [buildFromMarker(point)]);
  }

  @override
  MarkerLayer buildToMarkerLayerOptions(LatLng point) {
    return MarkerLayer(markers: [buildToMarker(point)]);
  }

  @override
  MarkerLayer buildYourLocationMarkerLayerOptions(LatLng? point) {
    return MarkerLayer(markers: [buildYourLocationMarker(point)]);
  }
}
