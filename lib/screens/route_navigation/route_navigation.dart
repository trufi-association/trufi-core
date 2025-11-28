import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/consts.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';
import 'package:trufi_core/adapters/plan_entity_adapter.dart';
import 'package:trufi_core/pages/home/widgets/search_bar/location_search_bar.dart';
import 'package:trufi_core/pages/home/widgets/travel_bottom_sheet/travel_bottom_sheet.dart';
import 'package:trufi_core/repositories/services/gps_lcoation/gps_location.dart';
import 'package:trufi_core/repositories/storage/shared_preferences_storage.dart';
import 'package:trufi_core/repositories/storage/local_storage_adapter.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core/models/trufi_location.dart';
import 'package:trufi_core/models/enums/transport_mode.dart' as app_mode;
import 'package:trufi_core/screens/route_navigation/widgets/map_type_button.dart';
import 'package:trufi_core/widgets/app_lifecycle_reactor.dart';
import 'package:trufi_core/widgets/bottom_sheet/trufi_bottom_sheet.dart';
import 'package:trufi_core/widgets/bottom_sheet/location_selector_bottom_sheet.dart';

class RouteNavigationScreen extends StatefulWidget {
  const RouteNavigationScreen({
    super.key,
    this.mapBuilder = defaultMapBuilder,
    this.mapLayerBuilder = defaultMapLayerBuilder,
    this.routingMapControllerBuilder = defaultRoutingMapController,
    this.fitCameraLayer = defaultFitCameraLayer,
    this.routeSearchBuilder = defaultRouteSearchBuilder,
  });

  final List<TrufiMap> Function(
    TrufiMapController controller,
    void Function(latlng.LatLng)? onMapClick,
    void Function(latlng.LatLng)? onMapLongClick,
  )
  mapBuilder;

  final List<TrufiLayer> Function(TrufiMapController controller)
  mapLayerBuilder;

  final RouteSearchBuilder routeSearchBuilder;

  final RoutingMapController Function(TrufiMapController controller)
  routingMapControllerBuilder;
  final IFitCameraLayer Function(TrufiMapController controller) fitCameraLayer;

  static List<TrufiMap> defaultMapBuilder(
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

  static RoutingMapController defaultRoutingMapController(
    TrufiMapController controller,
  ) {
    return RoutingMapController(
      controller,
      routingService: RoutingService(
        repository: OtpPlanRepository(endpoint: ApiConfig().openTripPlannerUrl),
      ),
      cacheRepository: StorageMapRouteRepository(
        LocalStorageAdapter(SharedPreferencesStorage()),
      ),
      transportIconBuilder: (leg) => _buildTransportIcon(leg),
    );
  }

  /// Builds a transport icon widget for a given leg.
  static Widget _buildTransportIcon(ItineraryLeg leg) {
    final mode = app_mode.getTransportMode(mode: leg.transportMode.otpName);
    return mode.getImage();
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

  late final RoutingMapController routingMapController;
  late final IFitCameraLayer fitCameraLayer;
  TrufiMarker? selectedMarker;
  late List<TrufiLayer> mapLayerRenders;
  late List<TrufiMap> mapRenders;

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
            await routingMapController.addOrigin(
              RoutingLocation(
                description: '',
                position: coord,
              ),
            );
            await _fetchPlanWithLoading();
          },
          onSetAsDestination: () async {
            await routingMapController.addDestination(
              RoutingLocation(
                description: '',
                position: coord,
              ),
            );
            // Auto-set origin to current location if not set
            if (routingMapController.origin == null) {
              final currentLocation = GPSLocationProvider().current;
              if (currentLocation != null) {
                await routingMapController.addOrigin(
                  RoutingLocation(
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
    routingMapController = widget.routingMapControllerBuilder(mapController);
    fitCameraLayer = widget.fitCameraLayer(mapController);
  }

  @override
  void dispose() {
    mapController.dispose();
    routingMapController.dispose();
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
      await routingMapController.fetchPlan();
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

  /// Converts routing location to TrufiLocation for UI components.
  TrufiLocation? _toTrufiLocation(RoutingLocation? loc) {
    if (loc == null) return null;
    return PlanEntityAdapter.toTrufiLocation(loc);
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
                        routingMapController.selectedItinerary;
                    final plan = routingMapController.plan;
                    final origin = _toTrufiLocation(routingMapController.origin);
                    final destination = _toTrufiLocation(routingMapController.destination);

                    // Convert domain plan to UI plan for TransitBottomSheet
                    final uiPlan = plan != null
                        ? PlanEntityAdapter.fromRoutingPlan(plan)
                        : null;
                    final uiSelectedItinerary = selectedItinerary != null && uiPlan != null
                        ? uiPlan.itineraries?.firstWhere(
                            (it) => it.startTime == selectedItinerary.startTime,
                            orElse: () => uiPlan.itineraries!.first,
                          )
                        : null;

                    return Stack(
                      children: [
                        widget.routeSearchBuilder(
                          onSaveFrom: (location) async {
                            await routingMapController.addOrigin(
                              PlanEntityAdapter.toRoutingLocation(location),
                            );

                            await _fetchPlanWithLoading();
                          },
                          onClearFrom: () {},
                          onSaveTo: (location) async {
                            await routingMapController.addDestination(
                              PlanEntityAdapter.toRoutingLocation(location),
                            );
                            if (routingMapController.origin == null) {
                              final currentLocation =
                                  GPSLocationProvider().current;
                              if (currentLocation != null) {
                                await routingMapController.addOrigin(
                                  RoutingLocation(
                                    description: 'Your Location',
                                    position: currentLocation,
                                  ),
                                );
                              }
                            }

                            await _fetchPlanWithLoading();
                          },
                          onClearTo: () async {
                            routingMapController.clearAll();
                            await _fetchPlanWithLoading();
                          },
                          onFetchPlan: () {},
                          onReset: () {},
                          onSwap: () async {
                            if (routingMapController.destination != null &&
                                routingMapController.origin != null) {
                              final temp = routingMapController.origin;
                              await routingMapController.addOrigin(
                                routingMapController.destination!,
                              );
                              await routingMapController.addDestination(temp!);
                              await _fetchPlanWithLoading();
                            }
                          },
                          origin: origin,
                          destination: destination,
                        ),
                        if (uiPlan != null)
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
                              plan: uiPlan,
                              selectedItinerary: uiSelectedItinerary,
                              updateCamera:
                                  ({bearing, target, visibleRegion, zoom}) {
                                    return routingMapController.controller
                                        .updateCamera(target: target, zoom: 18);
                                  },
                              onClose: () {
                                routingMapController.clearAll();
                              },
                              onSelectItinerary: (itinerary) {
                                if (itinerary != null && plan?.itineraries != null) {
                                  // Find matching domain itinerary by startTime
                                  final domainItinerary = plan!.itineraries!.firstWhere(
                                    (it) => it.startTime == itinerary.startTime,
                                    orElse: () => plan.itineraries!.first,
                                  );
                                  routingMapController.changeItinerary(
                                    domainItinerary,
                                  );
                                  final points = itinerary.legs
                                      .expand((leg) => leg.accumulatedPoints)
                                      .toList();
                                  fitCameraLayer.fitBoundsOnCamera(points);
                                } else {
                                  routingMapController.changeItinerary(null);
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
