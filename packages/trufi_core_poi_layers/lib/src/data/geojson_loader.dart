import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../models/poi.dart';
import '../models/poi_category_config.dart';

/// Loads POIs from GeoJSON assets with support for lazy loading and parallel preloading.
///
/// Features:
/// - Lazy loading: Categories are loaded only when requested
/// - Parallel preloading: Multiple categories can be preloaded in background
/// - Caching: Loaded data is cached to avoid redundant loads
/// - Future deduplication: Multiple simultaneous requests for the same category
///   share a single loading operation
/// - Dynamic metadata: Loads category definitions from metadata.json
class GeoJSONLoader {
  /// Cached POI data by category name
  final Map<String, List<POI>> _cache = {};

  /// In-flight loading futures to prevent duplicate loads
  final Map<String, Future<List<POI>>> _loadingFutures = {};

  /// Cached metadata
  POIMetadata? _metadata;

  /// In-flight metadata loading future
  Future<POIMetadata>? _metadataFuture;

  /// Base path for POI assets
  final String assetsBasePath;

  GeoJSONLoader({
    required this.assetsBasePath,
  });

  /// Load POI metadata from metadata.json
  ///
  /// This loads category definitions, subcategories, icons, and colors.
  /// The metadata is cached after first load.
  Future<POIMetadata> loadMetadata() async {
    // Return cached if available
    if (_metadata != null) {
      return _metadata!;
    }

    // Wait for ongoing load if exists
    if (_metadataFuture != null) {
      return await _metadataFuture!;
    }

    // Start new load
    _metadataFuture = _loadMetadata();
    return await _metadataFuture!;
  }

  /// Internal method to load metadata
  Future<POIMetadata> _loadMetadata() async {
    try {
      final assetPath = '$assetsBasePath/metadata.json';
      debugPrint('📦 GeoJSONLoader: Loading metadata from $assetPath...');

      final jsonString = await rootBundle.loadString(assetPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      _metadata = POIMetadata.fromJson(json);
      debugPrint(
          '✅ GeoJSONLoader: Loaded metadata with ${_metadata!.categories.length} categories');

      return _metadata!;
    } catch (e, stackTrace) {
      debugPrint('❌ GeoJSONLoader: Error loading metadata: $e');
      debugPrint('Stack trace: $stackTrace');
      // Return empty metadata on error
      _metadata = const POIMetadata(categories: []);
      return _metadata!;
    } finally {
      _metadataFuture = null;
    }
  }

  /// Get cached metadata (returns null if not loaded yet)
  POIMetadata? get metadata => _metadata;

  /// Load POIs for a specific category.
  ///
  /// If the category is already cached, returns immediately.
  /// If the category is currently loading, waits for the existing load to complete.
  /// Otherwise, starts a new load operation.
  Future<List<POI>> loadCategory(POICategoryConfig category) async {
    final categoryName = category.name;

    // Return cached if available
    if (_cache.containsKey(categoryName)) {
      return _cache[categoryName]!;
    }

    // Wait for ongoing load if exists
    if (_loadingFutures.containsKey(categoryName)) {
      return await _loadingFutures[categoryName]!;
    }

    // Start new load
    return await _startLoad(category);
  }

  /// Start loading a category (internal method)
  Future<List<POI>> _startLoad(POICategoryConfig category) {
    final categoryName = category.name;

    final future = Future(() async {
      try {
        final assetPath = '$assetsBasePath/${category.filename}.geojson';
        debugPrint('📦 GeoJSONLoader: Loading $assetPath...');

        final jsonString = await rootBundle.loadString(assetPath);
        final geojson = json.decode(jsonString) as Map<String, dynamic>;

        final features = geojson['features'] as List<dynamic>? ?? [];
        final pois = features
            .map((f) => POI.fromGeoJsonFeature(
                  f as Map<String, dynamic>,
                  category,
                ))
            .toList();

        _cache[categoryName] = pois;
        debugPrint(
            '✅ GeoJSONLoader: Loaded ${pois.length} POIs for $categoryName');
        return pois;
      } catch (e, stackTrace) {
        debugPrint(
            '❌ GeoJSONLoader: Error loading $categoryName from $assetsBasePath: $e');
        debugPrint('Stack trace: $stackTrace');
        return <POI>[];
      } finally {
        // Remove from loading futures once complete
        _loadingFutures.remove(categoryName);
      }
    });

    _loadingFutures[categoryName] = future;
    return future;
  }

  /// Preload categories in the background without blocking.
  ///
  /// This is useful for preloading commonly used categories during app initialization.
  /// The loading happens in parallel and doesn't block the caller.
  void preloadCategories(List<POICategoryConfig> categories) {
    for (final category in categories) {
      final categoryName = category.name;
      if (!_cache.containsKey(categoryName) &&
          !_loadingFutures.containsKey(categoryName)) {
        _startLoad(category);
      }
    }
  }

  /// Load POIs for multiple categories in parallel.
  Future<List<POI>> loadCategoriesParallel(
      List<POICategoryConfig> categories) async {
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
  bool isCategoryLoaded(String categoryName) => _cache.containsKey(categoryName);

  /// Check if a category is currently being loaded
  bool isCategoryLoading(String categoryName) =>
      _loadingFutures.containsKey(categoryName);

  /// Get the number of POIs for a loaded category (returns 0 if not loaded)
  int getCategoryCount(String categoryName) =>
      _cache[categoryName]?.length ?? 0;

  /// Clear cache for a specific category
  void clearCategoryCache(String categoryName) {
    _cache.remove(categoryName);
    _loadingFutures.remove(categoryName);
  }

  /// Clear all cached data including metadata
  void clearCache() {
    _cache.clear();
    _loadingFutures.clear();
    _metadata = null;
    _metadataFuture = null;
  }

  /// Get loading statistics
  Map<String, dynamic> getStats() {
    return {
      'cached_categories': _cache.length,
      'loading_categories': _loadingFutures.length,
      'total_pois': _cache.values.fold(0, (sum, pois) => sum + pois.length),
      'metadata_loaded': _metadata != null,
      'categories': {
        for (final entry in _cache.entries) entry.key: entry.value.length,
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
