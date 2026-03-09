import '../entities/marker.dart';
import '../entities/line.dart';

/// Immutable data class representing a map layer with markers and lines.
///
/// Pass layers declaratively to [TrufiMap]:
/// ```dart
/// TrufiMap(
///   layers: [
///     TrufiLayer(id: 'route', markers: routeMarkers, lines: routeLines),
///     TrufiLayer(id: 'pois', markers: poiMarkers),
///   ],
/// )
/// ```
class TrufiLayer {
  const TrufiLayer({
    required this.id,
    this.markers = const [],
    this.lines = const [],
    this.visible = true,
    this.layerLevel = 1,
    this.parentId,
  });

  final String id;
  final List<TrufiMarker> markers;
  final List<TrufiLine> lines;
  final bool visible;
  final int layerLevel;

  /// Optional parent layer ID for hierarchical organization.
  final String? parentId;

  TrufiLayer copyWith({
    String? id,
    List<TrufiMarker>? markers,
    List<TrufiLine>? lines,
    bool? visible,
    int? layerLevel,
    String? parentId,
  }) =>
      TrufiLayer(
        id: id ?? this.id,
        markers: markers ?? this.markers,
        lines: lines ?? this.lines,
        visible: visible ?? this.visible,
        layerLevel: layerLevel ?? this.layerLevel,
        parentId: parentId ?? this.parentId,
      );
}
