import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:trufi_core/models/map_tile_provider.dart';

import 'local_storage.dart';

part 'map_tile_provider_state.dart';

class MapTileProviderCubit extends Cubit<MapTileProviderState> {
  final MapTileLocalStorage _localStorage = MapTileLocalStorage();
  final List<MapTileProvider> mapTileProviders;

  MapTileProviderCubit({required this.mapTileProviders})
      : super(MapTileProviderState(
            currentMapTileProvider: mapTileProviders.first)) {
    _loadSavedStatus();
  }
  Future<void> _loadSavedStatus() async {
    final mapTileSavedId = await _localStorage.load();
    final MapTileProvider? mapTileProvider = mapTileProviders.firstWhereOrNull(
      (element) => element.id == mapTileSavedId,
    );
    emit(state.copyWith(currentMapTileProvider: mapTileProvider));
  }

  void changeMapTileProvider(MapTileProvider mapTileProvider) {
    emit(state.copyWith(currentMapTileProvider: mapTileProvider));
    _localStorage.save(mapTileProvider.id);
  }
}
