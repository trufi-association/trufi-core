import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_app/location/location_map_controller.dart';

class ChooseOnMapScreen extends StatelessWidget {
  final LatLng position;

  ChooseOnMapScreen({this.position});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RichText(
              maxLines: 1,
              overflow: TextOverflow.clip,
              text: new TextSpan(
                text: "Choose a point",
                style: theme.textTheme.title,
              ),
            ),
            new RichText(
              maxLines: 1,
              overflow: TextOverflow.clip,
              text: new TextSpan(
                text: "Tap on map to choose",
                style: theme.textTheme.subhead,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: new MapControllerPage(
          position: position,
          onSelected: (point) {
            Navigator.pop(context, point);
          },
        ),
      ),
    );
  }
}
