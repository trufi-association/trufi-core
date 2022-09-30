import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/pages/transport_list/services/models.dart';
import 'package:trufi_core/base/pages/transport_list/transport_list_detail/maps/share_route_button.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/utils/leaflet_map_utils.dart';
import 'package:trufi_core/base/widgets/base_maps/map_buttons/crop_button.dart';

class LeafletMapTransport extends StatefulWidget {
  final LeafletMapController trufiMapController;
  final PatternOtp? transportData;
  final Uri? shareBaseRouteUri;

  const LeafletMapTransport({
    Key? key,
    required this.trufiMapController,
    this.transportData,
    this.shareBaseRouteUri,
  }) : super(key: key);

  @override
  State<LeafletMapTransport> createState() => _LeafletMapTransportState();
}

class _LeafletMapTransportState extends State<LeafletMapTransport>
    with TickerProviderStateMixin {
  final _cropButtonKey = GlobalKey<CropButtonState>();

  @override
  Widget build(BuildContext context) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;

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
              color: widget.transportData?.route?.primaryColor ?? Colors.black,
              strokeWidth: 6.0,
            ),
          ],
        ),
        if (widget.transportData?.geometry != null)
          MarkerLayer(markers: [
            if (widget.transportData!.geometry!.length > 2)
              buildFromMarker(widget.transportData!.geometry![0],
                  mapConfiguratiom.markersConfiguration.fromMarker),
            if (widget.transportData!.geometry!.length > 2)
              buildToMarker(
                  widget.transportData!
                      .geometry![widget.transportData!.geometry!.length - 1],
                  mapConfiguratiom.markersConfiguration.toMarker),
          ]),
      ],
      floatingActionButtons: Column(
        children: [
          CropButton(
            key: _cropButtonKey,
            onPressed: _handleOnCropPressed,
          ),
          const Padding(padding: EdgeInsets.all(4.0)),
          if (widget.transportData != null &&
              widget.shareBaseRouteUri != null)
            ShareRouteButton(
              transportData: widget.transportData!,
              shareBaseRouteUri: widget.shareBaseRouteUri!,
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
}
