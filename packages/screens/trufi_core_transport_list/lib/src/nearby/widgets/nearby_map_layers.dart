import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart'
    show RouteBadge, RouteBadgeVariant;

import '../../models/transport_route.dart' show gtfsRouteTypeIcon;
import '../nearby_geometry.dart';
import '../nearby_line.dart';
import '../nearby_lines_cubit.dart';
import '../nearby_radius.dart';

/// Marker id prefix of the per-line "201 · 75 m" labels; the rest of the id
/// is the [NearbyLine.lineKey], so a tap on the label toggles that line.
const String nearbyPointMarkerPrefix = 'nearby-point-';

/// Labels drawn on the map: the list is the source of truth, the map shows
/// the nearest ones so a dense corner does not become a wall of chips.
const int maxNearbyPointMarkers = 40;

/// Marker id prefix of the corner dots drawn for a street anchor.
const String nearbyCornerMarkerPrefix = 'nearby-corner-';

/// Pure function of the state: radius rings and their label, the
/// highlighted line, one label per nearby line and the anchor marker. For
/// a street anchor the rings and the pin give way to a dot per corner: the
/// search ran from every corner, so one ring would be a lie.
///
/// Rings are outlines, not the mock's translucent fill: no map engine reads
/// `TrufiMarker.metersRadius` and line colors are serialised without alpha,
/// so a filled buffer needs a maps-package change first.
List<TrufiLayer> buildNearbyLayers({
  required NearbyLinesState state,
  required ColorScheme colorScheme,
  required String Function(double meters) formatMeters,
}) {
  final anchor = state.anchor;
  if (anchor == null) return const [];

  final selected = state.selectedLine;
  final street = state.street;
  final ringLabelPosition = LatLng(
    anchor.latitude + state.radius.meters / NearbyGeometry.metersPerDegree,
    anchor.longitude,
  );

  return [
    if (street != null)
      TrufiLayer(
        id: 'nearby-street-corners',
        layerLevel: 0,
        markers: [
          for (final (index, corner) in street.corners.indexed)
            TrufiMarker(
              id: '$nearbyCornerMarkerPrefix$index',
              position: corner,
              widget: _CornerMarker(color: colorScheme.primary),
              size: const Size(16, 16),
              layerLevel: 0,
              allowOverlap: true,
              imageCacheKey: 'nearby-corner-${colorScheme.primary.toARGB32()}',
            ),
        ],
      )
    else
      TrufiLayer(
        id: 'nearby-rings',
        layerLevel: 0,
        lines: [
          for (final radius in NearbyRadius.values)
            TrufiLine(
              id: 'nearby-ring-${radius.meters.round()}',
              position: NearbyGeometry.circlePolygon(anchor, radius.meters),
              color: radius == state.radius
                  ? colorScheme.primary
                  : colorScheme.outline,
              lineWidth: radius == state.radius ? 3 : 1,
              layerLevel: 0,
            ),
        ],
        markers: [
          TrufiMarker(
            id: 'nearby-ring-label',
            position: ringLabelPosition,
            widget: _RingLabel(
              text: formatMeters(state.radius.meters),
              color: colorScheme.primary,
              textColor: colorScheme.onPrimary,
            ),
            size: const Size(56, 22),
            layerLevel: 0,
            allowOverlap: true,
            imageCacheKey:
                'nearby-ring-label-${state.radius.meters.round()}-'
                '${colorScheme.primary.toARGB32()}-'
                '${colorScheme.onPrimary.toARGB32()}',
          ),
        ],
      ),
    if (state.selectedGeometry.length > 1)
      TrufiLayer(
        id: 'nearby-selected-line',
        layerLevel: 1,
        lines: [
          TrufiLine(
            id: 'nearby-selected-line',
            position: state.selectedGeometry,
            color: selected?.color ?? colorScheme.primary,
            lineWidth: 5,
            layerLevel: 1,
          ),
        ],
      ),
    TrufiLayer(
      id: 'nearby-points',
      layerLevel: 2,
      markers: [
        for (final line in state.lines.take(maxNearbyPointMarkers))
          _pointMarker(
            line,
            inside: line.isWithin(state.radius),
            selected: line.lineKey == state.selectedLineKey,
            colorScheme: colorScheme,
            label: formatMeters(line.distanceMeters),
          ),
      ],
    ),
    if (street == null)
      TrufiLayer(
        id: 'nearby-anchor',
        layerLevel: 5,
        markers: [
          TrufiMarker(
            id: 'nearby-anchor',
            position: anchor,
            widget: _AnchorMarker(
              source: state.anchorSource,
              colorScheme: colorScheme,
            ),
            size: state.anchorSource == NearbyAnchorSource.device
                ? const Size(24, 24)
                : const Size(32, 32),
            alignment: state.anchorSource == NearbyAnchorSource.device
                ? Alignment.center
                : Alignment.bottomCenter,
            layerLevel: 5,
            allowOverlap: true,
            imageCacheKey:
                'nearby-anchor-${state.anchorSource.name}-'
                '${colorScheme.error.toARGB32()}',
          ),
        ],
      ),
  ];
}

