import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:trufi_core/base/blocs/map_layer/map_layer.dart';
import 'package:trufi_core/base/blocs/map_layer/map_layers_cubit.dart';

import 'package:trufi_core/base/blocs/map_tile_provider/map_tile_provider_cubit.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class MapTypeButton extends StatelessWidget {
  const MapTypeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BaseTrufiPage(
              child: _MapOptionsPage(
                child: _BuildMapTypeBottomSheet(),
              ),
            ),
          ),
        );
      },
      heroTag: null,
      child: const Icon(Icons.layers),
    );
  }
}

class _MapItemsSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            localization.commonShowMap,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView(
              children: const [_CustomExpansionPanel()],
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomExpansionPanel extends StatefulWidget {
  const _CustomExpansionPanel({Key? key}) : super(key: key);

  @override
  __CustomExpansionPanelState createState() => __CustomExpansionPanelState();
}

class __CustomExpansionPanelState extends State<_CustomExpansionPanel> {
  Set<MapLayerContainer> customLayersState = {};
  @override
  Widget build(BuildContext context) {
    final customLayersCubit = context.watch<MapLayersCubit>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            final target = customLayersCubit.layersContainer.toList()[index];
            if (customLayersState.contains(target)) {
              setState(() {
                customLayersState.remove(target);
              });
            } else {
              setState(() {
                customLayersState.add(target);
              });
            }
          });
        },
        children: customLayersCubit.layersContainer.map((element) {
          final containerStatus =
              element.checkStatus(customLayersCubit.state.layersSatus);
          return ExpansionPanel(
              canTapOnHeader: true,
              headerBuilder: (_, __) {
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        customLayersCubit.changeCustomMapLayerContainerState(
                          customLayer: element,
                          // ignore: avoid_bool_literals_in_conditional_expressions
                          newState: true,
                        );
                      },
                      child: (containerStatus == null)
                          ? SizedBox(
                              height: 48,
                              width: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: const [
                                  Icon(Icons.crop_square),
                                  Icon(
                                    Icons.remove,
                                    size: 15,
                                  )
                                ],
                              ),
                            )
                          : Checkbox(
                              value: containerStatus,
                              fillColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.selected)) {
                                  return theme.colorScheme.secondary;
                                } else {
                                  return isDarkMode
                                      ? Colors.white
                                      : Colors.black;
                                }
                              }),
                              onChanged: (value) {
                                customLayersCubit
                                    .changeCustomMapLayerContainerState(
                                  customLayer: element,
                                  newState: value ?? false,
                                );
                              },
                            ),
                    ),
                    Container(
                      width: 25,
                      height: 25,
                      margin: const EdgeInsets.only(right: 10),
                      child: element.icon(context),
                    ),
                    Expanded(
                      child: Text(
                        element.name(context),
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                );
              },
              isExpanded: customLayersState.contains(element),
              body: Container(
                color: Colors.grey.withOpacity(.1),
                child: Column(
                  children: element.layers
                      .map(
                        (customLayer) => Row(
                          children: [
                            Checkbox(
                              value: customLayersCubit
                                  .state.layersSatus[customLayer.id],
                              fillColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.selected)) {
                                  return theme.colorScheme.secondary;
                                } else {
                                  return isDarkMode
                                      ? Colors.grey[200]
                                      : Colors.grey;
                                }
                              }),
                              onChanged: (value) {
                                customLayersCubit.changeCustomMapLayerState(
                                  customLayer: customLayer,
                                  newState: value ?? false,
                                );
                              },
                            ),
                            Container(
                              width: 25,
                              height: 25,
                              margin: const EdgeInsets.only(right: 10),
                              child: customLayer.icon(context),
                            ),
                            Expanded(
                              child: Text(
                                customLayer.name(context),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ));
        }).toList(),
      ),
    );
  }
}

class _MapOptionsPage extends StatefulWidget {
  final Widget child;

  const _MapOptionsPage({
    super.key,
    required this.child,
  });

  @override
  State<_MapOptionsPage> createState() => _MapOptionsPageState();
}

class _MapOptionsPageState extends State<_MapOptionsPage> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor, context: context);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!stopDefaultButtonEvent) {
      Navigator.of(context).pop();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final localization = TrufiBaseLocalization.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(localization.commonMapSettings),
        ),
        body: widget.child);
  }
}

class _BuildMapTypeBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    final mapTileProviderCubit = context.watch<MapTileProviderCubit>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: _MapItemsSelector()),
          if (mapTileProviderCubit.mapTileProviders.length > 1)
            Card(
              margin: const EdgeInsets.all(0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      localization.mapTypeLabel,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: mapTileProviderCubit.mapTileProviders
                          .map(
                            (mapTileProvider) => _BuildMapTypeOptionButton(
                              image: mapTileProvider.imageBuilder(context),
                              label: mapTileProvider.name(context),
                              onPressed: () {
                                mapTileProviderCubit
                                    .changeMapTileProvider(mapTileProvider);
                              },
                              active: mapTileProviderCubit
                                      .state.currentMapTileProvider ==
                                  mapTileProvider,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BuildMapTypeOptionButton extends StatelessWidget {
  final Widget image;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  const _BuildMapTypeOptionButton({
    super.key,
    required this.image,
    required this.label,
    required this.onPressed,
    this.active = false,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
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
                    color: active
                        ? theme.colorScheme.secondary
                        : Colors.transparent,
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
                    fontSize: theme.textTheme.bodySmall?.fontSize,
                    color: active
                        ? theme.colorScheme.secondary
                        : (isDarkMode ? Colors.grey[400] : Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
