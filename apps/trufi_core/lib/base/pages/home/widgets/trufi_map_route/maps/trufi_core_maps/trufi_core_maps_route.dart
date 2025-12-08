import 'dart:math' as math;

import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/panel/panel_cubit.dart';
import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/map_provider_collection/map_engine.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/layers/location_marker_layer.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/layers/route_layer.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/layers/temp_marker_layer.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/load_location.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/share_itinerary_button.dart';
import 'package:trufi_core/base/widgets/base_maps/map_buttons/crop_button.dart';
import 'package:trufi_core/base/widgets/base_maps/trufi_core_maps/trufi_core_maps_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/trufi_core_maps/widgets/map_type_button.dart';
import 'package:trufi_core/base/widgets/base_maps/utils/trufi_map_utils.dart';
import 'package:trufi_core/base/widgets/bottom_sheet/trufi_bottom_sheet.dart';
import 'package:trufi_core/base/widgets/bottom_sheet/transit_bottom_sheet.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

/// Route map widget using trufi_core_maps with TrufiLayer architecture.
///
/// Supports any map engine that implements ITrufiMapEngine.
class TrufiCoreMapsRoute extends StatefulWidget {
  final TrufiCoreMapsController trufiMapController;
  final AsyncExecutor asyncExecutor;
  final Uri? shareBaseItineraryUri;
  final WidgetBuilder? overlapWidget;

  /// The primary map engine to use
  final ITrufiMapEngine mapEngine;

  /// List of available engines for switching
  final List<ITrufiMapEngine> availableEngines;

  const TrufiCoreMapsRoute({
    super.key,
    required this.trufiMapController,
    required this.asyncExecutor,
    required this.mapEngine,
    required this.availableEngines,
    this.shareBaseItineraryUri,
    this.overlapWidget,
  });

  @override
  State<TrufiCoreMapsRoute> createState() => _TrufiCoreMapsRouteState();
}

