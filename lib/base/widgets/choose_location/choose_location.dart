import 'dart:async';
import 'package:async/async.dart' as async;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/map_configuration/marker_configurations/marker_configuration.dart';
import 'package:trufi_core/base/const/consts.dart';
import 'package:trufi_core/base/models/map_provider/trufi_map_definition.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/models/trufi_place.dart';
import 'package:trufi_core/base/pages/saved_places/search_locations_cubit/search_locations_cubit.dart';
import 'package:trufi_core/base/pages/saved_places/translations/saved_places_localizations.dart';
import 'package:trufi_core/base/translations/trufi_base_localizations.dart';
import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

typedef SelectLocationData = Future<LocationDetail?> Function(
  BuildContext context, {
  TrufiLatLng? position,
  bool? isOrigin,
});

class ChooseLocationPage extends StatefulWidget {
  static Future<LocationDetail?> selectPosition(
    BuildContext buildContext, {
    required MapChooseLocationProvider mapChooseLocationProvider,
    TrufiLatLng? position,
    bool? isOrigin,
  }) async {
    return await showTrufiDialog<LocationDetail?>(
      context: buildContext,
      builder: (BuildContext context) => ChooseLocationPage(
        position: position,
        isOrigin: isOrigin ?? false,
        mapChooseLocationProvider: mapChooseLocationProvider.rebuild(),
      ),
    );
  }

  const ChooseLocationPage({
    Key? key,
    required this.isOrigin,
    required this.mapChooseLocationProvider,
    this.position,
  }) : super(key: key);

  final TrufiLatLng? position;
  final MapChooseLocationProvider mapChooseLocationProvider;
  final bool isOrigin;

  @override
  State<ChooseLocationPage> createState() => _ChooseLocationPageState();
}

class _ChooseLocationPageState extends State<ChooseLocationPage>
    with TickerProviderStateMixin {
  TrufiLatLng? position;
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
      widget.mapChooseLocationProvider.trufiMapController.onReady.then(
        (value) => widget.mapChooseLocationProvider.trufiMapController.move(
          center: widget.position!,
          zoom: mapConfiguratiom.chooseLocationZoom,
          tickerProvider: this,
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((duration) {
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
                widget.mapChooseLocationProvider.mapChooseLocationBuilder(
                  context,
                  (center) {
                    setState(() {
                      position = center;
                    });
                    if (center != null) {
                      debounce(
                        () => loadData(center),
                      );
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
                if (loading)
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
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
                          if (position != null) {
                            Navigator.of(context).pop(
                              LocationDetail(
                                '',
                                '',
                                position!,
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
        ? Padding(
            padding: const EdgeInsets.all(6.0),
            child: markerConfiguration.fromMarker,
          )
        : markerConfiguration.toMarker;
  }

  async.CancelableOperation<LocationDetail>? cancelableOperation;

  Future<void> loadData(TrufiLatLng location) async {
    if (!mounted) return;

    await Future.delayed(Duration.zero);
    if (cancelableOperation != null && !cancelableOperation!.isCanceled) {
      await cancelableOperation!.cancel();
    }
    setState(() {
      fetchError = null;
      loading = true;
    });
    cancelableOperation = async.CancelableOperation.fromFuture(_fetchData(location));
    cancelableOperation?.valueOrCancellation().then((value) {
      if (mounted) {
        setState(() {
          locationData = value;
          loading = false;
        });
      }
    });
  }

  Future<LocationDetail> _fetchData(TrufiLatLng location) async {
    final searchLocationsCubit = context.read<SearchLocationsCubit>();
    return searchLocationsCubit.reverseGeodecoding(location).catchError(
      (error) {
        return LocationDetail("", "", location);
      },
    );
  }
}
