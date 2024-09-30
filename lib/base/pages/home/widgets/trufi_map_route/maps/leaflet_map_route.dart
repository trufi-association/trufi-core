import 'dart:async';
import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/panel/panel_cubit.dart';
import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/route_planner_cubit/route_planner_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/load_location.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/share_itinerary_button.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/route_map_manager/route_map_manager_cubit.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/utils/leaflet_map_utils.dart';
import 'package:trufi_core/base/widgets/base_maps/map_buttons/crop_button.dart';
import 'package:trufi_core/base/widgets/base_maps/utils/trufi_map_utils.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class LeafletMapRoute extends StatefulWidget {
  final LeafletMapController trufiMapController;
  final AsyncExecutor asyncExecutor;
  final Uri? shareBaseItineraryUri;
  final WidgetBuilder? overlapWidget;
  const LeafletMapRoute({
    super.key,
    required this.trufiMapController,
    required this.asyncExecutor,
    this.shareBaseItineraryUri,
    this.overlapWidget,
  });

  @override
  State<LeafletMapRoute> createState() => _LeafletMapRouteState();
}

class _LeafletMapRouteState extends State<LeafletMapRoute>
    with TickerProviderStateMixin {
  final _cropButtonKey = GlobalKey<CropButtonState>();
  final RouteMapManagerCubit routeMapManagerCubit = RouteMapManagerCubit();
  Marker? tempMarker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
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

  @override
  Widget build(BuildContext context) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
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
          child: BlocBuilder<RouteMapManagerCubit, RouteMapManagerState>(
            bloc: routeMapManagerCubit,
            builder: (context, state) {
              return LeafletMap(
                trufiMapController: widget.trufiMapController,
                showPOILayers: true,
                layerOptionsBuilder: (context) => [
                  if (state.unselectedPolylinesLayer != null)
                    state.unselectedPolylinesLayer!,
                  if (state.unselectedMarkersLayer != null)
                    state.unselectedMarkersLayer!,
                  if (state.selectedPolylinesLayer != null)
                    state.selectedPolylinesLayer!,
                  if (state.selectedMarkersLayer != null)
                    state.selectedMarkersLayer!,
                ],
                layerOptionsBuilderTop: (context) => [
                  MarkerLayer(
                    markers: [
                      if (routePlannerState.fromPlace != null)
                        buildFromMarker(routePlannerState.fromPlace!.latLng,
                            mapConfiguratiom.markersConfiguration.fromMarker),
                      if (routePlannerState.toPlace != null)
                        buildToMarker(routePlannerState.toPlace!.latLng,
                            mapConfiguratiom.markersConfiguration.toMarker),
                      if (tempMarker != null) tempMarker!,
                    ],
                  ),
                ],
                onTap: (_, point) {
                  if (state.unselectedPolylinesLayer != null) {
                    _handleOnMapTap(
                      context,
                      TrufiLatLng.fromLatLng(point),
                      routePlannerState.plan!.itineraries!,
                    );
                  } else {
                    _onMapPress(context, TrufiLatLng.fromLatLng(point));
                  }
                },
                onLongPress: (_, point) =>
                    _onLongMapPress(context, TrufiLatLng.fromLatLng(point)),
                onPositionChanged: _handleOnMapPositionChanged,
                floatingActionButtons: Column(
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
              );
            },
          ),
        ),
        if (widget.overlapWidget != null) widget.overlapWidget!(context)
      ],
    );
  }

  void _repaintMap(
    RoutePlannerCubit routePlannerCubit,
    RoutePlannerState routePlannerState, {
    Color? walkColor,
  }) {
    if (routePlannerState.plan != null &&
        routePlannerState.selectedItinerary != null) {
      routeMapManagerCubit.selectItinerary(
        plan: routePlannerState.plan!,
        from: routePlannerState.fromPlace!,
        to: routePlannerState.toPlace!,
        selectedItinerary: routePlannerState.selectedItinerary!,
        onTap: (p1) {
          routePlannerCubit.selectItinerary(p1);
        },
        getBounds: (currentBounds) {
          widget.trufiMapController.moveBounds(
            points: currentBounds,
            tickerProvider: this,
          );
        },
        walkColor: walkColor,
      );
    } else {
      routeMapManagerCubit.cleanMap();
    }
  }

  void _handleOnCropPressed() {
    widget.trufiMapController.moveCurrentBounds(tickerProvider: this);
  }

  void _handleOnMapPositionChanged(
    MapCamera mapCamera,
    bool hasGesture,
  ) {
    if (widget.trufiMapController.selectedBounds != null) {
      _cropButtonKey.currentState?.setVisible(
        visible: !mapCamera.visibleBounds
            .containsBounds(widget.trufiMapController.selectedBounds!),
      );
    }
  }

  void _handleOnMapTap(
    BuildContext context,
    TrufiLatLng point,
    List<Itinerary> itineraries,
  ) {
    final Itinerary? tappedItinerary = itineraryForPoint(
      itineraries,
      point,
    );
    if (tappedItinerary != null) {
      context.read<RoutePlannerCubit>().selectItinerary(tappedItinerary);
    }
  }

  void _onMapPress(BuildContext context, TrufiLatLng location) {
    final panelCubit = context.read<PanelCubit>();
    panelCubit.cleanPanel();
  }

  void _onLongMapPress(BuildContext context, TrufiLatLng location) {
    final panelCubit = context.read<PanelCubit>();
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    panelCubit.cleanPanel();
    setState(() {
      tempMarker = buildToMarker(
          location, mapConfiguratiom.markersConfiguration.toMarker);
    });
    widget.trufiMapController.move(
      center: location,
      zoom: mapConfiguratiom.chooseLocationZoom,
      tickerProvider: this,
    );
    _showBottomMarkerModal(
      context: context,
      location: location,
    ).then((value) {
      setState(() {
        tempMarker = null;
      });
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
