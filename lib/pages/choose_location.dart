import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core/blocs/gps_location/location_provider_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/widgets/map/trufi_map_controller.dart';

import '../trufi_configuration.dart';
import '../trufi_map_utils.dart';
import '../widgets/map/trufi_online_map.dart';

class ChooseLocationPage extends StatefulWidget {
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
  }

  @override
  void dispose() {
    _trufiMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: TrufiOnlineMap(
        controller: _trufiMapController,
        onPositionChanged: _handleOnMapPositionChanged,
        layerOptionsBuilder: (context) {
          return <LayerOptions>[
            // _trufiMapController.yourLocationLayer,
            MarkerLayerOptions(markers: <Marker>[_chooseOnMapMarker]),
          ];
        },
      ),
      floatingActionButton: Column(
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
      ),
    );
  }

  Future<void> _handleOnYourLocationPressed() async {
      final location =
          context.read<LocationProviderCubit>().state.currentLocation;
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
