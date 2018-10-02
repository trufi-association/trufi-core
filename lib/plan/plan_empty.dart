import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/widgets/alerts.dart';
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
    ThemeData theme = Theme.of(context);
    return FloatingActionButton(
      backgroundColor: theme.primaryColor,
      child: Icon(Icons.my_location, color: theme.primaryIconTheme.color),
      onPressed: _handleOnMyLocationTap,
      heroTag: null,
    );
  }

  void _handleOnMyLocationTap() async {
    final locationProviderBloc = LocationProviderBloc.of(context);
    LatLng lastLocation = await locationProviderBloc.lastLocation;
    if (lastLocation != null) {
      _trufiOnAndOfflineMapController.mapController.move(lastLocation, 17.0);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => buildAlertLocationServicesDenied(context),
    );
  }
}
