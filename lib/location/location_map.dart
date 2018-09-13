import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/location/location_map_controller.dart';
import 'package:trufi_app/trufi_localizations.dart';

class ChooseOnMapScreen extends StatelessWidget {
  final LatLng initialPosition;

  ChooseOnMapScreen({this.initialPosition});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              maxLines: 1,
              overflow: TextOverflow.clip,
              text: TextSpan(
                text: TrufiLocalizations.of(context).mapChoosePoint,
                style: theme.textTheme.title,
              ),
            ),
            RichText(
              maxLines: 1,
              overflow: TextOverflow.clip,
              text: TextSpan(
                text: TrufiLocalizations.of(context).mapTapToChoose,
                style: theme.textTheme.subhead,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: MapControllerPage(
          initialPosition: initialPosition,
          onSelected: (point) {
            Navigator.pop(context, point);
          },
        ),
      ),
    );
  }
}
