import 'dart:convert';

import 'package:trufi_core_storage/src/storage_service.dart';

/// Generic repository for typed storage operations
class StorageRepository<T> {
  final StorageService _storage;
  final String prefix;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  StorageRepository({
    required StorageService storage,
    required this.prefix,
    required this.fromJson,
    required this.toJson,
  }) : _storage = storage;

  String _key(String id) => '${prefix}_$id';

  Future<void> save(String id, T entity) async {
    final json = jsonEncode(toJson(entity));
    await _storage.write(_key(id), json);
  }

  Future<T?> get(String id) async {
    final json = await _storage.read(_key(id));
    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return fromJson(map);
    } catch (e) {
      return null;
    }
  }

  Future<void> delete(String id) async {
    await _storage.delete(_key(id));
  }

  Future<List<T>> getAll() async {
    final keys = await _storage.getKeys();
    final matchingKeys = keys.where((k) => k.startsWith(prefix));

    final entities = <T>[];
    for (final key in matchingKeys) {
      final json = await _storage.read(key);
      if (json != null) {
        try {
          final map = jsonDecode(json) as Map<String, dynamic>;
          entities.add(fromJson(map));
        } catch (e) {
          // Skip invalid entries
        }
      }
    }

    return entities;
  }

  Future<void> clear() async {
    final keys = await _storage.getKeys();
    final matchingKeys = keys.where((k) => k.startsWith(prefix));

    for (final key in matchingKeys) {
      await _storage.delete(key);
    }
  }

  Future<bool> exists(String id) async {
    return await _storage.containsKey(_key(id));
  }
}
