import 'dart:async';
import 'package:async/async.dart' as async;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trufi_core/consts.dart';

import 'package:trufi_core/repositories/location/location_repository.dart';
import 'package:trufi_core/screens/route_navigation/maps/maplibre_gl.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/widgets/base_marker/to_marker.dart';

class ChooseLocationPage extends StatefulWidget {
  static Future<TrufiLocation?> selectLocation(
    BuildContext buildContext, {
    LatLng? position,
    bool? isOrigin,
    bool? hideLocationDetails,
  }) async {
    return await showDialog<TrufiLocation?>(
      context: buildContext,
      useSafeArea: false,
      builder: (BuildContext context) => ChooseLocationPage(
        position: position,
        isOrigin: isOrigin ?? false,
        hideLocationDetails: hideLocationDetails ?? false,
      ),
    );
  }

  const ChooseLocationPage({
    super.key,
    required this.isOrigin,
    required this.position,
    required this.hideLocationDetails,
  });

  final LatLng? position;
  final bool isOrigin;
  final bool hideLocationDetails;

  @override
  State<ChooseLocationPage> createState() => _ChooseLocationPageState();
}

class _ChooseLocationPageState extends State<ChooseLocationPage>
    with TickerProviderStateMixin {
  // --- External dependencies ---
  final locationRepository = LocationRepository();
  late final TrufiMapController mapController;

  // --- Map and routing ---
  async.CancelableOperation<TrufiLocation>? cancelableOperation;
  LatLng? position;

  // --- State ---
  bool loading = true;
  String? fetchError;
  TrufiLocation? locationData;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    mapController = TrufiMapController(
      initialCameraPosition: TrufiCameraPosition(
        target: widget.position ?? ApiConfig().originMap,
        zoom: 15,
        bearing: 0,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      // TODO replace static position with center city
      _loadData(widget.position ?? ApiConfig().originMap);
      mapController.cameraPositionNotifier.addListener(
        _onCameraChangedDebounced,
      );
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Choose Location On Map',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Pan and zoom to adjust',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                TrufiMapLibreMap(
                  controller: mapController,
                  styleString: 'https://tiles.openfreemap.org/styles/liberty',
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: ToMarker(height: 40),
                    ),
                  ),
                ),
                if (loading && !widget.hideLocationDetails)
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
            padding: EdgeInsets.all(widget.hideLocationDetails ? 0 : 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!widget.hideLocationDetails) ...[
                  Text(
                    locationData != null
                        ? locationData!.description != ""
                              ? locationData!.description
                              : "Unkown Place"
                        : "Loading",
                    style: theme.textTheme.bodyLarge?.copyWith(),
                  ),
                  Text(
                    locationData?.address ?? "",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (!mounted) return;
                      if (locationData != null) {
                        Navigator.of(context).pop(locationData);
                      } else if (position != null) {
                        Navigator.of(context).pop(
                          TrufiLocation(
                            description: '',
                            position: position!,
                            type: TrufiLocationType.selectedOnMap,
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: widget.hideLocationDetails ? 12 : 8,
                      ),
                      child: Text(
                        (locationData != null || widget.hideLocationDetails)
                            ? 'Ok'
                            : 'Choose Now',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onCameraChangedDebounced() {
    _debounce(() {
      if (!mounted) return;
      final center = mapController.cameraPositionNotifier.value.target;
      if (center != position) {
        position = center;
        _loadData(center);
      }
    });
  }

  void _debounce(void Function() onExecute) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 200), () {
      timer?.cancel();
      timer == null;
      onExecute();
    });
  }

  Future<void> _loadData(LatLng location) async {
    if (widget.hideLocationDetails) return;
    if (!mounted) return;

    await Future.delayed(Duration.zero);
    if (cancelableOperation != null && !cancelableOperation!.isCanceled) {
      await cancelableOperation!.cancel();
    }
    setState(() {
      fetchError = null;
      loading = true;
      locationData = null;
    });
    cancelableOperation = async.CancelableOperation.fromFuture(
      _fetchData(location),
    );
    cancelableOperation?.valueOrCancellation().then((value) {
      if (mounted) {
        setState(() {
          locationData = value;
          loading = false;
        });
      }
    });
  }

  Future<TrufiLocation> _fetchData(LatLng location) async {
    return locationRepository.reverseGeodecoding(location).catchError((error) {
      return TrufiLocation(
        description: '',
        position: location,
        type: TrufiLocationType.selectedOnMap,
      );
    });
  }
}
