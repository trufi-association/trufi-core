import 'dart:async';
import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';

import 'package:trufi_core/base/const/consts.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/search_locations_cubit/search_locations_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/maps/markers/marker_configuration.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map.dart';
import 'package:trufi_core/base/widgets/maps/trufi_map_cubit/trufi_map_cubit.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

class ChooseLocationPage extends StatefulWidget {
  static Future<LocationDetail?> selectPosition(
    BuildContext context, {
    LatLng? position,
    bool? isOrigin,
  }) async {
    return await showTrufiDialog<LocationDetail?>(
      context: context,
      builder: (BuildContext context) => ChooseLocationPage(
        position: position,
        isOrigin: isOrigin ?? false,
      ),
    );
  }

  const ChooseLocationPage({
    Key? key,
    required this.isOrigin,
    this.position,
  }) : super(key: key);

  final LatLng? position;
  final bool isOrigin;

  @override
  ChooseLocationPageState createState() => ChooseLocationPageState();
}

class ChooseLocationPageState extends State<ChooseLocationPage>
    with TickerProviderStateMixin {
  final TrufiMapController trufiMapController = TrufiMapController();
  MapPosition? position;
  Widget? _chooseOnMapMarker;

  bool loading = true;
  String? fetchError;
  LocationDetail? locationData;

  @override
  void initState() {
    super.initState();
    final mapConfiguratiom = context.read<MapConfigurationCubit>().state;

    _chooseOnMapMarker = _selectedMarker(
      mapConfiguratiom.markersConfiguration,
    );
    if (widget.position != null) {
      trufiMapController.mapController.onReady.then(
        (value) => trufiMapController.move(
          center: widget.position!,
          zoom: mapConfiguratiom.chooseLocationZoom,
          tickerProvider: this,
        ),
      );
    }
    WidgetsBinding.instance?.addPostFrameCallback((duration) {
      loadData(widget.position ?? mapConfiguratiom.center);
    });
  }

  Timer? timer;

  void debounce(void Function() onExecute) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 200), () {
      timer?.cancel();
      timer == null;
      onExecute();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiBaseLocalization.of(context);
    final localizationSP = SavedPlacesLocalization.of(context);
    // final trufiConfiguration = context.read<ConfigurationCubit>().state;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              maxLines: 2,
              text: TextSpan(
                text: localization.chooseLocationPageTitle,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            RichText(
              maxLines: 2,
              text: TextSpan(
                text: localization.chooseLocationPageSubtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                TrufiMap(
                  trufiMapController: trufiMapController,
                  layerOptionsBuilder: (context) => [],
                  onPositionChanged: (mapPosition, hasGesture) {
                    setState(() {
                      position = mapPosition;
                    });
                    if (mapPosition.center != null) {
                      debounce(() => loadData(mapPosition.center!));
                    }
                  },
                ),
                Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: _chooseOnMapMarker,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  locationData != null
                      ? locationData!.description != ""
                          ? locationData!.description
                          : localization.commonUnkownPlace
                      : localization.commonLoading,
                  style: const TextStyle(fontSize: 17),
                ),
                Text(
                  locationData?.street ?? "",
                  style: TextStyle(color: hintTextColor(theme)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (loading)
                      OutlinedButton(
                        onPressed: () async {
                          if (position?.center != null) {
                            Navigator.of(context).pop(
                              LocationDetail(
                                '',
                                '',
                                position!.center!,
                              ),
                            );
                          }
                        },
                        child: SizedBox(
                          width: 140,
                          child: Text(
                            localizationSP.chooseNowLabel,
                            style:
                                TextStyle(color: theme.colorScheme.secondary),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      )
                    else
                      OutlinedButton(
                        onPressed: () async {
                          if (locationData != null) {
                            Navigator.of(context).pop(locationData);
                          }
                        },
                        child: SizedBox(
                          width: 140,
                          child: Text(
                            localization.commonConfirmLocation,
                            style: TextStyle(
                                color: locationData != null
                                    ? theme.colorScheme.secondary
                                    : Colors.grey),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _selectedMarker(
    MarkerConfiguration markerConfiguration,
  ) {
    return widget.isOrigin
        ? markerConfiguration.fromMarker
        : markerConfiguration.toMarker;
  }

  CancelableOperation<LocationDetail>? cancelableOperation;

  Future<void> loadData(LatLng location) async {
    if (!mounted) return;

    await Future.delayed(Duration.zero);
    if (cancelableOperation != null && !cancelableOperation!.isCanceled) {
      await cancelableOperation!.cancel();
    }
    setState(() {
      fetchError = null;
      loading = true;
    });
    cancelableOperation = CancelableOperation.fromFuture(_fetchData(location));
    cancelableOperation?.valueOrCancellation().then((value) {
      if (mounted) {
        setState(() {
          locationData = value;
          loading = false;
        });
      }
    });
  }

  Future<LocationDetail> _fetchData(LatLng location) async {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    return searchLocationsCubit.reverseGeodecoding(location).catchError(
      (error) {
        return LocationDetail("", "", location);
      },
    );
  }
}
