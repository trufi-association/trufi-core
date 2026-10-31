import 'package:flutter/widgets.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    show VehicleEtaProvider;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

import '../models/vehicle_eta_state.dart' show defaultEtaRefreshCooldown;

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

  /// Initial state of the live-vehicles map layer on a fresh install.
  ///
  /// Defaults to `false` (the user opts in from the map settings sheet).
  /// Deploys whose realtime feed is a headline feature (e.g. an operator
  /// pilot) can start with the layer on; once the user touches the toggle,
  /// their choice is persisted and this value no longer applies.
  final bool liveVehiclesInitiallyEnabled;

  /// Optional telemetry source for the "next vehicle" badges on itinerary
  /// cards (#1004): `RealtimeVehiclesEtaProvider` over a GTFS-RT feed, or
  /// any other `VehicleEtaProvider`.
  ///
  /// Null (default): the badges follow the selected routing engine's
  /// [IRoutingProvider.vehicleEtaProvider] (#1018) — an engine without one
  /// draws no badge and no refresh button. Set it only to force one
  /// telemetry source for every engine (legacy override: it wins over the
  /// engine's own provider).
  final VehicleEtaProvider? vehicleEtaProvider;

  /// Minimum gap between two user-triggered ETA requests (issue #1004 asks
  /// for a 10–15 s client-side throttle). Applies to whichever source is in
  /// use: this override or the selected engine's.
  final Duration etaRefreshCooldown;

  /// Whether the itinerary detail lists each transit leg's intermediate
  /// stops: the "`N` stops" toggle under the leg and the expandable list
  /// behind it. `false` keeps the line, the boarding and alighting places,
  /// the duration, the agency and the route drawing, and drops only those
  /// two rows.
  ///
  /// Same name and default as `TransportDetailScreen.showStops` (#1014): a
  /// city whose feed carries no real stops (Sana'a's are OSM way nodes
  /// placed along each line, trufi-sanaa#18) turns both off together.
  final bool showStops;

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
    this.liveVehiclesInitiallyEnabled = false,
    this.vehicleEtaProvider,
    this.etaRefreshCooldown = defaultEtaRefreshCooldown,
    this.showStops = true,
  });
}
