import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/trufi_map_utils.dart';

class TrufiMap extends StatefulWidget {
  static final LatLng cochabambaCenter = LatLng(-17.3940469, -66.233916);
  static final LatLng cochabambaSouthWest = LatLng(-17.79300, -66.75000);
  static final LatLng cochabambaNorthEast = LatLng(-16.90400, -65.67400);

  TrufiMap({
    @required this.mapController,
    @required this.mapOptions,
    this.backgroundLayers,
    this.foregroundLayers,
  });

  final MapController mapController;
  final MapOptions mapOptions;
  final List<LayerOptions> backgroundLayers;
  final List<LayerOptions> foregroundLayers;

  @override
  TrufiMapState createState() => TrufiMapState();
}

class TrufiMapState extends State<TrufiMap> {
  @override
  Widget build(BuildContext context) {
    final locationProviderBloc = LocationProviderBloc.of(context);
    final preferencesBloc = PreferencesBloc.of(context);
    return StreamBuilder<bool>(
      stream: preferencesBloc.outChangeOffline,
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> snapshotOffline,
      ) {
        return StreamBuilder<LatLng>(
          stream: locationProviderBloc.outLocationUpdate,
          builder: (
            BuildContext context,
            AsyncSnapshot<LatLng> snapshotLocation,
          ) {
            List<LayerOptions> layers = List();
            // Map tiles layer
            layers.add(
              snapshotOffline.data == true
                  ? offlineMapTileLayerOptions()
                  : tileHostingTileLayerOptions(),
            );
            // Parent background layers
            if (widget.backgroundLayers != null) {
              layers.addAll(widget.backgroundLayers);
            }
            // Your location layer
            if (snapshotLocation.data != null) {
              layers.add(
                MarkerLayerOptions(markers: <Marker>[
                  buildYourLocationMarker(
                    snapshotLocation.data,
                  ),
                ]),
              );
            }
            // Parent foreground layers
            if (widget.foregroundLayers != null) {
              layers.addAll(widget.foregroundLayers);
            }
            return FlutterMap(
              mapController: widget.mapController,
              options: widget.mapOptions,
              layers: layers,
            );
          },
        );
      },
    );
  }
}
