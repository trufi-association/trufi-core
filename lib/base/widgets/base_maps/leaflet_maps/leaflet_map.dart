import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_provider_cubit.dart';
import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/leaflet_map_controller.dart';
import 'package:trufi_core/base/widgets/base_maps/leaflet_maps/utils/leaflet_map_utils.dart';
import 'package:trufi_core/base/widgets/base_maps/map_buttons/your_location_button.dart';

typedef LayerOptionsBuilder = List<Widget> Function(BuildContext context);

class LeafletMap extends StatefulWidget {
  final LeafletMapController trufiMapController;
  final LayerOptionsBuilder layerOptionsBuilder;
  final Widget? floatingActionButtons;
  final TapCallback? onTap;
  final LongPressCallback? onLongPress;
  final PositionCallback? onPositionChanged;
  final double? bottomPaddingButtons;
  const LeafletMap({
    Key? key,
    required this.trufiMapController,
    required this.layerOptionsBuilder,
    this.floatingActionButtons,
    this.onTap,
    this.onLongPress,
    this.onPositionChanged,
    this.bottomPaddingButtons,
  }) : super(key: key);

  @override
  State<LeafletMap> createState() => _LeafletMapState();
}

class _LeafletMapState extends State<LeafletMap> {
  bool isTrackingPosition = false;
  @override
  Widget build(BuildContext context) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    final currentMapType = context.watch<MapTileProviderCubit>().state;
    return Stack(
      children: [
        StreamBuilder<TrufiLatLng?>(
          initialData: null,
          stream: GPSLocationProvider().streamLocation,
          builder: (context, snapshot) {
            final currentLocation = snapshot.data;
            return FlutterMap(
              key: Key(
                  widget.trufiMapController.mapController.hashCode.toString()),
              mapController: widget.trufiMapController.mapController,
              options: MapOptions(
                interactiveFlags: InteractiveFlag.drag |
                    InteractiveFlag.flingAnimation |
                    InteractiveFlag.pinchMove |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom,
                minZoom: mapConfiguratiom.onlineMinZoom,
                maxZoom: mapConfiguratiom.onlineMaxZoom,
                zoom: mapConfiguratiom.onlineZoom,
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                center: mapConfiguratiom.center.toLatLng(),
                onMapReady: () {
                  if (!widget.trufiMapController.readyCompleter.isCompleted) {
                    widget.trufiMapController.readyCompleter.complete();
                  }
                },
                onPositionChanged: (
                  MapPosition position,
                  bool hasGesture,
                ) {
                  if (widget.onPositionChanged != null) {
                    Future.delayed(Duration.zero, () {
                      widget.onPositionChanged!(position, hasGesture);
                    });
                  }
                  if (hasGesture && isTrackingPosition) {
                    setState(() {
                      isTrackingPosition = false;
                    });
                  }
                },
              ),
              children: [
                ...currentMapType.currentMapTileProvider
                    .buildTileLayerOptions(),
                ...widget.layerOptionsBuilder(context),
                MarkerLayer(markers: [
                  buildYourLocationMarker(
                    currentLocation,
                    mapConfiguratiom.markersConfiguration.yourLocationMarker,
                  )
                ]),
              ],
            );
          },
        ),
        Positioned(
          bottom: widget.bottomPaddingButtons ?? 16.0,
          right: 16.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (widget.floatingActionButtons != null)
                widget.floatingActionButtons!,
              const Padding(padding: EdgeInsets.all(4.0)),
              YourLocationButton(
                trufiMapController: widget.trufiMapController,
                isTrackingPosition: isTrackingPosition,
                setTracking: (isTraking) {
                  setState(() {
                    isTrackingPosition = isTraking;
                  });
                },
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: mapConfiguratiom.mapAttributionBuilder!(context),
        ),
      ],
    );
  }
}
