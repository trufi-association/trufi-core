import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/routing_preferences.dart';

/// Manages routing preferences with persistence.
///
/// Call [initialize] after WidgetsFlutterBinding.ensureInitialized() to load
/// saved preferences. Until then, default preferences will be used.
class RoutingPreferencesManager extends ChangeNotifier {
  static const _storageKey = 'trufi_routing_preferences';

  RoutingPreferences _preferences;
  bool _isInitialized = false;

  RoutingPreferencesManager({
    RoutingPreferences defaultPreferences = const RoutingPreferences(),
  }) : _preferences = defaultPreferences;

  /// Whether the manager has loaded saved preferences.
  bool get isInitialized => _isInitialized;

  /// Initializes and loads saved preferences from storage.
  /// Call this after WidgetsFlutterBinding.ensureInitialized().
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadSavedPreferences();
    _isInitialized = true;
  }

  /// Current routing preferences.
  RoutingPreferences get preferences => _preferences;

  /// Whether wheelchair accessibility is enabled.
  bool get wheelchair => _preferences.wheelchair;

  /// Current walk speed level.
  WalkSpeedLevel get walkSpeedLevel => _preferences.walkSpeedLevel;

  /// Maximum walk distance (null = unlimited).
  double? get maxWalkDistance => _preferences.maxWalkDistance;

  /// Transport modes enabled for routing.
  Set<RoutingMode> get transportModes => _preferences.transportModes;

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final loaded = _fromJson(json);
        if (loaded != _preferences) {
          _preferences = loaded;
          notifyListeners();
        }
      } catch (_) {
        // Invalid JSON, use defaults
      }
    }
  }

  Future<void> _persistPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _toJson(_preferences);
    await prefs.setString(_storageKey, jsonEncode(json));
  }

  /// Updates the routing preferences.
  void updatePreferences(RoutingPreferences newPreferences) {
    if (_preferences != newPreferences) {
      _preferences = newPreferences;
      _persistPreferences();
      notifyListeners();
    }
  }

  /// Sets wheelchair accessibility.
  void setWheelchair(bool value) {
    if (_preferences.wheelchair != value) {
      _preferences = _preferences.copyWith(wheelchair: value);
      if (value) {
        // Auto-adjust for wheelchair users
        _preferences = _preferences.copyWith(
          walkSpeed: 0.8,
          walkReluctance: 3.0,
          maxWalkDistance: _preferences.maxWalkDistance ?? 400,
        );
      }
      _persistPreferences();
      notifyListeners();
    }
  }

  /// Sets the walk speed level.
  void setWalkSpeedLevel(WalkSpeedLevel level) {
    if (_preferences.walkSpeedLevel != level) {
      _preferences = _preferences.copyWith(
        walkSpeed: level.speedValue,
        walkReluctance: level.reluctanceValue,
      );
      _persistPreferences();
      notifyListeners();
    }
  }

  /// Sets the maximum walk distance (null = unlimited).
  void setMaxWalkDistance(double? distance) {
    if (_preferences.maxWalkDistance != distance) {
      _preferences = distance != null
          ? _preferences.copyWith(maxWalkDistance: distance)
          : _preferences.copyWith(clearMaxWalkDistance: true);
      _persistPreferences();
      notifyListeners();
    }
  }

  /// Sets the transport modes.
  void setTransportModes(Set<RoutingMode> modes) {
    if (_preferences.transportModes != modes) {
      _preferences = _preferences.copyWith(transportModes: modes);
      _persistPreferences();
      notifyListeners();
    }
  }

  /// Toggles a transport mode on/off.
  void toggleTransportMode(RoutingMode mode) {
    final modes = Set<RoutingMode>.from(_preferences.transportModes);
    if (modes.contains(mode)) {
      // Don't allow removing all modes
      if (modes.length > 1) {
        modes.remove(mode);
      }
    } else {
      modes.add(mode);
    }
    setTransportModes(modes);
  }

  /// Resets to default preferences.
  void reset() {
    _preferences = const RoutingPreferences();
    _persistPreferences();
    notifyListeners();
  }

  Map<String, dynamic> _toJson(RoutingPreferences prefs) {
    return {
      'wheelchair': prefs.wheelchair,
      'walkSpeed': prefs.walkSpeed,
      'maxWalkDistance': prefs.maxWalkDistance,
      'walkReluctance': prefs.walkReluctance,
      'bikeSpeed': prefs.bikeSpeed,
      'transportModes': prefs.transportModes.map((m) => m.name).toList(),
    };
  }

  RoutingPreferences _fromJson(Map<String, dynamic> json) {
    return RoutingPreferences(
      wheelchair: json['wheelchair'] as bool? ?? false,
      walkSpeed: (json['walkSpeed'] as num?)?.toDouble() ?? 1.33,
      maxWalkDistance: (json['maxWalkDistance'] as num?)?.toDouble(),
      walkReluctance: (json['walkReluctance'] as num?)?.toDouble() ?? 2.0,
      bikeSpeed: (json['bikeSpeed'] as num?)?.toDouble() ?? 5.0,
      transportModes: (json['transportModes'] as List<dynamic>?)
              ?.map((e) => RoutingMode.values.firstWhere(
                    (m) => m.name == e,
                    orElse: () => RoutingMode.transit,
                  ))
              .toSet() ??
          const {RoutingMode.transit, RoutingMode.walk},
    );
  }

  /// Reads the manager from context (does not listen to changes).
  static RoutingPreferencesManager read(BuildContext context) =>
      context.read<RoutingPreferencesManager>();

  /// Watches the manager from context (rebuilds on changes).
  static RoutingPreferencesManager watch(BuildContext context) =>
      context.watch<RoutingPreferencesManager>();

  /// Tries to read the manager from context, returns null if not found.
  static RoutingPreferencesManager? maybeRead(BuildContext context) {
    try {
      return context.read<RoutingPreferencesManager>();
    } catch (_) {
      return null;
    }
  }

  /// Tries to watch the manager from context, returns null if not found.
  static RoutingPreferencesManager? maybeWatch(BuildContext context) {
    try {
      return context.watch<RoutingPreferencesManager>();
    } catch (_) {
      return null;
    }
  }
}
