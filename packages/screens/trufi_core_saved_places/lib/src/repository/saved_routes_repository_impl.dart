import 'dart:convert';

import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../models/saved_route.dart';
import 'saved_routes_repository.dart';

/// Default implementation of [SavedRoutesRepository].
///
/// Keeps the whole list as one JSON array under [storageKey] on a
/// [StorageService]; by default [SharedPreferencesStorage], but any
/// implementation works for testing or alternative backends.
class SavedRoutesRepositoryImpl implements SavedRoutesRepository {
  /// Preferences key holding the JSON list of saved routes.
  static const String storageKey = 'trufi_saved_routes';

  final StorageService _storage;
  bool _isInitialized = false;

  SavedRoutesRepositoryImpl({StorageService? storage})
    : _storage = storage ?? SharedPreferencesStorage();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _storage.initialize();
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    await _storage.dispose();
    _isInitialized = false;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'SavedRoutesRepositoryImpl not initialized. Call initialize() first.',
      );
    }
  }

  @override
  Future<List<SavedRoute>> getAllRoutes() async {
    _ensureInitialized();
    return _readRoutes();
  }

  @override
  Future<void> saveRoute(SavedRoute route) async {
    _ensureInitialized();
    final routes = await _readRoutes();
    routes.add(route);
    await _writeRoutes(routes);
  }

  @override
  Future<void> updateRoute(SavedRoute route) async {
    _ensureInitialized();
    final routes = await _readRoutes();
    final index = routes.indexWhere((r) => r.id == route.id);
    if (index == -1) return;
    routes[index] = route;
    await _writeRoutes(routes);
  }

  @override
  Future<void> deleteRoute(String id) async {
    _ensureInitialized();
    final routes = await _readRoutes();
    final originalLength = routes.length;
    routes.removeWhere((r) => r.id == id);
    if (routes.length != originalLength) {
      await _writeRoutes(routes);
    }
  }

  Future<List<SavedRoute>> _readRoutes() async {
    final data = await _storage.read(storageKey);
    if (data == null) return [];
    final jsonList = jsonDecode(data) as List<dynamic>;
    return jsonList
        .map((json) => SavedRoute.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeRoutes(List<SavedRoute> routes) async {
    final jsonList = routes.map((r) => r.toJson()).toList();
    await _storage.write(storageKey, jsonEncode(jsonList));
  }
}
