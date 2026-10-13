/// Walking-distance brackets of the nearby-lines search (#1006).
///
/// The query always runs for the widest bracket; the narrower ones are
/// filters over that result, so switching the chip never re-queries.
enum NearbyRadius {
  m100(100),
  m300(300),
  m500(500);

  const NearbyRadius(this.meters);

  /// Upper bound of the bracket, in meters (inclusive).
  final double meters;

  /// The widest bracket — the radius every row is computed for.
  static NearbyRadius get largest => NearbyRadius.values.last;

  /// Query radius in meters: a line farther than this is not "nearby".
  /// A constant (not `largest.meters`) so it can be a parameter default;
  /// `nearby_radius_test.dart` pins it to [largest].
  static const double maxMeters = 500;

  /// Whether a line [distanceMeters] away belongs to this bracket.
  bool contains(double distanceMeters) => distanceMeters <= meters;
}
