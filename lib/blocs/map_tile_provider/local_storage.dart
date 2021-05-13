
import 'package:shared_preferences/shared_preferences.dart';

class MapTileLocalStorage {
  final String customLayersStorage = "map_tile_layers_storage";
  Future<bool> save(String mapLayerId) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(
      customLayersStorage,
      mapLayerId,
    );
  }

  Future<String> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(customLayersStorage);
  }
}
