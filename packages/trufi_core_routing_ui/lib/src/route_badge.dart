import 'package:flutter/material.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

/// The shapes a [RouteBadge] takes. Each one is the exact geometry a screen
/// of the ecosystem already draws; they are promoted here so a new screen
/// reuses the badge instead of inventing a fifth look.
enum RouteBadgeVariant {
  /// Square badge, mode icon above the name — the routes list tile.
  tile,

  /// Row badge, icon beside a 14 pt name — the route detail header.
  pill,

  /// Compact row badge — the legs strip of the itinerary card.
  chip,

  /// [chip] with a white outline and a drop shadow — labels over the map.
  mapLabel,
}

/// The one way a transit line is identified across Trufi screens: the mode
/// icon and the `route_short_name` on the GTFS `route_color`.
///
/// The caller resolves the background ([color] is the GTFS colour or the
/// theme's primary, see [parseGtfsColor]); the badge only picks a readable
/// foreground when the feed has no `route_text_color`
/// ([routeBadgeForeground]) and a bus icon when no mode icon is given.
class RouteBadge extends StatelessWidget {
  const RouteBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.icon,
    this.variant = RouteBadgeVariant.tile,
  });

  /// `route_short_name` (or the display name). May be empty: the icon then
  /// stands alone.
  final String label;

  /// Background, already resolved: GTFS `route_color` or the fallback.
  final Color color;

  /// GTFS `route_text_color`; null → [routeBadgeForeground] of [color].
  final Color? textColor;

  /// Mode icon as a widget so a caller holding an [Icon] (or an SVG) passes
  /// it as is; its colour and size come from the badge. Null → bus.
  final Widget? icon;

  final RouteBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final foreground = textColor ?? routeBadgeForeground(color);
    return switch (variant) {
      RouteBadgeVariant.tile => _buildTile(foreground),
      RouteBadgeVariant.pill => _buildRow(
        foreground,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        radius: 10,
        iconSize: 16,
        fontSize: 14,
      ),
      RouteBadgeVariant.chip => _buildRow(
        foreground,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        radius: 8,
        iconSize: 16,
        fontSize: 12,
      ),
      RouteBadgeVariant.mapLabel => _buildRow(
        foreground,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        radius: 8,
        iconSize: 16,
        fontSize: 12,
        outlined: true,
      ),
    };
  }

  Widget _buildIcon(Color foreground, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: IconTheme(
        data: IconThemeData(color: foreground, size: size),
        child: icon ?? const Icon(Icons.directions_bus_rounded),
      ),
    );
  }

  /// `_RouteBadge` of the routes list tile.
  Widget _buildTile(Color foreground) {
    return Container(
      constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(foreground, 18),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// The detail header pill, the itinerary leg chip and the map label share
  /// one row layout and differ only in padding, radius, type size and the
  /// map label's white outline and shadow.
  Widget _buildRow(
    Color foreground, {
    required EdgeInsets padding,
    required double radius,
    required double iconSize,
    required double fontSize,
    bool outlined = false,
  }) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: outlined ? TextOverflow.ellipsis : null,
      style: TextStyle(
        color: foreground,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: outlined ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: outlined
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(foreground, iconSize),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            if (outlined) Flexible(child: text) else text,
          ],
        ],
      ),
    );
  }
}

/// The ink for text on a route colour — the ecosystem's single contrast rule.
///
/// The badge language is white-on-colour (the map's route labels; Sam,
/// 2026-08-13: nothing black on the options), so white wins whenever it
/// clears WCAG large-text AA (3:1) and near-black takes over only on fills
/// too light for white to stay readable.
Color routeBadgeForeground(Color background) {
  final luminance = background.computeLuminance();
  final whiteRatio = 1.05 / (luminance + 0.05);
  return whiteRatio >= 3.0 ? Colors.white : Colors.black87;
}

/// Six hex digits, the GTFS `route_color` / `route_text_color` shape.
final RegExp _sixHexDigits = RegExp(r'^[0-9a-fA-F]{6}$');

/// `RRGGBB` or `#RRGGBB` → opaque [Color]; null, empty or malformed → null,
/// so the caller falls back to its theme colour instead of painting garbage
/// (an empty string would otherwise parse `'FF'` into a transparent blue).
Color? parseGtfsColor(String? hex) {
  if (hex == null) return null;
  final digits = hex.startsWith('#') ? hex.substring(1) : hex;
  if (!_sixHexDigits.hasMatch(digits)) return null;
  return Color(int.parse('FF$digits', radix: 16));
}

/// The rounded mode glyph the home screen draws on itinerary legs and map
/// labels; every badge built from a routing [TransportMode] uses it so the
/// same line carries the same icon on every screen.
IconData transportModeBadgeIcon(TransportMode mode) {
  switch (mode) {
    case TransportMode.bus:
    case TransportMode.trufi:
    case TransportMode.micro:
    case TransportMode.miniBus:
      return Icons.directions_bus_rounded;
    case TransportMode.rail:
    case TransportMode.lightRail:
      return Icons.train_rounded;
    case TransportMode.subway:
      return Icons.subway_rounded;
    case TransportMode.tram:
      return Icons.tram_rounded;
    case TransportMode.ferry:
      return Icons.directions_ferry_rounded;
    case TransportMode.cableCar:
    case TransportMode.gondola:
    case TransportMode.funicular:
      return Icons.airline_seat_legroom_reduced_rounded;
    default:
      return Icons.directions_transit_rounded;
  }
}
