/// Interface for local storage operations
/// 
/// This interface provides a generic contract for storing and retrieving
/// data locally. It can be implemented by different storage mechanisms
/// like SharedPreferences, Hive, Isar, etc.
abstract class ILocalStorage {
  /// Initialize the storage service
  Future<void> init();

  /// Store a string value
  Future<void> setString(String key, String value);

  /// Retrieve a string value
  Future<String?> getString(String key);

  /// Check if a key exists
  Future<bool> containsKey(String key);

  /// Remove a specific key
  Future<void> remove(String key);

  /// Clear all stored data
  Future<void> clear();

  /// Get all keys
  Future<Set<String>> getKeys();
}
