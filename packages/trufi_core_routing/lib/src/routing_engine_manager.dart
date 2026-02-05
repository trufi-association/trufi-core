import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/routing_provider.dart';
import 'providers/gtfs/data/gtfs_plan_repository.dart';

/// Manages the current routing engine for the app with persistence.
///
/// This is a ChangeNotifier that can be used with Provider to manage
/// the selected routing provider across the app.
///
/// Example usage:
/// ```dart
/// // Create the manager
/// final routingEngineManager = RoutingEngineManager(
///   engines: [
///     Otp28RoutingProvider(endpoint: 'https://otp.trufi.app'),
///     GtfsRoutingProvider(config: ...),
///   ],
/// );
///
/// // Provide it to the widget tree
/// ChangeNotifierProvider.value(
///   value: routingEngineManager,
///   child: MyApp(),
/// )
///
/// // Use it in widgets
/// final manager = RoutingEngineManager.watch(context);
/// manager.currentEngine.createPlanRepository();
///
/// // Change the engine
/// RoutingEngineManager.read(context).setEngine(newEngine);
/// ```
class RoutingEngineManager extends ChangeNotifier {
  static const _storageKey = 'trufi_routing_engine_id';

  final List<IRoutingProvider> _engines;
  int _currentIndex;
  bool _isPreloading = false;

  RoutingEngineManager({
    required List<IRoutingProvider> engines,
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

    // Preload offline data if current engine is offline
    if (!currentEngine.requiresInternet) {
      _preloadCurrentEngine();
    }
  }

  /// List of available engines.
  List<IRoutingProvider> get engines => List.unmodifiable(_engines);

  /// Initialize all engines.
  ///
  /// This should be called during app startup to prepare all engines.
  /// For online engines (OTP), this is a no-op. For offline engines (GTFS),
  /// this loads and indexes the data.
  Future<void> initializeEngines() async {
    for (final engine in _engines) {
      await engine.initialize();
    }
  }

  /// Currently selected engine.
  IRoutingProvider get currentEngine => _engines[_currentIndex];

  /// Index of the currently selected engine.
  int get currentIndex => _currentIndex;

  /// Whether data is currently being preloaded.
  bool get isPreloading => _isPreloading;

  /// Returns true if there are multiple engines available.
  bool get hasMultipleEngines => _engines.length > 1;

  /// Returns true if offline routing is available.
  bool get hasOfflineEngine => _engines.any((e) => !e.requiresInternet);

  /// Sets the current engine by instance.
  void setEngine(IRoutingProvider engine) {
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

      // Preload if offline engine
      if (!currentEngine.requiresInternet) {
        _preloadCurrentEngine();
      }
    }
  }

  /// Sets the current engine by its id.
  void setEngineById(String id) {
    final index = _engines.indexWhere((e) => e.id == id);
    if (index != -1) {
      setEngineByIndex(index);
    }
  }

  Future<void> _persistEngine(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, id);
  }

  /// Preloads data for the current engine (if it supports preloading).
  void _preloadCurrentEngine() {
    if (_isPreloading) return;

    final repo = currentEngine.createPlanRepository();
    if (repo is GtfsPlanRepository) {
      if (!repo.isLoaded && !repo.isLoading) {
        _isPreloading = true;
        notifyListeners();

        repo.preload().then((_) {
          _isPreloading = false;
          notifyListeners();
        }).catchError((e) {
          debugPrint('RoutingEngineManager: Preload failed: $e');
          _isPreloading = false;
          notifyListeners();
        });
      }
    }
  }

  /// Reads the RoutingEngineManager from context (does not listen to changes).
  static RoutingEngineManager read(BuildContext context) =>
      context.read<RoutingEngineManager>();

  /// Watches the RoutingEngineManager from context (rebuilds on changes).
  static RoutingEngineManager watch(BuildContext context) =>
      context.watch<RoutingEngineManager>();

  /// Tries to read the RoutingEngineManager from context, returns null if not found.
  static RoutingEngineManager? maybeRead(BuildContext context) {
    try {
      return context.read<RoutingEngineManager>();
    } catch (_) {
      return null;
    }
  }

  /// Tries to watch the RoutingEngineManager from context, returns null if not found.
  static RoutingEngineManager? maybeWatch(BuildContext context) {
    try {
      return context.watch<RoutingEngineManager>();
    } catch (_) {
      return null;
    }
  }
}
