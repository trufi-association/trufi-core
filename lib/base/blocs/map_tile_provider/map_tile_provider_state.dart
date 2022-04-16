part of 'map_tile_provider_cubit.dart';

@immutable
class MapTileProviderState extends Equatable {
  final MapTileProvider currentMapTileProvider;

  const MapTileProviderState({
    required this.currentMapTileProvider,
  });

  MapTileProviderState copyWith({
    MapTileProvider? currentMapTileProvider,
  }) {
    return MapTileProviderState(
      currentMapTileProvider:
          currentMapTileProvider ?? this.currentMapTileProvider,
    );
  }

  @override
  List<Object> get props => [currentMapTileProvider];
}
