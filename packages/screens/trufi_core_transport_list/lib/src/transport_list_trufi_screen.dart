import 'package:flutter/material.dart';
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

/// Configuration for the Transport List screen with OTP integration
class TransportListOtpConfig {
  final String otpEndpoint;
  final OtpVersion otpVersion;

  const TransportListOtpConfig({
    required this.otpEndpoint,
    this.otpVersion = OtpVersion.v2_4,
  });
}

/// Transport List screen module for TrufiApp integration with OTP and Map support
class TransportListTrufiScreen extends TrufiScreen {
  final TransportListOtpConfig config;

  TransportListTrufiScreen({required this.config});

  @override
  String get id => 'transport_list';

  @override
  String get path => '/routes';

  @override
  Widget Function(BuildContext context) get builder =>
      (_) => _TransportListScreenWidget(config: config);

  @override
  List<LocalizationsDelegate> get localizationsDelegates => [
        ...TransportListLocalizations.localizationsDelegates,
      ];

  @override
  List<Locale> get supportedLocales => TransportListLocalizations.supportedLocales;

  @override
  List<SingleChildWidget> get providers => [];

  @override
  bool get hasOwnAppBar => true;

  @override
  ScreenMenuItem? get menuItem => const ScreenMenuItem(
        icon: Icons.directions_bus,
        order: 1,
      );

  @override
  String getLocalizedTitle(BuildContext context) {
    return TransportListLocalizations.of(context)?.menuTransportList ??
        'Routes';
  }
}

class _TransportListScreenWidget extends StatefulWidget {
  final TransportListOtpConfig config;

  const _TransportListScreenWidget({required this.config});

  @override
  State<_TransportListScreenWidget> createState() =>
      _TransportListScreenWidgetState();
}

class _TransportListScreenWidgetState
    extends State<_TransportListScreenWidget> {
  late final TransportListDataProvider _dataProvider;
  late final TransportListCache _cache;

  @override
  void initState() {
    super.initState();
    _cache = TransportListCache();
    _cache.initialize();
    _dataProvider = OtpTransportDataProvider(
      otpConfiguration: OtpConfiguration(
        endpoint: widget.config.otpEndpoint,
        version: widget.config.otpVersion,
      ),
      cache: _cache,
    );
  }

  @override
  void dispose() {
    _dataProvider.dispose();
    _cache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TransportListContent(
      dataProvider: _dataProvider,
      onRouteTap: (route) {
        TransportDetailScreen.show(
          context,
          routeCode: route.code,
          getRouteDetails: _dataProvider.getRouteDetails,
          mapBuilder: (context, routeDetails, registerMapMoveCallback) =>
              _RouteMapView(
            route: routeDetails,
            registerMapMoveCallback: registerMapMoveCallback,
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

  const _RouteMapView({
    required this.route,
    required this.registerMapMoveCallback,
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
  }

  void _moveToLocation(double latitude, double longitude) {
    _mapController?.setCameraPosition(
      TrufiCameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 16,
      ),
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
    final points =
        route.geometry!.map((p) => LatLng(p.latitude, p.longitude)).toList();

    if (points.length > 1) {
      _fitCameraLayer?.setFitPoints(points);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Widget _buildMap(ITrufiMapEngine engine, {required bool isDarkMode}) {
    return engine.buildMap(
      controller: _mapController!,
      isDarkMode: isDarkMode,
    );
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
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        // Calculate safe offset to avoid overlapping with TransportDetailScreen topbar
        final topOffset = viewPadding.top + 70;

        return Stack(
          children: [
            // Map (full area)
            _buildMap(
              mapEngineManager.currentEngine,
              isDarkMode: isDarkMode,
            ),

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
                            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            elevation: 2,
                            shadowColor: Colors.black26,
                            child: InkWell(
                              onTap: outOfFocus ? _fitCameraLayer!.reFitCamera : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.crop_free_rounded,
                                  size: 22,
                                  color: Theme.of(context).colorScheme.onSurface,
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

  void setRoute(TransportRouteDetails route) {
    clearMarkers();
    clearLines();

    if (route.geometry == null || route.geometry!.isEmpty) return;

    final routeColor = route.backgroundColor ?? Colors.blue;
    final points =
        route.geometry!.map((p) => LatLng(p.latitude, p.longitude)).toList();

    // Add route line
    addLine(TrufiLine(
      id: 'route-line',
      position: points,
      color: routeColor,
      lineWidth: 5,
    ));

    // Add stop markers (intermediate stops)
    final stops = route.stops ?? [];
    // Create stable imageKeys based on visual properties (color + isTerminal)
    final colorHex = routeColor.toARGB32().toRadixString(16);
    final terminalImageKey = 'stop_terminal_$colorHex';
    final intermediateImageKey = 'stop_intermediate_$colorHex';

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final isFirst = i == 0;
      final isLast = i == stops.length - 1;
      final isTerminal = isFirst || isLast;

      addMarker(TrufiMarker(
        id: 'stop-$i',
        position: LatLng(stop.latitude, stop.longitude),
        widget: _StopMarker(
          color: routeColor,
          isTerminal: isTerminal,
        ),
        size: Size(isTerminal ? 16 : 12, isTerminal ? 16 : 12),
        layerLevel: isTerminal ? 2 : 1,
        imageKey: isTerminal ? terminalImageKey : intermediateImageKey,
      ));
    }
  }
}

/// Marker widget for stops
class _StopMarker extends StatelessWidget {
  final Color color;
  final bool isTerminal;

  const _StopMarker({
    required this.color,
    this.isTerminal = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isTerminal ? 16.0 : 12.0;
    final borderWidth = isTerminal ? 3.0 : 2.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isTerminal ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isTerminal ? Colors.white : color,
          width: borderWidth,
        ),
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
