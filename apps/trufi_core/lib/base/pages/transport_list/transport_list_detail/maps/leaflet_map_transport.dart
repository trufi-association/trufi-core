import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/transit_route/transit_route.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/utils/leaflet_map_utils.dart';
import 'package:trufi_core/base/widgets/base_maps/map_buttons/crop_button.dart';

class LeafletMapTransport extends StatefulWidget {
  final LeafletMapController trufiMapController;
  final TransitRoute? transportData;
  final Uri? shareBaseRouteUri;

  const LeafletMapTransport({
    super.key,
    required this.trufiMapController,
    this.transportData,
    this.shareBaseRouteUri,
  });

  @override
  State<LeafletMapTransport> createState() => _LeafletMapTransportState();
}

class _LeafletMapTransportState extends State<LeafletMapTransport>
    with TickerProviderStateMixin {
  final _cropButtonKey = GlobalKey<CropButtonState>();

  @override
  Widget build(BuildContext context) {
    final mapConfiguration = context.read<MapConfigurationCubit>().state;

    widget.trufiMapController.onReady.then((value) {
      if (widget.transportData?.geometry != null) {
        widget.trufiMapController.moveBounds(
          points: widget.transportData!.geometry!,
          tickerProvider: this,
        );
      }
    });
    return LeafletMap(
      trufiMapController: widget.trufiMapController,
      layerOptionsBuilder: (context) => [
        PolylineLayer(
          polylines: [
            Polyline(
              points: TrufiLatLng.toListLatLng(
                  widget.transportData?.geometry ?? []),
              color:
                  widget.transportData?.route?.backgroundColor ?? Colors.black,
              strokeWidth: 6.0,
            ),
          ],
        ),
        if (widget.transportData?.geometry != null)
          MarkerLayer(markers: [
            if (widget.transportData!.geometry!.length > 2)
              buildFromMarker(widget.transportData!.geometry![0],
                  mapConfiguration.markersConfiguration.fromMarker),
            if (widget.transportData!.geometry!.length > 2)
              buildToMarker(
                  widget.transportData!
                      .geometry![widget.transportData!.geometry!.length - 1],
                  mapConfiguration.markersConfiguration.toMarker),
          ]),
      ],
      floatingActionButtons: Column(
        children: [
          CropButton(
            key: _cropButtonKey,
            onPressed: _handleOnCropPressed,
          ),
        ],
      ),
      onPositionChanged: _handleOnMapPositionChanged,
    );
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
}
