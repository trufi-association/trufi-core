part of 'google_map_controller.dart';

class GoogleMapState extends Equatable {
  const GoogleMapState({
    required this.markers,
    required this.polylines,
    required this.polygons,
    required this.cameraPosition,
  });

  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Polygon> polygons;
  final CameraPosition cameraPosition;

  GoogleMapState copyWith({
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    Set<Polygon>? polygons,
    CameraPosition? cameraPosition,
  }) {
    return GoogleMapState(
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      polygons: polygons ?? this.polygons,
      cameraPosition: cameraPosition ?? this.cameraPosition,
    );
  }

  @override
  List<Object> get props => [markers, polylines, polygons];
}
