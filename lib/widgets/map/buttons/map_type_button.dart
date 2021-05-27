import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trufi_core/blocs/custom_layer/custom_layers_cubit.dart';
import 'package:trufi_core/blocs/map_tile_provider/map_tile_provider_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

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
          builder: (context) => _BuildMapTypeBottomSheet(),
          backgroundColor: Theme.of(context).backgroundColor,
        );
      },
      heroTag: null,
      child: const Icon(Icons.layers, color: Colors.black),
    );
  }
}

class _MapItemsSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final customLayersCubit = context.watch<CustomLayersCubit>();
    return Container(
      child: (customLayersCubit.state.layers.isNotEmpty)
          ? Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        localization.commonShowMap,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyText1,
                      ),
                    ),
                    ...customLayersCubit.state.layers
                        .map(
                          (customLayer) => CheckboxListTile(
                            title: Text(
                              customLayer.id,
                              style: const TextStyle(color: Colors.black),
                            ),
                            value: customLayersCubit
                                .state.layersSatus[customLayer.id],
                            onChanged: (bool value) {
                              customLayersCubit.changeCustomMapLayerState(
                                customLayer: customLayer,
                                newState: value,
                              );
                            },
                          ),
                        )
                        .toList()
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _BuildMapTypeBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final mapTileProviderCubit = context.watch<MapTileProviderCubit>();
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        _MapItemsSelector(),
        Container(
          padding: const EdgeInsets.all(16.0),
          child:
              Text(localization.mapTypeLabel, style: theme.textTheme.bodyText1),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: mapTileProviderCubit.mapTileProviders
                .map(
                  (mapTileProvider) => _BuildMapTypeOptionButton(
                    image: mapTileProvider.imageBuilder(context),
                    label: mapTileProvider.id,
                    onPressed: () {
                      mapTileProviderCubit
                          .changeMapTileProvider(mapTileProvider);
                    },
                    active: mapTileProviderCubit.state.currentMapTileProvider ==
                        mapTileProvider,
                  ),
                )
                .toList(),
          ),
        ),
      ]),
    );
  }
}

class _BuildMapTypeOptionButton extends StatelessWidget {
  final Widget image;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  const _BuildMapTypeOptionButton({
    Key key,
    this.image,
    this.label,
    this.onPressed,
    this.active = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                child: image,
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
      ),
    );
  }
}
