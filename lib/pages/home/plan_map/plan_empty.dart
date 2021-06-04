import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';

import 'package:trufi_core/blocs/home_page_cubit.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/trufi_place.dart';
import 'package:trufi_core/trufi_app.dart';
import 'package:trufi_core/widgets/map/buttons/map_type_button.dart';
import 'package:trufi_core/widgets/map/buttons/your_location_button.dart';
import 'package:trufi_core/widgets/map/trufi_map.dart';
import 'package:trufi_core/widgets/map/trufi_map_controller.dart';

const double customOverlayWidgetMargin = 80;

class PlanEmptyPage extends StatefulWidget {
  const PlanEmptyPage({
    Key key,
    @required this.onFetchPlan,
    this.initialPosition,
    this.customOverlayWidget,
    this.customBetweenFabWidget,
  }) : super(key: key);

  final LatLng initialPosition;
  final LocaleWidgetBuilder customOverlayWidget;
  final WidgetBuilder customBetweenFabWidget;
  final void Function() onFetchPlan;

  @override
  PlanEmptyPageState createState() => PlanEmptyPageState();
}

class PlanEmptyPageState extends State<PlanEmptyPage>
    with TickerProviderStateMixin {
  final _trufiMapController = TrufiMapController();

  @override
  Widget build(BuildContext context) {
    _trufiMapController.mapController.onReady.then((value) {
      final cfg = context.read<ConfigurationCubit>().state;
      final mapRouteState = context.read<HomePageCubit>().state;
      final chooseZoom = cfg.map.chooseLocationZoom;
      if (mapRouteState.toPlace != null) {
        _trufiMapController.mapController
            .move(mapRouteState.toPlace.latLng, chooseZoom);
      } else if (mapRouteState.fromPlace != null) {
        _trufiMapController.mapController
            .move(mapRouteState.fromPlace.latLng, chooseZoom);
      } else {
        _trufiMapController.mapController
            .move(cfg.map.center, cfg.map.defaultZoom);
      }
      _trufiMapController.inMapReady.add(null);
    });

    final Locale locale = Localizations.localeOf(context);
    final trufiConfiguration = context.read<ConfigurationCubit>().state;
    final homePageCubit = context.read<HomePageCubit>();
    return Stack(
      children: <Widget>[
        TrufiMap(
          key: const ValueKey("PlanEmptyMap"),
          controller: _trufiMapController,
          layerOptionsBuilder: (context) => [
            MarkerLayerOptions(markers: [
              if (homePageCubit.state.fromPlace != null)
                trufiConfiguration.markers
                    .buildFromMarker(homePageCubit.state.fromPlace.latLng),
              if (homePageCubit.state.toPlace != null)
                trufiConfiguration.markers
                    .buildToMarker(homePageCubit.state.toPlace.latLng),
            ]),
          ],
          onTap: (location) => _showBottomMarkerModal(
            context: context,
            location: location,
          ),
          onLongPress: (location) => _showBottomMarkerModal(
            context: context,
            location: location,
          ),
        ),
        const Positioned(
          top: 16.0,
          right: 16.0,
          child: MapTypeButton(),
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: YourLocationButton(
            trufiMapController: _trufiMapController,
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(
              right: customOverlayWidgetMargin,
              bottom: 60,
            ),
            child: widget.customOverlayWidget != null
                ? widget.customOverlayWidget(context, locale)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 10,
          child: SafeArea(
            child: trufiConfiguration.map.mapAttributionBuilder(context),
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: EdgeInsets.only(
              left:
                  MediaQuery.of(context).size.width - customOverlayWidgetMargin,
              bottom: 80,
              top: 65,
            ),
            child: widget.customBetweenFabWidget != null
                ? widget.customBetweenFabWidget(context)
                : null,
          ),
        )
      ],
    );
  }

  void _showBottomMarkerModal({
    BuildContext context,
    LatLng location,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (buildContext) => _LoadLocation(
        location: location,
        onFetchPlan: widget.onFetchPlan,
      ),
    );
  }
}

class _LoadLocation extends StatefulWidget {
  final LatLng location;
  final void Function() onFetchPlan;
  const _LoadLocation(
      {Key key, @required this.location, @required this.onFetchPlan})
      : super(key: key);
  @override
  __LoadLocationState createState() => __LoadLocationState();
}

class __LoadLocationState extends State<_LoadLocation> {
  bool loading = true;
  String fetchError;
  LocationDetail locationData;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final textStyle = theme.textTheme.bodyText1.copyWith(fontSize: 17);
    final hintStyle = theme.textTheme.bodyText2.copyWith(
      color: theme.textTheme.caption.color,
    );
    final homePageCubit = context.read<HomePageCubit>();
    return Card(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (loading)
                LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                )
              else if (locationData != null) ...[
                Text(
                  locationData.description,
                  style: textStyle,
                ),
                Text(
                  locationData.street,
                  style: hintStyle,
                ),
                const SizedBox(height: 20),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await homePageCubit.setFromPlace(
                            TrufiLocation(
                              description: locationData.description,
                              address: locationData.street,
                              latitude: widget.location.latitude,
                              longitude: widget.location.longitude,
                            ),
                          );
                          widget.onFetchPlan();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          localization.commonOrigin,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await homePageCubit.setToPlace(
                            TrufiLocation(
                              description: locationData.description,
                              address: locationData.street,
                              latitude: widget.location.latitude,
                              longitude: widget.location.longitude,
                            ),
                          );
                          widget.onFetchPlan();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          localization.commonDestination,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ] else
                Text(
                  fetchError,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadData() async {
    if (!mounted) return;
    setState(() {
      fetchError = null;
      loading = true;
    });
    await _fetchData().then((value) {
      if (mounted) {
        setState(() {
          locationData = value;
          loading = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          fetchError = "$error";
          loading = false;
        });
      }
    });
  }

  Future<LocationDetail> _fetchData() async {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    return searchLocationsCubit.reverseGeodecoding(widget.location).catchError(
      (error) {
        return LocationDetail("unknown place", "");
      },
    );
  }
}

class LocationDetail {
  final String description;
  final String street;

  LocationDetail(this.description, this.street);
}
