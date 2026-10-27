import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';

/// Test double: a [StorageService] over a map, no platform channels. Shared
/// between repository instances to simulate an app restart.
class InMemoryStorage implements StorageService {
  final Map<String, Object> _values = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<String?> read(String key) async => _values[key] as String?;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> writeInt(String key, int value) async => _values[key] = value;

  @override
  Future<int?> readInt(String key) async => _values[key] as int?;

  @override
  Future<void> writeBool(String key, bool value) async => _values[key] = value;

  @override
  Future<bool?> readBool(String key) async => _values[key] as bool?;

  @override
  Future<void> writeDouble(String key, double value) async =>
      _values[key] = value;

  @override
  Future<double?> readDouble(String key) async => _values[key] as double?;

  @override
  Future<void> writeStringList(String key, List<String> value) async =>
      _values[key] = value;

  @override
  Future<List<String>?> readStringList(String key) async =>
      _values[key] as List<String>?;

  @override
  Future<bool> containsKey(String key) async => _values.containsKey(key);

  @override
  Future<Set<String>> getKeys() async => _values.keys.toSet();
}
