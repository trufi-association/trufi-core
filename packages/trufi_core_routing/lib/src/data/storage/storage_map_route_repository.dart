import 'dart:convert';

import '../../domain/entities/plan.dart';
import '../../domain/entities/routing_location.dart';
import '../../domain/repositories/map_route_repository.dart';
import 'local_storage.dart';

/// Implementation of [MapRouteRepository] using generic local storage.
///
/// This implementation uses [LocalStorage] interface, making it storage-agnostic.
/// It can work with any storage backend (SharedPreferences, Hive, Isar, etc.)
class StorageMapRouteRepository implements MapRouteRepository {
  static const _planKey = 'StorageMapRouteRepository_Plan';
  static const _originKey = 'StorageMapRouteRepository_Origin';
  static const _destinationKey = 'StorageMapRouteRepository_Destination';

  final LocalStorage _storage;

  StorageMapRouteRepository(this._storage);

  @override
  Future<void> loadRepository() async {
    await _storage.init();
  }

  @override
  Future<Plan?> getPlan() async {
    final data = await _storage.getString(_planKey);
    if (data == null) return null;
    return Plan.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> savePlan(Plan? data) async {
    if (data == null) {
      await _storage.remove(_planKey);
      return;
    }
    await _storage.setString(_planKey, jsonEncode(data.toJson()));
  }

  @override
  Future<void> saveOriginPosition(RoutingLocation? location) async {
    if (location == null) {
      await _storage.remove(_originKey);
      return;
    }
    await _storage.setString(_originKey, jsonEncode(location.toJson()));
  }

  @override
  Future<RoutingLocation?> getOriginPosition() async {
    final data = await _storage.getString(_originKey);
    if (data == null) return null;
    return RoutingLocation.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> saveDestinationPosition(RoutingLocation? location) async {
    if (location == null) {
      await _storage.remove(_destinationKey);
      return;
    }
    await _storage.setString(_destinationKey, jsonEncode(location.toJson()));
  }

  @override
  Future<RoutingLocation?> getDestinationPosition() async {
    final data = await _storage.getString(_destinationKey);
    if (data == null) return null;
    return RoutingLocation.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }
}
