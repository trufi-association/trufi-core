import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'trufi_map_engine.dart';

/// Manages the current map engine for the app with persistence.
///
/// This is a ChangeNotifier that can be used with Provider to manage
/// the selected map engine across the app.
///
/// Example usage:
/// ```dart
/// // Create the manager
/// final mapEngineManager = MapEngineManager(
///   engines: [
///     FlutterMapEngine(),
///     MapLibreEngine(styleString: 'https://...'),
///   ],
/// );
///
/// // Provide it to the widget tree
/// ChangeNotifierProvider.value(
///   value: mapEngineManager,
///   child: MyApp(),
/// )
///
/// // Use it in widgets
/// final manager = MapEngineManager.watch(context);
/// manager.currentEngine.buildMap(...);
///
/// // Change the engine
/// MapEngineManager.read(context).setEngine(newEngine);
/// ```
class MapEngineManager extends ChangeNotifier {
  static const _storageKey = 'trufi_map_engine_id';

  final List<ITrufiMapEngine> _engines;
  final LatLng defaultCenter;
  final double defaultZoom;
  int _currentIndex;

  MapEngineManager({
    required List<ITrufiMapEngine> engines,
    required this.defaultCenter,
    this.defaultZoom = 12.0,
    int defaultIndex = 0,
  })  : assert(engines.isNotEmpty, 'At least one engine is required'),
        assert(
          defaultIndex >= 0 && defaultIndex < engines.length,
          'defaultIndex must be valid',
        ),
        _engines = engines,
        _currentIndex = defaultIndex {
    _loadSavedEngine();
  }

  Future<void> _loadSavedEngine() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_storageKey);
    if (savedId != null) {
      final index = _engines.indexWhere((e) => e.id == savedId);
      if (index != -1 && index != _currentIndex) {
        _currentIndex = index;
        notifyListeners();
      }
    }
  }

  /// List of available engines.
  List<ITrufiMapEngine> get engines => List.unmodifiable(_engines);

  /// Currently selected engine.
  ITrufiMapEngine get currentEngine => _engines[_currentIndex];

  /// Index of the currently selected engine.
  int get currentIndex => _currentIndex;

  /// Sets the current engine by instance.
  void setEngine(ITrufiMapEngine engine) {
    final index = _engines.indexOf(engine);
    if (index != -1) {
      setEngineByIndex(index);
    }
  }

  /// Sets the current engine by index.
  void setEngineByIndex(int index) {
    if (index >= 0 && index < _engines.length && _currentIndex != index) {
      _currentIndex = index;
      _persistEngine(currentEngine.id);
      notifyListeners();
    }
  }

  Future<void> _persistEngine(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, id);
  }

  /// Sets the current engine by its id.
  void setEngineById(String id) {
    final index = _engines.indexWhere((e) => e.id == id);
    if (index != -1) {
      setEngineByIndex(index);
    }
  }

  /// Reads the MapEngineManager from context (does not listen to changes).
  static MapEngineManager read(BuildContext context) =>
      context.read<MapEngineManager>();

  /// Watches the MapEngineManager from context (rebuilds on changes).
  static MapEngineManager watch(BuildContext context) =>
      context.watch<MapEngineManager>();

  /// Tries to read the MapEngineManager from context, returns null if not found.
  static MapEngineManager? maybeRead(BuildContext context) {
    try {
      return context.read<MapEngineManager>();
    } catch (_) {
      return null;
    }
  }

  /// Tries to watch the MapEngineManager from context, returns null if not found.
  static MapEngineManager? maybeWatch(BuildContext context) {
    try {
      return context.watch<MapEngineManager>();
    } catch (_) {
      return null;
    }
  }
}
