import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/widgets/trufi_map.dart';

class PlanEmptyPage extends StatefulWidget {
  PlanEmptyPage({this.initialPosition});

  final LatLng initialPosition;

  @override
  PlanEmptyPageState createState() => PlanEmptyPageState();
}

class PlanEmptyPageState extends State<PlanEmptyPage> {
  final _trufiOnAndOfflineMapController = TrufiOnAndOfflineMapController();

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      TrufiOnAndOfflineMap(
        key: ValueKey("PlanEmptyMap"),
        controller: _trufiOnAndOfflineMapController,
        layerOptionsBuilder: (context) {
          return <LayerOptions>[
            _trufiOnAndOfflineMapController.yourLocationLayer,
          ];
        },
      ),
      Positioned(
        bottom: 16.0,
        right: 16.0,
        child: _buildFloatingActionButton(context),
      ),
    ]);
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      child: Icon(Icons.my_location, color: Colors.black),
      onPressed: _handleOnYourLocationPressed,
      heroTag: null,
    );
  }

  void _handleOnYourLocationPressed() async {
    _trufiOnAndOfflineMapController.moveToYourLocation(context);
  }
}
