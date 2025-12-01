part of 'map_layers_cubit.dart';

class MapLayersState extends Equatable {
  final Map<String, bool> layersSatus;
  final List<MapLayer> layers;
  const MapLayersState({
    required this.layersSatus,
    required this.layers,
  });

  MapLayersState copyWith({
    Map<String, bool>? layersSatus,
    List<MapLayer>? layers,
    Widget? layer,
  }) {
    return MapLayersState(
      layersSatus: layersSatus ?? this.layersSatus,
      layers: layers ?? this.layers,
    );
  }

  @override
  List<Object?> get props => [
        layersSatus,
        layers,
      ];
}
