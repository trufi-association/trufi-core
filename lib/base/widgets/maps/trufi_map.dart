import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_provider_cubit.dart';
import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';
import 'package:trufi_core/base/widgets/maps/buttons/your_location_button.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map_cubit/trufi_map_cubit.dart';

typedef LayerOptionsBuilder = List<LayerOptions> Function(BuildContext context);

class TrufiMap extends StatelessWidget {
  final TrufiMapController trufiMapController;
  final LayerOptionsBuilder layerOptionsBuilder;
  final Widget? floatingActionButtons;
  final TapCallback? onTap;
  final LongPressCallback? onLongPress;
  final PositionCallback? onPositionChanged;
  const TrufiMap({
    Key? key,
    required this.trufiMapController,
    required this.layerOptionsBuilder,
    this.floatingActionButtons,
    this.onTap,
    this.onLongPress,
    this.onPositionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;
    final currentMapType = context.watch<MapTileProviderCubit>().state;
    return Stack(
      children: [
        StreamBuilder<LatLng?>(
            initialData: null,
            stream: GPSLocationProvider().streamLocation,
            builder: (context, snapshot) {
              final currentLocation = snapshot.data;
              return FlutterMap(
                mapController: trufiMapController.mapController,
                options: MapOptions(
                  interactiveFlags: InteractiveFlag.drag |
                      InteractiveFlag.flingAnimation |
                      InteractiveFlag.pinchMove |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom,
                  minZoom: mapConfiguratiom.onlineMinZoom,
                  maxZoom: mapConfiguratiom.onlineMaxZoom,
                  zoom: mapConfiguratiom.onlineZoom,
                  onTap: onTap,
                  onLongPress: onLongPress,
                  center: mapConfiguratiom.center,
                  onPositionChanged: (
                    MapPosition position,
                    bool hasGesture,
                  ) {
                    if (onPositionChanged != null) {
                      Future.delayed(Duration.zero, () {
                        onPositionChanged!(position, hasGesture);
                      });
                    }
                  },
                ),
                layers: [
                  ...currentMapType.currentMapTileProvider
                      .buildTileLayerOptions(),
                  mapConfiguratiom.markersConfiguration
                      .buildYourLocationMarkerLayerOptions(currentLocation),
                  ...layerOptionsBuilder(context)
                ],
              );
            }),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (floatingActionButtons != null) floatingActionButtons!,
              const Padding(padding: EdgeInsets.all(4.0)),
              YourLocationButton(
                trufiMapController: trufiMapController,
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
