import 'package:flutter/widgets.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

/// Configuration for the Home Screen module.
///
/// Routing configuration is provided via RoutingEngineManager in the app's
/// providers, similar to how MapEngineManager works. This allows for consistent
/// engine selection in Settings.
class HomeScreenConfig {
  /// Zoom level when choosing a location
  final double chooseLocationZoom;

  /// Search service for location search (defaults to Photon)
  final SearchLocationService? searchService;

  /// List of saved places to show in search (Home, Work, etc.)
  /// Only used if SavedPlacesCubit is not available in context.
  final List<SearchLocation> myPlaces;

  /// App name to show in shared route text
  final String? appName;

  /// Deep link scheme for route sharing (e.g., 'trufiapp').
  /// When set, shared routes will include a deep link URL.
  final String? deepLinkScheme;

  /// Base URL for web-based route sharing (e.g., 'https://maps.trujillo.trufi.dev').
  /// When set, shared routes use a web URL instead of the deep link scheme,
  /// making shared links openable from any platform/browser.
  final String? shareBaseUrl;

  /// Optional custom map layers to display on the home screen map.
  final List<TrufiLayer> Function(TrufiMapController controller)?
  customMapLayers;

  /// Optional POI layers manager for displaying points of interest on the map.
  final POILayersManager? poiLayersManager;

  /// Optional extra section appended under the built-in sections in the map
  /// settings bottom sheet. Use this for deploy-specific overlays beyond POIs
  /// and live vehicles.
  ///
  /// Note: live vehicle support is wired automatically via the currently-active
  /// [IRoutingProvider.realtimeVehiclesProvider] — no config needed here.
  final Widget? extraMapLayerSettings;

  const HomeScreenConfig({
    this.chooseLocationZoom = 16.0,
    this.searchService,
    this.myPlaces = const [],
    this.appName,
    this.deepLinkScheme,
    this.shareBaseUrl,
    this.customMapLayers,
    this.poiLayersManager,
    this.extraMapLayerSettings,
  });
}
