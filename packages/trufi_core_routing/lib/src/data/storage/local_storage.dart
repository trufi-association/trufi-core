/// Interface for local storage operations.
abstract class LocalStorage {
  /// Initializes the storage.
  Future<void> init();

  /// Retrieves a string value by key.
  Future<String?> getString(String key);

  /// Stores a string value by key.
  Future<void> setString(String key, String value);

  /// Removes a value by key.
  Future<void> remove(String key);
}
