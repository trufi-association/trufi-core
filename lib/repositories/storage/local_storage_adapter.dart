import 'package:trufi_core/repositories/storage/i_local_storage.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// Adapter that makes [ILocalStorage] compatible with [LocalStorage] from the routing package.
class LocalStorageAdapter implements LocalStorage {
  final ILocalStorage _storage;

  LocalStorageAdapter(this._storage);

  @override
  Future<void> init() => _storage.init();

  @override
  Future<String?> getString(String key) => _storage.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _storage.setString(key, value);

  @override
  Future<void> remove(String key) => _storage.remove(key);
}
