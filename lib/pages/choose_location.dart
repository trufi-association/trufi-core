import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:trufi_core/blocs/location_provider_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

import '../trufi_configuration.dart';
import '../trufi_map_utils.dart';
import '../widgets/trufi_map.dart';
import '../widgets/trufi_online_map.dart';

class ChooseLocationPage extends StatefulWidget {
  final LatLng initialPosition;

  const ChooseLocationPage({Key key, this.initialPosition}) : super(key: key);

  @override
  ChooseLocationPageState createState() => ChooseLocationPageState();
}

class ChooseLocationPageState extends State<ChooseLocationPage>
    with TickerProviderStateMixin {
  final _trufiMapController = TrufiMapController();

  Marker _chooseOnMapMarker;

  @override
  void initState() {
    super.initState();
    final cfg = TrufiConfiguration();
    _chooseOnMapMarker = buildToMarker(cfg.map.center);
    if (widget.initialPosition != null) {
      _trufiMapController.outMapReady.listen((_) {
        _trufiMapController.move(
          center: widget.initialPosition,
          zoom: cfg.map.chooseLocationZoom,
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RichText(
            maxLines: 2,
            text: TextSpan(
              text: localization.chooseLocationPageTitle,
              style: theme.primaryTextTheme.bodyText2,
            ),
          ),
          RichText(
            maxLines: 2,
            text: TextSpan(
              text: localization.chooseLocationPageSubtitle,
              style: theme.primaryTextTheme.caption,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _handleOnConfirmationPressed,
          child: Center(
            child: RichText(
              maxLines: 1,
              text: TextSpan(
                text: localization.commonOK,
                style: theme.primaryTextTheme.button,
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
        SizedBox(
          height: 70.0,
          width: 56.0,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).backgroundColor,
            onPressed: _handleOnYourLocationPressed,
            heroTag: null,
            child: Icon(
              Icons.my_location,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleOnYourLocationPressed() async {
    final location =
        await context.read<LocationProviderCubit>().getCurrentLocation();
    _trufiMapController.moveToYourLocation(
      location: location,
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
