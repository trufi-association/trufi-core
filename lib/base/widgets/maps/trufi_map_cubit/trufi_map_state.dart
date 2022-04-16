part of 'trufi_map_cubit.dart';

@immutable
class TrufiMapState extends Equatable {
  final MarkerLayerOptions? fromMarkerLayer;
  final MarkerLayerOptions? toMarkerLayer;
  final MarkerLayerOptions? unselectedMarkersLayer;
  final PolylineLayerOptions? unselectedPolylinesLayer;
  final MarkerLayerOptions? selectedMarkersLayer;
  final PolylineLayerOptions? selectedPolylinesLayer;

  const TrufiMapState({
    this.fromMarkerLayer,
    this.toMarkerLayer,
    this.unselectedMarkersLayer,
    this.unselectedPolylinesLayer,
    this.selectedMarkersLayer,
    this.selectedPolylinesLayer,
  });

  TrufiMapState copyWith({
    MarkerLayerOptions? fromMarkerLayer,
    MarkerLayerOptions? toMarkerLayer,
    MarkerLayerOptions? unselectedMarkersLayer,
    PolylineLayerOptions? unselectedPolylinesLayer,
    MarkerLayerOptions? selectedMarkersLayer,
    PolylineLayerOptions? selectedPolylinesLayer,
  }) {
    return TrufiMapState(
      fromMarkerLayer: fromMarkerLayer ?? this.fromMarkerLayer,
      toMarkerLayer: toMarkerLayer ?? this.toMarkerLayer,
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
        fromMarkerLayer,
        toMarkerLayer,
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
