part of 'custom_layers_cubit.dart';

class CustomLayersState extends Equatable {
  final Map<String, bool> layersSatus;
  final List<CustomLayer> layers;
  const CustomLayersState({
    this.layersSatus,
    this.layers,
  });

  CustomLayersState copyWith({
    Map<String, bool> layersSatus,
    List<CustomLayer> layers,
  }) {
    return CustomLayersState(
      layersSatus: layersSatus ?? this.layersSatus,
      layers: layers ?? this.layers,
    );
  }

  @override
  List<Object> get props => [
        layersSatus,
        layers,
      ];
}
