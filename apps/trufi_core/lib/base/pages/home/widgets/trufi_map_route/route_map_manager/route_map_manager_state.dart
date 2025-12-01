part of 'route_map_manager_cubit.dart';

@immutable
class RouteMapManagerState extends Equatable {
  final MarkerLayer? unselectedMarkersLayer;
  final PolylineLayer? unselectedPolylinesLayer;
  final MarkerLayer? selectedMarkersLayer;
  final PolylineLayer? selectedPolylinesLayer;

  const RouteMapManagerState({
    this.unselectedMarkersLayer,
    this.unselectedPolylinesLayer,
    this.selectedMarkersLayer,
    this.selectedPolylinesLayer,
  });

  RouteMapManagerState copyWith({
    MarkerLayer? unselectedMarkersLayer,
    PolylineLayer? unselectedPolylinesLayer,
    MarkerLayer? selectedMarkersLayer,
    PolylineLayer? selectedPolylinesLayer,
  }) {
    return RouteMapManagerState(
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
    return 'RouteMapManagerState: {}';
  }
}
