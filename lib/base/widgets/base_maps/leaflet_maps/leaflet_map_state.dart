part of 'leaflet_map_controller.dart';

@immutable
class LeafletMapState extends Equatable {
  final MarkerLayerOptions? unselectedMarkersLayer;
  final PolylineLayerOptions? unselectedPolylinesLayer;
  final MarkerLayerOptions? selectedMarkersLayer;
  final PolylineLayerOptions? selectedPolylinesLayer;

  const LeafletMapState({
    this.unselectedMarkersLayer,
    this.unselectedPolylinesLayer,
    this.selectedMarkersLayer,
    this.selectedPolylinesLayer,
  });

  LeafletMapState copyWith({
    MarkerLayerOptions? fromMarkerLayer,
    MarkerLayerOptions? toMarkerLayer,
    MarkerLayerOptions? unselectedMarkersLayer,
    PolylineLayerOptions? unselectedPolylinesLayer,
    MarkerLayerOptions? selectedMarkersLayer,
    PolylineLayerOptions? selectedPolylinesLayer,
  }) {
    return LeafletMapState(
      unselectedMarkersLayer:
          unselectedMarkersLayer ?? this.unselectedMarkersLayer,
      unselectedPolylinesLayer:
          unselectedPolylinesLayer ?? this.unselectedPolylinesLayer,
      selectedMarkersLayer: selectedMarkersLayer ?? this.selectedMarkersLayer,
      selectedPolylinesLayer:
          selectedPolylinesLayer ?? this.selectedPolylinesLayer,
    );
  }

  @override
  List<Object?> get props => [
        unselectedMarkersLayer,
        unselectedPolylinesLayer,
        selectedMarkersLayer,
        selectedPolylinesLayer,
      ];

  @override
  String toString() {
    return 'TrufiMapState: {}';
  }
}
