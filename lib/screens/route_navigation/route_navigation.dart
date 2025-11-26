import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/consts.dart';
import 'package:trufi_core/pages/home/service/i_plan_repository.dart';
import 'package:trufi_core/pages/home/widgets/routing_map/routing_map_controller.dart';
import 'package:trufi_core/pages/home/widgets/search_bar/location_search_bar.dart';
import 'package:trufi_core/pages/home/widgets/travel_bottom_sheet/travel_bottom_sheet.dart';
import 'package:trufi_core/repositories/services/gps_lcoation/gps_location.dart';
import 'package:trufi_core/screens/route_navigation/map_layers/fit_camera_layer.dart';
import 'package:trufi_core/screens/route_navigation/maps/flutter_map.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';
import 'package:trufi_core/screens/route_navigation/maps/maplibre_gl.dart';
import 'package:trufi_core/screens/route_navigation/widgets/map_type_button.dart';
import 'package:trufi_core/widgets/app_lifecycle_reactor.dart';
import 'package:trufi_core/widgets/bottom_sheet/trufi_bottom_sheet.dart';
import 'package:trufi_core/widgets/bottom_sheet/location_selector_bottom_sheet.dart';

class RouteNavigationScreen extends StatefulWidget {
  const RouteNavigationScreen({
    super.key,
    this.mapBuilder = defaultMapBuilder,
    this.mapLayerBuilder = defaultMapLayerBuilder,
    this.routingMapComponent = defaultRoutingMapComponent,
    this.fitCameraLayer = defaultFitCameraLayer,
    this.routeSearchBuilder = defaultRouteSearchBuilder,
  });

  final List<TrufiMapRender> Function(
    TrufiMapController controller,
    void Function(latlng.LatLng)? onMapClick,
    void Function(latlng.LatLng)? onMapLongClick,
  )
  mapBuilder;

  final List<TrufiLayer> Function(TrufiMapController controller)
  mapLayerBuilder;

  final RouteSearchBuilder routeSearchBuilder;

  final IRoutingMapComponent Function(
    TrufiMapController controller,
    IPlanRepository? planRepository,
  )
  routingMapComponent;
  final IFitCameraLayer Function(TrufiMapController controller) fitCameraLayer;

  static List<TrufiMapRender> defaultMapBuilder(
    TrufiMapController controller,
    void Function(latlng.LatLng)? onMapClick,
    void Function(latlng.LatLng)? onMapLongClick,
  ) {
    return [
      TrufiMapLibreMap(
        controller: controller,
        onMapClick: onMapClick,
        onMapLongClick: onMapLongClick,
        styleString: 'https://tiles.openfreemap.org/styles/liberty',
      ),
      TrufiFlutterMap(
        controller: controller,
        tileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        onMapClick: onMapClick,
        onMapLongClick: onMapLongClick,
      ),
    ];
  }

  static List<TrufiLayer> defaultMapLayerBuilder(
    TrufiMapController controller,
  ) {
    return [];
  }

  static IRoutingMapComponent defaultRoutingMapComponent(
    TrufiMapController controller,
    IPlanRepository? customPlanRepository,
  ) {
    return RoutingMapComponent(
      controller,
      customPlanRepository: customPlanRepository,
    );
  }

  static Widget defaultRouteSearchBuilder({
    required void Function(TrufiLocation) onSaveFrom,
    required void Function() onClearFrom,
    required void Function(TrufiLocation) onSaveTo,
    required void Function() onClearTo,
    required void Function() onFetchPlan,
    required void Function() onReset,
    required void Function() onSwap,
    required TrufiLocation? origin,
    required TrufiLocation? destination,
  }) {
    return RouteSearchComponent(
      onSaveFrom: onSaveFrom,
      onClearFrom: onClearFrom,
      onSaveTo: onSaveTo,
      onClearTo: onClearTo,
      onFetchPlan: onFetchPlan,
      onReset: onReset,
      onSwap: onSwap,
      origin: origin,
      destination: destination,
    );
  }

