import '../entities/transit_route.dart';

/// Repository interface for fetching transit route patterns from OTP.
abstract class TransitRouteRepository {
  /// Fetches all transit patterns (routes).
  Future<List<TransitRoute>> fetchPatterns();

  /// Fetches a single pattern with geometry and stops.
  Future<TransitRoute> fetchPatternById(String id);
}
