import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/repository/local_repository.dart';

class SearchLocationsHiveLocalRepository
    implements SearchLocationsLocalRepository {
  static const String path = "SearchLocationsCubit";
  static const _favoritePlacesKey = 'SearchLocationsCubitFavoritePlaces';
  static const _historyPlacesKey = 'SearchLocationsCubitHistoryPlaces';
  static const _myDefaultPlacesKey = 'SearchLocationsCubitMyDefaultPlaces';
  static const _myPlacesKey = 'SearchLocationsCubitMyPlaces';
  late Box _box;

  @override
  Future<void> loadRepository() async {
    _box =  Hive.box(path);
  }

  @override
  Future<List<TrufiLocation>> getFavoritePlaces() async {
    if (!_box.containsKey(_favoritePlacesKey)) return [];
    return (jsonDecode(_box.get(_favoritePlacesKey)) as List<dynamic>)
        .map<TrufiLocation>((dynamic json) =>
            TrufiLocation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TrufiLocation>> getHistoryPlaces() async {
    if (!_box.containsKey(_historyPlacesKey)) return [];
    return (jsonDecode(_box.get(_historyPlacesKey)) as List<dynamic>)
        .map<TrufiLocation>((dynamic json) =>
            TrufiLocation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TrufiLocation>> getMyDefaultPlaces() async {
    if (!_box.containsKey(_myDefaultPlacesKey)) return [];
    return (jsonDecode(_box.get(_myDefaultPlacesKey)) as List<dynamic>)
        .map<TrufiLocation>((dynamic json) =>
            TrufiLocation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TrufiLocation>> getMyPlaces() async {
    if (!_box.containsKey(_myPlacesKey)) return [];
    return (jsonDecode(_box.get(_myPlacesKey)) as List<dynamic>)
        .map<TrufiLocation>(
          (dynamic json) =>
              TrufiLocation.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveFavoritePlaces(List<TrufiLocation> data) async {
    await _box.put(_favoritePlacesKey, jsonEncode(data));
  }

  @override
  Future<void> saveHistoryPlaces(List<TrufiLocation> data) async {
    await _box.put(_historyPlacesKey, jsonEncode(data));
  }

  @override
  Future<void> saveMyDefaultPlaces(List<TrufiLocation> data) async {
    await _box.put(_myDefaultPlacesKey, jsonEncode(data));
  }

  @override
  Future<void> saveMyPlaces(List<TrufiLocation> data) async {
    await _box.put(_myPlacesKey, jsonEncode(data));
  }
}
