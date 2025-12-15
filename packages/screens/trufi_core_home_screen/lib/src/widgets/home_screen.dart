import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    hide ITrufiMapEngine;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart' as routing;
import 'package:trufi_core_saved_places/trufi_core_saved_places.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';

import '../../l10n/home_screen_localizations.dart';
import '../config/home_screen_config.dart';
import '../cubit/route_planner_cubit.dart';
import '../models/route_planner_state.dart';
import 'itinerary_list.dart';

/// Main home screen widget with route planning functionality.
class HomeScreen extends StatefulWidget {
  /// Callback when menu button is pressed.
  final VoidCallback onMenuPressed;

  /// Configuration for the home screen.
  final HomeScreenConfig config;

  /// Callback when itinerary details are requested.
  final void Function(routing.Itinerary itinerary)? onItineraryDetails;

  const HomeScreen({
    super.key,
    required this.onMenuPressed,
    required this.config,
    this.onItineraryDetails,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TrufiMapController? _mapController;
  FitCameraLayer? _fitCameraLayer;
  _RouteLayer? _routeLayer;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // Sheet snap positions
  static const double _sheetMinSize = 0.08;
  static const double _sheetMidSize = 0.35;
  static const double _sheetMaxSize = 0.85;

  void _initializeIfNeeded(MapEngineManager mapEngineManager) {
    if (_mapController == null) {
      _mapController = TrufiMapController(
        initialCameraPosition: TrufiCameraPosition(
          target: mapEngineManager.defaultCenter,
          zoom: mapEngineManager.defaultZoom,
        ),
      );
      _fitCameraLayer = FitCameraLayer(
        _mapController!,
        devicePixelRatio: MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.first,
        ).devicePixelRatio,
      );
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _mapController?.dispose();
    super.dispose();
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
          onYourLocation: () => SearchLocation(
            id: 'current_location',
            displayName: l10n.yourLocation,
            latitude: defaultCenter.latitude,
            longitude: defaultCenter.longitude,
          ),
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

  void _fetchPlanIfReady() {
    final cubit = context.read<RoutePlannerCubit>();
    if (cubit.state.isPlacesDefined) {
      cubit.fetchPlan();
    }
  }

  void _clearRouteFromMap() {
    if (_routeLayer != null) {
      _mapController?.removeLayer(_routeLayer!.id);
      _routeLayer = null;
    }
  }

  void _updateRouteOnMap(routing.Itinerary? itinerary) {
    _clearRouteFromMap();

    if (itinerary == null || _mapController == null) return;

    _routeLayer = _RouteLayer(_mapController!);
    _routeLayer!.setItinerary(itinerary);

    // Fit camera to route
    final allPoints = <LatLng>[];
    for (final leg in itinerary.legs) {
      allPoints.addAll(leg.decodedPoints);
    }

    if (allPoints.length > 1) {
      _fitCameraLayer?.setFitPoints(allPoints);
    }
  }

  Widget _buildMap(ITrufiMapEngine engine) {
    return engine.buildMap(controller: _mapController!);
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.watch(context);
    _initializeIfNeeded(mapEngineManager);
    final l10n = HomeScreenLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<RoutePlannerCubit, RoutePlannerState>(
        listener: (context, state) {
          _updateRouteOnMap(state.selectedItinerary);
          _expandSheetIfNeeded(state);
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
              _fitCameraLayer?.updateViewport(
                Size(constraints.maxWidth, constraints.maxHeight),
                MediaQuery.of(context).viewPadding,
              );

              return Stack(
                children: [
                  // Map (full screen)
                  Positioned.fill(
                    child: _buildMap(mapEngineManager.currentEngine),
                  ),

                  // SearchLocationBar at top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SearchLocationBar(
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
                          onMenuPressed: widget.onMenuPressed,
                        ),
                      ),
                    ),
                  ),

                  // Floating action buttons (map controls)
                  _buildMapControls(
                    context,
                    mapEngineManager,
                    hasResults,
                  ),

                  // Draggable bottom sheet for itineraries
                  if (hasResults)
                    DraggableScrollableSheet(
                      controller: _sheetController,
                      initialChildSize: _sheetMidSize,
                      minChildSize: _sheetMinSize,
                      maxChildSize: _sheetMaxSize,
                      snap: true,
                      snapSizes: const [_sheetMinSize, _sheetMidSize],
                      builder: (context, scrollController) {
                        return _buildBottomSheet(
                          context,
                          scrollController,
                          state,
                          theme,
                        );
                      },
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
    bool hasResults,
  ) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      right: 16,
      bottom: hasResults
          ? MediaQuery.of(context).size.height * _sheetMidSize + 16
          : 100,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Map type button (original)
            if (mapEngineManager.engines.length > 1) ...[
              MapTypeButton.fromEngines(
                engines: mapEngineManager.engines,
                currentEngineIndex: mapEngineManager.currentIndex,
                onEngineChanged: (engine) {
                  mapEngineManager.setEngine(engine);
                },
              ),
              const SizedBox(height: 8),
            ],
            // Recenter button
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
                      icon: Icons.my_location_rounded,
                      onPressed: outOfFocus ? _fitCameraLayer!.reFitCamera : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(
    BuildContext context,
    ScrollController scrollController,
    RoutePlannerState state,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          GestureDetector(
            onTap: _toggleSheet,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          // Summary row when collapsed
          _buildSummaryRow(state, theme),
          // Itinerary list
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: ItineraryList(
                    onItineraryDetails: widget.onItineraryDetails,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            Text(
              'Finding routes...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
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
          ],
        ),
      );
    }

    final itineraries = state.plan?.itineraries;
    if (itineraries == null || itineraries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.route_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${itineraries.length} ${itineraries.length == 1 ? 'route' : 'routes'} found',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.keyboard_arrow_up_rounded,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  void _toggleSheet() {
    if (!_sheetController.isAttached) return;

    HapticFeedback.selectionClick();
    final currentSize = _sheetController.size;
    final targetSize = currentSize > _sheetMidSize ? _sheetMinSize : _sheetMidSize;

    _sheetController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
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
  _RouteLayer(super.controller) : super(id: 'route-layer', layerLevel: 1);

  void setItinerary(routing.Itinerary itinerary) {
    clearMarkers();
    clearLines();

    final allPoints = <LatLng>[];

    // Add legs with improved styling
    for (int i = 0; i < itinerary.legs.length; i++) {
      final leg = itinerary.legs[i];
      if (leg.decodedPoints.isEmpty) continue;

      allPoints.addAll(leg.decodedPoints);

      final color = leg.transitLeg ? _parseColor(leg.routeColor) : Colors.grey;

      // Add route line with different style for transit vs walking
      addLine(
        TrufiLine(
          id: 'leg-$i-${leg.startTime.millisecondsSinceEpoch}',
          position: leg.decodedPoints,
          color: color,
          lineWidth: leg.transitLeg ? 6 : 4,
          activeDots: !leg.transitLeg,
        ),
      );

      // Add transit stop markers for transit legs
      if (leg.transitLeg && leg.decodedPoints.length > 1) {
        // Add boarding point marker
        addMarker(
          TrufiMarker(
            id: 'board-$i',
            position: leg.decodedPoints.first,
            widget: _TransitStopMarker(
              color: color,
              routeName: leg.shortName ?? leg.route?.shortName ?? '',
              isBoarding: true,
            ),
            size: const Size(32, 32),
          ),
        );

        // Add alighting point marker (if not last leg)
        if (i < itinerary.legs.length - 1) {
          addMarker(
            TrufiMarker(
              id: 'alight-$i',
              position: leg.decodedPoints.last,
              widget: _TransitStopMarker(
                color: color,
                routeName: leg.shortName ?? leg.route?.shortName ?? '',
                isBoarding: false,
              ),
              size: const Size(32, 32),
            ),
          );
        }
      }
    }

    if (allPoints.isNotEmpty) {
      // Add start marker (origin)
      addMarker(
        TrufiMarker(
          id: 'start-marker',
          position: allPoints.first,
          widget: const _EndpointMarker(
            icon: Icons.trip_origin_rounded,
            color: Color(0xFF4CAF50),
            label: 'A',
          ),
          size: const Size(40, 40),
        ),
      );

      // Add end marker (destination)
      addMarker(
        TrufiMarker(
          id: 'end-marker',
          position: allPoints.last,
          widget: const _EndpointMarker(
            icon: Icons.location_on_rounded,
            color: Color(0xFFE53935),
            label: 'B',
          ),
          size: const Size(40, 40),
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
}

/// Marker for origin/destination endpoints
class _EndpointMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _EndpointMarker({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

/// Marker for transit boarding/alighting points
class _TransitStopMarker extends StatelessWidget {
  final Color color;
  final String routeName;
  final bool isBoarding;

  const _TransitStopMarker({
    required this.color,
    required this.routeName,
    required this.isBoarding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBoarding ? Icons.arrow_circle_up_rounded : Icons.arrow_circle_down_rounded,
            color: Colors.white,
            size: 14,
          ),
          if (routeName.isNotEmpty) ...[
            const SizedBox(width: 2),
            Text(
              routeName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
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

  const _MapControlButton({
    required this.icon,
    this.onPressed,
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
        onTap: onPressed != null
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
          child: Icon(
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
