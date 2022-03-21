import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';

import 'package:trufi_core/base/pages/transport_list/services/models.dart';
import 'package:trufi_core/base/widgets/maps/buttons/crop_button.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map_cubit/trufi_map_cubit.dart';

class TrufiMapTransport extends StatefulWidget {
  final TrufiMapController trufiMapController;
  final PatternOtp? transportData;
  const TrufiMapTransport({
    Key? key,
    required this.trufiMapController,
    this.transportData,
  }) : super(key: key);

  @override
  State<TrufiMapTransport> createState() => _TrufiMapTransportState();
}

class _TrufiMapTransportState extends State<TrufiMapTransport>
    with TickerProviderStateMixin {
  final _cropButtonKey = GlobalKey<CropButtonState>();

  @override
  Widget build(BuildContext context) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    if (widget.transportData?.geometry != null) {
      widget.trufiMapController.moveBounds(
        points: widget.transportData!.geometry!,
        tickerProvider: this,
      );
    }
    return TrufiMap(
      trufiMapController: widget.trufiMapController,
      layerOptionsBuilder: (context) => [
        PolylineLayerOptions(
          polylines: [
            Polyline(
              points: widget.transportData?.geometry ?? [],
              color: widget.transportData?.route?.primaryColor ?? Colors.black,
              strokeWidth: 6.0,
            ),
          ],
        ),
        if (widget.transportData?.geometry != null)
          MarkerLayerOptions(markers: [
            if (widget.transportData!.geometry!.length > 2)
              mapConfiguratiom.markersConfiguration
                  .buildFromMarker(widget.transportData!.geometry![0]),
            if (widget.transportData!.geometry!.length > 2)
              mapConfiguratiom.markersConfiguration.buildToMarker(widget
                  .transportData!
                  .geometry![widget.transportData!.geometry!.length - 1]),
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
