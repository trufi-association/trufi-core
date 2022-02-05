import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:trufi_core/base/pages/transport_list/repository/local_repository.dart';
import 'package:trufi_core/base/pages/transport_list/services/models.dart';

class RouteTransportsHiveLocalRepository
    implements RouteTransportsLocalRepository {
  static const _transportListKey = 'RouteTransportsCubitTransportsListss';
  static const String path = "RouteTransportsCubit";
  late Box _box;

  @override
  Future<void> loadRepository() async {
    _box = Hive.box(path);
  }

  @override
  Future<void> saveTransports(List<PatternOtp> data) async {
    await _box.put(_transportListKey, jsonEncode(data));
  }

  @override
  Future<List<PatternOtp>> getTransports() async {
    if (!_box.containsKey(_transportListKey)) return [];
    return (jsonDecode(_box.get(_transportListKey)) as List<dynamic>)
        .map<PatternOtp>(
            (dynamic json) => PatternOtp.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
