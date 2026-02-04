import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import 'poi_category_config.dart';

/// Internal class to hold geometry extraction results
class _GeometryInfo {
  final double lat;
  final double lon;
  final POIGeometryType geometryType;
  final double? areaMeters;
  final List<LatLng>? polygonPoints;

  const _GeometryInfo({
    required this.lat,
    required this.lon,
    required this.geometryType,
    this.areaMeters,
    this.polygonPoints,
  });
}

/// Geometry type of the POI
enum POIGeometryType {
  point,
  polygon,
  line,
}

/// A Point of Interest
class POI extends Equatable {
  /// Unique identifier (OSM node ID)
  final String id;

  /// Geographic position (centroid for polygons/lines)
  final LatLng position;

  /// Name of the POI (may be null for unnamed POIs)
  final String? name;

  /// Category this POI belongs to (dynamic from metadata)
  final POICategoryConfig category;

  /// Subcategory within the category (e.g., "pharmacy" within "healthcare")
  final String? subcategory;

  /// Original geometry type from GeoJSON
  final POIGeometryType geometryType;

  /// Approximate area in square meters (for polygons)
  final double? areaMeters;

  /// Additional properties from OSM tags
  final Map<String, dynamic> properties;

  /// Polygon coordinates for area POIs (list of LatLng points)
  final List<LatLng>? polygonPoints;

  const POI({
    required this.id,
    required this.position,
    this.name,
    required this.category,
    this.subcategory,
    this.geometryType = POIGeometryType.point,
    this.areaMeters,
    this.properties = const {},
    this.polygonPoints,
  });

  /// Whether this POI is an area (polygon)
  bool get isArea => geometryType == POIGeometryType.polygon;

  /// Whether this POI is a large area (> 10000 m²)
  bool get isLargeArea => (areaMeters ?? 0) > 10000;

  /// Get the subcategory configuration if available
  POISubcategoryConfig? get subcategoryConfig {
    if (subcategory == null) return null;
    return category.getSubcategory(subcategory!);
  }

  /// Get the color for this POI (subcategory color if available, else category color)
  Color get color {
    final subConfig = subcategoryConfig;
    return subConfig?.color ?? category.color;
  }

  /// Create POI from GeoJSON feature
  factory POI.fromGeoJsonFeature(
    Map<String, dynamic> feature,
    POICategoryConfig category,
  ) {
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final geoJsonType = geometry['type'] as String;
    final coordinates = geometry['coordinates'];
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};

    // Extract coordinates and geometry info
    final geoInfo = _extractGeometryInfo(geoJsonType, coordinates);

    final subcategoryStr = properties['subcategory'] as String?;

