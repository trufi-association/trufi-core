import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/trufi_map.dart';

class MapControllerPage extends StatefulWidget {
  MapControllerPage({
    this.initialPosition,
    this.onSelected,
  });

  final LatLng initialPosition;
  final ValueChanged<LatLng> onSelected;

  @override
  MapControllerPageState createState() => MapControllerPageState();
}

class MapControllerPageState extends State<MapControllerPage> {
  MapController mapController;
  Marker chooseOnMapMarker;

  void initState() {
    super.initState();
    chooseOnMapMarker = buildToMarker(
      widget.initialPosition != null
          ? widget.initialPosition
          : LatLng(-17.4603761, -66.1860606),
    );
    mapController = MapController()
      ..onReady.then((_) {
        mapController.move(chooseOnMapMarker.point, 15.0);
      });
  }

  Widget build(BuildContext context) {
    final TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: TrufiMap(
            mapController: mapController,
            mapOptions: MapOptions(
              zoom: 5.0,
              maxZoom: 19.0,
              minZoom: 1.0,
              onTap: _handleOnMapTap,
            ),
            layers: <LayerOptions>[
              MarkerLayerOptions(markers: <Marker>[chooseOnMapMarker])
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: SafeArea(
                child: RaisedButton(
                  child: Text(localizations.commonOK),
                  onPressed: () => _handleOnOKPressed(context),
                ),
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
