/// Abstract interface for key-value storage operations.
///
/// Implementations can use SharedPreferences, Hive, ObjectBox, or any other
/// storage backend.
abstract class StorageService {
  /// Initialize the storage backend.
  Future<void> initialize();

  /// Dispose resources.
  Future<void> dispose();

  // String operations
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();

  // Typed operations
  Future<void> writeInt(String key, int value);
  Future<int?> readInt(String key);

  Future<void> writeBool(String key, bool value);
  Future<bool?> readBool(String key);

  Future<void> writeDouble(String key, double value);
  Future<double?> readDouble(String key);

  Future<void> writeStringList(String key, List<String> value);
  Future<List<String>?> readStringList(String key);

  // Query operations
  Future<bool> containsKey(String key);
  Future<Set<String>> getKeys();
}
