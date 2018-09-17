import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
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
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _mapController.onReady.then((_) {
      _mapController.move(
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
    return Stack(children: <Widget>[
      TrufiMap(
        mapController: _mapController,
        mapOptions: MapOptions(
          zoom: 5.0,
          maxZoom: 19.0,
          minZoom: 1.0,
        ),
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
    LocationProviderBloc locationProviderBloc =
        BlocProvider.of<LocationProviderBloc>(context);
    LatLng lastLocation = await locationProviderBloc.lastLocation;
    if (lastLocation != null) {
      _mapController.move(lastLocation, 17.0);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => buildAlertLocationServicesDenied(context),
    );
  }
}
