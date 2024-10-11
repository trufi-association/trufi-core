part of 'panel_cubit.dart';

class PanelState extends Equatable {
  final MarkerPanel? panel;

  const PanelState({
    this.panel,
  });
  @override
  List<Object?> get props => [panel];
}

class MarkerPanel extends Equatable {
  final Widget Function(
    BuildContext context,
    void Function() onFetchPlan, {
    bool? isOnlyDestination,
  }) panel;
  final TrufiLatLng position;
  final double minSize;

  const MarkerPanel({
    required this.panel,
    required this.position,
    required this.minSize,
  });

  @override
  List<Object?> get props => [
        panel,
        position,
        minSize,
      ];
}
