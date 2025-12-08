part of 'panel_cubit.dart';

/// State for the panel cubit.
class PanelState extends Equatable {
  final MarkerPanel? panel;

  const PanelState({
    this.panel,
  });
  @override
  List<Object?> get props => [panel];
}

/// Represents a marker panel to be displayed on the map.
class MarkerPanel extends Equatable {
  final Widget Function(
    BuildContext context,
    void Function() onFetchPlan, {
    bool? isOnlyDestination,
  }) panel;
  final TrufiLatLng positon;
  final double minSize;

  const MarkerPanel({
    required this.panel,
    required this.positon,
    required this.minSize,
  });

  @override
  List<Object?> get props => [
        panel,
        positon,
        minSize,
      ];
}
