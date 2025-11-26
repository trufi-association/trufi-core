import 'dart:convert';

import 'package:trufi_core/repositories/storage/i_local_storage.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/repositories/location/interfaces/i_location_service.dart';

/// Implementation of ILocationService using generic local storage
/// 
/// This implementation uses ILocalStorage interface, making it storage-agnostic.
/// It can work with any storage backend (SharedPreferences, Hive, Isar, etc.)
class StorageLocationService implements ILocationService {
  static const _favoritePlacesKey = 'StorageLocationService_FavoritePlaces';
  static const _historyPlacesKey = 'StorageLocationService_HistoryPlaces';
  static const _myDefaultPlacesKey = 'StorageLocationService_MyDefaultPlaces';
  static const _myPlacesKey = 'StorageLocationService_MyPlaces';

  final ILocalStorage _storage;

  StorageLocationService(this._storage);

  @override
  Future<void> loadRepository() async {
    await _storage.init();
  }

  @override
  Future<List<TrufiLocation>> getFavoritePlaces() async {
    final data = await _storage.getString(_favoritePlacesKey);
    if (data == null) return [];
    return (jsonDecode(data) as List<dynamic>)
        .map<TrufiLocation>(
          (dynamic json) =>
              TrufiLocation.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveFavoritePlaces(List<TrufiLocation> data) async {
    await _storage.setString(_favoritePlacesKey, jsonEncode(data));
  }

  @override
  Future<List<TrufiLocation>> getHistoryPlaces() async {
    final data = await _storage.getString(_historyPlacesKey);
    if (data == null) return [];
    return (jsonDecode(data) as List<dynamic>)
        .map<TrufiLocation>(
          (dynamic json) =>
              TrufiLocation.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveHistoryPlaces(List<TrufiLocation> data) async {
    await _storage.setString(_historyPlacesKey, jsonEncode(data));
  }

  @override
  Future<List<TrufiLocation>> getMyDefaultPlaces() async {
    final data = await _storage.getString(_myDefaultPlacesKey);
    if (data == null) return [];
    return (jsonDecode(data) as List<dynamic>)
        .map<TrufiLocation>(
          (dynamic json) =>
              TrufiLocation.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveMyDefaultPlaces(List<TrufiLocation> data) async {
    await _storage.setString(_myDefaultPlacesKey, jsonEncode(data));
  }

  @override
  Future<List<TrufiLocation>> getMyPlaces() async {
    final data = await _storage.getString(_myPlacesKey);
    if (data == null) return [];
    return (jsonDecode(data) as List<dynamic>)
        .map<TrufiLocation>(
          (dynamic json) =>
              TrufiLocation.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveMyPlaces(List<TrufiLocation> data) async {
    await _storage.setString(_myPlacesKey, jsonEncode(data));
  }
}
