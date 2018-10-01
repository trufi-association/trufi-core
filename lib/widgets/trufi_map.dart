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
    this.backgroundLayers,
    this.foregroundLayers,
    this.onTap,
    this.onPositionChanged,
  });

  final MapController mapController;
  final List<LayerOptions> backgroundLayers;
  final List<LayerOptions> foregroundLayers;
  final TapCallback onTap;
  final PositionCallback onPositionChanged;

  @override
  TrufiMapState createState() => TrufiMapState();
}

class TrufiMapState extends State<TrufiMap> {
  @override
  Widget build(BuildContext context) {
    final locationProviderBloc = LocationProviderBloc.of(context);
    final preferencesBloc = PreferencesBloc.of(context);
    return StreamBuilder<bool>(
      stream: preferencesBloc.outChangeOnline,
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> snapshotOnline,
      ) {
        return StreamBuilder<LatLng>(
          stream: locationProviderBloc.outLocationUpdate,
          builder: (
            BuildContext context,
            AsyncSnapshot<LatLng> snapshotLocation,
          ) {
            List<LayerOptions> layers = List();
            bool isOnline = snapshotOnline.data == true;
            // Map tiles layer
            layers.add(
              isOnline
                  ? tileHostingTileLayerOptions()
                  : offlineMapTileLayerOptions(),
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
              options: MapOptions(
                minZoom: isOnline ? 1.0 : 8.0,
                maxZoom: isOnline ? 19.0 : 14.0,
                zoom: 13.0,
                onTap: widget.onTap,
                onPositionChanged: widget.onPositionChanged,
                swPanBoundary: TrufiMap.cochabambaSouthWest,
                nePanBoundary: TrufiMap.cochabambaNorthEast,
                center: TrufiMap.cochabambaCenter,
              ),
              layers: layers,
            );
          },
        );
      },
    );
  }
}
