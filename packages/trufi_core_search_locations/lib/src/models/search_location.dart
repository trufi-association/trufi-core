import 'package:intl/intl.dart' show Bidi;

import '../utils/coordinate_parser.dart';

/// Represents a location that can be searched and selected.
///
/// This is a simple data class that holds the essential information
/// about a location for display and identification purposes.
class SearchLocation {
  /// Unique identifier for this location.
  final String id;

  /// The display name of the location.
  final String displayName;

  /// Optional address or secondary description.
  final String? address;

  /// Latitude coordinate.
  final double latitude;

  /// Longitude coordinate.
  final double longitude;

  const SearchLocation({
    required this.id,
    required this.displayName,
    this.address,
    required this.latitude,
    required this.longitude,
  });

  /// Returns a formatted display string combining name and address.
  ///
  /// A name that is a coordinate pair ("15.29483, 44.22437") is prefixed
  /// with a left-to-right mark so that inside a right-to-left UI the bidi
  /// algorithm keeps the comma and the signs where they belong (#1024):
  /// without it an Arabic app paints "44.22437 ,15.29483" and
  /// "66.16- ,17.39-". Display only: [displayName] stays bare for copying
  /// and sharing.
  String get formattedDisplay {
    final name = isCoordinatePair ? '${Bidi.LRM}$displayName' : displayName;
    if (address != null && address!.isNotEmpty) {
      return '$name, $address';
    }
    return name;
  }

  /// Whether [displayName] reads as a decimal latitude/longitude pair (the
  /// "Go to" results, or any location named by its coordinates).
  bool get isCoordinatePair => CoordinateParser.parse(displayName) != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchLocation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SearchLocation(id: $id, displayName: $displayName)';
}
