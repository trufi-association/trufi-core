import '../models/search_location.dart';

/// Abstract interface for location search services.
///
/// Implement this interface to create custom search providers
/// (e.g., Photon, Nominatim, Google Places, etc.)
abstract class SearchLocationService {
  /// Search for locations matching the query.
  ///
  /// Returns a list of [SearchLocation] results.
  /// Returns an empty list if no results are found or query is empty.
  Future<List<SearchLocation>> search(String query);

  /// Reverse geocode: find location name from coordinates.
  ///
  /// Returns a [SearchLocation] with address information,
  /// or null if no result is found.
  Future<SearchLocation?> reverse(double latitude, double longitude);

  /// Dispose any resources held by the service.
  void dispose();
}

/// Exception thrown when a search operation fails.
class SearchLocationException implements Exception {
  final String message;
  final int? statusCode;
  final Object? originalError;

  SearchLocationException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'SearchLocationException: $message';
}
