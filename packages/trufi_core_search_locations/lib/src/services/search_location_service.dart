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

/// Optional capability for search services that can localize their result
/// texts (#945). [LocationSearchScreen] keeps the language in sync with the
/// app's locale on every dependency change, so switching the app language
/// switches the geocoder's answers too;
/// [CompositeSearchLocationService] forwards to every capable child.
abstract mixin class LanguageAwareSearch {
  /// Language for result texts, as a lowercase code (e.g. 'es', 'qu').
  set searchLanguage(String? languageCode);
}

/// Optional capability for services whose results can be expanded into
/// finer-grained locations — the street → corners flow (#745).
///
/// In cities without street numbers people give directions as
/// intersections, so picking a street is rarely the end of the search:
/// the old core let you tap a street and choose the corner. A service
/// that knows a location's inner points (e.g. every junction of a
/// street) implements this; [LocationSearchScreen] then offers the
/// drill-down affordance on those results with no extra wiring in the
/// host app — [CompositeSearchLocationService] forwards to whichever of
/// its children can answer.
abstract mixin class SearchLocationDrillDown {
  /// Whether [location] can be expanded (e.g. a street whose corners
  /// this service knows). Must be cheap and synchronous: the search
  /// screen calls it per visible result while building the list.
  bool canDrillDown(SearchLocation location);

  /// The locations inside [location] (e.g. every corner of a street),
  /// in a useful order. Only called when [canDrillDown] returned true.
  Future<List<SearchLocation>> drillDown(SearchLocation location);
}

/// Exception thrown when a search operation fails.
class SearchLocationException implements Exception {
  final String message;
  final int? statusCode;
  final Object? originalError;

  SearchLocationException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'SearchLocationException: $message';
}
