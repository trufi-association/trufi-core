import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';
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

  /// App name to show in shared route text
  final String? appName;

  /// Deep link scheme for route sharing (e.g., 'trufiapp').
  /// When set, shared routes will include a deep link URL.
  final String? deepLinkScheme;

  /// Optional custom map layers to display on the home screen map.
  ///
  /// Use this to add POI layers or other custom map layers.
  /// Each layer will be automatically added to the map controller.
  ///
  /// Example:
  /// ```dart
  /// customMapLayers: [
  ///   POITrufiLayerAdapter(poiLayersCubit),
  /// ]
  /// ```
  final List<TrufiLayer> Function(TrufiMapController controller)? customMapLayers;

  /// Optional POI layers manager for displaying points of interest on the map.
  ///
  /// When provided, the HomeScreen will:
  /// 1. Initialize the layers when the map is ready
  /// 2. Register the provider in the widget tree for child widgets to access
  /// 3. Show POI settings in the map type button automatically
  ///
  /// Default enabled subcategories are determined by `defaultActive: true`
  /// in the metadata.json file for each subcategory.
  ///
  /// Example:
  /// ```dart
  /// poiLayersManager: POILayersManager(
  ///   assetsBasePath: 'assets/pois',
  /// ),
  /// ```
  final POILayersManager? poiLayersManager;

  const HomeScreenConfig({
    required this.otpEndpoint,
    this.chooseLocationZoom = 16.0,
    this.searchService,
    this.photonUrl = 'https://photon.komoot.io/api/',
    this.myPlaces = const [],
    this.appName,
    this.deepLinkScheme,
    this.customMapLayers,
    this.poiLayersManager,
  });
}
