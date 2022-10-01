part of 'leaflet_map_controller.dart';

@immutable
class LeafletMapState extends Equatable {
  final MarkerLayer? unselectedMarkersLayer;
  final PolylineLayer? unselectedPolylinesLayer;
  final MarkerLayer? selectedMarkersLayer;
  final PolylineLayer? selectedPolylinesLayer;

  const LeafletMapState({
    this.unselectedMarkersLayer,
    this.unselectedPolylinesLayer,
    this.selectedMarkersLayer,
    this.selectedPolylinesLayer,
  });

  LeafletMapState copyWith({
    MarkerLayer? fromMarkerLayer,
    MarkerLayer? toMarkerLayer,
    MarkerLayer? unselectedMarkersLayer,
    PolylineLayer? unselectedPolylinesLayer,
    MarkerLayer? selectedMarkersLayer,
    PolylineLayer? selectedPolylinesLayer,
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
