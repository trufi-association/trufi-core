import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/preferences.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/trufi_models.dart';

class MapTypeButton extends StatelessWidget {
  const MapTypeButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Theme.of(context).backgroundColor,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => _buildMapTypeBottomSheet(context),
          backgroundColor: Theme.of(context).backgroundColor,
        );
      },
      heroTag: null,
      child: const Icon(Icons.layers, color: Colors.black),
    );
  }

  Widget _buildMapTypeBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final cfg = TrufiConfiguration();
    final localization = TrufiLocalization.of(context);
    return SafeArea(
      child: SizedBox(
        height: 140,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Text(localization.mapTypeLabel,
                    style: theme.textTheme.bodyText1),
              ),
              BlocBuilder<PreferencesCubit, Preference>(
                bloc: BlocProvider.of<PreferencesCubit>(context),
                builder: (context, state) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildMapTypeOptionButton(
                      context: context,
                      assetPath: "assets/images/maptype-streets.png",
                      label: localization.mapTypeStreetsCaption,
                      onPressed: () {
                        BlocProvider.of<PreferencesCubit>(context)
                            .updateMapType(MapStyle.streets);
                      },
                      active: state.currentMapType == MapStyle.streets ||
                          state.currentMapType == "",
                    ),
                    if (cfg.map.satelliteMapTypeEnabled)
                      _buildMapTypeOptionButton(
                        context: context,
                        assetPath: "assets/images/maptype-satellite.png",
                        label: localization.mapTypeSatelliteCaption,
                        onPressed: () {
                          BlocProvider.of<PreferencesCubit>(context)
                              .updateMapType(MapStyle.satellite);
                        },
                        active: state.currentMapType == MapStyle.satellite,
                      ),
                    if (cfg.map.terrainMapTypeEnabled)
                      _buildMapTypeOptionButton(
                        context: context,
                        assetPath: "assets/images/maptype-terrain.png",
                        label: localization.mapTypeTerrainCaption,
                        onPressed: () {
                          BlocProvider.of<PreferencesCubit>(context)
                              .updateMapType(MapStyle.terrain);
                        },
                        active: state.currentMapType == MapStyle.terrain,
                      ),
                  ],
                ),
              ),
            ]),
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
    // TODO: Fix with TextButton and ButtonStyle
    // ignore: deprecated_member_use
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
            decoration: BoxDecoration(
                border: Border.all(
                  width: 2.0,
                  color: active ? theme.accentColor : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(8.0)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(assetPath, width: 64, height: 64),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: theme.textTheme.caption.fontSize,
                  color: active
                      ? theme.accentColor
                      : theme.textTheme.bodyText2.color),
            ),
          ),
        ],
      ),
    );
  }
}
