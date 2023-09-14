import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';

import 'map_layer.dart';
import 'map_layer_local_storage.dart';
part 'map_layers_state.dart';

class MapLayersCubit extends Cubit<MapLayersState> {
  final MapLayerLocalStorage _localStorage = MapLayerLocalStorage();
  final List<MapLayerContainer> layersContainer;
  MapLayersCubit(this.layersContainer)
      : super(
          MapLayersState(
            layersSatus: layersContainer
                .fold<List<MapLayer>>(
                    [],
                    (previousValue, element) =>
                        [...previousValue, ...element.layers])
                .asMap()
                .map((key, value) => MapEntry(value.id, false)),
            layers: layersContainer.fold<List<MapLayer>>(
                [],
                (previousValue, element) =>
                    [...previousValue, ...element.layers]),
          ),
        ) {
    for (final MapLayerContainer layerContainer in layersContainer) {
      for (final MapLayer layer in layerContainer.layers) {
        layer.onRefresh = () {
          // TODO: improve state refresh
          final tempLayers = state.layers;
          emit(state.copyWith(layers: []));
          emit(state.copyWith(layers: tempLayers));
        };
      }
    }
    _loadSavedStatus();
  }
  Future<void> _loadSavedStatus() async {
    final savedMap = await _localStorage.load();
    emit(state.copyWith(layersSatus: {...state.layersSatus, ...savedMap}));
  }

  void changeCustomMapLayerState({
    required MapLayer customLayer,
    required bool newState,
  }) {
    final Map<String, bool> tempMap = Map.from(state.layersSatus);
    tempMap[customLayer.id] = newState;
    emit(state.copyWith(layersSatus: tempMap));
    _localStorage.save(state.layersSatus);
  }

  void changeCustomMapLayerContainerState({
    required MapLayerContainer customLayer,
    required bool newState,
  }) {
    final Map<String, bool> tempMap = Map.from(state.layersSatus);
    for (final MapLayer layer in customLayer.layers) {
      tempMap[layer.id] = newState;
    }

    emit(state.copyWith(layersSatus: tempMap));
    _localStorage.save(state.layersSatus);
  }

  List<Marker> markers(
    int zoom,
  ) {
    List<MapLayer> listSort = state.layers
        .where((element) => state.layersSatus[element.id] ?? false)
        .toList();

    listSort.sort((a, b) => a.weight.compareTo(b.weight));
    final allList =
        listSort.map((element) => element.buildLayerMarkers(zoom)).toList();
    return allList.expand((list) => list ?? <Marker>[]).toList();
  }

  List<Widget> activeCustomLayers({
    required int zoom,
    required List<Widget> layers,
    required Widget layersClusterPOIs,
  }) {
    List<MapLayer> listSort = state.layers;
    listSort = state.layers
        .where((element) => state.layersSatus[element.id] ?? false)
        .toList();
    listSort.sort((a, b) => a.weight.compareTo(b.weight));

    final listPOIBackground = [];
    Widget? layerPOIBackground;
    for (MapLayer customL in listSort) {
      layerPOIBackground = customL.buildLayerOptionsBackground(zoom);
      if (layerPOIBackground != null) {
        listPOIBackground.add(layerPOIBackground);
      }
    }
    final listPOI =
        listSort.map((element) => element.buildLayerOptions(zoom)).toList();

    return zoom > 13
        ? layers.isNotEmpty
            ? [
                ...listPOIBackground,
                ...listPOI,
                ...layers,
              ]
            : [
                ...listPOIBackground,
                ...listPOI,
                layersClusterPOIs,
                ...layers,
              ]
        : layers;
  }
}
