import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_storage/trufi_core_storage.dart';

import 'home_screen_repository.dart';

/// Hive-based implementation of [HomeScreenRepository].
class HiveHomeScreenRepository implements HomeScreenRepository {
  static const String _boxName = 'home_screen_repository';
  static const String _fromPlaceKey = 'from_place';
  static const String _toPlaceKey = 'to_place';
  static const String _planKey = 'plan';
  static const String _selectedItineraryKey = 'selected_itinerary';

  Box? _box;

  @override
  Future<void> initialize() async {
    await TrufiHive.ensureInitialized();
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<void> dispose() async {
    await _box?.close();
  }

  @override
  Future<TrufiLocation?> getFromPlace() async {
    final data = _box?.get(_fromPlaceKey) as String?;
    if (data == null) return null;
    return TrufiLocation.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> saveFromPlace(TrufiLocation? data) async {
    if (data == null) {
      await _box?.delete(_fromPlaceKey);
    } else {
      await _box?.put(_fromPlaceKey, jsonEncode(data.toJson()));
    }
  }

  @override
  Future<TrufiLocation?> getToPlace() async {
    final data = _box?.get(_toPlaceKey) as String?;
    if (data == null) return null;
    return TrufiLocation.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> saveToPlace(TrufiLocation? data) async {
    if (data == null) {
      await _box?.delete(_toPlaceKey);
    } else {
      await _box?.put(_toPlaceKey, jsonEncode(data.toJson()));
    }
  }

  @override
  Future<routing.Plan?> getPlan() async {
    final data = _box?.get(_planKey) as String?;
    if (data == null) return null;
    return routing.Plan.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> savePlan(routing.Plan? data) async {
    if (data == null) {
      await _box?.delete(_planKey);
    } else {
      await _box?.put(_planKey, jsonEncode(data.toJson()));
    }
  }

  @override
  Future<routing.Itinerary?> getSelectedItinerary() async {
    final data = _box?.get(_selectedItineraryKey) as String?;
    if (data == null) return null;
    return routing.Itinerary.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> saveSelectedItinerary(routing.Itinerary? data) async {
    if (data == null) {
      await _box?.delete(_selectedItineraryKey);
    } else {
      await _box?.put(_selectedItineraryKey, jsonEncode(data.toJson()));
    }
  }

  @override
  Future<void> clear() async {
    await _box?.clear();
  }
}
