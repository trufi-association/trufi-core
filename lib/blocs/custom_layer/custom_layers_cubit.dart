import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core/models/custom_layer.dart';

import 'local_storage.dart';

part 'custom_layers_state.dart';

class CustomLayersCubit extends Cubit<CustomLayersState> {
  final LocalStorage _localStorage = LocalStorage();
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
        // TODO: improve state refresh
        final tempLayers = state.layers;
        emit(state.copyWith(layers: []));
        emit(state.copyWith(layers: tempLayers));
      };
    }
    _loadSavedStatus();
  }
  Future<void> _loadSavedStatus() async {
    final savedMap = await _localStorage.load();
    emit(state.copyWith(layersSatus: {...state.layersSatus, ...savedMap}));
  }

  void changeCustomMapLayerState({
    @required CustomLayer customLayer,
    @required bool newState,
  }) {
    final Map<String, bool> tempMap = Map.from(state.layersSatus);
    tempMap[customLayer.id] = newState;
    emit(state.copyWith(layersSatus: tempMap));
    _localStorage.save(state.layersSatus);
  }

  List<LayerOptions> activeCustomLayers(int zoom) => state.layers
      .where((element) => state.layersSatus[element.id])
      .map((element) => element.buildLayerOptions(zoom))
      .toList();
}
