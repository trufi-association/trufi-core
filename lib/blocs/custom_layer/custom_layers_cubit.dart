import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core/models/custom_layer.dart';

part 'custom_layers_state.dart';

class CustomLayersCubit extends Cubit<CustomLayersState> {
  CustomLayersCubit(List<CustomLayer> layers)
      : super(
          CustomLayersState(
            layersSatus:
                layers.asMap().map((key, value) => MapEntry(value.id, true)),
            layers: layers,
          ),
        ) {
    /// listen changes called by on [onRefresh] from each [CustomLayer] for request refresh the current [CustomLayersState]
    for (final CustomLayer layer in layers) {
      layer.onRefresh = () {
        emit(state.copyWith());
      };
    }
  }

  void changeCustomMapLayerState({
    @required CustomLayer customLayer,
    @required bool newState,
  }) {
    final Map<String, bool> tempMap = Map.from(state.layersSatus);
    tempMap[customLayer.id] = newState;
    emit(state.copyWith(layersSatus: tempMap));
  }

  List<LayerOptions> get activeCustomLayers => state.layers
      .where((element) => state.layersSatus[element.id])
      .map((element) => element.layerOptions)
      .toList();
}
