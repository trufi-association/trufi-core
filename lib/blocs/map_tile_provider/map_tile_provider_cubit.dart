import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:trufi_core/models/map_tile_provider.dart';

import 'local_storage.dart';

part 'map_tile_provider_state.dart';

class MapTileProviderCubit extends Cubit<MapTileProviderState> {
  final MapTileLocalStorage _localStorage = MapTileLocalStorage();
  final List<MapTileProvider> mapTileProviders;

  MapTileProviderCubit({this.mapTileProviders})
      : super(MapTileProviderState(
            currentMapTileProvider: mapTileProviders.first)) {
    _loadSavedStatus();
  }
  Future<void> _loadSavedStatus() async {
    final mapTileSavedId = await _localStorage.load();
    final MapTileProvider mapTileProvider = mapTileProviders.firstWhere(
      (element) => element.id == mapTileSavedId,
      orElse: () => null,
    );
    emit(state.copyWith(currentMapTileProvider: mapTileProvider));
  }

  void changeMapTileProvider(MapTileProvider mapTileProvider) {
    emit(state.copyWith(currentMapTileProvider: mapTileProvider));
    _localStorage.save(mapTileProvider.id);
  }
}
