import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Configuration for a POI subcategory loaded from metadata.json
class POISubcategoryConfig extends Equatable {
  /// Internal name/identifier (e.g., "hospital", "clinic")
  final String name;

  /// Display name for UI (e.g., "Hospitals", "Clinics & Doctors")
  final String displayName;

  /// Translations for display name keyed by language code (e.g., "en", "es", "de")
  final Map<String, String> displayNameTranslations;

  /// Number of POIs in this subcategory
  final int count;

  /// SVG icon string for this subcategory
  final String? iconSvg;

  /// Color for this subcategory (hex string parsed to Color)
  final Color color;

  /// Whether this subcategory should be active by default
  final bool defaultActive;

  const POISubcategoryConfig({
    required this.name,
    required this.displayName,
    this.displayNameTranslations = const {},
    required this.count,
    this.iconSvg,
    required this.color,
    this.defaultActive = false,
  });

  /// Get localized display name for the given language code
  /// Falls back to default displayName if translation not found
  String getLocalizedDisplayName(String languageCode) {
    return displayNameTranslations[languageCode] ?? displayName;
  }

  /// Create from JSON object in metadata.json
  factory POISubcategoryConfig.fromJson(Map<String, dynamic> json) {
    return POISubcategoryConfig(
      name: json['name'] as String,
      displayName: json['displayName'] as String? ?? json['name'] as String,
      displayNameTranslations: _extractTranslations(json, 'displayName'),
      count: json['count'] as int? ?? 0,
      iconSvg: json['icon'] as String?,
      color: _parseColor(json['color'] as String?),
      defaultActive: json['defaultActive'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [name, displayName, count, color, defaultActive];
}

/// Configuration for a POI category loaded from metadata.json
class POICategoryConfig extends Equatable {
  /// Internal name/identifier (e.g., "healthcare", "transport")
  final String name;

  /// Display name for UI (e.g., "Healthcare", "Transport")
  final String displayName;

  /// Translations for display name keyed by language code (e.g., "en", "es", "de")
  final Map<String, String> displayNameTranslations;

  /// Total number of POIs in this category
  final int count;

  /// SVG icon string for this category
  final String? iconSvg;

  /// Color for this category (derived from first subcategory if not specified)
  final Color color;

  /// Weight for layer ordering (lower = rendered first)
  /// Generated automatically based on order in metadata
  final int weight;

  /// Filename for the GeoJSON file (same as name)
  String get filename => name;

  /// Minimum zoom level to show POIs of this category
  final int minZoom;

  /// Subcategories within this category
  final List<POISubcategoryConfig> subcategories;

  /// Fallback icon when no SVG is available
  IconData get fallbackIcon => _categoryFallbackIcons[name] ?? Icons.place;

  const POICategoryConfig({
    required this.name,
    required this.displayName,
    this.displayNameTranslations = const {},
    required this.count,
    this.iconSvg,
    required this.color,
    required this.weight,
    this.minZoom = 14,
    this.subcategories = const [],
  });

  /// Get localized display name for the given language code
  /// Falls back to default displayName if translation not found
  String getLocalizedDisplayName(String languageCode) {
    return displayNameTranslations[languageCode] ?? displayName;
  }

  /// Create from JSON object in metadata.json
  factory POICategoryConfig.fromJson(Map<String, dynamic> json, int index) {
    final subcategoriesJson = json['subcategories'] as List<dynamic>? ?? [];
    final subcategories = subcategoriesJson
        .map((s) => POISubcategoryConfig.fromJson(s as Map<String, dynamic>))
        .toList();

    // Get color from JSON or derive from first subcategory
    Color color;
    final colorStr = json['color'] as String?;
    if (colorStr != null) {
      color = _parseColor(colorStr);
    } else if (subcategories.isNotEmpty) {
      color = subcategories.first.color;
    } else {
      color = const Color(0xFF757575); // Default gray
    }

    return POICategoryConfig(
      name: json['name'] as String,
      displayName: json['displayName'] as String? ?? json['name'] as String,
      displayNameTranslations: _extractTranslations(json, 'displayName'),
      count: json['count'] as int? ?? 0,
      iconSvg: json['icon'] as String?,
      color: color,
      weight: index + 1,
      subcategories: subcategories,
    );
  }

  /// Get all subcategory names
  Set<String> get subcategoryNames =>
      subcategories.map((s) => s.name).toSet();

  /// Get subcategories that are active by default
  Set<String> get defaultActiveSubcategories =>
      subcategories.where((s) => s.defaultActive).map((s) => s.name).toSet();

  /// Find a subcategory by name
  POISubcategoryConfig? getSubcategory(String name) {
    try {
      return subcategories.firstWhere((s) => s.name == name);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [name, displayName, count, color, weight];
}

/// POI Metadata containing all categories and bbox info
class POIMetadata {
  /// When the metadata was generated
  final DateTime? generated;

  /// Source of the data
  final String? source;

  /// Bounding box for the data
  final POIBoundingBox? bbox;

  /// All category configurations
  final List<POICategoryConfig> categories;

  const POIMetadata({
    this.generated,
    this.source,
    this.bbox,
    required this.categories,
  });

  /// Create from JSON
  factory POIMetadata.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as List<dynamic>? ?? [];
    final categories = <POICategoryConfig>[];

    for (var i = 0; i < categoriesJson.length; i++) {
      categories.add(POICategoryConfig.fromJson(
        categoriesJson[i] as Map<String, dynamic>,
        i,
      ));
    }

    POIBoundingBox? bbox;
    final bboxJson = json['bbox'] as Map<String, dynamic>?;
    if (bboxJson != null) {
      bbox = POIBoundingBox.fromJson(bboxJson);
    }

    DateTime? generated;
    final generatedStr = json['generated'] as String?;
    if (generatedStr != null) {
      generated = DateTime.tryParse(generatedStr);
    }

    return POIMetadata(
      generated: generated,
      source: json['source'] as String?,
      bbox: bbox,
      categories: categories,
    );
  }

  /// Find a category by name
  POICategoryConfig? getCategory(String name) {
    try {
      return categories.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Get all category names
  List<String> get categoryNames => categories.map((c) => c.name).toList();

  /// Get default enabled subcategories for all categories
  /// Returns a map of category name -> set of subcategory names
  Map<String, Set<String>> get defaultEnabledSubcategories {
    final result = <String, Set<String>>{};
    for (final category in categories) {
      final defaultActive = category.defaultActiveSubcategories;
      if (defaultActive.isNotEmpty) {
        result[category.name] = defaultActive;
      }
    }
    return result;
  }
}

/// Bounding box for POI data
class POIBoundingBox {
  final double south;
  final double west;
  final double north;
  final double east;

  const POIBoundingBox({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  factory POIBoundingBox.fromJson(Map<String, dynamic> json) {
    return POIBoundingBox(
      south: (json['south'] as num).toDouble(),
      west: (json['west'] as num).toDouble(),
      north: (json['north'] as num).toDouble(),
      east: (json['east'] as num).toDouble(),
    );
  }
}

/// Parse color from hex string (e.g., "#E53935" or "E53935")
Color _parseColor(String? colorStr) {
  if (colorStr == null || colorStr.isEmpty) {
    return const Color(0xFF757575); // Default gray
  }

  String hex = colorStr.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex'; // Add alpha
  }

  return Color(int.parse(hex, radix: 16));
}

/// Extract translations from JSON for a given field name
/// Looks for keys like "displayName:en", "displayName:es", "displayName:de"
Map<String, String> _extractTranslations(
    Map<String, dynamic> json, String fieldName) {
  final translations = <String, String>{};
  final prefix = '$fieldName:';

  for (final key in json.keys) {
    if (key.startsWith(prefix)) {
      final langCode = key.substring(prefix.length);
      final value = json[key];
      if (value is String) {
        translations[langCode] = value;
      }
    }
  }

  return translations;
}

/// Fallback icons for categories when SVG is not available
const Map<String, IconData> _categoryFallbackIcons = {
  'transport': Icons.directions_bus_rounded,
  'food': Icons.restaurant_rounded,
  'shopping': Icons.shopping_bag_rounded,
  'healthcare': Icons.local_hospital_rounded,
  'education': Icons.school_rounded,
  'finance': Icons.account_balance_rounded,
  'tourism': Icons.photo_camera_rounded,
  'recreation': Icons.park_rounded,
  'government': Icons.account_balance_rounded,
  'religion': Icons.church_rounded,
  'emergency': Icons.emergency_rounded,
  'accommodation': Icons.hotel_rounded,
};
