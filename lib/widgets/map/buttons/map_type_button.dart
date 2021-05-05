import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/custom_layer/custom_layers_cubit.dart';
import 'package:trufi_core/blocs/preferences_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/preferences.dart';
import 'package:trufi_core/trufi_configuration.dart';
import 'package:trufi_core/trufi_models.dart';

class MapTypeButton extends StatelessWidget {
  const MapTypeButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cfg = TrufiConfiguration();
    return (cfg.map.satelliteMapTypeEnabled || cfg.map.terrainMapTypeEnabled)
        ? FloatingActionButton(
            mini: true,
            backgroundColor: Theme.of(context).backgroundColor,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _BuildMapTypeBottomSheet(),
                backgroundColor: Theme.of(context).backgroundColor,
              );
            },
            heroTag: null,
            child: const Icon(Icons.layers, color: Colors.black),
          )
        : Container();
  }
}

class _MapItemsSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final customLayersCubit = context.watch<CustomLayersCubit>();
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: customLayersCubit.state.layers
            .map(
              (customLayer) => CheckboxListTile(
                title: Text(customLayer.id),
                subtitle: Text(customLayer.id),
                value: customLayersCubit.state.layersSatus[customLayer.id],
                onChanged: (bool value) {
                  customLayersCubit.changeCustomMapLayerState(
                    customLayer: customLayer,
                    newState: value,
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _BuildMapTypeBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cfg = TrufiConfiguration();
    final localization = TrufiLocalization.of(context);
    return SafeArea(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text("What should be shown on the map?",
                  style: theme.textTheme.bodyText1),
            ),
            _MapItemsSelector(),
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
                  _BuildMapTypeOptionButton(
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
                    _BuildMapTypeOptionButton(
                      assetPath: "assets/images/maptype-satellite.png",
                      label: localization.mapTypeSatelliteCaption,
                      onPressed: () {
                        BlocProvider.of<PreferencesCubit>(context)
                            .updateMapType(MapStyle.satellite);
                      },
                      active: state.currentMapType == MapStyle.satellite,
                    ),
                  if (cfg.map.terrainMapTypeEnabled)
                    _BuildMapTypeOptionButton(
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
    );
  }
}

class _BuildMapTypeOptionButton extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  const _BuildMapTypeOptionButton({
    Key key,
    this.assetPath,
    this.label,
    this.onPressed,
    this.active = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
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
