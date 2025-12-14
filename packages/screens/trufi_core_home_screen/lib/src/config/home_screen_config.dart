import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// Configuration for the Home Screen module.
class HomeScreenConfig {
  /// OTP server endpoint for route planning
  final String otpEndpoint;

  /// Zoom level when choosing a location
  final double chooseLocationZoom;

  /// Search service for location search (defaults to Photon)
  final SearchLocationService? searchService;

  /// Photon server URL for search (used if searchService is not provided)
  final String photonUrl;

  /// List of saved places to show in search (Home, Work, etc.)
  /// Only used if SavedPlacesCubit is not available in context.
  final List<SearchLocation> myPlaces;

  const HomeScreenConfig({
    required this.otpEndpoint,
    this.chooseLocationZoom = 16.0,
    this.searchService,
    this.photonUrl = 'https://photon.komoot.io/api/',
    this.myPlaces = const [],
  });
}
