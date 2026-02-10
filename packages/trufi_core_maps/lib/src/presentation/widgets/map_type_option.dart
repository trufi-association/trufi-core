import 'package:flutter/material.dart';

/// Model class representing a map type option for selection.
class MapTypeOption {
  /// Unique identifier for this map type.
  final String id;

  /// Display name for this map type.
  final String name;

  /// Description of this map type.
  final String description;

  /// Optional preview image widget for this map type.
  final Widget? previewImage;

  /// Whether this is an offline map.
  final bool isOffline;

  const MapTypeOption({
    required this.id,
    required this.name,
    required this.description,
    this.previewImage,
    this.isOffline = false,
  });
}
