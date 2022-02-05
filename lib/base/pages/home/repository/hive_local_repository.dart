import 'dart:convert';
import 'package:hive/hive.dart';

import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/repository/local_repository.dart';

class MapRouteHiveLocalRepository implements MapRouteLocalRepository {
  static const String path = "MapRouteCubit";
  static const _planKey = 'MapRouteCubitPlan';
  static const _itineraryKey = 'MapRouteCubitItinerary';
  static const _fromPlaceKey = 'MapRouteCubitFromPlace';
  static const _toPlaceKey = 'MapRouteCubitToPlace';
  late Box _box;

  @override
  Future<void> loadRepository() async {
    _box = Hive.box(path);
  }

  @override
  Future<TrufiLocation?> getFromPlace() async {
    final data = _box.get(_fromPlaceKey);
    if (data == null) return null;
    return TrufiLocation.fromJson(jsonDecode(data));
  }

  @override
  Future<Plan?> getPlan() async {
    final data = _box.get(_planKey);
    if (data == null) return null;
    return Plan.fromJson(jsonDecode(data));
  }

  @override
  Future<Itinerary?> getSelectedItinerary() async {
    final data = _box.get(_itineraryKey);
    if (data == null) return null;
    return Itinerary.fromJson(jsonDecode(data));
  }

  @override
  Future<TrufiLocation?> getToPlace() async {
    final data = _box.get(_toPlaceKey);
    if (data == null) return null;
    return TrufiLocation.fromJson(jsonDecode(data));
  }

  @override
  Future<void> saveFromPlace(TrufiLocation? data) async {
    await _box.put(_fromPlaceKey, data != null ? jsonEncode(data) : null);
  }

  @override
  Future<void> savePlan(Plan? data) async {
    await _box.put(_planKey, data != null ? jsonEncode(data) : null);
  }

  @override
  Future<void> saveToPlace(TrufiLocation? data) async {
    await _box.put(_toPlaceKey, data != null ? jsonEncode(data) : null);
  }

  @override
  Future<void> saveSelectedItinerary(Itinerary? data) async {
    await _box.put(_itineraryKey, data != null ? jsonEncode(data) : null);
  }
}
