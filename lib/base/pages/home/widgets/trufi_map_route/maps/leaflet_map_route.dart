import 'dart:async';
import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/load_location.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/share_itinerary_button.dart';
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
    Key? key,
    required this.trufiMapController,
    required this.asyncExecutor,
    this.shareBaseItineraryUri,
    this.overlapWidget,
  }) : super(key: key);

  @override
  State<LeafletMapRoute> createState() => _LeafletMapRouteState();
}

class _LeafletMapRouteState extends State<LeafletMapRoute>
    with TickerProviderStateMixin {
  final _cropButtonKey = GlobalKey<CropButtonState>();
  Marker? tempMarker;

  @override
  Widget build(BuildContext context) {
    final mapRouteState = context.read<MapRouteCubit>().state;
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    return Stack(
      children: [
        BlocBuilder<LeafletMapController, LeafletMapState>(
          bloc: widget.trufiMapController,
          builder: (context1, state) {
            return LeafletMap(
              trufiMapController: widget.trufiMapController,
              layerOptionsBuilder: (context) => [
                if (state.unselectedPolylinesLayer != null)
                  state.unselectedPolylinesLayer!,
                if (state.unselectedMarkersLayer != null)
                  state.unselectedMarkersLayer!,
                if (state.selectedPolylinesLayer != null)
                  state.selectedPolylinesLayer!,
                if (state.selectedMarkersLayer != null)
                  state.selectedMarkersLayer!,
                MarkerLayer(
                  markers: [
                    if (mapRouteState.fromPlace != null)
                      buildFromMarker(mapRouteState.fromPlace!.latLng,
                          mapConfiguratiom.markersConfiguration.fromMarker),
                    if (mapRouteState.toPlace != null)
                      buildToMarker(mapRouteState.toPlace!.latLng,
                          mapConfiguratiom.markersConfiguration.toMarker),
                    if (tempMarker != null) tempMarker!,
                  ],
                ),
              ],
              onTap: (_, point) {
                if (widget.trufiMapController.state.unselectedPolylinesLayer !=
                    null) {
                  _handleOnMapTap(
                    context,
                    TrufiLatLng.fromLatLng(point),
                    mapRouteState.plan!.itineraries!,
                  );
                } else {
                  onMapPress(context, TrufiLatLng.fromLatLng(point));
                }
              },
              onLongPress: (_, point) =>
                  onMapPress(context, TrufiLatLng.fromLatLng(point)),
              onPositionChanged: _handleOnMapPositionChanged,
              floatingActionButtons: Column(
                children: [
                  CropButton(
                    key: _cropButtonKey,
                    onPressed: _handleOnCropPressed,
                  ),
                  const Padding(padding: EdgeInsets.all(4.0)),
                  if (mapRouteState.isPlanCorrect &&
                      widget.shareBaseItineraryUri != null)
                    ShareItineraryButton(
                      shareBaseItineraryUri: widget.shareBaseItineraryUri!,
                    ),
                ],
              ),
            );
          },
        ),
        if (widget.overlapWidget != null) widget.overlapWidget!(context)
      ],
    );
  }

  void _handleOnCropPressed() {
    widget.trufiMapController.moveCurrentBounds(tickerProvider: this);
  }

  void _handleOnMapPositionChanged(
    MapPosition position,
    bool hasGesture,
  ) {
    if (widget.trufiMapController.selectedBounds.isValid &&
        position.bounds != null) {
      _cropButtonKey.currentState?.setVisible(
        visible: !position.bounds!
            .containsBounds(widget.trufiMapController.selectedBounds),
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
      context.read<MapRouteCubit>().selectItinerary(tappedItinerary);
    }
  }

  void onMapPress(BuildContext context, TrufiLatLng location) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
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
    final mapRouteCubit = context.read<MapRouteCubit>();
    final mapRouteState = mapRouteCubit.state;
    if (mapRouteState.toPlace == null || mapRouteState.fromPlace == null) {
      return;
    }
    widget.asyncExecutor.run(
      context: context,
      onExecute: mapRouteCubit.fetchPlan,
      onFinish: (_) {
        AppReviewProvider().incrementReviewWorthyActions();
      },
    );
  }
}
