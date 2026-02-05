import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_base_widgets/trufi_core_base_widgets.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    hide ITrufiMapEngine;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

import '../../l10n/home_screen_localizations.dart';
import '../config/home_screen_config.dart';
import '../cubit/route_planner_cubit.dart';
import '../models/route_planner_state.dart';
import '../services/share_route_service.dart';
import 'itinerary_list.dart';
import 'routing_settings_sheet.dart';

/// Main home screen widget with route planning functionality.
class HomeScreen extends StatefulWidget {
  /// Callback when menu button is pressed.
  final VoidCallback onMenuPressed;

  /// Configuration for the home screen.
  final HomeScreenConfig config;

  /// Callback when itinerary details are requested.
  final void Function(routing.Itinerary itinerary)? onItineraryDetails;

  /// Callback when navigation is started for an itinerary.
  /// Receives the BuildContext, itinerary, and LocationService so the caller
  /// can show the navigation screen using the same location service.
  final void Function(
    BuildContext context,
    routing.Itinerary itinerary,
    LocationService locationService,
  )?
  onStartNavigation;

  /// Callback when a transit route badge is tapped in itinerary details.
  /// Provides the route code to allow navigation to route details screen.
  final void Function(BuildContext context, String routeCode)? onRouteTap;

  const HomeScreen({
    super.key,
    required this.onMenuPressed,
    required this.config,
    this.onItineraryDetails,
    this.onStartNavigation,
    this.onRouteTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TrufiMapController? _mapController;
  FitCameraLayer? _fitCameraLayer;
  _RouteLayer? _routeLayer;
  _LocationMarkersLayer? _locationMarkersLayer;
  _MyLocationLayer? _myLocationLayer;
  bool _customLayersInitialized = false;
  bool _viewportReady = false;
  List<LatLng>? _pendingFitPoints;
  bool _needsRouteRefresh = false;

  // GPS location service
  final LocationService _locationService = LocationService();
  bool _isLocating = false;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // Sheet snap positions
  static const double _sheetMinSize = 0.08;
  static const double _sheetMidSize = 0.35;
  static const double _sheetMaxSize = 0.85;

  // Deep link handling
  SharedRouteNotifier? _sharedRouteNotifier;

  @override
  void initState() {
    super.initState();
    // Listen to location updates
    _locationService.addListener(_onLocationUpdate);
    // Listen to POI selection changes
    widget.config.poiLayersManager?.addListener(_onPOISelectionChanged);
  }

  void _onPOISelectionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to shared route notifier for deep links
    _setupSharedRouteListener();
    // Parse URL parameters on first load (web only)
    _parseUrlAndSetPlaces();
  }

  @override
  void deactivate() {
    // Mark that we need to refresh the route when returning
    _needsRouteRefresh = true;
    super.deactivate();
  }


  void _setupSharedRouteListener() {
    // Try to get SharedRouteNotifier from context (it may not be available)
    try {
      final notifier = context.read<SharedRouteNotifier>();
      if (_sharedRouteNotifier != notifier) {
        _sharedRouteNotifier?.removeListener(_onSharedRouteChanged);
        _sharedRouteNotifier = notifier;
        _sharedRouteNotifier!.addListener(_onSharedRouteChanged);
        // Check if there's already a pending route
        _onSharedRouteChanged();
      }
    } catch (_) {
      // SharedRouteNotifier not available (deep links not configured)
    }
  }

  void _onSharedRouteChanged() {
    final route = _sharedRouteNotifier?.pendingRoute;
    if (route == null) return;

    // Clear the pending route immediately to prevent duplicate handling
    _sharedRouteNotifier!.clearPendingRoute();

    // Set origin and destination from the shared route
    final cubit = context.read<RoutePlannerCubit>();

    final fromPlace = TrufiLocation(
      description: route.fromName,
      latitude: route.fromLat,
      longitude: route.fromLng,
    );

    final toPlace = TrufiLocation(
      description: route.toName,
      latitude: route.toLat,
      longitude: route.toLng,
    );

    // Set locations and fetch plan with selected itinerary index
    cubit.setFromPlace(fromPlace);
    cubit.setToPlace(toPlace);
    cubit.fetchPlan(selectedItineraryIndex: route.selectedItineraryIndex);
  }

  // ============================================================
  // URL State Sync (Web)
  // ============================================================

  TrufiLocation? _lastUrlFrom;
  TrufiLocation? _lastUrlTo;
  routing.TimeMode? _lastUrlTimeMode;
  DateTime? _lastUrlDateTime;
  int? _lastUrlRouteIndex;
  bool _urlParsed = false;
  bool _showDetailOnLoad = false;

  /// Updates the URL with current state (web only).
  void _updateUrlWithState(RoutePlannerState state) {
    if (!kIsWeb) return;

    final from = state.fromPlace;
    final to = state.toPlace;

    // Get current time settings
    routing.TimeMode? currentTimeMode;
    DateTime? currentDateTime;
    try {
      final prefsManager = routing.RoutingPreferencesManager.maybeRead(context);
      if (prefsManager != null) {
        currentTimeMode = prefsManager.timeMode;
        currentDateTime = prefsManager.dateTime;
      }
    } catch (_) {}

    // Calculate selected itinerary index
    int? routeIndex;
    if (state.selectedItinerary != null && state.plan?.itineraries != null) {
      routeIndex = state.plan!.itineraries!.indexOf(state.selectedItinerary!);
      if (routeIndex < 0) routeIndex = null;
    }

    // Skip if nothing has changed
    final placesChanged = _lastUrlFrom != from || _lastUrlTo != to;
    final timeChanged = _lastUrlTimeMode != currentTimeMode ||
        _lastUrlDateTime != currentDateTime;
    final routeChanged = _lastUrlRouteIndex != routeIndex;
    if (!placesChanged && !timeChanged && !routeChanged) return;

    // Update tracking variables
    _lastUrlFrom = from;
    _lastUrlTo = to;
    _lastUrlTimeMode = currentTimeMode;
    _lastUrlDateTime = currentDateTime;
    _lastUrlRouteIndex = routeIndex;

    // Build query parameters
    final params = <String, String>{};
    if (from != null) {
      params['from_lat'] = from.latitude.toStringAsFixed(6);
      params['from_lng'] = from.longitude.toStringAsFixed(6);
      if (from.description.isNotEmpty) {
        params['from_name'] = from.description;
      }
    }
    if (to != null) {
      params['to_lat'] = to.latitude.toStringAsFixed(6);
      params['to_lng'] = to.longitude.toStringAsFixed(6);
      if (to.description.isNotEmpty) {
        params['to_name'] = to.description;
      }
    }

    // Add time settings
    if (currentTimeMode != null) {
      params['time_mode'] = currentTimeMode.name;
      if (currentTimeMode != routing.TimeMode.leaveNow &&
          currentDateTime != null) {
        params['time'] = currentDateTime.millisecondsSinceEpoch.toString();
      }
    }

    // Add selected route index
    if (routeIndex != null && routeIndex >= 0) {
      params['route'] = routeIndex.toString();
    }

    // Update URL without navigation
    try {
      final uri = Uri(path: '/', queryParameters: params.isEmpty ? null : params);
      GoRouter.of(context).replace(uri.toString());
    } catch (e) {
      debugPrint('HomeScreen: Error updating URL: $e');
    }
  }

  /// Parses URL parameters and sets places (web only, called once on init).
  Future<void> _parseUrlAndSetPlaces() async {
    if (!kIsWeb || _urlParsed) return;
    _urlParsed = true;

    try {
      final routerState = GoRouterState.of(context);
      final params = routerState.uri.queryParameters;

      if (params.isEmpty) return;

      final cubit = context.read<RoutePlannerCubit>();

      // Parse and apply time settings first
      try {
        final prefsManager = routing.RoutingPreferencesManager.maybeRead(context);
        if (prefsManager != null) {
          final timeModeStr = params['time_mode'];
          if (timeModeStr != null) {
            final timeMode = routing.TimeMode.values.firstWhere(
              (m) => m.name == timeModeStr,
              orElse: () => routing.TimeMode.leaveNow,
            );
            prefsManager.setTimeMode(timeMode);

            // Parse datetime if not leaveNow
            if (timeMode != routing.TimeMode.leaveNow) {
              final timeMs = int.tryParse(params['time'] ?? '');
              if (timeMs != null) {
                prefsManager.setDateTime(
                  DateTime.fromMillisecondsSinceEpoch(timeMs),
                );
              }
            }
          }
        }
      } catch (_) {
        // RoutingPreferencesManager not available
      }

      // Parse origin
      final fromLat = double.tryParse(params['from_lat'] ?? '');
      final fromLng = double.tryParse(params['from_lng'] ?? '');
      if (fromLat != null && fromLng != null) {
        final fromPlace = TrufiLocation(
          description: params['from_name'] ?? 'Origin',
          latitude: fromLat,
          longitude: fromLng,
        );
        await cubit.setFromPlace(fromPlace);
        _lastUrlFrom = fromPlace;
      }

      // Parse destination
      final toLat = double.tryParse(params['to_lat'] ?? '');
      final toLng = double.tryParse(params['to_lng'] ?? '');
      if (toLat != null && toLng != null) {
        final toPlace = TrufiLocation(
          description: params['to_name'] ?? 'Destination',
          latitude: toLat,
          longitude: toLng,
        );
        await cubit.setToPlace(toPlace);
        _lastUrlTo = toPlace;
      }

      // Parse route index (selected itinerary)
      final routeIndex = int.tryParse(params['route'] ?? '');

      // Fetch plan if both are set
      if (fromLat != null && fromLng != null && toLat != null && toLng != null) {
        // If a route index is specified, show details on load
        if (routeIndex != null && routeIndex >= 0) {
          _showDetailOnLoad = true;
        }
        await cubit.fetchPlan(selectedItineraryIndex: routeIndex);
      }
    } catch (e) {
      debugPrint('HomeScreen: Error parsing URL: $e');
    }
  }

  /// Attempts to start GPS tracking automatically on app start.
  /// Silently fails if permissions are not granted - user can enable via button.
  Future<void> _tryAutoStartTracking() async {
    final status = await _locationService.checkPermission();
    if (status == LocationPermissionStatus.granted) {
      final started = await _locationService.startTracking();
      if (started && mounted) {
        // Get initial location to show marker immediately
        final location = _locationService.currentLocation;
        if (location != null && _mapController != null) {
          final position = LatLng(location.latitude, location.longitude);
          _myLocationLayer ??= _MyLocationLayer(_mapController!);
          _myLocationLayer!.setLocation(position, location.accuracy);
        }
      }
    }
  }

  void _initializeIfNeeded(
    BuildContext context,
    MapEngineManager mapEngineManager,
  ) {
    if (_mapController == null) {
      _mapController = TrufiMapController(
        initialCameraPosition: TrufiCameraPosition(
          target: mapEngineManager.defaultCenter,
          zoom: mapEngineManager.defaultZoom,
        ),
      );
      _fitCameraLayer = FitCameraLayer(_mapController!);

      // Create custom layers if provided in config
      if (widget.config.customMapLayers != null) {
        final layers = widget.config.customMapLayers!(_mapController!);
        debugPrint('Custom layers initialized: ${layers.length} layers');
        _customLayersInitialized = true;
      }

      // Initialize custom map layers if provided in config
      _tryInitializeCustomMapLayers();

      // Try to start GPS tracking now that map controller is ready
      _tryAutoStartTracking();
    }
  }

  /// Initialize custom map layers from config if provided.
  void _tryInitializeCustomMapLayers() {
    // Skip if already initialized via customMapLayers callback
    if (_customLayersInitialized) return;

    final poiManager = widget.config.poiLayersManager;
    if (poiManager != null) {
      poiManager.initializeLayers(_mapController);
      _customLayersInitialized = true;
      debugPrint('POI layers initialized');
    }
  }

  @override
  void dispose() {
    _sharedRouteNotifier?.removeListener(_onSharedRouteChanged);
    _locationService.removeListener(_onLocationUpdate);
    widget.config.poiLayersManager?.removeListener(_onPOISelectionChanged);
    _locationService.dispose();
    _sheetController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Called when location updates from the GPS tracking
  void _onLocationUpdate() {
    if (!mounted) return;

    final location = _locationService.currentLocation;
    if (location != null && _mapController != null) {
      final position = LatLng(location.latitude, location.longitude);

      // Update my location marker on map
      _myLocationLayer ??= _MyLocationLayer(_mapController!);
      _myLocationLayer!.setLocation(position, location.accuracy);

      // Force rebuild to update UI (e.g., location button icon)
      setState(() {});
    }
  }

  /// Expand sheet when results are available
  void _expandSheetIfNeeded(RoutePlannerState state) {
    if (!_sheetController.isAttached) return;

    if (state.plan != null && state.plan!.hasItineraries) {
      // Animate to mid position when results arrive
      if (_sheetController.size < _sheetMidSize) {
        _sheetController.animateTo(
          _sheetMidSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  Future<SearchLocation?> _showSearchScreen({required bool isOrigin}) async {
    final l10n = HomeScreenLocalizations.of(context);

    // Try to get SavedPlacesCubit from context if available
    MyPlacesProvider? myPlacesProvider;
    try {
      final cubit = context.read<SavedPlacesCubit>();
      myPlacesProvider = SavedPlacesCubitProvider(cubit);
    } catch (_) {
      // SavedPlacesCubit not available, will use myPlaces list instead
    }

    final mapEngineManager = MapEngineManager.read(context);
    final defaultCenter = mapEngineManager.defaultCenter;

    // Get search service from SearchLocationsCubit
    final searchLocationsCubit = context.read<SearchLocationsCubit>();

    return Navigator.push<SearchLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSearchScreen(
          isOrigin: isOrigin,
          searchService: searchLocationsCubit.searchLocationService,
          myPlaces: widget.config.myPlaces,
          myPlacesProvider: myPlacesProvider,
          configuration: LocationSearchScreenConfiguration(
            originHintText: l10n.searchOrigin,
            destinationHintText: l10n.searchDestination,
            yourLocationText: l10n.yourLocation,
            chooseOnMapText: l10n.chooseOnMap,
          ),
          onYourLocation: () async {
            // Try to get GPS location
            var status = await _locationService.checkPermission();

            if (status == LocationPermissionStatus.denied) {
              status = await _locationService.requestPermission();
            }

            if (status == LocationPermissionStatus.granted) {
              final location = await _locationService.getCurrentLocation();
              if (location != null) {
                return SearchLocation(
                  id: 'current_location',
                  displayName: l10n.yourLocation,
                  latitude: location.latitude,
                  longitude: location.longitude,
                );
              }
            }

            // Fallback to default center if GPS not available
            return SearchLocation(
              id: 'current_location',
              displayName: l10n.yourLocation,
              latitude: defaultCenter.latitude,
              longitude: defaultCenter.longitude,
            );
          },
          onChooseOnMap: () async {
            final result = await Navigator.push<MapLocationResult>(
              context,
              MaterialPageRoute(
                builder: (context) => ChooseOnMapScreen(
                  configuration: ChooseOnMapConfiguration(
                    title: l10n.chooseOnMap,
                    initialLatitude: defaultCenter.latitude,
                    initialLongitude: defaultCenter.longitude,
                    initialZoom: widget.config.chooseLocationZoom,
                    confirmButtonText: l10n.confirmLocation,
                  ),
                ),
              ),
            );

            if (result != null) {
              return SearchLocation(
                id: 'map_${DateTime.now().millisecondsSinceEpoch}',
                displayName: l10n.selectedLocation,
                address:
                    '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}',
                latitude: result.latitude,
                longitude: result.longitude,
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Future<void> _onOriginSelected(SearchLocation location) async {
    final cubit = context.read<RoutePlannerCubit>();
    await cubit.setFromPlace(_searchLocationToTrufiLocation(location));
    _fetchPlanIfReady();
  }

  Future<void> _onDestinationSelected(SearchLocation location) async {
    final cubit = context.read<RoutePlannerCubit>();
    await cubit.setToPlace(_searchLocationToTrufiLocation(location));
    _fetchPlanIfReady();
  }

  Future<void> _onSwapLocations() async {
    final cubit = context.read<RoutePlannerCubit>();
    await cubit.swapLocations();
    _fetchPlanIfReady();
  }

  void _onReset() {
    final cubit = context.read<RoutePlannerCubit>();
    cubit.reset();
    _clearRouteFromMap();
  }

  void _onClearLocation({required bool isOrigin}) {
    final cubit = context.read<RoutePlannerCubit>();
    if (isOrigin) {
      cubit.resetFromPlace();
    } else {
      cubit.resetToPlace();
    }
    cubit.clearPlan();
    _clearRouteFromMap();
  }

  Future<void> _onRoutingSettings() async {
    final shouldRefetch = await showRoutingSettingsSheet(context);
    if (shouldRefetch == true) {
      _fetchPlanIfReady();
    }
  }

  void _fetchPlanIfReady() {
    final cubit = context.read<RoutePlannerCubit>();
    if (cubit.state.isPlacesDefined) {
      cubit.fetchPlan();
    }
  }

  void _clearRouteFromMap() {
    if (_routeLayer != null) {
      _routeLayer!.clearMarkers();
      _routeLayer!.clearLines();
      _mapController?.removeLayer(_routeLayer!.id);
      _routeLayer = null;
    }
  }

  void _updateLocationMarkers(RoutePlannerState state) {
    if (_mapController == null) return;

    // Don't show location markers when we have a route (route has its own markers)
    if (state.selectedItinerary != null) {
      if (_locationMarkersLayer != null) {
        _locationMarkersLayer!.clearMarkers();
        _mapController?.removeLayer(_locationMarkersLayer!.id);
        _locationMarkersLayer = null;
      }
      return;
    }

    // Create layer if needed
    _locationMarkersLayer ??= _LocationMarkersLayer(_mapController!);

    // Update markers
    _locationMarkersLayer!.updateMarkers(
      origin: state.fromPlace,
      destination: state.toPlace,
    );
  }

  void _updateRouteOnMap(routing.Itinerary? itinerary) {
    _clearRouteFromMap();

    if (itinerary == null || _mapController == null) return;

    _routeLayer = _RouteLayer(_mapController!);
    _routeLayer!.setItinerary(itinerary);
  }

  /// Updates the fit camera layer with route points.
  /// Only fits camera when there's a route (itinerary), not for individual markers.
  void _updateFitCameraPoints(RoutePlannerState state) {
    // Only fit camera when there's a selected itinerary (route)
    // Don't auto-fit when just selecting origin/destination markers
    if (state.selectedItinerary == null) {
      _pendingFitPoints = null;
      _fitCameraLayer?.clearFitPoints();
      return;
    }

    final allPoints = <LatLng>[];
    for (final leg in state.selectedItinerary!.legs) {
      allPoints.addAll(leg.decodedPoints);
    }

    if (allPoints.isNotEmpty) {
      // Save points for when viewport is ready
      _pendingFitPoints = allPoints;
      if (_viewportReady) {
        _fitCameraLayer?.setFitPoints(allPoints);
      }
    } else {
      _pendingFitPoints = null;
      _fitCameraLayer?.clearFitPoints();
    }
  }

  Future<void> _onMyLocationPressed() async {
    // If already tracking, just center the map on current location
    if (_locationService.isTracking) {
      final location = _locationService.currentLocation;
      if (location != null) {
        _mapController?.setCameraPosition(
          TrufiCameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: 16,
          ),
        );
      }
      return;
    }

    if (_isLocating) return;

    setState(() => _isLocating = true);

    try {
      // Check permission first
      var status = await _locationService.checkPermission();

      if (status == LocationPermissionStatus.denied) {
        // Request permission
        status = await _locationService.requestPermission();
      }

      if (status == LocationPermissionStatus.granted) {
        // Start tracking location continuously
        final started = await _locationService.startTracking();

        if (started && mounted) {
          // Get initial location to center the map
          final location = await _locationService.getCurrentLocation();
          if (location != null && mounted) {
            final position = LatLng(location.latitude, location.longitude);

            // Move camera to location
            _mapController?.setCameraPosition(
              TrufiCameraPosition(target: position, zoom: 16),
            );
          }
        }
      } else if (status == LocationPermissionStatus.deniedForever) {
        // Show dialog to open app settings
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      } else if (status == LocationPermissionStatus.serviceDisabled) {
        // Show dialog to open location settings
        if (mounted) {
          _showLocationDisabledDialog();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _showPermissionDeniedDialog() {
    final theme = Theme.of(context);
    final l10n = HomeScreenLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.locationPermissionTitle)),
          ],
        ),
        content: Text(l10n.locationPermissionDeniedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _locationService.openAppSettings();
            },
            child: Text(l10n.buttonOpenSettings),
          ),
        ],
      ),
    );
  }

  void _showLocationDisabledDialog() {
    final theme = Theme.of(context);
    final l10n = HomeScreenLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.location_disabled_rounded,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.locationDisabledTitle)),
          ],
        ),
        content: Text(l10n.locationDisabledMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _locationService.openLocationSettings();
            },
            child: Text(l10n.buttonOpenSettings),
          ),
        ],
      ),
    );
  }

  void _onMapClick(LatLng position) {
    // Try to select a POI at the tap position
    final poiManager = widget.config.poiLayersManager;
    if (poiManager != null && _mapController != null) {
      final selected = poiManager.trySelectPOIAtPosition(
        _mapController!,
        position,
      );
      if (selected) {
        // POI was selected, panel will show automatically
        return;
      }
    }
    // Clear POI selection if tapping elsewhere
    widget.config.poiLayersManager?.clearSelection();
  }

  void _onMapLongPress(LatLng position) async {
    // Clear POI selection when long pressing
    widget.config.poiLayersManager?.clearSelection();

    final l10n = HomeScreenLocalizations.of(context);
    final theme = Theme.of(context);

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.selectedLocation,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Action buttons
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  title: Text(
                    l10n.setAsOrigin,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.of(context).pop('origin'),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.place_rounded,
                      color: Color(0xFFE53935),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    l10n.setAsDestination,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.of(context).pop('destination'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    final cubit = context.read<RoutePlannerCubit>();

    if (result == 'origin') {
      final location = TrufiLocation(
        description: l10n.selectedLocation,
        latitude: position.latitude,
        longitude: position.longitude,
        address:
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
      );
      await cubit.setFromPlace(location);
      // Check if both places are now set and fetch
      if (cubit.state.toPlace != null) {
        cubit.fetchPlan();
      }
    } else if (result == 'destination') {
      final location = TrufiLocation(
        description: l10n.selectedLocation,
        latitude: position.latitude,
        longitude: position.longitude,
        address:
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
      );
      await cubit.setToPlace(location);
      // Check if both places are now set and fetch
      if (cubit.state.fromPlace != null) {
        cubit.fetchPlan();
      }
    }
  }

  Widget _buildMap(ITrufiMapEngine engine) {
    return engine.buildMap(
      controller: _mapController!,
      onMapClick: _onMapClick,
      onMapLongClick: _onMapLongPress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.watch(context);
    _initializeIfNeeded(context, mapEngineManager);
    final l10n = HomeScreenLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<RoutePlannerCubit, RoutePlannerState>(
        listener: (context, state) {
          _updateLocationMarkers(state);
          _updateRouteOnMap(state.selectedItinerary);
          _updateFitCameraPoints(state);
          _expandSheetIfNeeded(state);
          // Update URL with current state (web only)
          _updateUrlWithState(state);
        },
        builder: (context, state) {
          final locationState = SearchLocationState(
            origin: state.fromPlace != null
                ? _trufiLocationToSearchLocation(state.fromPlace!)
                : null,
            destination: state.toPlace != null
                ? _trufiLocationToSearchLocation(state.toPlace!)
                : null,
          );

          final hasResults =
              state.plan != null || state.isLoading || state.hasError;

          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout: use side panel for wide screens (≥600px)
              final isWideScreen = constraints.maxWidth >= 600;
              final sidePanelWidth = _getSidePanelWidth(constraints.maxWidth);

              // Update viewport with actual map area size (excluding side panel on wide screens)
              final mapWidth = isWideScreen
                  ? constraints.maxWidth - sidePanelWidth
                  : constraints.maxWidth;
              _fitCameraLayer?.updateViewport(
                Size(mapWidth, constraints.maxHeight),
                MediaQuery.of(context).viewPadding,
              );

              // Apply pending fit points once viewport is ready
              if (!_viewportReady) {
                _viewportReady = true;
                if (_pendingFitPoints != null &&
                    _pendingFitPoints!.isNotEmpty) {
                  // Set initial padding based on screen type
                  if (isWideScreen) {
                    _fitCameraLayer?.updatePadding(
                      const EdgeInsets.all(30),
                      recenter: false,
                    );
                  } else {
                    // Narrow screen: account for search bar and bottom sheet
                    final sheetHeight = constraints.maxHeight * _sheetMidSize;
                    _fitCameraLayer?.updatePadding(
                      EdgeInsets.only(
                        top: 120, // SearchLocationBar height
                        bottom: sheetHeight,
                        left: 30,
                        right: 30,
                      ),
                      recenter: false,
                    );
                  }
                  _fitCameraLayer?.setFitPoints(_pendingFitPoints!);
                }
              }

              // Ensure route is rendered when returning from another screen
              // The BlocConsumer listener only fires on state changes, so if we
              // navigate away and come back with the same state, we need to
              // re-render the route manually.
              final needsRouteRender = _needsRouteRefresh ||
                  (state.selectedItinerary != null && _routeLayer == null);

              if (_needsRouteRefresh) {
                _needsRouteRefresh = false;
                // Reset URL tracking to force URL restoration
                _lastUrlFrom = null;
                _lastUrlTo = null;
                _lastUrlTimeMode = null;
                _lastUrlDateTime = null;
              }

              if (needsRouteRender) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (state.selectedItinerary != null) {
                    // Clear location markers first (they duplicate with route markers)
                    _updateLocationMarkers(state);
                    _updateRouteOnMap(state.selectedItinerary);
                    _updateFitCameraPoints(state);
                  } else if (state.fromPlace != null || state.toPlace != null) {
                    _updateLocationMarkers(state);
                  }
                  // Restore URL with current state
                  _updateUrlWithState(state);
                });
              }

              // Update camera padding for side panel layout (panel on LEFT)
              // Note: The map is already positioned to the right of the side panel,
              // so we don't need to include sidePanelWidth in the padding.
              if (isWideScreen) {
                _fitCameraLayer?.updatePadding(
                  const EdgeInsets.all(30),
                );
              }

              return Stack(
                children: [
                  // Map - adjusts for side panel on LEFT on wide screens
                  Positioned(
                    top: 0,
                    left: isWideScreen ? sidePanelWidth : 0,
                    bottom: 0,
                    right: 0,
                    child: _buildMap(mapEngineManager.currentEngine),
                  ),

                  // Wide screens: always show left panel with SearchBar
                  if (isWideScreen)
                    _buildSidePanel(
                      state,
                      theme,
                      sidePanelWidth,
                      locationState: locationState,
                      l10n: l10n,
                    ),

                  // Narrow screens: SearchBar floats on top of map
                  if (!isWideScreen)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SearchLocationBar(
                                state: locationState,
                                configuration: SearchLocationBarConfiguration(
                                  originHintText: l10n.searchOrigin,
                                  destinationHintText: l10n.searchDestination,
                                ),
                                onSearch: _showSearchScreen,
                                onOriginSelected: _onOriginSelected,
                                onDestinationSelected: _onDestinationSelected,
                                onSwap: _onSwapLocations,
                                onReset: _onReset,
                                onClearLocation: _onClearLocation,
                                onRoutingSettings: _onRoutingSettings,
                                onMenuPressed: widget.onMenuPressed,
                              ),
                              // Departure time chip (visible when locations are set)
                              if (state.fromPlace != null ||
                                  state.toPlace != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: _DepartureTimeChip(
                                    onTimeChanged: _fetchPlanIfReady,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Floating action buttons (map controls) - always on right side of map
                  _buildMapControls(
                    context,
                    mapEngineManager,
                    hasResults,
                    sidePanelOffset: 0, // No offset needed, panel is on left
                    isWideScreen: isWideScreen,
                  ),

                  // Narrow screens: bottom sheet for results
                  // Hide when POI is selected (POI panel takes priority)
                  if (!isWideScreen &&
                      hasResults &&
                      widget.config.poiLayersManager?.selectedPOI == null)
                    _buildBottomSheet(state, theme, constraints),

                  // POI detail panel (narrow screens only) - shows at bottom
                  if (!isWideScreen &&
                      widget.config.poiLayersManager?.selectedPOI != null)
                    _buildPOIDetailPanel(
                      widget.config.poiLayersManager!.selectedPOI!,
                      theme,
                      isWideScreen: false,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMapControls(
    BuildContext context,
    MapEngineManager mapEngineManager,
    bool hasResults, {
    double sidePanelOffset = 0,
    bool isWideScreen = false,
  }) {
    return Positioned(
      right: 16 + sidePanelOffset,
      top: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          // On wide screens, no floating SearchBar so less top padding needed
          padding: EdgeInsets.only(top: isWideScreen ? 16 : 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Map type button (with optional POI layers if available)
              if (mapEngineManager.engines.length > 1) ...[
                MapTypeButton.fromEngines(
                  engines: mapEngineManager.engines,
                  currentEngineIndex: mapEngineManager.currentIndex,
                  onEngineChanged: (engine) {
                    mapEngineManager.setEngine(engine);
                  },
                  additionalSettings: widget.config.poiLayersManager != null
                      ? const POILayersSettingsSection()
                      : null,
                ),
                const SizedBox(height: 8),
              ],
              // My location button
              _MapControlButton(
                icon: _locationService.isTracking
                    ? Icons
                          .my_location_rounded // Filled when tracking
                    : Icons.my_location_outlined, // Outlined when not tracking
                onPressed: _onMyLocationPressed,
                isLoading: _isLocating,
              ),
              const SizedBox(height: 8),
              // Recenter button (only visible when route is out of focus)
              ValueListenableBuilder<bool>(
                valueListenable: _fitCameraLayer!.outOfFocusNotifier,
                builder: (context, outOfFocus, _) {
                  return AnimatedOpacity(
                    opacity: outOfFocus ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedScale(
                      scale: outOfFocus ? 1.0 : 0.8,
                      duration: const Duration(milliseconds: 200),
                      child: _MapControlButton(
                        icon: Icons.crop_free_rounded,
                        onPressed: outOfFocus
                            ? _fitCameraLayer!.reFitCamera
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetContent(RoutePlannerState state, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summary row when collapsed
        GestureDetector(
          onTap: _toggleSheet,
          behavior: HitTestBehavior.opaque,
          child: _buildSummaryRow(state, theme),
        ),
        // Itinerary list - shrinkWrap: true because it's inside a scrollable bottom sheet
        ItineraryList(
          shrinkWrap: true,
          showDetailOnLoad: _showDetailOnLoad,
          onDetailStateChanged: (isShowing) {
            if (!isShowing) {
              _showDetailOnLoad = false;
            }
          },
          onItineraryDetails: widget.onItineraryDetails,
          onRouteTap: widget.onRouteTap != null
              ? (routeCode) => widget.onRouteTap!(context, routeCode)
              : null,
          onStartNavigation: widget.onStartNavigation != null
              ? (context, itinerary, locationService) {
                  // Clear the home screen's location marker before starting navigation
                  // to avoid duplicate markers on the navigation screen
                  _myLocationLayer?.clearMarkers();
                  widget.onStartNavigation!(
                    context,
                    itinerary,
                    locationService,
                  );
                }
              : null,
          locationService: _locationService,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(RoutePlannerState state, ThemeData theme) {
    final l10n = HomeScreenLocalizations.of(context);

    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Finding routes...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            _buildCloseButton(),
          ],
        ),
      );
    }

    if (state.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.error ?? l10n.errorNoRoutes,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildCloseButton(),
          ],
        ),
      );
    }

    final itineraries = state.plan?.itineraries;
    if (itineraries == null || itineraries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find selected itinerary index
    final selectedIndex = state.selectedItinerary != null
        ? itineraries.indexOf(state.selectedItinerary!)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Share button on the left
          if (state.selectedItinerary != null &&
              state.fromPlace != null &&
              state.toPlace != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                final l10n = HomeScreenLocalizations.of(context);
                final appName = widget.config.appName ?? 'Trufi App';
                ShareRouteService.shareRoute(
                  from: state.fromPlace!,
                  to: state.toPlace!,
                  itinerary: state.selectedItinerary!,
                  selectedItineraryIndex: selectedIndex != -1
                      ? selectedIndex
                      : null,
                  appName: appName,
                  deepLinkScheme: widget.config.deepLinkScheme,
                  strings: ShareRouteStrings(
                    title: l10n.shareRouteTitle,
                    origin: l10n.shareRouteOrigin,
                    destination: l10n.shareRouteDestination,
                    date: l10n.shareRouteDate,
                    times: l10n.shareRouteTimes,
                    duration: l10n.shareRouteDuration,
                    itinerary: l10n.shareRouteItinerary,
                    openInApp: l10n.shareRouteOpenInApp,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          if (state.selectedItinerary != null &&
              state.fromPlace != null &&
              state.toPlace != null)
            const SizedBox(width: 8),
          Icon(Icons.route_rounded, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${itineraries.length} ${itineraries.length == 1 ? 'route' : 'routes'} found',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _onReset();
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 18,
          color: Color(0xFFE53935),
        ),
      ),
    );
  }

  void _toggleSheet() {
    if (!_sheetController.isAttached) return;

    HapticFeedback.selectionClick();
    final currentSize = _sheetController.size;
    final targetSize = currentSize > _sheetMidSize
        ? _sheetMinSize
        : _sheetMidSize;

    _sheetController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  // ============================================================
  // Responsive Layout Methods
  // ============================================================

  /// Calculates the side panel width based on screen width.
  /// Returns different widths for different screen sizes.
  double _getSidePanelWidth(double screenWidth) {
    if (screenWidth >= 1200) return 420;
    if (screenWidth >= 900) return 380;
    return 340;
  }

  /// Builds the side panel for wide screens (≥600px).
  /// Panel is positioned on the LEFT side and includes the SearchBar.
  Widget _buildSidePanel(
    RoutePlannerState state,
    ThemeData theme,
    double width, {
    required SearchLocationState locationState,
    required HomeScreenLocalizations l10n,
  }) {
    final hasResults = state.plan != null || state.isLoading || state.hasError;

    return Positioned(
      top: 0,
      left: 0, // Panel on LEFT
      bottom: 0,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: SafeArea(
          right: false,
          child: Column(
            children: [
              // SearchBar section - no shadow since it's inside the panel
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchLocationBar(
                      state: locationState,
                      configuration: SearchLocationBarConfiguration(
                        originHintText: l10n.searchOrigin,
                        destinationHintText: l10n.searchDestination,
                      ),
                      showShadow: false,
                      onSearch: _showSearchScreen,
                      onOriginSelected: _onOriginSelected,
                      onDestinationSelected: _onDestinationSelected,
                      onSwap: _onSwapLocations,
                      onReset: _onReset,
                      onClearLocation: _onClearLocation,
                      onRoutingSettings: _onRoutingSettings,
                      onMenuPressed: widget.onMenuPressed,
                    ),
                    // Departure time chip
                    if (state.fromPlace != null || state.toPlace != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _DepartureTimeChip(
                          onTimeChanged: _fetchPlanIfReady,
                        ),
                      ),
                  ],
                ),
              ),
              // Results section (only if there are results, loading, or error)
              if (hasResults) ...[
                // Results header with colored background
                _buildSidePanelHeader(state, theme),
                // Itinerary list - use Flexible when POI panel is shown
                if (widget.config.poiLayersManager?.selectedPOI != null)
                  Flexible(
                    flex: 1,
                    child: ItineraryList(
                      showDetailOnLoad: _showDetailOnLoad,
                      onDetailStateChanged: (isShowing) {
                        if (!isShowing) {
                          _showDetailOnLoad = false;
                        }
                      },
                      onItineraryDetails: widget.onItineraryDetails,
                      onRouteTap: widget.onRouteTap != null
                          ? (routeCode) => widget.onRouteTap!(context, routeCode)
                          : null,
                      onStartNavigation: widget.onStartNavigation != null
                          ? (context, itinerary, locationService) {
                              _myLocationLayer?.clearMarkers();
                              widget.onStartNavigation!(
                                context,
                                itinerary,
                                locationService,
                              );
                            }
                          : null,
                      locationService: _locationService,
                    ),
                  )
                else
                  Expanded(
                    child: ItineraryList(
                      showDetailOnLoad: _showDetailOnLoad,
                      onDetailStateChanged: (isShowing) {
                        if (!isShowing) {
                          _showDetailOnLoad = false;
                        }
                      },
                      onItineraryDetails: widget.onItineraryDetails,
                      onRouteTap: widget.onRouteTap != null
                          ? (routeCode) => widget.onRouteTap!(context, routeCode)
                          : null,
                      onStartNavigation: widget.onStartNavigation != null
                          ? (context, itinerary, locationService) {
                              _myLocationLayer?.clearMarkers();
                              widget.onStartNavigation!(
                                context,
                                itinerary,
                                locationService,
                              );
                            }
                          : null,
                      locationService: _locationService,
                    ),
                  ),
              ],
              // Empty state when no results
              if (!hasResults)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.searchForRoute,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.searchForRouteHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // POI detail panel (wide screen) - always at bottom of side panel
              if (widget.config.poiLayersManager?.selectedPOI != null)
                _buildPOIDetailPanel(
                  widget.config.poiLayersManager!.selectedPOI!,
                  theme,
                  isWideScreen: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header for the side panel with route count, share, and close buttons.
  Widget _buildSidePanelHeader(RoutePlannerState state, ThemeData theme) {
    final l10n = HomeScreenLocalizations.of(context);
    final itineraries = state.plan?.itineraries;
    final routeCount = itineraries?.length ?? 0;

    // Find selected itinerary index for sharing
    final selectedIndex = state.selectedItinerary != null && itineraries != null
        ? itineraries.indexOf(state.selectedItinerary!)
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.route_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.routesFound(routeCount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (state.isLoading)
                  Text(
                    l10n.findingRoutes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                if (state.hasError)
                  Text(
                    state.error ?? l10n.errorNoRoutes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Share button
          if (state.selectedItinerary != null &&
              state.fromPlace != null &&
              state.toPlace != null)
            IconButton.filled(
              icon: const Icon(Icons.share_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                foregroundColor: theme.colorScheme.primary,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                final appName = widget.config.appName ?? 'Trufi App';
                ShareRouteService.shareRoute(
                  from: state.fromPlace!,
                  to: state.toPlace!,
                  itinerary: state.selectedItinerary!,
                  selectedItineraryIndex:
                      selectedIndex != null && selectedIndex != -1
                      ? selectedIndex
                      : null,
                  appName: appName,
                  deepLinkScheme: widget.config.deepLinkScheme,
                  strings: ShareRouteStrings(
                    title: l10n.shareRouteTitle,
                    origin: l10n.shareRouteOrigin,
                    destination: l10n.shareRouteDestination,
                    date: l10n.shareRouteDate,
                    times: l10n.shareRouteTimes,
                    duration: l10n.shareRouteDuration,
                    itinerary: l10n.shareRouteItinerary,
                    openInApp: l10n.shareRouteOpenInApp,
                  ),
                );
              },
              tooltip: l10n.tooltipShare,
            ),
          const SizedBox(width: 4),
          // Close button
          IconButton.filled(
            icon: const Icon(Icons.close_rounded, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: _onReset,
            tooltip: l10n.tooltipClose,
          ),
        ],
      ),
    );
  }

  /// Builds the bottom sheet for narrow screens (<600px).
  Widget _buildBottomSheet(
    RoutePlannerState state,
    ThemeData theme,
    BoxConstraints constraints,
  ) {
    return TrufiBottomSheet(
      controller: _sheetController,
      initialChildSize: _sheetMidSize,
      minChildSize: _sheetMinSize,
      maxChildSize: _sheetMaxSize,
      snap: true,
      snapSizes: const [_sheetMinSize, _sheetMidSize],
      onHeightChanged: (height) {
        final maxHeight = constraints.maxHeight;
        _fitCameraLayer?.updatePadding(
          EdgeInsets.only(
            bottom: math.min(maxHeight * 0.5, height),
            left: 30,
            right: 30,
            top: 120,
          ),
        );
      },
      child: _buildBottomSheetContent(state, theme),
    );
  }

  /// Builds the POI detail panel.
  ///
  /// - On narrow screens: Shows as a bottom panel that replaces/overlays the results sheet
  /// - On wide screens: Shows at the bottom of the side panel
  Widget _buildPOIDetailPanel(
    POI poi,
    ThemeData theme, {
    required bool isWideScreen,
  }) {
    final l10n = HomeScreenLocalizations.of(context);

    if (isWideScreen) {
      // Wide screen: compact card style at bottom of side panel
      return Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: poi.category.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      poi.category.fallbackIcon,
                      color: poi.category.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poi.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          poi.subcategoryConfig?.displayName ??
                              poi.subcategory ??
                              poi.category.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () =>
                        widget.config.poiLayersManager?.clearSelection(),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
            // Details
            if (poi.address != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        poi.address!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _setPoiAsOrigin(poi),
                      icon: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      label: Text(l10n.setAsOrigin),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _setPoiAsDestination(poi),
                      icon: const Icon(Icons.place, size: 16),
                      label: Text(l10n.setAsDestination),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Narrow screen: bottom panel
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: POIDetailPanel(
          poi: poi,
          onClose: () => widget.config.poiLayersManager?.clearSelection(),
          onSetAsOrigin: () => _setPoiAsOrigin(poi),
          onSetAsDestination: () => _setPoiAsDestination(poi),
        ),
      ),
    );
  }

  void _setPoiAsOrigin(POI poi) {
    final location = TrufiLocation(
      description: poi.displayName,
      latitude: poi.position.latitude,
      longitude: poi.position.longitude,
      address: poi.address,
    );
    final cubit = context.read<RoutePlannerCubit>();
    cubit.setFromPlace(location);
    widget.config.poiLayersManager?.clearSelection();
    _fetchPlanIfReady();
  }

  void _setPoiAsDestination(POI poi) {
    final location = TrufiLocation(
      description: poi.displayName,
      latitude: poi.position.latitude,
      longitude: poi.position.longitude,
      address: poi.address,
    );
    final cubit = context.read<RoutePlannerCubit>();
    cubit.setToPlace(location);
    widget.config.poiLayersManager?.clearSelection();
    _fetchPlanIfReady();
  }
}

// Helper functions to convert between location types
SearchLocation _trufiLocationToSearchLocation(TrufiLocation location) {
  return SearchLocation(
    id: '${location.latitude}_${location.longitude}',
    displayName: location.description,
    address: location.address,
    latitude: location.latitude,
    longitude: location.longitude,
  );
}

TrufiLocation _searchLocationToTrufiLocation(SearchLocation location) {
  return TrufiLocation(
    description: location.displayName,
    latitude: location.latitude,
    longitude: location.longitude,
    address: location.address,
  );
}

/// Custom layer for displaying route on map with improved markers
class _RouteLayer extends TrufiLayer {
  _RouteLayer(super.controller) : super(id: 'route-layer', layerLevel: 1000);

  void setItinerary(routing.Itinerary itinerary) {
    clearMarkers();
    clearLines();

    final allPoints = <LatLng>[];

    // Add legs with improved styling
    for (int i = 0; i < itinerary.legs.length; i++) {
      final leg = itinerary.legs[i];
      if (leg.decodedPoints.isEmpty) continue;

      allPoints.addAll(leg.decodedPoints);

      // Determine color based on leg type
      final Color color;
      final double lineWidth;
      final bool useDots;

      if (leg.transitLeg) {
        // Transit legs use route color
        color = _parseColor(leg.routeColor);
        lineWidth = 6;
        useDots = false;
      } else if (leg.transportMode == routing.TransportMode.bicycle) {
        // Bicycle legs are green
        color = const Color(0xFF4CAF50);
        lineWidth = 5;
        useDots = false;
      } else {
        // Walking legs are grey with dots
        color = Colors.grey;
        lineWidth = 4;
        useDots = true;
      }

      // Add route line
      addLine(
        TrufiLine(
          id: 'leg-$i-${leg.startTime.millisecondsSinceEpoch}',
          position: leg.decodedPoints,
          color: color,
          lineWidth: lineWidth,
          activeDots: useDots,
        ),
      );

      // Add route label at midpoint for transit legs
      if (leg.transitLeg && leg.decodedPoints.length > 1) {
        final routeName = leg.shortName ?? leg.route?.shortName ?? '';
        final midIndex = leg.decodedPoints.length ~/ 2;
        final midPoint = leg.decodedPoints[midIndex];
        final modeIcon = _getModeIcon(leg.transportMode);

        addMarker(
          TrufiMarker(
            id: 'transit-label-$i',
            position: midPoint,
            widget: _TransitRouteLabel(
              color: color,
              routeName: routeName,
              icon: modeIcon,
            ),
            size: const Size(72, 28),
            layerLevel: 2,
            allowOverlap: true,
          ),
        );
      }

      // Add bicycle label at midpoint for bicycle legs
      if (leg.transportMode == routing.TransportMode.bicycle &&
          leg.decodedPoints.length > 1) {
        final midIndex = leg.decodedPoints.length ~/ 2;
        final midPoint = leg.decodedPoints[midIndex];
        final durationMin = leg.duration.inMinutes;

        addMarker(
          TrufiMarker(
            id: 'bike-label-$i',
            position: midPoint,
            widget: _TransitRouteLabel(
              color: color,
              routeName: '$durationMin\'',
              icon: Icons.directions_bike_rounded,
            ),
            size: const Size(72, 28),
            layerLevel: 2,
            allowOverlap: true,
          ),
        );
      }
    }

    if (allPoints.isNotEmpty) {
      // Add start marker (origin)
      addMarker(
        TrufiMarker(
          id: 'start-marker',
          position: allPoints.first,
          widget: const _OriginMarker(),
          size: const Size(24, 24),
          layerLevel: 3,
          allowOverlap: true,
        ),
      );

      // Add end marker (destination)
      addMarker(
        TrufiMarker(
          id: 'end-marker',
          position: allPoints.last,
          widget: const _DestinationMarker(),
          size: const Size(32, 32),
          alignment: Alignment.topCenter,
          layerLevel: 3,
          allowOverlap: true,
        ),
      );
    }
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF1976D2);
    }
  }

  IconData _getModeIcon(routing.TransportMode mode) {
    switch (mode) {
      case routing.TransportMode.bus:
      case routing.TransportMode.trufi:
      case routing.TransportMode.micro:
      case routing.TransportMode.miniBus:
        return Icons.directions_bus_rounded;
      case routing.TransportMode.rail:
      case routing.TransportMode.lightRail:
        return Icons.train_rounded;
      case routing.TransportMode.subway:
        return Icons.subway_rounded;
      case routing.TransportMode.tram:
        return Icons.tram_rounded;
      case routing.TransportMode.ferry:
        return Icons.directions_ferry_rounded;
      case routing.TransportMode.cableCar:
      case routing.TransportMode.gondola:
      case routing.TransportMode.funicular:
        return Icons.airline_seat_legroom_reduced_rounded;
      default:
        return Icons.directions_transit_rounded;
    }
  }
}

/// Origin marker - green circle (same color as search bar)
class _OriginMarker extends StatelessWidget {
  const _OriginMarker();

  static const _color = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// Destination marker - red pin icon (same as long press panel)
class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  static const _color = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.place_rounded,
      color: _color,
      size: 32,
      shadows: [
        Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
      ],
    );
  }
}

/// Label for transit route displayed at midpoint of the leg
class _TransitRouteLabel extends StatelessWidget {
  final Color color;
  final String routeName;
  final IconData icon;

  const _TransitRouteLabel({
    required this.color,
    required this.routeName,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          if (routeName.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              routeName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Floating action button for map controls
class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _MapControlButton({
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onPressed != null && !isLoading
            ? () {
                HapticFeedback.lightImpact();
                onPressed!();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : Icon(
                  icon,
                  size: 22,
                  color: onPressed != null
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                ),
        ),
      ),
    );
  }
}

/// Layer for displaying origin/destination markers before route is found
class _LocationMarkersLayer extends TrufiLayer {
  _LocationMarkersLayer(super.controller)
    : super(id: 'location-markers-layer', layerLevel: 2);

  void updateMarkers({TrufiLocation? origin, TrufiLocation? destination}) {
    clearMarkers();

    if (origin != null) {
      addMarker(
        TrufiMarker(
          id: 'origin-preview',
          position: LatLng(origin.latitude, origin.longitude),
          widget: const _OriginMarker(),
          size: const Size(24, 24),
        ),
      );
    }

    if (destination != null) {
      addMarker(
        TrufiMarker(
          id: 'destination-preview',
          position: LatLng(destination.latitude, destination.longitude),
          widget: const _DestinationMarker(),
          size: const Size(32, 32),
          alignment: Alignment.topCenter,
        ),
      );
    }
  }
}

/// Compact departure time chip displayed below search bar
class _DepartureTimeChip extends StatelessWidget {
  final VoidCallback onTimeChanged;

  const _DepartureTimeChip({required this.onTimeChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = HomeScreenLocalizations.of(context);
    final manager = routing.RoutingPreferencesManager.maybeWatch(context);

    if (manager == null) return const SizedBox.shrink();

    final timeMode = manager.timeMode;
    final dateTime = manager.dateTime;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        child: InkWell(
          onTap: () => _showTimePicker(context, manager),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTimeModeIcon(timeMode),
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _getTimeModeLabel(timeMode, dateTime, l10n),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTimeModeIcon(routing.TimeMode mode) {
    switch (mode) {
      case routing.TimeMode.leaveNow:
        return Icons.access_time_rounded;
      case routing.TimeMode.departAt:
        return Icons.departure_board_rounded;
      case routing.TimeMode.arriveBy:
        return Icons.schedule_rounded;
    }
  }

  String _getTimeModeLabel(routing.TimeMode mode, DateTime? dateTime, HomeScreenLocalizations l10n) {
    switch (mode) {
      case routing.TimeMode.leaveNow:
        return l10n.leaveNow;
      case routing.TimeMode.departAt:
        if (dateTime != null) {
          return l10n.departAtTime(_formatDateTime(dateTime, l10n));
        }
        return l10n.departAt;
      case routing.TimeMode.arriveBy:
        if (dateTime != null) {
          return l10n.arriveByTime(_formatDateTime(dateTime, l10n));
        }
        return l10n.arriveBy;
    }
  }

  String _formatDateTime(DateTime dt, HomeScreenLocalizations l10n) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isTomorrow =
        dt.year == now.year && dt.month == now.month && dt.day == now.day + 1;

    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (isToday) {
      return time;
    } else if (isTomorrow) {
      return l10n.tomorrowWithTime(time);
    } else {
      return '${dt.day}/${dt.month} $time';
    }
  }

  void _showTimePicker(
    BuildContext context,
    routing.RoutingPreferencesManager manager,
  ) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _DepartureTimeSheet(manager: manager, onTimeChanged: onTimeChanged),
    );
  }
}

/// Bottom sheet for selecting departure time mode and date/time
class _DepartureTimeSheet extends StatefulWidget {
  final routing.RoutingPreferencesManager manager;
  final VoidCallback onTimeChanged;

  const _DepartureTimeSheet({
    required this.manager,
    required this.onTimeChanged,
  });

  @override
  State<_DepartureTimeSheet> createState() => _DepartureTimeSheetState();
}

class _DepartureTimeSheetState extends State<_DepartureTimeSheet> {
  late routing.TimeMode _selectedMode;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.manager.timeMode;
    _selectedDateTime = widget.manager.dateTime ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = HomeScreenLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.whenDoYouWantToTravel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Time mode options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _TimeModeOption(
                    icon: Icons.access_time_rounded,
                    label: l10n.leaveNow,
                    isSelected: _selectedMode == routing.TimeMode.leaveNow,
                    onTap: () {
                      setState(() => _selectedMode = routing.TimeMode.leaveNow);
                    },
                  ),
                  const SizedBox(height: 8),
                  _TimeModeOption(
                    icon: Icons.departure_board_rounded,
                    label: l10n.departAt.replaceAll('...', ''),
                    isSelected: _selectedMode == routing.TimeMode.departAt,
                    onTap: () {
                      setState(() => _selectedMode = routing.TimeMode.departAt);
                    },
                  ),
                  const SizedBox(height: 8),
                  _TimeModeOption(
                    icon: Icons.schedule_rounded,
                    label: l10n.arriveBy.replaceAll('...', ''),
                    isSelected: _selectedMode == routing.TimeMode.arriveBy,
                    onTap: () {
                      setState(() => _selectedMode = routing.TimeMode.arriveBy);
                    },
                  ),
                ],
              ),
            ),
            // Date/time picker (only shown when not "Leave now")
            if (_selectedMode != routing.TimeMode.leaveNow) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _DateTimeButton(
                        icon: Icons.calendar_today_rounded,
                        label: _formatDate(_selectedDateTime, l10n),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateTimeButton(
                        icon: Icons.access_time_rounded,
                        label: _formatTime(_selectedDateTime),
                        onTap: () => _selectTime(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _applyChanges,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l10n.buttonApply),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt, HomeScreenLocalizations l10n) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isTomorrow =
        dt.year == now.year && dt.month == now.month && dt.day == now.day + 1;

    if (isToday) return l10n.today;
    if (isTomorrow) return l10n.tomorrow;

    final months = [
      l10n.monthJan,
      l10n.monthFeb,
      l10n.monthMar,
      l10n.monthApr,
      l10n.monthMay,
      l10n.monthJun,
      l10n.monthJul,
      l10n.monthAug,
      l10n.monthSep,
      l10n.monthOct,
      l10n.monthNov,
      l10n.monthDec,
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _applyChanges() {
    HapticFeedback.mediumImpact();
    widget.manager.setTimeMode(_selectedMode);
    if (_selectedMode != routing.TimeMode.leaveNow) {
      widget.manager.setDateTime(_selectedDateTime);
    }
    Navigator.of(context).pop();
    widget.onTimeChanged();
  }
}

/// Time mode selection option
class _TimeModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeModeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Date/time selection button
class _DateTimeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DateTimeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Layer for displaying user's current location on the map
class _MyLocationLayer extends TrufiLayer {
  _MyLocationLayer(super.controller)
    : super(
        id: 'my-location-layer',
        layerLevel: 0,
      ); // Below origin/destination markers

  void setLocation(LatLng position, double? accuracy) {
    clearMarkers();

    // Add accuracy circle if available (scales with zoom using metersRadius)
    if (accuracy != null && accuracy > 0) {
      addMarker(
        TrufiMarker(
          id: 'my-location-accuracy',
          position: position,
          widget: const _MyLocationAccuracyCircle(),
          metersRadius: accuracy, // This makes the marker scale with zoom
        ),
      );
    }

    // Add the blue dot marker (fixed size in pixels)
    addMarker(
      TrufiMarker(
        id: 'my-location-dot',
        position: position,
        widget: const _MyLocationMarker(),
        size: const Size(24, 24),
        layerLevel: 1,
        allowOverlap: true,
      ),
    );
  }
}

/// Blue dot marker for current location (Google Maps style)
class _MyLocationMarker extends StatelessWidget {
  const _MyLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4), // Google blue
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
    );
  }
}

/// Accuracy circle around the location marker.
/// Size is controlled by the parent marker's metersRadius property.
class _MyLocationAccuracyCircle extends StatelessWidget {
  const _MyLocationAccuracyCircle();

  @override
  Widget build(BuildContext context) {
    // Fill the entire marker size (which scales with zoom via metersRadius)
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF4285F4).withValues(alpha: 0.15),
        border: Border.all(
          color: const Color(0xFF4285F4).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    );
  }
}
