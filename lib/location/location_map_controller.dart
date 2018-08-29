import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/trufi_map_utils.dart';

class MapControllerPage extends StatefulWidget {
  final LatLng position;
  final Function(LatLng) onSelected;

  MapControllerPage({this.position, this.onSelected});

  @override
  MapControllerPageState createState() {
    return MapControllerPageState();
  }
}

class MapControllerPageState extends State<MapControllerPage> {
  MapController mapController;
  Marker marker;

  void initState() {
    super.initState();
    marker = buildToMarker(widget.position != null
        ? widget.position
        : LatLng(-17.413977, -66.165321));
    mapController = MapController();
    mapController.onReady.then((_) {
      mapController.move(marker.point, 15.0);
    });
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                zoom: 5.0,
                maxZoom: 19.0,
                minZoom: 1.0,
                onTap: (point) => _handleOnMapTap(point),
              ),
              layers: [
                mapBoxTileLayerOptions(),
                MarkerLayerOptions(markers: <Marker>[marker]),
              ],
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
      ),
    );
  }

  _handleOnMapTap(LatLng point) {
    setState(() {
      marker = buildToMarker(point);
    });
  }

  _handleOnOKPressed(BuildContext context) {
    if (widget.onSelected != null) {
      widget.onSelected(marker.point);
    }
  }
}
