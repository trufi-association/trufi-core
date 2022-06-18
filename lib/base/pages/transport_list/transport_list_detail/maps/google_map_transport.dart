import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/transport_list/services/models.dart';
// import 'package:trufi_core/base/pages/transport_list/transport_list_detail/maps/share_route_button.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/google_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/google_maps/widget_marker/marker_generator.dart';
import 'package:trufi_core/base/widgets/base_maps/map_buttons/crop_button.dart';

class TGoogleMapTransport extends StatefulWidget {
  final TGoogleMapController trufiMapController;
  final PatternOtp? transportData;
  const TGoogleMapTransport({
    Key? key,
    required this.trufiMapController,
    this.transportData,
  }) : super(key: key);

  @override
  State<TGoogleMapTransport> createState() => _TGoogleMapTransportState();
}

class _TGoogleMapTransportState extends State<TGoogleMapTransport>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    if (widget.transportData?.geometry != null) {
      widget.trufiMapController.moveBounds(
        points: widget.transportData!.geometry!,
        tickerProvider: this,
      );
    }
    final polyline = widget.trufiMapController.addPolyline(
      points: TrufiLatLng.fromGoogleListLatLng(
          widget.transportData?.geometry ?? []),
      polylineId: widget.transportData.hashCode.toString(),
      color: widget.transportData?.route?.primaryColor ?? Colors.black,
      strokeWidth: 6,
    );
    return Stack(
      children: [
        MarkerGenerator(
          widgetMarkers: widget.transportData?.geometry != null
              ? [
                  if (widget.transportData!.geometry!.length > 2)
                    WidgetMarker(
                      position:
                          widget.transportData!.geometry![0].toGoogleLatLng(),
                      markerId: const MarkerId("fromPlace"),
                      widget: SizedBox(
                        height: 15,
                        child: mapConfiguratiom.markersConfiguration.fromMarker,
                      ),
                      anchor: const Offset(0.5, 0.5),
                    ),
                  if (widget.transportData!.geometry!.length > 2)
                    WidgetMarker(
                      position: widget.transportData!
                          .geometry![widget.transportData!.geometry!.length - 1]
                          .toGoogleLatLng(),
                      markerId: const MarkerId("toPlace"),
                      widget: SizedBox(
                        height: 30,
                        child: mapConfiguratiom.markersConfiguration.toMarker,
                      ),
                      anchor: const Offset(0.45, 0.9),
                    ),
                ]
              : [],
          onMarkerGenerated: (_markers, _listIdsRemove) {
            widget.trufiMapController.onMarkerGenerated(
              _markers,
              _listIdsRemove,
              newPolylines: {polyline},
            );
          },
        ),
        TGoogleMap(
          trufiMapController: widget.trufiMapController,
          onCameraMove: (onCameraMove) async {
            widget.trufiMapController.cameraPosition = onCameraMove;
            await _showAndHideCropButton(
              widget.transportData?.geometry?[0],
              widget.transportData
                  ?.geometry?[widget.transportData!.geometry!.length - 1],
              onCameraMove,
            );
          },
          floatingActionButtons: Column(
            children: [
              CropButton(
                key: widget.trufiMapController.cropButtonKey,
                onPressed: () async => _handleOnCropPressed(),
              ),
              // const Padding(padding: EdgeInsets.all(4.0)),
              // if (widget.transportData != null)
              //   ShareRouteButton(
              //     transportData: widget.transportData!,
              //   ),
            ],
          ),
        ),
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
}
