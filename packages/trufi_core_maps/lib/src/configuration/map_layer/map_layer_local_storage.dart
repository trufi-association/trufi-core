/// Abstract interface for persisting map layer visibility states.
abstract class MapLayerLocalStorage {
  /// Initialize the storage.
  Future<void> initialize();

  /// Close the storage and release resources.
  Future<void> dispose();

  /// Save the layer visibility states.
  Future<bool> save(Map<String, bool> currentState);

  /// Load the saved layer visibility states.
  Future<Map<String, bool>> load();
}
