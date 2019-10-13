import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/trufi_localizations.dart';
import 'package:trufi_app/trufi_map_utils.dart';
import 'package:trufi_app/widgets/trufi_map.dart';
import 'package:trufi_app/widgets/trufi_online_map.dart';

class ChooseLocationPage extends StatefulWidget {
  ChooseLocationPage({this.initialPosition});

  final LatLng initialPosition;

  @override
  ChooseLocationPageState createState() => ChooseLocationPageState();
}

class ChooseLocationPageState extends State<ChooseLocationPage>
    with TickerProviderStateMixin {
  final _trufiMapController = TrufiMapController();

  Marker _chooseOnMapMarker;

  void initState() {
    super.initState();

    final cfg = GlobalConfiguration();
    final zoom = cfg.getDouble("mapChooseLocationZoom");
    final centerCoords = List<double>.from(cfg.get("mapCenterCoordsLatLng"));
    final mapCenter = LatLng(centerCoords[0], centerCoords[1]);

    _chooseOnMapMarker = buildToMarker(mapCenter);
    if (widget.initialPosition != null) {
      _trufiMapController.outMapReady.listen((_) {
        _trufiMapController.move(
          center: widget.initialPosition,
          zoom: zoom,
          tickerProvider: this,
        );
      });
    }
  }

  @override
  void dispose() {
    _trufiMapController.dispose();
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
            maxLines: 2,
            text: TextSpan(
              text: localizations.chooseLocationPageTitle(),
              style: theme.primaryTextTheme.body1,
            ),
          ),
          RichText(
            maxLines: 2,
            text: TextSpan(
              text: localizations.chooseLocationPageSubtitle(),
              style: theme.primaryTextTheme.caption,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: _handleOnConfirmationPressed,
          child: Container(
            child: Center(
              child: RichText(
                maxLines: 1,
                text: TextSpan(
                  text: localizations.commonOK(),
                  style: theme.primaryTextTheme.button,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return TrufiOnlineMap(
      controller: _trufiMapController,
      onPositionChanged: _handleOnMapPositionChanged,
      layerOptionsBuilder: (context) {
        return <LayerOptions>[
          _trufiMapController.yourLocationLayer,
          MarkerLayerOptions(markers: <Marker>[_chooseOnMapMarker]),
        ];
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 70.0,
          width: 56.0,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).backgroundColor,
            child: Icon(
              Icons.my_location,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: _handleOnYourLocationPressed,
            heroTag: null,
          ),
        ),
      ],
    );
  }

  void _handleOnYourLocationPressed() async {
    _trufiMapController.moveToYourLocation(
      context: context,
      tickerProvider: this,
    );
  }

  void _handleOnConfirmationPressed() {
    Navigator.of(context).pop(_chooseOnMapMarker.point);
  }

  void _handleOnMapPositionChanged(
    MapPosition position,
    bool hasGesture,
  ) {
    setState(() {
      _chooseOnMapMarker = buildToMarker(position.center);
    });
  }
}
