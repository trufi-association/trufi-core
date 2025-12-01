import 'package:hive/hive.dart';

class MapTileLocalStorage {
  static const String customLayersStorage = "map_tile_layers_storage";

  late Box _box;

  MapTileLocalStorage() {
    _box = Hive.box(customLayersStorage);
  }

  Future<void> save(String mapLayerId) async {
    await _box.put(customLayersStorage, mapLayerId);
  }

  Future<String?> load() async {
    return _box.get(customLayersStorage);
  }
}
