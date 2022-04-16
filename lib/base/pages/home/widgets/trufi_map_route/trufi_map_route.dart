import 'dart:async';
import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/load_location.dart';
import 'package:trufi_core/base/widgets/maps/buttons/crop_button.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map_cubit/trufi_map_cubit.dart';
import 'package:trufi_core/base/widgets/maps/utils/trufi_map_utils.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

typedef MapRouteBuilder = Widget Function(
  BuildContext,
  TrufiMapController,
);

class TrufiMapRoute extends StatefulWidget {
  final TrufiMapController trufiMapController;
  final AsyncExecutor asyncExecutor;
  final WidgetBuilder? overlapWidget;
  const TrufiMapRoute({
    Key? key,
    required this.trufiMapController,
    required this.asyncExecutor,
    this.overlapWidget,
  }) : super(key: key);

  @override
  State<TrufiMapRoute> createState() => _TrufiMapRouteState();
}

class _TrufiMapRouteState extends State<TrufiMapRoute>
    with TickerProviderStateMixin {
  final _cropButtonKey = GlobalKey<CropButtonState>();
  Marker? tempMarker;

  @override
  Widget build(BuildContext context) {
    final mapRouteState = context.read<MapRouteCubit>().state;
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    return Stack(
      children: [
        BlocBuilder<TrufiMapController, TrufiMapState>(
          bloc: widget.trufiMapController,
          builder: (context1, state) {
            return TrufiMap(
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
                if (state.fromMarkerLayer != null) state.fromMarkerLayer!,
                if (state.toMarkerLayer != null) state.toMarkerLayer!,
                MarkerLayerOptions(markers: [
                  if (mapRouteState.fromPlace != null)
                    mapConfiguratiom.markersConfiguration
                        .buildFromMarker(mapRouteState.fromPlace!.latLng),
                  if (mapRouteState.toPlace != null)
                    mapConfiguratiom.markersConfiguration
                        .buildToMarker(mapRouteState.toPlace!.latLng),
                  if (tempMarker != null) tempMarker!,
                ]),
              ],
              onTap: (_, point) {
                if (widget.trufiMapController.state.unselectedPolylinesLayer !=
                    null) {
                  _handleOnMapTap(context, point);
                } else {
                  onMapPress(context, point);
                }
              },
              onLongPress: (_, point) => onMapPress(context, point),
              onPositionChanged: _handleOnMapPositionChanged,
              floatingActionButtons: Column(
                children: [
                  CropButton(
                      key: _cropButtonKey, onPressed: _handleOnCropPressed),
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

  void _handleOnMapTap(BuildContext context, LatLng point) {
    final Itinerary? tappedItinerary = itineraryForPoint(
        widget.trufiMapController.itineraries,
        widget.trufiMapController.state.unselectedPolylinesLayer!.polylines,
        point);
    if (tappedItinerary != null) {
      context.read<MapRouteCubit>().selectItinerary(tappedItinerary);
    }
  }

  void onMapPress(BuildContext context, LatLng location) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    setState(() {
      tempMarker =
          mapConfiguratiom.markersConfiguration.buildToMarker(location);
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
    required LatLng location,
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
