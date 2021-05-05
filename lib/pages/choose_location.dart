import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/widgets/map/buttons/your_location_button.dart';
import 'package:trufi_core/widgets/map/trufi_map_controller.dart';

import '../trufi_configuration.dart';
import '../widgets/map/utils/trufi_map_utils.dart';
import '../widgets/map/trufi_online_map.dart';

class ChooseLocationPage extends StatefulWidget {
  @override
  ChooseLocationPageState createState() => ChooseLocationPageState();
}

class ChooseLocationPageState extends State<ChooseLocationPage> {
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
            MarkerLayerOptions(markers: <Marker>[_chooseOnMapMarker]),
          ];
        },
      ),
      floatingActionButton: YourLocationButton(
        trufiMapController: _trufiMapController,
      ),
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
