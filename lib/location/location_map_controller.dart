import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/trufi_map_utils.dart';

class MapControllerPage extends StatefulWidget {
  MapControllerPage(
    this.initialPosition, {
    this.onSelected,
  }) : assert(initialPosition != null);

  final LatLng initialPosition;
  final ValueChanged<LatLng> onSelected;

  @override
  MapControllerPageState createState() => MapControllerPageState();
}

class MapControllerPageState extends State<MapControllerPage> {
  MapController mapController;
  Marker chooseOnMapMarker;
  Marker yourLocationMarker;

  void initState() {
    super.initState();
    chooseOnMapMarker = buildToMarker(widget.initialPosition);
    mapController = MapController()
      ..onReady.then((_) {
        mapController.move(widget.initialPosition, 15.0);
      });
  }

  Widget build(BuildContext context) {
    LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<LatLng>(
            stream: locationProviderBloc.outLocationUpdate,
            initialData: widget.initialPosition,
            builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
              List<Marker> markers = <Marker>[chooseOnMapMarker];
              if (snapshot.data != null) {
                yourLocationMarker = buildYourLocationMarker(snapshot.data);
                markers.add(yourLocationMarker);
              }
              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  zoom: 5.0,
                  maxZoom: 19.0,
                  minZoom: 1.0,
                  onTap: (point) => _handleOnMapTap(point),
                ),
                layers: [
                  mapBoxTileLayerOptions(),
                  MarkerLayerOptions(markers: markers),
                ],
              );
            },
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                child: Text("OK"),
                onPressed: () => _handleOnOKPressed(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleOnMapTap(LatLng point) {
    setState(() {
      chooseOnMapMarker = buildToMarker(point);
    });
  }

  void _handleOnOKPressed(BuildContext context) {
    if (widget.onSelected != null) {
      widget.onSelected(chooseOnMapMarker.point);
    }
  }
}