  static IFitCameraLayer defaultFitCameraLayer(TrufiMapController controller) {
    return FitCameraLayer(
      controller,
      padding: const EdgeInsets.only(
        bottom: 200,
        right: 30,
        left: 30,
        top: 100,
      ),
      // debugFlag: true,
    );
  }

  @override
  State<RouteNavigationScreen> createState() => _RouteNavigationScreenState();
}

class _RouteNavigationScreenState extends State<RouteNavigationScreen> {
  int showMapIndex = 0;

  final mapController = TrufiMapController(
    initialCameraPosition: TrufiCameraPosition(
      target: ApiConfig().originMap,
      zoom: 12,
      bearing: 0,
    ),
  );

  late final IRoutingMapComponent routingMapComponent;
  late final IFitCameraLayer fitCameraLayer;
  TrufiMarker? selectedMarker;
  late List<TrufiLayer> mapLayerRenders;
  late List<TrufiMapRender> mapRenders;

  @override
  void initState() {
    super.initState();

    mapRenders = widget.mapBuilder(
      mapController,
      (mapLatLng) {
        final nearest = mapController.pickNearestMarkerAt(
          mapLatLng,
          hitboxPx: 24.0,
        );
        setState(() {
          selectedMarker = nearest;
        });
      },
      (coord) async {
        // Show bottom sheet with options to set as origin or destination
        await LocationSelectorBottomSheet.show(
          context,
          selectedLocation: coord,
          onSetAsOrigin: () async {
            await routingMapComponent.addOrigin(
              TrufiLocation(
                description: '',
                position: coord,
                type: TrufiLocationType.selectedOnMap,
              ),
            );
            await _fetchPlanWithLoading();
          },
          onSetAsDestination: () async {
            await routingMapComponent.addDestination(
              TrufiLocation(
                description: '',
                position: coord,
                type: TrufiLocationType.selectedOnMap,
              ),
            );
            // Auto-set origin to current location if not set
            if (routingMapComponent.origin == null) {
              final currentLocation = GPSLocationProvider().current;
              if (currentLocation != null) {
                await routingMapComponent.addOrigin(
                  TrufiLocation(
                    description: 'Your Location',
                    position: currentLocation,
                  ),
                );
              }
            }
            await _fetchPlanWithLoading();
          },
        );
      },
    );

    mapLayerRenders = widget.mapLayerBuilder(mapController);
    routingMapComponent = widget.routingMapComponent(mapController, null);
    fitCameraLayer = widget.fitCameraLayer(mapController);
  }