    return POI(
      id: (feature['id'] ?? properties['id'] ?? '').toString(),
      position: LatLng(geoInfo.lat, geoInfo.lon),
      name: properties['name'] as String?,
      category: category,
      subcategory: subcategoryStr,
      geometryType: geoInfo.geometryType,
      areaMeters: geoInfo.areaMeters,
      properties: properties,
      polygonPoints: geoInfo.polygonPoints,
    );
  }

  /// Extract geometry info from different geometry types
  static _GeometryInfo _extractGeometryInfo(
    String geoJsonType,
    dynamic coordinates,
  ) {
    switch (geoJsonType) {
      case 'Point':
        // [lon, lat]
        final coords = coordinates as List<dynamic>;
        return _GeometryInfo(
          lat: (coords[1] as num).toDouble(),
          lon: (coords[0] as num).toDouble(),
          geometryType: POIGeometryType.point,
        );

      case 'Polygon':
        // [[[lon, lat], [lon, lat], ...]]
        final rings = coordinates as List<dynamic>;
        final firstRing = rings[0] as List<dynamic>;
        final (lat, lon) = _calculateCentroid(firstRing);
        final area = _calculatePolygonArea(firstRing);
        final points = firstRing.map((coord) {
          final c = coord as List<dynamic>;
          return LatLng(
            (c[1] as num).toDouble(),
            (c[0] as num).toDouble(),
          );
        }).toList();
        return _GeometryInfo(
          lat: lat,
          lon: lon,
          geometryType: POIGeometryType.polygon,
          areaMeters: area,
          polygonPoints: points,
        );

      case 'MultiPolygon':
        // [[[[lon, lat], ...]], [[[lon, lat], ...]]]
        final polygons = coordinates as List<dynamic>;
        final firstPolygon = polygons[0] as List<dynamic>;
        final firstRing = firstPolygon[0] as List<dynamic>;
        final (lat, lon) = _calculateCentroid(firstRing);
        final area = _calculatePolygonArea(firstRing);
        final points = firstRing.map((coord) {
          final c = coord as List<dynamic>;
          return LatLng(
            (c[1] as num).toDouble(),
            (c[0] as num).toDouble(),
          );
        }).toList();
        return _GeometryInfo(
          lat: lat,
          lon: lon,
          geometryType: POIGeometryType.polygon,
          areaMeters: area,
          polygonPoints: points,
        );

      case 'LineString':
        // [[lon, lat], [lon, lat], ...]
        final coords = coordinates as List<dynamic>;
        final midIndex = coords.length ~/ 2;
        final midPoint = coords[midIndex] as List<dynamic>;
        return _GeometryInfo(
          lat: (midPoint[1] as num).toDouble(),
          lon: (midPoint[0] as num).toDouble(),
          geometryType: POIGeometryType.line,
        );

      case 'MultiLineString':
        // [[[lon, lat], ...], [[lon, lat], ...]]
        final lines = coordinates as List<dynamic>;
        final firstLine = lines[0] as List<dynamic>;
        final midIndex = firstLine.length ~/ 2;
        final midPoint = firstLine[midIndex] as List<dynamic>;
        return _GeometryInfo(
          lat: (midPoint[1] as num).toDouble(),
          lon: (midPoint[0] as num).toDouble(),
          geometryType: POIGeometryType.line,
        );

      case 'MultiPoint':
        // [[lon, lat], [lon, lat], ...]
        final points = coordinates as List<dynamic>;
        final firstPoint = points[0] as List<dynamic>;
        return _GeometryInfo(
          lat: (firstPoint[1] as num).toDouble(),
          lon: (firstPoint[0] as num).toDouble(),
          geometryType: POIGeometryType.point,
        );

      default:
        // Fallback: try to parse as Point
        final coords = coordinates as List<dynamic>;
        if (coords.isNotEmpty && coords[0] is num) {
          return _GeometryInfo(
            lat: (coords[1] as num).toDouble(),
            lon: (coords[0] as num).toDouble(),
            geometryType: POIGeometryType.point,
          );
        }
        throw FormatException('Unsupported geometry type: $geoJsonType');
    }
  }

  /// Calculate centroid of a polygon ring
  static (double lat, double lon) _calculateCentroid(List<dynamic> ring) {
    double sumLat = 0;
    double sumLon = 0;
    // Exclude last point if it's the same as first (closed ring)
    final count = ring.length > 1 && _samePoint(ring.first, ring.last)
        ? ring.length - 1
        : ring.length;

    for (var i = 0; i < count; i++) {
      final point = ring[i] as List<dynamic>;
      sumLon += (point[0] as num).toDouble();
      sumLat += (point[1] as num).toDouble();
    }

    return (sumLat / count, sumLon / count);
  }

  /// Calculate approximate area of a polygon in square meters
  /// Uses the Shoelace formula with latitude correction
  static double _calculatePolygonArea(List<dynamic> ring) {
    if (ring.length < 3) return 0;

    double area = 0;
    final n = ring.length;

    for (var i = 0; i < n; i++) {
      final p1 = ring[i] as List<dynamic>;
      final p2 = ring[(i + 1) % n] as List<dynamic>;

      final lon1 = (p1[0] as num).toDouble();
      final lat1 = (p1[1] as num).toDouble();
      final lon2 = (p2[0] as num).toDouble();
      final lat2 = (p2[1] as num).toDouble();

      area += (lon2 - lon1) * (lat2 + lat1);
    }

    area = area.abs() / 2;

    // Convert from degrees² to m² (approximate at average latitude)
    final avgLat = (ring[0] as List<dynamic>)[1] as num;
    final latCorrection = cos(avgLat.toDouble() * pi / 180);
    const metersPerDegree = 111320.0; // meters per degree at equator

    return area * metersPerDegree * metersPerDegree * latCorrection;
  }

  /// Check if two coordinate points are the same
  static bool _samePoint(dynamic a, dynamic b) {
    if (a is! List || b is! List) return false;
    if (a.length < 2 || b.length < 2) return false;
    return a[0] == b[0] && a[1] == b[1];
  }

  /// Get display name (name or subcategory displayName if no name)
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    final subConfig = subcategoryConfig;
    if (subConfig != null) return subConfig.displayName;
    if (subcategory != null) return _formatSubcategoryName(subcategory!);
    return category.displayName;
  }

  /// Format subcategory name to title case
  static String _formatSubcategoryName(String subcategory) {
    return subcategory
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Get address if available
  String? get address {
    final street = properties['addr:street'];
    final houseNumber = properties['addr:housenumber'];
    if (street != null) {
      return houseNumber != null ? '$street $houseNumber' : street.toString();
    }
    return null;
  }

  /// Get opening hours if available
  String? get openingHours => properties['opening_hours']?.toString();

  /// Get phone number if available
  String? get phone => properties['phone']?.toString();

  /// Get website if available
  String? get website => properties['website']?.toString();

  @override
  List<Object?> get props => [id, position, name, category.name, subcategory];
}
