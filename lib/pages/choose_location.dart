import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/blocs/bloc_provider.dart';
import 'package:trufi_app/blocs/location_provider_bloc.dart';
import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/alerts.dart';
import 'package:trufi_app/widgets/trufi_map.dart';

class ChooseLocationPage extends StatefulWidget {
  ChooseLocationPage({this.initialPosition});

  final LatLng initialPosition;

  @override
  ChooseLocationPageState createState() => ChooseLocationPageState();
}

class ChooseLocationPageState extends State<ChooseLocationPage> {
  MapController _mapController = MapController();
  Marker _chooseOnMapMarker;

  void initState() {
    super.initState();
    _chooseOnMapMarker = buildToMarker(
      widget.initialPosition != null
          ? widget.initialPosition
          : TrufiMap.cochabambaLocation,
    );
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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TrufiLocalizations localizations = TrufiLocalizations.of(context);
    return AppBar(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RichText(
            maxLines: 1,
            overflow: TextOverflow.clip,
            text: TextSpan(
              text: localizations.chooseLocationPageTitle,
              style: theme.textTheme.title,
            ),
          ),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.clip,
            text: TextSpan(
              text: localizations.chooseLocationPageSubtitle,
              style: theme.textTheme.subhead,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return TrufiMap(
      mapController: _mapController,
      mapOptions: MapOptions(
        zoom: 5.0,
        maxZoom: 19.0,
        minZoom: 1.0,
        onPositionChanged: _handleOnMapPositionChanged,
      ),
      layers: <LayerOptions>[
        MarkerLayerOptions(markers: <Marker>[_chooseOnMapMarker])
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 70.0,
          width: 56.0,
          child: ScaleTransition(
            scale: AlwaysStoppedAnimation<double>(0.8),
            child: FloatingActionButton(
              backgroundColor: Colors.grey,
              child: Icon(Icons.my_location),
              onPressed: _handleOnMyLocationTap,
              heroTag: null,
            ),
          ),
        ),
        FloatingActionButton(
          backgroundColor: theme.primaryColor,
          child: Icon(
            Icons.check,
            color: theme.primaryIconTheme.color,
          ),
          onPressed: _handleOnCheckTap,
          heroTag: null,
        ),
      ],
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

  void _handleOnCheckTap() {
    Navigator.of(context).pop(_chooseOnMapMarker.point);
  }

  void _handleOnMapPositionChanged(MapPosition position) {
    Future.delayed(Duration.zero, () {
      setState(() {
        _chooseOnMapMarker = buildToMarker(position.center);
      });
    });
  }
}
