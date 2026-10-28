import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// A street as the anchor of the nearby-lines search (trufi-sanaa#20).
///
/// The feed relates routes to geometries, not to streets, so "the lines
/// along a street" is approximated with what the offline search index does
/// know about it: its corners. The lines along the street are the union of
/// the nearby lines of every corner, each line kept once at its nearest
/// corner (`NearbyLinesResult.union`).
class NearbyStreetAnchor extends Equatable {
  NearbyStreetAnchor({
    required this.name,
    this.subtitle,
    required Iterable<LatLng> corners,
  }) : corners = List.unmodifiable(_distinct(corners));

  /// The street name, as the search index spells it.
  final String name;

  /// The street's municipality when the index carries one; display only.
  final String? subtitle;

  /// The corners in the index's order, without repeated coordinates (an
  /// index lists a corner once per crossing street, so a three-way corner
  /// appears twice with the same point).
  final List<LatLng> corners;

  /// Mean of the corners: where the camera starts and what the state
  /// reports as its anchor. Null when there are no corners.
  LatLng? get center {
    if (corners.isEmpty) return null;
    var latitude = 0.0;
    var longitude = 0.0;
    for (final corner in corners) {
      latitude += corner.latitude;
      longitude += corner.longitude;
    }
    return LatLng(latitude / corners.length, longitude / corners.length);
  }

  static List<LatLng> _distinct(Iterable<LatLng> corners) {
    final seen = <LatLng>{};
    return [
      for (final corner in corners)
        if (seen.add(corner)) corner,
    ];
  }

  @override
  List<Object?> get props => [name, subtitle, corners];
}
