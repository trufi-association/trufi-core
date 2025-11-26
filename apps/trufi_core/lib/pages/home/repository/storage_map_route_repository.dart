import 'dart:convert';

import 'package:trufi_core/models/plan_entity.dart';
import 'package:trufi_core/pages/home/repository/local_repository.dart';
import 'package:trufi_core/repositories/storage/i_local_storage.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

/// Implementation of MapRouteLocalRepository using generic local storage
/// 
/// This implementation uses ILocalStorage interface, making it storage-agnostic.
/// It can work with any storage backend (SharedPreferences, Hive, Isar, etc.)
class StorageMapRouteRepository implements MapRouteLocalRepository {
  static const String path = "StorageMapRouteRepository";
  static const _planKey = 'StorageMapRouteRepository_Plan';
  static const _originKey = 'StorageMapRouteRepository_Origin';
  static const _destinationKey = 'StorageMapRouteRepository_Destination';

  final ILocalStorage _storage;

  StorageMapRouteRepository(this._storage);

  @override
  Future<void> loadRepository() async {
    await _storage.init();
  }

  @override
  Future<PlanEntity?> getPlan() async {
    final data = await _storage.getString(_planKey);
    if (data == null) return null;
    return PlanEntity.fromJson(jsonDecode(data));
  }

  @override
  Future<void> savePlan(PlanEntity? data) async {
    if (data == null) {
      await _storage.remove(_planKey);
      return;
    }
    await _storage.setString(_planKey, jsonEncode(data));
  }

  @override
  Future<void> saveOriginPosition(TrufiLocation? location) async {
    if (location == null) {
      await _storage.remove(_originKey);
      return;
    }
    await _storage.setString(_originKey, jsonEncode(location.toJson()));
  }

  @override
  Future<TrufiLocation?> getOriginPosition() async {
    final data = await _storage.getString(_originKey);
    if (data == null) return null;
    return TrufiLocation.fromJson(jsonDecode(data));
  }

  @override
  Future<void> saveDestinationPosition(TrufiLocation? location) async {
    if (location == null) {
      await _storage.remove(_destinationKey);
      return;
    }
    await _storage.setString(_destinationKey, jsonEncode(location.toJson()));
  }

  @override
  Future<TrufiLocation?> getDestinationPosition() async {
    final data = await _storage.getString(_destinationKey);
    if (data == null) return null;
    return TrufiLocation.fromJson(jsonDecode(data));
  }
}
