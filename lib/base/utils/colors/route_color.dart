import 'package:flutter/material.dart';

/// Relative luminance above which a feed colour is treated as "no colour":
/// white is 1.0; the lightest brand colour of the Arequipa feed (`FEDD00`)
/// is 0.73.
const double tooLightLuminance = 0.85;

/// The colour a GTFS feed gives a route (`route_color`, six hex digits), or
/// null when it gives none, an unparsable value, or one that would vanish
/// on the white tiles (trufi-arequipa#77: Albotran and Chiguata come with
/// `FFFFFF`, which painted the route list rows white on white, the group
/// chevron invisible, and the planner's polyline white).
Color? parseRouteColor(String? hex) {
  if (hex == null) return null;
  final value = hex.trim().replaceFirst('#', '');
  if (value.length != 6) return null;
  final parsed = int.tryParse('0xFF$value');
  if (parsed == null) return null;
  final color = Color(parsed);
  return color.computeLuminance() > tooLightLuminance ? null : color;
}
