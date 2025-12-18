import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

/// Cache for transport route list data.
///
/// Stores the raw route patterns from OTP to avoid refetching on app restart.
/// The cached data is JSON serializable (no widgets).
class TransportListCache {
  static const String _routesCacheKey = 'trufi_transport_list_routes_cache';
  static const String _detailsCacheKeyPrefix = 'trufi_transport_list_details_';

  final StorageService _storage;
  bool _isInitialized = false;

  /// Cached route patterns (raw data from API).
  List<CachedRoutePattern>? _cachedRoutes;

  /// Cached route details by code.
  final Map<String, CachedRouteDetails> _cachedDetails = {};

  TransportListCache({StorageService? storage})
      : _storage = storage ?? SharedPreferencesStorage();

  /// Initialize the cache.
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _storage.initialize();
    _isInitialized = true;
  }

  /// Dispose resources.
  Future<void> dispose() async {
    await _storage.dispose();
    _isInitialized = false;
  }

  // ============ Route List Cache ============

  /// Get cached routes (returns null if no cache).
  Future<List<CachedRoutePattern>?> getCachedRoutes() async {
    if (!_isInitialized) await initialize();

    // Return in-memory cache if available
    if (_cachedRoutes != null) return _cachedRoutes;

    // Try to load from storage
    try {
      final json = await _storage.read(_routesCacheKey);
      if (json == null) return null;

      final List<dynamic> decoded = jsonDecode(json);
      _cachedRoutes = decoded
          .map((e) => CachedRoutePattern.fromJson(e as Map<String, dynamic>))
          .toList();
      return _cachedRoutes;
    } catch (e) {
      debugPrint('TransportListCache: Error loading routes cache: $e');
      return null;
    }
  }

  /// Save routes to cache.
  Future<void> cacheRoutes(List<CachedRoutePattern> routes) async {
    if (!_isInitialized) await initialize();

    _cachedRoutes = routes;

    try {
      final json = jsonEncode(routes.map((r) => r.toJson()).toList());
      await _storage.write(_routesCacheKey, json);
    } catch (e) {
      debugPrint('TransportListCache: Error saving routes cache: $e');
    }
  }

  /// Clear the routes cache.
  Future<void> clearRoutesCache() async {
    if (!_isInitialized) await initialize();

    _cachedRoutes = null;
    await _storage.delete(_routesCacheKey);
  }

  // ============ Route Details Cache ============

  /// Get cached route details by code (returns null if not cached).
  Future<CachedRouteDetails?> getCachedDetails(String code) async {
    if (!_isInitialized) await initialize();

    // Return in-memory cache if available
    if (_cachedDetails.containsKey(code)) {
      return _cachedDetails[code];
    }

    // Try to load from storage
    try {
      final json = await _storage.read('$_detailsCacheKeyPrefix$code');
      if (json == null) return null;

      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final details = CachedRouteDetails.fromJson(decoded);
      _cachedDetails[code] = details;
      return details;
    } catch (e) {
      debugPrint('TransportListCache: Error loading details cache for $code: $e');
      return null;
    }
  }

  /// Save route details to cache.
  Future<void> cacheDetails(String code, CachedRouteDetails details) async {
    if (!_isInitialized) await initialize();

    _cachedDetails[code] = details;

    try {
      final json = jsonEncode(details.toJson());
      await _storage.write('$_detailsCacheKeyPrefix$code', json);
    } catch (e) {
      debugPrint('TransportListCache: Error saving details cache for $code: $e');
    }
  }

  /// Check if routes are cached.
  bool get hasRoutesCache => _cachedRoutes != null;
}

/// Cached route pattern data (JSON serializable).
class CachedRoutePattern {
  final String id;
  final String code;
  final String name;
  final String? shortName;
  final String? longName;
  final String? color;
  final String? textColor;
  final String? mode;

  const CachedRoutePattern({
    required this.id,
    required this.code,
    required this.name,
    this.shortName,
    this.longName,
    this.color,
    this.textColor,
    this.mode,
  });

  factory CachedRoutePattern.fromJson(Map<String, dynamic> json) {
    return CachedRoutePattern(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      longName: json['longName'] as String?,
      color: json['color'] as String?,
      textColor: json['textColor'] as String?,
      mode: json['mode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'shortName': shortName,
      'longName': longName,
      'color': color,
      'textColor': textColor,
      'mode': mode,
    };
  }
}

/// Cached route details data (JSON serializable).
class CachedRouteDetails extends CachedRoutePattern {
  final List<CachedLatLng>? geometry;
  final List<CachedStop>? stops;

  const CachedRouteDetails({
    required super.id,
    required super.code,
    required super.name,
    super.shortName,
    super.longName,
    super.color,
    super.textColor,
    super.mode,
    this.geometry,
    this.stops,
  });

  factory CachedRouteDetails.fromJson(Map<String, dynamic> json) {
    return CachedRouteDetails(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      longName: json['longName'] as String?,
      color: json['color'] as String?,
      textColor: json['textColor'] as String?,
      mode: json['mode'] as String?,
      geometry: (json['geometry'] as List<dynamic>?)
          ?.map((e) => CachedLatLng.fromJson(e as Map<String, dynamic>))
          .toList(),
      stops: (json['stops'] as List<dynamic>?)
          ?.map((e) => CachedStop.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'geometry': geometry?.map((e) => e.toJson()).toList(),
      'stops': stops?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Cached lat/lng coordinate.
class CachedLatLng {
  final double latitude;
  final double longitude;

  const CachedLatLng({
    required this.latitude,
    required this.longitude,
  });

  factory CachedLatLng.fromJson(Map<String, dynamic> json) {
    return CachedLatLng(
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
    };
  }
}

/// Cached stop data.
class CachedStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const CachedStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory CachedStop.fromJson(Map<String, dynamic> json) {
    return CachedStop(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': latitude,
      'lng': longitude,
    };
  }
}
