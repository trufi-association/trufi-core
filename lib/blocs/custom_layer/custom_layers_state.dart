part of 'custom_layers_cubit.dart';

class CustomLayersState extends Equatable {
  final Map<String, bool> layersSatus;
  final List<CustomLayer> layers;
  final int mapZom;
  const CustomLayersState({
    this.layersSatus,
    this.layers,
    this.mapZom,
  });

  CustomLayersState copyWith({
    Map<String, bool> layersSatus,
    List<CustomLayer> layers,
    int mapZom,
  }) {
    return CustomLayersState(
      layersSatus: layersSatus ?? this.layersSatus,
      layers: layers ?? this.layers,
      mapZom: mapZom ?? this.mapZom,
    );
  }

  @override
  List<Object> get props => [
        layersSatus,
        layers,

        /// the state should be refreshed if the [LayerOptions] has been changed
        ...layers.map((e) => e.buildLayerOptions).toList(),
        mapZom
      ];
}
