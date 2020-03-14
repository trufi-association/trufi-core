import 'package:flutter/material.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/trufi_models.dart';
import 'package:trufi_core/trufi_localizations.dart';
import 'package:trufi_core/blocs/preferences_bloc.dart';

class MapTypeButton extends StatelessWidget {
  MapTypeButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Theme.of(context).backgroundColor,
      child: Icon(Icons.layers, color: Colors.black),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => _buildMapTypeBottomSheet(context),
          backgroundColor: Theme.of(context).backgroundColor,
        );
      },
      heroTag: null,
    );
  }

   Widget _buildMapTypeBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final cfg = TrufiConfiguration();
    final preferencesBloc = PreferencesBloc.of(context);
    final localization = TrufiLocalizations.of(context).localization;
    return SafeArea(
      child: Container(
        height: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(localization.mapTypeTitle(), style: theme.textTheme.body2),
            ),
            StreamBuilder(
              stream: preferencesBloc.outChangeMapType,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildMapTypeOptionButton(
                      context: context,
                      assetPath: "assets/images/maptype-streets.png",
                      label: localization.mapTypeStreetsCaption(),
                      onPressed: () {
                        preferencesBloc.inChangeMapType.add(MapStyle.streets);
                      },
                      active: snapshot.data == MapStyle.streets || snapshot.data == "",
                    ),
                    if (cfg.map.satelliteMapTypeEnabled)
                    _buildMapTypeOptionButton(
                      context: context,
                      assetPath: "assets/images/maptype-satellite.png",
                      label: localization.mapTypeSatelliteCaption(),
                      onPressed: () {
                        preferencesBloc.inChangeMapType.add(MapStyle.satellite);
                      },
                      active: snapshot.data == MapStyle.satellite,
                    ),
                    if (cfg.map.terrainMapTypeEnabled)
                    _buildMapTypeOptionButton(
                      context: context,
                      assetPath: "assets/images/maptype-terrain.png",
                      label: localization.mapTypeTerrainCaption(),
                      onPressed: () {
                        preferencesBloc.inChangeMapType.add(MapStyle.terrain);
                      },
                      active: snapshot.data == MapStyle.terrain,
                    ),
                  ],
                );
              },
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildMapTypeOptionButton({
    @required BuildContext context,
    @required String assetPath,
    @required String label,
    VoidCallback onPressed,
    bool active = false,
  }) {
    final theme = Theme.of(context);
    return FlatButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(assetPath, width: 64, height: 64),
            ),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2.0, 
                color: active
                  ? theme.accentColor
                  : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(8.0)
            ),
          ),
          Container(
            padding: EdgeInsets.all(4.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: theme.textTheme.caption.fontSize,
                color: active
                  ? theme.accentColor
                  : theme.textTheme.body1.color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