TrufiMarker _pointMarker(
  NearbyLine line, {
  required bool inside,
  required bool selected,
  required ColorScheme colorScheme,
  required String label,
}) {
  return TrufiMarker(
    id: '$nearbyPointMarkerPrefix${line.lineKey}',
    position: line.nearestPoint,
    widget: _NearestPointMarker(
      line: line,
      label: label,
      inside: inside,
      selected: selected,
      colorScheme: colorScheme,
    ),
    size: const Size(130, 32),
    layerLevel: selected ? 3 : 2,
    // The selected label always shows; the others may yield to neighbours.
    allowOverlap: selected,
    // Everything the raster depends on: the mode glyph, the feed colors and
    // the theme colors of the distance chip (light / dark), besides the
    // name, the distance and the two states.
    imageCacheKey:
        'nearby-point-${line.displayName}-${line.routeType.name}-'
        '${line.distanceMeters.round()}-'
        '${line.color?.toARGB32()}-${line.textColor?.toARGB32()}-'
        '${colorScheme.primary.toARGB32()}-${colorScheme.surface.toARGB32()}-'
        '$inside-$selected',
  );
}

/// "300 m" pill on top of the selected ring, in the theme's primary pair.
class _RingLabel extends StatelessWidget {
  const _RingLabel({
    required this.text,
    required this.color,
    required this.textColor,
  });

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// "201 · 75 m": the line's badge as the home map draws its route labels
/// (mode icon + name on the route color, white border, drop shadow) plus
/// the distance chip, in the primary color inside the selected radius and
/// plain outside.
class _NearestPointMarker extends StatelessWidget {
  const _NearestPointMarker({
    required this.line,
    required this.label,
    required this.inside,
    required this.selected,
    required this.colorScheme,
  });

  final NearbyLine line;
  final String label;
  final bool inside;
  final bool selected;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RouteBadge(
              variant: RouteBadgeVariant.mapLabel,
              label: line.displayName,
              color: line.color ?? colorScheme.primary,
              textColor: line.textColor,
              icon: Icon(gtfsRouteTypeIcon(line.routeType)),
            ),
            const SizedBox(width: 4),
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: selected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: inside ? colorScheme.primary : colorScheme.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One corner of the street anchor: a small dot in the primary colour.
class _CornerMarker extends StatelessWidget {
  const _CornerMarker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

/// Blue dot for a GPS fix (the home screen's), a pin otherwise.
class _AnchorMarker extends StatelessWidget {
  const _AnchorMarker({required this.source, required this.colorScheme});

  final NearbyAnchorSource source;
  final ColorScheme colorScheme;

  /// Google-blue dot, same as the home screen's my-location marker.
  static const Color _deviceDotColor = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    if (source == NearbyAnchorSource.device) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _deviceDotColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        const Icon(Icons.location_on_rounded, size: 32, color: Colors.white),
        Icon(Icons.location_on_rounded, size: 26, color: colorScheme.error),
      ],
    );
  }
}
