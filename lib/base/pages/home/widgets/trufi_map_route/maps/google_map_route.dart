import 'dart:async';
import 'package:async_executor/async_executor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/providers/app_review_provider.dart';
import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/home/map_route_cubit/map_route_cubit.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/load_location.dart';
import 'package:trufi_core/base/pages/home/widgets/trufi_map_route/maps/share_itinerary_button.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/widget_marker/marker_generator.dart';
import 'package:trufi_core/base/widgets/base_maps/map_buttons/crop_button.dart';
import 'package:trufi_core/base/widgets/base_maps/utils/trufi_map_utils.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class TGoogleMapRoute extends StatefulWidget {
  final TGoogleMapController trufiMapController;
  final AsyncExecutor asyncExecutor;
  final WidgetBuilder? overlapWidget;
  const TGoogleMapRoute({
    Key? key,
    required this.trufiMapController,
    required this.asyncExecutor,
    this.overlapWidget,
  }) : super(key: key);

  @override
  State<TGoogleMapRoute> createState() => _TGoogleMapRouteState();
}

class _TGoogleMapRouteState extends State<TGoogleMapRoute>
    with TickerProviderStateMixin {
  LatLng? tempMarker;

  @override
  void dispose() {
    widget.trufiMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapRouteState = context.watch<MapRouteCubit>().state;
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    final data = <WidgetMarker>[];
    mapRouteState.plan?.itineraries?.forEach((itinerary) {
      final isSelected = itinerary == mapRouteState.selectedItinerary;
      final markers =
          itinerary.compressLegs.where((leg) => leg.transitLeg).map((leg) {
        final color = isSelected
            ? leg.transitLeg
                ? leg.route?.primaryColor ?? leg.transportMode.backgroundColor
                : leg.transportMode.color
            : Colors.grey.withOpacity(0.7);
        return WidgetMarker(
          position: midPointForPoints(leg.accumulatedPoints).toGoogleLatLng(),
          markerId: MarkerId(leg.hashCode.toString()),
          anchor: const Offset(0.5, 0.5),
          zIndex: isSelected ? 2 : 1.9,
          consumeTapEvents: true,
          onTap: () async {
            if (!isSelected) {
              await context.read<MapRouteCubit>().selectItinerary(itinerary);
            }
          },
          widget: Container(
            width: 50,
            height: 26,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: leg.transportMode.getImage(color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      leg.route?.shortName ?? leg.headSign,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }).toList();
      data.addAll(markers);
    });
    Set<Polyline> polylines = {};
    mapRouteState.plan?.itineraries?.forEach((itinerary) {
      final isSelected = itinerary == mapRouteState.selectedItinerary;
      for (Leg leg in itinerary.compressLegs) {
        final color = isSelected
            ? leg.transitLeg
                ? leg.route?.primaryColor ?? leg.transportMode.backgroundColor
                : leg.transportMode.color
            : Colors.grey;
        polylines.add(widget.trufiMapController.addPolyline(
          points: TrufiLatLng.fromGoogleListLatLng(leg.accumulatedPoints),
          polylineId: leg.hashCode.toString(),
          color: color,
          strokeWidth: isSelected ? 6 : 3,
          isDotted: leg.transportMode == TransportMode.walk,
          zIndex: isSelected ? 2 : 1,
        ));
      }
    });
    return Stack(
      children: [
        MarkerGenerator(
          widgetMarkers: data,
          onMarkerGenerated: (_markers, _listIdsRemove) {
            widget.trufiMapController.onMarkerGenerated(
              _markers,
              _listIdsRemove,
              newPolylines: polylines,
            );
          },
        ),
        MarkerGenerator(
          widgetMarkers: mapRouteState.selectedItinerary?.compressLegs
                  .where((leg) => leg.accumulatedPoints.isNotEmpty)
                  .map((leg) {
                final color = leg.transitLeg
                    ? leg.route?.primaryColor ??
                        leg.transportMode.backgroundColor
                    : leg.transportMode.color;
                return WidgetMarker(
                  position: leg.accumulatedPoints[0].toGoogleLatLng(),
                  markerId: MarkerId('${leg.hashCode}start'),
                  anchor: const Offset(0.5, 0.5),
                  consumeTapEvents: true,
                  widget: Container(
                    height: 13,
                    width: 13,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }).toList() ??
              [],
          onMarkerGenerated: widget.trufiMapController.onMarkerGenerated,
        ),
        MarkerGenerator(
          widgetMarkers: [
            if (tempMarker != null)
              WidgetMarker(
                position: tempMarker!,
                markerId: const MarkerId("tempMarker"),
                widget: mapConfiguratiom.markersConfiguration.toMarker,
                zIndex: 5,
                anchor: const Offset(0.5, 0.5),
                consumeTapEvents: true,
              ),
            if (mapRouteState.fromPlace != null)
              WidgetMarker(
                position: mapRouteState.fromPlace!.latLng.toGoogleLatLng(),
                markerId: const MarkerId("fromPlace"),
                zIndex: 4,
                widget: SizedBox(
                  height: 18,
                  child: mapConfiguratiom.markersConfiguration.fromMarker,
                ),
                anchor: const Offset(0.5, 0.5),
                consumeTapEvents: true,
              ),
            if (mapRouteState.toPlace != null)
              WidgetMarker(
                position: mapRouteState.toPlace!.latLng.toGoogleLatLng(),
                markerId: const MarkerId("toPlace"),
                zIndex: 4,
                widget: SizedBox(
                  height: 30,
                  child: mapConfiguratiom.markersConfiguration.toMarker,
                ),
                anchor: const Offset(0.45, 0.9),
                consumeTapEvents: true,
              ),
          ],
          onMarkerGenerated: widget.trufiMapController.onMarkerGenerated,
        ),
        TGoogleMap(
          trufiMapController: widget.trufiMapController,
          onTap: (point) {
            if (mapRouteState.selectedItinerary != null) {
              _handleOnMapTap(
                context,
                TrufiLatLng.fromGoogleLatLng(point),
                mapRouteState.plan!.itineraries!,
                mapRouteState.selectedItinerary!,
              );
            } else {
              onMapPress(context, TrufiLatLng.fromGoogleLatLng(point));
            }
          },
          onLongPress: (point) => onMapPress(
            context,
            TrufiLatLng.fromGoogleLatLng(point),
          ),
          onCameraMove: (onCameraMove) async {
            widget.trufiMapController.cameraPosition = onCameraMove;
            await _showAndHideCropButton(
              mapRouteState.fromPlace?.latLng,
              mapRouteState.toPlace?.latLng,
              onCameraMove,
            );
          },
          floatingActionButtons: Column(
            children: [
              CropButton(
                key: widget.trufiMapController.cropButtonKey,
                onPressed: () async => _handleOnCropPressed(),
              ),
              const Padding(padding: EdgeInsets.all(4.0)),
              if (mapRouteState.isPlanCorrect) const ShareItineraryButton(),
            ],
          ),
        ),
        if (widget.overlapWidget != null) widget.overlapWidget!(context)
      ],
    );
  }

  void _handleOnCropPressed() {
    widget.trufiMapController.moveCurrentBounds(tickerProvider: this);
  }

  Future<void> _showAndHideCropButton(
    TrufiLatLng? fromLocation,
    TrufiLatLng? toLocation,
    CameraPosition onCameraMove,
    // GoogleMapState state,
  ) async {
    if (fromLocation != null &&
        toLocation != null &&
        !TrufiLocation.sameLocations(
          TrufiLatLng.fromGoogleLatLng(onCameraMove.target),
          TrufiLocation.centerLocation(fromLocation, toLocation),
        )) {
      widget.trufiMapController.cropButtonKey.currentState?.setVisible(
        visible: true,
      );
    } else {
      widget.trufiMapController.cropButtonKey.currentState?.setVisible(
        visible: false,
      );
    }
  }

  void _handleOnMapTap(
    BuildContext context,
    TrufiLatLng point,
    List<Itinerary> itineraries,
    Itinerary selectedItinerary,
  ) {
    final tempItineraries = [...itineraries];
    tempItineraries.remove(selectedItinerary);
    final Itinerary? tappedItinerary = itineraryForPoint(
      tempItineraries,
      point,
    );
    if (tappedItinerary != null) {
      context.read<MapRouteCubit>().selectItinerary(tappedItinerary);
    }
  }

  void onMapPress(BuildContext context, TrufiLatLng location) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    setState(() {
      tempMarker = location.toGoogleLatLng();
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