class _TrufiCoreMapsRouteState extends State<TrufiCoreMapsRoute>
    with TickerProviderStateMixin {
  final _cropButtonKey = GlobalKey<CropButtonState>();

  // Current engine (mutable)
  late ITrufiMapEngine _currentEngine;

  // Layers
  RouteLayer? _routeLayer;
  LocationMarkerLayer? _locationMarkerLayer;
  TempMarkerLayer? _tempMarkerLayer;

  @override
  void initState() {
    super.initState();
    _currentEngine = widget.mapEngine;
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _initializeLayers();
      final theme = Theme.of(context);
      final routePlannerCubit = context.read<RoutePlannerCubit>();
      final routePlannerState = routePlannerCubit.state;
      _repaintMap(
        routePlannerCubit,
        routePlannerState,
        walkColor: theme.colorScheme.secondary,
      );
    });
  }

  void _initializeLayers() {
    final mapConfiguration = context.read<MapConfigurationCubit>().state;
    final theme = Theme.of(context);

    // Move camera to configured center
    widget.trufiMapController.move(
      center: mapConfiguration.center,
      zoom: mapConfiguration.onlineZoom,
      tickerProvider: this,
    );

    // Initialize route layer with theme for off-screen rendering
    _routeLayer = RouteLayer(
      widget.trufiMapController.mapController,
      markerConfiguration: mapConfiguration.markersConfiguration,
      themeData: theme,
    );

    // Initialize location marker layer with theme for off-screen rendering
    _locationMarkerLayer = LocationMarkerLayer(
      widget.trufiMapController.mapController,
      markerConfiguration: mapConfiguration.markersConfiguration,
      themeData: theme,
    );

    // Initialize temp marker layer
    _tempMarkerLayer = TempMarkerLayer(
      widget.trufiMapController.mapController,
      themeData: theme,
    );
  }

  @override
  void dispose() {
    _routeLayer?.dispose();
    _locationMarkerLayer?.dispose();
    _tempMarkerLayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapConfiguration = context.read<MapConfigurationCubit>().state;
    final theme = Theme.of(context);
    final routePlannerCubit = context.watch<RoutePlannerCubit>();
    final routePlannerState = routePlannerCubit.state;

    return Stack(
      children: [
        BlocListener<RoutePlannerCubit, RoutePlannerState>(
          listener: (buildContext, state) {
            widget.trufiMapController.onReady.then((_) {
              _repaintMap(
                routePlannerCubit,
                state,
                walkColor: theme.colorScheme.secondary,
              );
            });
          },
          child: _buildMap(context, routePlannerState, mapConfiguration),
        ),
        if (widget.overlapWidget != null) widget.overlapWidget!(context),
      ],
    );
  }

  Widget _buildMap(
    BuildContext context,
    RoutePlannerState routePlannerState,
    MapConfiguration mapConfiguration,
  ) {
    final routePlannerCubit = context.read<RoutePlannerCubit>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Update viewport for FitCameraLayer
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final padding = MediaQuery.of(context).viewPadding;
          widget.trufiMapController.fitCameraLayer?.updateViewport(
            Size(constraints.maxWidth, constraints.maxHeight),
            padding,
          );
        });

        return Stack(
          children: [
            // Map widget - use current renderer
            _buildMapRenderer(context, routePlannerState),

            // Floating action buttons (right side)
            if (widget.availableEngines.length > 1)
              Positioned(
                top: 100,
                right: 16.0,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Map type selector button (only if multiple renderers)
                      MapTypeButton(
                        currentMapIndex: _getCurrentMapIndex(),
                        mapOptions: _getMapOptions(),
                        onMapTypeChanged: _onMapTypeChanged,
                      ),
                      const Padding(padding: EdgeInsets.all(4.0)),
                      CropButton(
                        key: _cropButtonKey,
                        onPressed: _handleOnCropPressed,
                      ),
                      const Padding(padding: EdgeInsets.all(4.0)),
                      if (routePlannerState.isPlanCorrect &&
                          widget.shareBaseItineraryUri != null)
                        ShareItineraryButton(
                          shareBaseItineraryUri: widget.shareBaseItineraryUri!,
                        ),
                    ],
                  ),
                ),
              ),

            // Crop button only (when single renderer)
            if (widget.availableEngines.length <= 1)
              Positioned(
                top: 100,
                right: 16.0,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CropButton(
                        key: _cropButtonKey,
                        onPressed: _handleOnCropPressed,
                      ),
                      const Padding(padding: EdgeInsets.all(4.0)),
                      if (routePlannerState.isPlanCorrect &&
                          widget.shareBaseItineraryUri != null)
                        ShareItineraryButton(
                          shareBaseItineraryUri: widget.shareBaseItineraryUri!,
                        ),
                    ],
                  ),
                ),
              ),

            // Bottom sheet for itinerary display
            if (routePlannerState.plan != null)
              TrufiBottomSheet(
                onHeightChanged: (height) {
                  final currentHeight = constraints.maxHeight / 2;
                  widget.trufiMapController.fitCameraLayer?.updatePadding(
                    EdgeInsets.only(
                      bottom: math.min(currentHeight, height),
                      right: 30,
                      left: 30,
                      top: 100,
                    ),
                  );
                },
                child: TransitBottomSheet(
                  plan: routePlannerState.plan!,
                  selectedItinerary: routePlannerState.selectedItinerary,
                  onSelectItinerary: (itinerary) {
                    routePlannerCubit.selectItinerary(itinerary);
                    // Fit camera to itinerary bounds
                    final points = itinerary.legs
                        .expand((leg) => leg.accumulatedPoints)
                        .toList();
                    if (points.isNotEmpty) {
                      widget.trufiMapController.moveBounds(
                        points: points,
                        tickerProvider: this,
                      );
                    }
                  },
                  onClose: () {
                    routePlannerCubit.reset();
                  },
                  moveTo: (location) {
                    widget.trufiMapController.move(
                      center: location,
                      zoom: 18,
                      tickerProvider: this,
                    );
                    return true;
                  },
                ),
              ),

            // Attribution
            Positioned(
              bottom: 5.0,
              left: 10,
              child: SafeArea(
                child: mapConfiguration.mapAttributionBuilder!(context),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build the map using the current renderer
  Widget _buildMapRenderer(
    BuildContext context,
    RoutePlannerState routePlannerState,
  ) {
    return _currentEngine.buildMap(
      controller: widget.trufiMapController.mapController,
      onMapClick: (point) => _handleOnMapTap(context, point, routePlannerState),
      onMapLongClick: (point) => _onLongMapPress(context, point),
    );
  }

  void _repaintMap(
    RoutePlannerCubit routePlannerCubit,
    RoutePlannerState routePlannerState, {
    Color? walkColor,
  }) {
    if (_routeLayer == null || _locationMarkerLayer == null) return;

    // Update location markers
    _locationMarkerLayer!.setLocations(
      from: routePlannerState.fromPlace?.latLng,
      to: routePlannerState.toPlace?.latLng,
    );

    if (routePlannerState.plan != null &&
        routePlannerState.selectedItinerary != null) {
      // Display itinerary routes
      _routeLayer!.selectItinerary(
        plan: routePlannerState.plan!,
        from: routePlannerState.fromPlace!,
        to: routePlannerState.toPlace!,
        selectedItinerary: routePlannerState.selectedItinerary!,
        onTap: (itinerary) {
          routePlannerCubit.selectItinerary(itinerary);
        },
        walkColor: walkColor,
      );

      // Fit camera to bounds
      final bounds = _routeLayer!.selectedBoundsPoints;
      if (bounds.isNotEmpty) {
        widget.trufiMapController.moveBounds(
          points: bounds,
          tickerProvider: this,
        );
      }
    } else {
      _routeLayer!.clearRoute();
    }
  }

  void _handleOnCropPressed() {
    widget.trufiMapController.moveCurrentBounds(tickerProvider: this);
  }

  /// Get the current map index based on engine
  int _getCurrentMapIndex() {
    return widget.availableEngines.indexWhere((e) => e.id == _currentEngine.id);
  }

  /// Get map options from available engines
  List<MapTypeOption> _getMapOptions() {
    return widget.availableEngines.map((engine) {
      return MapTypeOption(
        id: engine.id,
        name: engine.name,
        description: engine.description,
      );
    }).toList();
  }

  /// Handle map type change
  void _onMapTypeChanged(int index) {
    if (index >= 0 && index < widget.availableEngines.length) {
      setState(() {
        _currentEngine = widget.availableEngines[index];
      });
    }
  }

  void _handleOnMapTap(
    BuildContext context,
    TrufiLatLng point,
    RoutePlannerState routePlannerState,
  ) {
    if (routePlannerState.plan?.itineraries != null &&
        routePlannerState.plan!.itineraries!.isNotEmpty) {
      final Itinerary? tappedItinerary = itineraryForPoint(
        routePlannerState.plan!.itineraries!,
        point,
      );
      if (tappedItinerary != null) {
        context.read<RoutePlannerCubit>().selectItinerary(tappedItinerary);
        return;
      }
    }
    _onMapPress(context, point);
  }

  void _onMapPress(BuildContext context, TrufiLatLng location) {
    final panelCubit = context.read<PanelCubit>();
    panelCubit.cleanPanel();
  }

  void _onLongMapPress(BuildContext context, TrufiLatLng location) {
    final panelCubit = context.read<PanelCubit>();
    final mapConfiguration = context.read<MapConfigurationCubit>().state;
    panelCubit.cleanPanel();

    // Set temp marker using the layer
    _tempMarkerLayer?.setTempMarker(
      location,
      customWidget: mapConfiguration.markersConfiguration.toMarker,
    );

    widget.trufiMapController.move(
      center: location,
      zoom: mapConfiguration.chooseLocationZoom,
      tickerProvider: this,
    );

    _showBottomMarkerModal(
      context: context,
      location: location,
    ).then((value) {
      _tempMarkerLayer?.clearTempMarker();
    });
  }

  Future<void> _showBottomMarkerModal({
    required BuildContext context,
    required TrufiLatLng location,
  }) async {
    return showTrufiModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (buildContext) => LoadLocation(
        location: location,
        onFetchPlan: () => _callFetchPlan(context),
      ),
    );
  }

  Future<void> _callFetchPlan(BuildContext context) async {
    final routePlannerCubit = context.read<RoutePlannerCubit>();
    final routePlannerState = routePlannerCubit.state;
    if (routePlannerState.toPlace == null ||
        routePlannerState.fromPlace == null) {
      return;
    }
    widget.asyncExecutor.run(
      context: context,
      onExecute: routePlannerCubit.fetchPlan,
      onFinish: (_) {
        AppReviewProvider().incrementReviewWorthyActions();
      },
    );
  }
}
