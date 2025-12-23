import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../models/poi.dart';
import '../models/poi_category.dart';

/// Loads POIs from GeoJSON assets with support for lazy loading and parallel preloading.
///
/// Features:
/// - Lazy loading: Categories are loaded only when requested
/// - Parallel preloading: Multiple categories can be preloaded in background
/// - Caching: Loaded data is cached to avoid redundant loads
/// - Future deduplication: Multiple simultaneous requests for the same category
///   share a single loading operation
class GeoJSONLoader {
  /// Cached POI data by category
  final Map<POICategory, List<POI>> _cache = {};

  /// In-flight loading futures to prevent duplicate loads
  final Map<POICategory, Future<List<POI>>> _loadingFutures = {};

  /// Base path for POI assets
  final String assetsBasePath;

  GeoJSONLoader({
    required this.assetsBasePath,
  });

  /// Load POIs for a specific category.
  ///
  /// If the category is already cached, returns immediately.
  /// If the category is currently loading, waits for the existing load to complete.
  /// Otherwise, starts a new load operation.
  Future<List<POI>> loadCategory(POICategory category) async {
    // Return cached if available
    if (_cache.containsKey(category)) {
      return _cache[category]!;
    }

    // Wait for ongoing load if exists
    if (_loadingFutures.containsKey(category)) {
      return await _loadingFutures[category]!;
    }

    // Start new load
    return await _startLoad(category);
  }

  /// Start loading a category (internal method)
  Future<List<POI>> _startLoad(POICategory category) {
    final future = Future(() async {
      try {
        final assetPath = '$assetsBasePath/${category.filename}.geojson';
        debugPrint('📦 GeoJSONLoader: Loading $assetPath...');

        final jsonString = await rootBundle.loadString(assetPath);
        final geojson = json.decode(jsonString) as Map<String, dynamic>;

        final features = geojson['features'] as List<dynamic>? ?? [];
        final pois = features
            .map((f) => POI.fromGeoJsonFeature(f as Map<String, dynamic>))
            .toList();

        _cache[category] = pois;
        debugPrint(
            '✅ GeoJSONLoader: Loaded ${pois.length} POIs for ${category.name}');
        return pois;
      } catch (e, stackTrace) {
        debugPrint(
            '❌ GeoJSONLoader: Error loading ${category.name} from $assetsBasePath: $e');
        debugPrint('Stack trace: $stackTrace');
        return <POI>[];
      } finally {
        // Remove from loading futures once complete
        _loadingFutures.remove(category);
      }
    });

    _loadingFutures[category] = future;
    return future;
  }

  /// Preload categories in the background without blocking.
  ///
  /// This is useful for preloading commonly used categories during app initialization.
  /// The loading happens in parallel and doesn't block the caller.
  ///
  /// Example:
  /// ```dart
  /// loader.preloadCategories({
  ///   POICategory.transport,
  ///   POICategory.food,
  /// });
  /// ```
  void preloadCategories(Set<POICategory> categories) {
    for (final category in categories) {
      if (!_cache.containsKey(category) &&
          !_loadingFutures.containsKey(category)) {
        _startLoad(category);
      }
    }
  }

  /// Preload all categories in parallel (non-blocking).
  ///
  /// Useful when you want all POI data available but don't want to block
  /// the UI during initialization.
  void preloadAll() {
    preloadCategories(POICategory.values.toSet());
  }

  /// Load POIs for multiple categories.
  ///
  /// This method loads categories sequentially. For parallel loading,
  /// use [preloadCategories] followed by [loadCategory] for each category.
  Future<List<POI>> loadCategories(Set<POICategory> categories) async {
    final results = <POI>[];
    for (final category in categories) {
      final pois = await loadCategory(category);
      results.addAll(pois);
    }
    return results;
  }

  /// Load multiple categories in parallel and return all POIs.
  ///
  /// This is more efficient than [loadCategories] when loading multiple
  /// categories simultaneously.
  Future<List<POI>> loadCategoriesParallel(Set<POICategory> categories) async {
    final futures =
        categories.map((category) => loadCategory(category)).toList();
    final results = await Future.wait(futures);
    return results.expand((pois) => pois).toList();
  }

  /// Filter POIs within given bounds
  List<POI> filterByBounds(List<POI> pois, LatLngBounds bounds) {
    return pois.where((poi) => bounds.contains(poi.position)).toList();
  }

  /// Check if a category is loaded in cache
  bool isCategoryLoaded(POICategory category) => _cache.containsKey(category);

  /// Check if a category is currently being loaded
  bool isCategoryLoading(POICategory category) =>
      _loadingFutures.containsKey(category);

  /// Get the number of POIs for a loaded category (returns 0 if not loaded)
  int getCategoryCount(POICategory category) =>
      _cache[category]?.length ?? 0;

  /// Clear cache for a specific category
  void clearCategoryCache(POICategory category) {
    _cache.remove(category);
    _loadingFutures.remove(category);
  }

  /// Clear all cached data
  void clearCache() {
    _cache.clear();
    _loadingFutures.clear();
  }

  /// Get loading statistics
  Map<String, dynamic> getStats() {
    return {
      'cached_categories': _cache.length,
      'loading_categories': _loadingFutures.length,
      'total_pois': _cache.values.fold(0, (sum, pois) => sum + pois.length),
      'categories': {
        for (final entry in _cache.entries)
          entry.key.name: entry.value.length,
      },
    };
  }
}

/// Geographic bounds for filtering
class LatLngBounds {
  final LatLng southWest;
  final LatLng northEast;

  const LatLngBounds({
    required this.southWest,
    required this.northEast,
  });

  bool contains(LatLng point) {
    return point.latitude >= southWest.latitude &&
        point.latitude <= northEast.latitude &&
        point.longitude >= southWest.longitude &&
        point.longitude <= northEast.longitude;
  }

  factory LatLngBounds.fromPoints(List<LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southWest: LatLng(minLat, minLng),
      northEast: LatLng(maxLat, maxLng),
    );
  }
}
