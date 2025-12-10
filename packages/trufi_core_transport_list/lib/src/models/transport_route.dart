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

  String get longNameLast => longName?.split("→ ").last ?? '';

  String get longNameFull => longName ?? '';
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
