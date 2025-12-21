import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import 'models/poi.dart';
import 'models/poi_category.dart';

/// Loads POIs from GeoJSON assets
class GeoJSONLoader {
  final Map<POICategory, List<POI>> _cache = {};

  /// Base path for POI assets
  final String assetsBasePath;

  GeoJSONLoader({
    required this.assetsBasePath,
  });

  /// Load POIs for a specific category
  Future<List<POI>> loadCategory(POICategory category) async {
    // Return cached if available
    if (_cache.containsKey(category)) {
      return _cache[category]!;
    }

    try {
      final assetPath = '$assetsBasePath/${category.filename}.geojson';
      final jsonString = await rootBundle.loadString(assetPath);
      final geojson = json.decode(jsonString) as Map<String, dynamic>;

      final features = geojson['features'] as List<dynamic>? ?? [];
      final pois = features
          .map((f) => POI.fromGeoJsonFeature(f as Map<String, dynamic>))
          .toList();

      _cache[category] = pois;
      return pois;
    } catch (e, stackTrace) {
      // Log error for debugging
      debugPrint('Error loading POI category ${category.name} from $assetsBasePath: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Load POIs for multiple categories
  Future<List<POI>> loadCategories(Set<POICategory> categories) async {
    final results = <POI>[];
    for (final category in categories) {
      final pois = await loadCategory(category);
      results.addAll(pois);
    }
    return results;
  }

  /// Filter POIs within given bounds
  List<POI> filterByBounds(List<POI> pois, LatLngBounds bounds) {
    return pois.where((poi) => bounds.contains(poi.position)).toList();
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
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
