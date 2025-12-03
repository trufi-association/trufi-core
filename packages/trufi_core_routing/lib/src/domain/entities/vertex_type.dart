/// Type of vertex in a trip plan.
enum VertexType {
  normal,
  bikePark,
  bikeShare,
  carPark,
  transit,
  unknown,
}

/// Extension methods for [VertexType].
extension VertexTypeExtension on VertexType {
  /// Creates a [VertexType] from a string value.
  static VertexType fromString(String? value) {
    if (value == null) return VertexType.unknown;
    return VertexType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => VertexType.unknown,
    );
  }
}
