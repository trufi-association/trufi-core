import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/trufi_map_utils.dart';

class TrufiMap extends StatefulWidget {
  TrufiMap({
    @required this.mapController,
    @required this.mapOptions,
    this.layers,
  });

  final MapController mapController;
  final MapOptions mapOptions;
  final List<LayerOptions> layers;

  @override
  TrufiMapState createState() => TrufiMapState();
}

class TrufiMapState extends State<TrufiMap> {
  Marker yourLocationMarker;

  @override
  Widget build(BuildContext context) {
    final LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    return StreamBuilder<LatLng>(
      stream: locationProviderBloc.outLocationUpdate,
      builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
        List<LayerOptions> layers = List();
        // Map tiles layer
        layers.add(tilehostingTileLayerOptions());
        // Parent layers
        if (widget.layers != null) {
          layers.addAll(widget.layers);
        }
        // Your location layer
        if (snapshot.data != null) {
          yourLocationMarker = buildYourLocationMarker(snapshot.data);
          layers.add(MarkerLayerOptions(markers: <Marker>[yourLocationMarker]));
        } else {
          yourLocationMarker = null;
        }
        return FlutterMap(
          mapController: widget.mapController,
          options: widget.mapOptions,
          layers: layers,
        );
      },
    );
  }
}
