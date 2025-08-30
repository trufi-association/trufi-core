import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:trufi_core/base/blocs/providers/city_selection_manager.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';

import 'local_repository.dart';

class RouteTransportsHiveLocalRepository
    implements RouteTransportsLocalRepository {
  static const _transportListKey = 'RouteTransportsCubitTransportsListss';
  static const String _cityInstanceKey = 'cityInstanceKey';
  static const String path = "RouteTransportsCubit";
  late Box _box;

  @override
  Future<void> loadRepository() async {
    _box = Hive.box(path);
  }

  @override
  Future<void> saveTransports(List<TransitRoute> data) async {
    await _box.put(_transportListKey, jsonEncode(data));
  }

  @override
  Future<List<TransitRoute>> getTransports() async {
    if (!_box.containsKey(_transportListKey)) return [];
    return (jsonDecode(_box.get(_transportListKey)) as List<dynamic>)
        .map<TransitRoute>((dynamic json) =>
            TransitRoute.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CityInstance?> getCityInstance() async {
    return CityInstanceExtension.fromValue(_box.get(_cityInstanceKey));
  }

  @override
  Future<void> saveCityInstance(CityInstance data) async {
    await _box.put(_cityInstanceKey, data.toValue());
  }
}