  @override
  void dispose() {
    mapController.dispose();
    routingMapComponent.dispose();
    fitCameraLayer.dispose();
    for (var layer in mapLayerRenders) {
      layer.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchPlanWithLoading() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingDialog(message: 'Calculating route...'),
    );

    try {
      await routingMapComponent.fetchPlan(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch route: $e')));
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLifecycleReactor(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logicalSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            final viewPadding = MediaQuery.of(context).viewPadding;
            fitCameraLayer.updateViewport(logicalSize, viewPadding);
            return Stack(
              children: [
                mapRenders[showMapIndex],
                ValueListenableBuilder(
                  valueListenable: mapController.layersNotifier,
                  builder: (context, value, child) {
                    final selectedItinerary =
                        routingMapComponent.selectedItinerary;
                    final plan = routingMapComponent.plan;
                    final origin = routingMapComponent.origin;
                    final destination = routingMapComponent.destination;
                    return Stack(
                      children: [
                        widget.routeSearchBuilder(
                          onSaveFrom: (location) async {
                            await routingMapComponent.addOrigin(location);

                            await _fetchPlanWithLoading();
                          },
                          onClearFrom: () {},
                          onSaveTo: (location) async {
                            await routingMapComponent.addDestination(location);
                            if (routingMapComponent.origin == null) {
                              final currentLocation =
                                  GPSLocationProvider().current;
                              if (currentLocation != null) {
                                await routingMapComponent.addOrigin(
                                  TrufiLocation(
                                    description: 'Your Location',
                                    position: currentLocation,
                                  ),
                                );
                              }
                            }

                            await _fetchPlanWithLoading();
                          },
                          onClearTo: () async {
                            routingMapComponent.cleanOriginAndDestination();
                            await _fetchPlanWithLoading();
                          },
                          onFetchPlan: () {},
                          onReset: () {},
                          onSwap: () async {
                            if (routingMapComponent.destination != null &&
                                routingMapComponent.origin != null) {
                              final temp = routingMapComponent.origin;
                              await routingMapComponent.addOrigin(
                                routingMapComponent.destination!,
                              );
                              await routingMapComponent.addDestination(temp!);
                              await _fetchPlanWithLoading();
                            }
                          },
                          origin: origin,
                          destination: destination,
                        ),
                        if (plan != null)
                          TrufiBottomSheet(
                            onHeightChanged: (height) {
                              final currentHeight = constraints.maxHeight / 2;
                              fitCameraLayer.updatePadding(
                                EdgeInsets.only(
                                  bottom: math.min(currentHeight, height),
                                  right: 30,
                                  left: 30,
                                  top: 100,
                                ),
                              );
                            },
                            child: TransitBottomSheet(
                              plan: plan,
                              selectedItinerary: selectedItinerary,
                              updateCamera:
                                  ({bearing, target, visibleRegion, zoom}) {
                                    return routingMapComponent.controller
                                        .updateCamera(target: target, zoom: 18);
                                  },
                              onClose: () {
                                routingMapComponent.cleanOriginAndDestination();
                              },
                              onSelectItinerary: (itinerary) {
                                if (itinerary != null) {
                                  routingMapComponent.changeItinerary(
                                    itinerary,
                                  );
                                  final points = itinerary.legs
                                      .expand((leg) => leg.accumulatedPoints)
                                      .toList();
                                  fitCameraLayer.fitBoundsOnCamera(points);
                                } else {
                                  routingMapComponent.changeItinerary(null);
                                  fitCameraLayer.fitBoundsOnCamera([]);
                                }
                              },
                            ),
                          )
                        else if (selectedMarker?.buildPanel != null)
                          TrufiBottomSheet(
                            child: selectedMarker!.buildPanel!(context),
                          ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 100, right: 8),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Map type button
                                  MapTypeButton(
                                    currentMapIndex: showMapIndex,
                                    mapOptions: [
                                      MapTypeOption(
                                        id: 'maplibre',
                                        name: 'MapLibre GL',
                                        description:
                                            'Mapa vectorial con estilo Liberty',
                                        previewImage: Container(
                                          color: Colors.blue.shade100,
                                          child: const Center(
                                            child: Icon(Icons.map, size: 40),
                                          ),
                                        ),
                                      ),
                                      MapTypeOption(
                                        id: 'osm',
                                        name: 'OpenStreetMap',
                                        description:
                                            'Mapa de teselas estándar de OSM',
                                        previewImage: Container(
                                          color: Colors.green.shade100,
                                          child: const Center(
                                            child: Icon(Icons.map_outlined,
                                                size: 40),
                                          ),
                                        ),
                                      ),
                                    ],
                                    onMapTypeChanged: (index) {
                                      setState(() {
                                        showMapIndex = index;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  // Re-center button
                                  ValueListenableBuilder<bool>(
                                    valueListenable:
                                        fitCameraLayer.outOfFocusNotifier,
                                    builder: (context, outOfFocus, _) {
                                      if (!outOfFocus) {
                                        return const SizedBox.shrink();
                                      }
                                      return Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Tooltip(
                                          message: 'Re-centrar mapa',
                                          child: IconButton(
                                            iconSize: 24,
                                            icon: const Icon(
                                              Icons.crop_free,
                                              color: Colors.blueAccent,
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  const WidgetStatePropertyAll(
                                                Colors.white,
                                              ),
                                              padding:
                                                  const WidgetStatePropertyAll(
                                                EdgeInsets.all(12),
                                              ),
                                              shape: WidgetStatePropertyAll(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                            onPressed:
                                                fitCameraLayer.reFitCamera,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      );
  }
}

class LoadingDialog extends StatelessWidget {
  final String message;
  const LoadingDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: 16),
              Flexible(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }
}
