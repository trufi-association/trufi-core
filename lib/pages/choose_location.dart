import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/blocs/configuration/configuration_cubit.dart';
import 'package:trufi_core/blocs/search_locations/search_locations_cubit.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/markers/marker_configuration.dart';
import 'package:trufi_core/widgets/custom_location_selector.dart';
import 'package:trufi_core/widgets/map/buttons/your_location_button.dart';
import 'package:trufi_core/widgets/map/trufi_map_controller.dart';
import 'package:async/async.dart';
import '../widgets/map/trufi_map.dart';

class ChooseLocationPage extends StatefulWidget {
  static Future<ChooseLocationDetail> selectPosition(BuildContext context,
      {LatLng position, bool isOrigin}) {
    return Navigator.of(context).push(
      MaterialPageRoute<ChooseLocationDetail>(
        builder: (BuildContext context) => ChooseLocationPage(
          position: position,
          isOrigin: isOrigin ?? false,
        ),
      ),
    );
  }

  const ChooseLocationPage({
    Key key,
    @required this.isOrigin,
    this.position,
  })  : assert(isOrigin != null),
        super(key: key);

  final LatLng position;
  final bool isOrigin;

  @override
  ChooseLocationPageState createState() => ChooseLocationPageState();
}

class ChooseLocationPageState extends State<ChooseLocationPage> {
  final _trufiMapController = TrufiMapController();
  MapPosition position;
  Widget _chooseOnMapMarker;

  bool loading = true;
  String fetchError;
  ChooseLocationDetail locationData;
  @override
  void initState() {
    super.initState();
    final cfg = context.read<ConfigurationCubit>().state;
    final markersConfiguration = cfg.map.markersConfiguration;
    _chooseOnMapMarker = _selectedMarker(cfg.map.center, markersConfiguration);
    if (widget.position != null) {
      _trufiMapController.mapController.onReady.then(
        (value) => _trufiMapController.move(
          center: widget.position,
          zoom: cfg.map.chooseLocationZoom,
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      loadData(widget.position ?? cfg.map.center);
    });
  }

  @override
  void dispose() {
    _trufiMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final trufiConfiguration = context.read<ConfigurationCubit>().state;
    final textStyle = theme.textTheme.bodyText1.copyWith(fontSize: 17);
    final hintStyle = theme.textTheme.bodyText2.copyWith(
      color: theme.textTheme.caption.color,
    );
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              maxLines: 2,
              text: TextSpan(
                text: localization.chooseLocationPageTitle,
                style: theme.primaryTextTheme.bodyText2,
              ),
            ),
            RichText(
              maxLines: 2,
              text: TextSpan(
                text: localization.chooseLocationPageSubtitle,
                style: theme.primaryTextTheme.caption,
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
                  showCustomMarkes: false,
                  controller: _trufiMapController,
                  onPositionChanged: (mapPosition, hasGesture) {
                    setState(() {
                      position = mapPosition;
                    });
                    loadData(position.center);
                  },
                  layerOptionsBuilder: (context) {
                    return <LayerOptions>[];
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
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: YourLocationButton(
                    trufiMapController: _trufiMapController,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: trufiConfiguration.map.mapAttributionBuilder(context),
                ),
              ],
            ),
          ),
          if (loading)
            LinearProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    locationData != null
                        ? locationData.description != ""
                            ? locationData.description
                            : localization.commonUnkownPlace
                        : localization.commonLoading,
                    style: textStyle,
                  ),
                  Text(
                    locationData?.street ?? "",
                    style: hintStyle,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(ChooseLocationDetail(
                            LocationDetail(
                              'Unknow',
                              '',
                              position.center,
                            ),
                            position.center,
                          ));
                        },
                        child: SizedBox(
                          width: 140,
                          child: Text(
                            // TODO translate
                            localization.localeName == 'en'
                                ? "Choose now"
                                : "Jetzt auswählen",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _selectedMarker(
    LatLng location,
    MarkerConfiguration markerConfiguration,
  ) {
    return widget.isOrigin
        ? markerConfiguration.fromMarker
        : markerConfiguration.toMarker;
  }

  CancelableOperation<LocationDetail> cancelableOperation;
  Future<void> loadData(LatLng location) async {
    if (!mounted) return;

    await Future.delayed(Duration.zero);
    if (cancelableOperation != null && !cancelableOperation.isCanceled) {
      await cancelableOperation.cancel();
    }
    setState(() {
      fetchError = null;
      loading = true;
    });
    cancelableOperation = CancelableOperation.fromFuture(_fetchData(location));
    cancelableOperation.valueOrCancellation().then((value) {
      if (mounted) {
        setState(() {
          locationData =
              value != null ? ChooseLocationDetail(value, location) : null;
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

class ChooseLocationDetail extends LocationDetail {
  final LatLng location;
  ChooseLocationDetail(
    LocationDetail locationDetail,
    this.location,
  ) : super(
          locationDetail.description,
          locationDetail.street,
          location,
        );
}
