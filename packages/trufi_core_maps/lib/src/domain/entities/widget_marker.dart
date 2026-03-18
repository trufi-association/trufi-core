import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;

/// A marker rendered as a real Flutter widget overlaid on the map.
///
/// Unlike [TrufiMarker] which converts widgets to PNG for native rendering
/// (ideal for thousands of markers), [WidgetMarker] renders the actual
/// Flutter widget on top of the map. Use this for interactive or animated
/// markers that need to remain as real widgets.
///
/// Example:
/// ```dart
/// TrufiMap(
///   widgetMarkers: [
///     WidgetMarker(
///       id: 'bus-1',
///       position: busPosition,
///       child: BusIndicator(route: 'L1', passengers: 42),
///     ),
///   ],
/// )
/// ```
class WidgetMarker {
  const WidgetMarker({
    required this.id,
    required this.position,
    required this.child,
    this.alignment = Alignment.center,
    this.size = const Size(40, 40),
  });

  final String id;
  final latlng.LatLng position;
  final Widget child;
  final Alignment alignment;
  final Size size;
}
