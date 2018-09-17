import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/trufi_map_utils.dart';

class TrufiMap extends StatefulWidget {
  static final LatLng cochabambaLocation = LatLng(-17.3940469, -66.233916);

  TrufiMap({
    @required this.mapController,
    @required this.mapOptions,
    this.layers,
    this.initialPosition,
  });

  final MapController mapController;
  final MapOptions mapOptions;
  final List<LayerOptions> layers;
  final LatLng initialPosition;

  @override
  TrufiMapState createState() => TrufiMapState();
}

class TrufiMapState extends State<TrufiMap> {
  Marker yourLocationMarker;

  @override
  void initState() {
    super.initState();
    widget.mapController.onReady.then((_) {
      widget.mapController.move(
        widget.initialPosition != null
            ? widget.initialPosition
            : TrufiMap.cochabambaLocation,
        12.0,
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    return StreamBuilder<LatLng>(
      stream: locationProviderBloc.outLocationUpdate,
      builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
        List<LayerOptions> layers = List();
        // Map tiles layer
        layers.add(tileHostingTileLayerOptions());
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
