part of 'panel_cubit.dart';

class PanelState extends Equatable {
  final CustomMarkerPanel panel;

  const PanelState({this.panel});
  @override
  List<Object> get props => [panel];
}

class CustomMarkerPanel {
  final WidgetBuilder panel;
  final LatLng positon;
  final double minSize;

  CustomMarkerPanel({
    @required this.panel,
    @required this.positon,
    @required this.minSize,
  });
}
