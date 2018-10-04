import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/trufi_map.dart';

class ChooseLocationPage extends StatefulWidget {
  ChooseLocationPage({this.initialPosition});

  final LatLng initialPosition;

  @override
  ChooseLocationPageState createState() => ChooseLocationPageState();
}

class ChooseLocationPageState extends State<ChooseLocationPage> {
  final _trufiOnAndOfflineMapController = TrufiOnAndOfflineMapController();

  Marker _chooseOnMapMarker;

  void initState() {
    super.initState();
    _chooseOnMapMarker = buildToMarker(
      widget.initialPosition != null
          ? widget.initialPosition
          : TrufiMap.cochabambaCenter,
    );
  }

  @override
  void dispose() {
    _trufiOnAndOfflineMapController.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
    return TrufiOnAndOfflineMap(
      controller: _trufiOnAndOfflineMapController,
      onPositionChanged: _handleOnMapPositionChanged,
      layerOptionsBuilder: (context) {
        return <LayerOptions>[
          _trufiOnAndOfflineMapController.yourLocationLayer,
          MarkerLayerOptions(markers: <Marker>[_chooseOnMapMarker]),
        ];
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 70.0,
          width: 56.0,
          child: Transform.scale(
            scale: 0.8,
            child: FloatingActionButton(
              backgroundColor: Colors.grey,
              child: Icon(Icons.my_location),
              onPressed: _handleOnYourLocationPressed,
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
          onPressed: _handleOnCheckPressed,
          heroTag: null,
        ),
      ],
    );
  }

  void _handleOnYourLocationPressed() async {
    _trufiOnAndOfflineMapController.moveToYourLocation(context);
  }

  void _handleOnCheckPressed() {
    Navigator.of(context).pop(_chooseOnMapMarker.point);
  }

  void _handleOnMapPositionChanged(MapPosition position) {
    setState(() {
      _chooseOnMapMarker = buildToMarker(position.center);
    });
  }
}
