import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    hide ITrufiMapEngine;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../l10n/transport_list_localizations.dart';
import 'models/transport_route.dart';
import 'otp_transport_data_provider.dart';
import 'repository/transport_list_cache.dart';
import 'transport_detail_screen.dart';
import 'transport_list_content.dart';
import 'transport_list_data_provider.dart';

/// Transport List screen module for TrufiApp integration with OTP and Map support.
///
/// Uses the current routing provider from [RoutingEngineManager] to fetch
/// transit routes. If the current provider doesn't support transit routes,
/// it will try to find an online provider that does.
class TransportListTrufiScreen extends TrufiScreen {
  TransportListTrufiScreen();

  @override
  String get id => 'transport_list';

  @override
  String get path => '/routes';

  @override
  Widget Function(BuildContext context) get builder =>
      (_) => const _TransportListScreenWidget();

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
    ...TransportListLocalizations.localizationsDelegates,
  ];

  @override
  List<Locale> get supportedLocales =>
      TransportListLocalizations.supportedLocales;

  @override
  List<SingleChildWidget> get providers => [];

  @override
  bool get hasOwnAppBar => true;

  @override
  ScreenMenuItem? get menuItem =>
      const ScreenMenuItem(icon: Icons.directions_bus, order: 1);

  @override
  String getLocalizedTitle(BuildContext context) {
    return TransportListLocalizations.of(context).menuTransportList;
  }
}

class _TransportListScreenWidget extends StatefulWidget {
  const _TransportListScreenWidget();

  @override
  State<_TransportListScreenWidget> createState() =>
      _TransportListScreenWidgetState();
}

