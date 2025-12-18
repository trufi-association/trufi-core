import 'package:flutter/material.dart';

/// Represents a transport route for display in the list
class TransportRoute {
  final String id;
  final String code;
  final String name;
  final String? shortName;
  final String? longName;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? modeIcon;

  const TransportRoute({
    required this.id,
    required this.code,
    required this.name,
    this.shortName,
    this.longName,
    this.backgroundColor,
    this.textColor,
    this.modeIcon,
  });

  String get displayName => shortName ?? name;

  /// Gets the route name prefix (e.g., "MiniBus 1" from "MiniBus 1: Origen → Destino")
  String get longNamePrefix {
    if (longName == null) return '';
    final colonIndex = longName!.indexOf(': ');
    if (colonIndex != -1) {
      return longName!.substring(0, colonIndex);
    }
    return '';
  }

  /// Gets the route description without the route name prefix (e.g., "MiniBus 1:")
  String get _longNameWithoutPrefix {
    if (longName == null) return '';
    // Remove prefix like "MiniBus 1: " if present
    final colonIndex = longName!.indexOf(': ');
    if (colonIndex != -1) {
      return longName!.substring(colonIndex + 2);
    }
    return longName!;
  }

  String get longNameStart => _longNameWithoutPrefix.split(" → ").first;

  String get longNameLast => _longNameWithoutPrefix.split(" → ").last;

  String get longNameFull => longName ?? '';

  bool get hasOriginDestination => _longNameWithoutPrefix.contains(" → ");
}

/// Represents a stop on a transport route
class TransportStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const TransportStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

/// Extended route details including geometry and stops
class TransportRouteDetails extends TransportRoute {
  final List<({double latitude, double longitude})>? geometry;
  final List<TransportStop>? stops;
  final String? modeName;

  const TransportRouteDetails({
    required super.id,
    required super.code,
    required super.name,
    super.shortName,
    super.longName,
    super.backgroundColor,
    super.textColor,
    super.modeIcon,
    this.geometry,
    this.stops,
    this.modeName,
  });
}
