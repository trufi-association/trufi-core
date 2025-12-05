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
  String get formattedDisplay {
    if (address != null && address!.isNotEmpty) {
      return '$displayName, $address';
    }
    return displayName;
  }

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
