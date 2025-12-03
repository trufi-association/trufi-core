abstract class StorageService {
  Future<void> initialize();

  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();

  Future<void> writeInt(String key, int value);
  Future<int?> readInt(String key);

  Future<void> writeBool(String key, bool value);
  Future<bool?> readBool(String key);

  Future<void> writeDouble(String key, double value);
  Future<double?> readDouble(String key);

  Future<void> writeStringList(String key, List<String> value);
  Future<List<String>?> readStringList(String key);

  Future<bool> containsKey(String key);
  Future<Set<String>> getKeys();
}
