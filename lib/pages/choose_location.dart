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
    _chooseOnMapMarker = buildToMarker(TrufiMap.cochabambaCenter);
    if (widget.initialPosition != null) {
      _trufiOnAndOfflineMapController.outMapReady.listen((_) {
        _trufiOnAndOfflineMapController.move(widget.initialPosition, 16.0);
      });
    }
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
            maxLines: 2,
            text: TextSpan(
              text: localizations.chooseLocationPageTitle,
              style: theme.textTheme.body2,
            ),
          ),
          RichText(
            maxLines: 2,
            text: TextSpan(
              text: localizations.chooseLocationPageSubtitle,
              style: theme.textTheme.caption.copyWith(
                color: theme.textTheme.body2.color,
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        GestureDetector(
          child: Center(
            child: Container(
              padding: EdgeInsets.only(right: 24.0),
              child: RichText(
                maxLines: 1,
                text: TextSpan(
                  text: localizations.commonOK.toUpperCase(),
                  style: theme.textTheme.button.copyWith(
                    fontSize: theme.textTheme.caption.fontSize,
                  ),
                ),
              ),
            ),
          ),
          onTap: _handleOnConfirmationPressed,
        )
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 70.0,
          width: 56.0,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.my_location,
              color: Colors.black,
            ),
            onPressed: _handleOnYourLocationPressed,
            heroTag: null,
          ),
        ),
      ],
    );
  }

  void _handleOnYourLocationPressed() async {
    _trufiOnAndOfflineMapController.moveToYourLocation(context);
  }

  void _handleOnConfirmationPressed() {
    Navigator.of(context).pop(_chooseOnMapMarker.point);
  }

  void _handleOnMapPositionChanged(MapPosition position) {
    setState(() {
      _chooseOnMapMarker = buildToMarker(position.center);
    });
  }
}