class _TransportListScreenWidgetState
    extends State<_TransportListScreenWidget> {
  TransportListDataProvider? _dataProvider;
  TransportListCache? _cache;
  bool _urlParsed = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize data provider with routing engine from context
    if (!_initialized) {
      _initialized = true;
      _initializeDataProvider();
    }

    // Parse URL parameters on first load (web only)
    _parseUrlAndOpenRoute();
  }

  void _initializeDataProvider() {
    _cache = TransportListCache();
    _cache!.initialize();

    // Get the transit route repository from the routing engine manager
    final routingManager = RoutingEngineManager.maybeRead(context);
    TransitRouteRepository? repository;

    if (routingManager != null) {
      // Try current engine first
      if (routingManager.currentEngine.supportsTransitRoutes) {
        repository = routingManager.currentEngine.createTransitRouteRepository();
      } else {
        // Fallback: find any engine that supports transit routes
        for (final engine in routingManager.engines) {
          if (engine.supportsTransitRoutes) {
            repository = engine.createTransitRouteRepository();
            break;
          }
        }
      }
    }

    _dataProvider = OtpTransportDataProvider(
      repository: repository,
      cache: _cache,
    );
  }

  @override
  void dispose() {
    _dataProvider?.dispose();
    _cache?.dispose();
    super.dispose();
  }

  /// Parses URL parameters and opens route detail if id is present (web only).
  void _parseUrlAndOpenRoute() {
    if (!kIsWeb || _urlParsed || _dataProvider == null) return;
    _urlParsed = true;

    try {
      final routerState = GoRouterState.of(context);
      final params = routerState.uri.queryParameters;
      final routeId = params['id'];

      if (routeId != null && routeId.isNotEmpty) {
        // Open route detail screen after frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _dataProvider == null) return;
          TransportDetailScreen.show(
            context,
            routeCode: routeId,
            getRouteDetails: _dataProvider!.getRouteDetails,
            basePath: '/routes',
            mapBuilder: (
              context,
              routeDetails,
              registerMapMoveCallback,
              registerStopSelectionCallback,
            ) =>
                _RouteMapView(
                  route: routeDetails,
                  registerMapMoveCallback: registerMapMoveCallback,
                  registerStopSelectionCallback: registerStopSelectionCallback,
                ),
          );
        });
      }
    } catch (e) {
      debugPrint('TransportListScreen: Error parsing URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = _dataProvider;
    if (dataProvider == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return TransportListContent(
      dataProvider: dataProvider,
      onRouteTap: (route) {
        TransportDetailScreen.show(
          context,
          routeCode: route.code,
          getRouteDetails: dataProvider.getRouteDetails,
          basePath: '/routes',
          mapBuilder:
              (
                context,
                routeDetails,
                registerMapMoveCallback,
                registerStopSelectionCallback,
              ) => _RouteMapView(
                route: routeDetails,
                registerMapMoveCallback: registerMapMoveCallback,
                registerStopSelectionCallback: registerStopSelectionCallback,
              ),
        );
      },
    );
  }
}

/// Map view for displaying a route
class _RouteMapView extends StatefulWidget {
  final TransportRouteDetails? route;
  final void Function(MapMoveCallback) registerMapMoveCallback;
  final void Function(StopSelectionCallback) registerStopSelectionCallback;

  const _RouteMapView({
    required this.route,
    required this.registerMapMoveCallback,
    required this.registerStopSelectionCallback,
  });

  @override
  State<_RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<_RouteMapView> {
  TrufiMapController? _mapController;
  FitCameraLayer? _fitCameraLayer;
  _RouteLayer? _routeLayer;

  @override
  void initState() {
    super.initState();
    // Register the callback for moving the map
    widget.registerMapMoveCallback(_moveToLocation);
    // Register the callback for stop selection
    widget.registerStopSelectionCallback(_onStopSelected);
  }

  void _onStopSelected(int? stopIndex) {
    _routeLayer?.setSelectedStop(stopIndex);
  }

  void _moveToLocation(double latitude, double longitude) {
    _mapController?.setCameraPosition(
      TrufiCameraPosition(target: LatLng(latitude, longitude), zoom: 16),
    );
  }

  void _initializeIfNeeded(MapEngineManager mapEngineManager) {
    if (_mapController == null) {
      _mapController = TrufiMapController(
        initialCameraPosition: TrufiCameraPosition(
          target: mapEngineManager.defaultCenter,
          zoom: mapEngineManager.defaultZoom,
        ),
      );
      _fitCameraLayer = FitCameraLayer(_mapController!);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateRoute();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _RouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.route != oldWidget.route) {
      _updateRoute();
    }
  }

  void _updateRoute() {
    final route = widget.route;
    if (route == null || route.geometry == null || _mapController == null) {
      return;
    }

    // Remove old layer if exists
    if (_routeLayer != null) {
      _mapController!.removeLayer(_routeLayer!.id);
    }

    // Create new route layer
    _routeLayer = _RouteLayer(_mapController!);
    _routeLayer!.setRoute(route);

    // Fit camera to route bounds
    final points = route.geometry!
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    if (points.length > 1) {
      _fitCameraLayer?.setFitPoints(points);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Widget _buildMap(ITrufiMapEngine engine) {
    return engine.buildMap(controller: _mapController!);
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.watch(context);
    _initializeIfNeeded(mapEngineManager);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewPadding = MediaQuery.of(context).viewPadding;
        // Add extra padding for top bar (~70px) and bottom sheet (~30% of screen)
        final sheetHeight = constraints.maxHeight * 0.30;
        final adjustedPadding = EdgeInsets.only(
          top: viewPadding.top + 70,
          bottom: viewPadding.bottom + sheetHeight,
          left: viewPadding.left,
          right: viewPadding.right,
        );
        _fitCameraLayer?.updateViewport(
          Size(constraints.maxWidth, constraints.maxHeight),
          adjustedPadding,
        );
        // Calculate safe offset to avoid overlapping with TransportDetailScreen topbar
        final topOffset = viewPadding.top + 70;

        return Stack(
          children: [
            // Map (full area)
            _buildMap(mapEngineManager.currentEngine),

            // Map controls (right side, below top bar)
            Positioned(
              top: topOffset,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Map Type Button
                  if (mapEngineManager.engines.length > 1) ...[
                    MapTypeButton.fromEngines(
                      engines: mapEngineManager.engines,
                      currentEngineIndex: mapEngineManager.currentIndex,
                      onEngineChanged: (engine) {
                        mapEngineManager.setEngine(engine);
                      },
                      settingsAppBarTitle: 'Map Settings',
                      settingsSectionTitle: 'Map Type',
                      settingsApplyButtonText: 'Apply Changes',
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Recenter button (only visible when route is out of focus)
                  ValueListenableBuilder<bool>(
                    valueListenable: _fitCameraLayer!.outOfFocusNotifier,
                    builder: (context, outOfFocus, _) {
                      return AnimatedOpacity(
                        opacity: outOfFocus ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedScale(
                          scale: outOfFocus ? 1.0 : 0.8,
                          duration: const Duration(milliseconds: 200),
                          child: Material(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            elevation: 2,
                            shadowColor: Colors.black26,
                            child: InkWell(
                              onTap: outOfFocus
                                  ? _fitCameraLayer!.reFitCamera
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.crop_free_rounded,
                                  size: 22,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom layer for displaying route on map
class _RouteLayer extends TrufiLayer {
  _RouteLayer(super.controller) : super(id: 'route-layer', layerLevel: 1);

  TransportRouteDetails? _currentRoute;
  int? _selectedStopIndex;

  void setSelectedStop(int? stopIndex) {
    _selectedStopIndex = stopIndex;
    if (_currentRoute != null) {
      _updateStopMarkers(_currentRoute!);
    }
  }

  void setRoute(TransportRouteDetails route) {
    _currentRoute = route;
    clearMarkers();
    clearLines();

    if (route.geometry == null || route.geometry!.isEmpty) return;

    final routeColor = route.backgroundColor ?? Colors.blue;
    final points = route.geometry!
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // Add route line
    addLine(
      TrufiLine(
        id: 'route-line',
        position: points,
        color: routeColor,
        lineWidth: 5,
      ),
    );

    // Add stop markers
    _updateStopMarkers(route);
  }

  void _updateStopMarkers(TransportRouteDetails route) {
    // Remove existing stop markers
    final stops = route.stops ?? [];
    for (int i = 0; i < stops.length; i++) {
      removeMarkerById('stop-$i');
    }
    removeMarkerById('selected-stop');
    removeMarkerById('origin-marker');
    removeMarkerById('destination-marker');

    if (stops.isEmpty) return;

    final routeColor = route.backgroundColor ?? Colors.blue;
    // Create stable imageCacheKeys based on visual properties (color + isTerminal + isSelected)
    final colorHex = routeColor.toARGB32().toRadixString(16);
    final intermediateImageKey = 'stop_intermediate_$colorHex';
    final selectedImageKey = 'stop_selected_$colorHex';

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final isFirst = i == 0;
      final isLast = i == stops.length - 1;
      final isSelected = i == _selectedStopIndex;

      // Skip origin, destination, and selected - they have special markers
      if (isFirst || isLast || isSelected) continue;

      addMarker(
        TrufiMarker(
          id: 'stop-$i',
          position: LatLng(stop.latitude, stop.longitude),
          widget: _StopMarker(color: routeColor),
          size: const Size(12, 12),
          layerLevel: 1,
          imageCacheKey: intermediateImageKey,
        ),
      );
    }

    // Add origin marker (green circle) - unless it's selected
    final firstStop = stops.first;
    if (_selectedStopIndex != 0) {
      addMarker(
        TrufiMarker(
          id: 'origin-marker',
          position: LatLng(firstStop.latitude, firstStop.longitude),
          widget: const _OriginMarker(),
          size: const Size(24, 24),
          layerLevel: 3,
          imageCacheKey: 'origin_marker',
        ),
      );
    }

    // Add destination marker (red pin) - unless it's selected
    final lastStop = stops.last;
    if (_selectedStopIndex != stops.length - 1) {
      addMarker(
        TrufiMarker(
          id: 'destination-marker',
          position: LatLng(lastStop.latitude, lastStop.longitude),
          widget: const _DestinationMarker(),
          size: const Size(32, 32),
          alignment: Alignment.topCenter,
          layerLevel: 3,
          imageCacheKey: 'destination_marker',
        ),
      );
    }

    // Add selected stop marker with higher priority
    if (_selectedStopIndex != null && _selectedStopIndex! < stops.length) {
      final selectedStop = stops[_selectedStopIndex!];
      addMarker(
        TrufiMarker(
          id: 'selected-stop',
          position: LatLng(selectedStop.latitude, selectedStop.longitude),
          widget: _SelectedStopMarker(color: routeColor),
          size: const Size(24, 24),
          layerLevel: 10,
          imageCacheKey: selectedImageKey,
        ),
      );
    }
  }
}

/// Marker widget for intermediate stops
class _StopMarker extends StatelessWidget {
  final Color color;

  const _StopMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

/// Origin marker - green circle (same as home screen)
class _OriginMarker extends StatelessWidget {
  const _OriginMarker();

  static const _color = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// Destination marker - red pin icon (same as home screen)
class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  static const _color = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.place_rounded,
      color: _color,
      size: 32,
      shadows: [
        Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
      ],
    );
  }
}

/// Marker widget for selected stop - larger solid circle
class _SelectedStopMarker extends StatelessWidget {
  final Color color;

  const _SelectedStopMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
