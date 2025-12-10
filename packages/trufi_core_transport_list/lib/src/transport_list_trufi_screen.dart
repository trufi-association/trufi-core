import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trufi_core_interfaces/trufi_core_interfaces.dart'
    hide ITrufiMapEngine;
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';

import '../l10n/transport_list_localizations.dart';
import 'models/transport_route.dart';
import 'otp_transport_data_provider.dart';
import 'transport_detail_screen.dart';
import 'transport_list_content.dart';
import 'transport_list_data_provider.dart';

/// Configuration for the Transport List screen with OTP integration
class TransportListOtpConfig {
  final String otpEndpoint;
  final OtpVersion otpVersion;
  final LatLng defaultCenter;
  final List<ITrufiMapEngine> mapEngines;

  const TransportListOtpConfig({
    required this.otpEndpoint,
    required this.defaultCenter,
    this.otpVersion = OtpVersion.v2_4,
    this.mapEngines = const [],
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
  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(
          create: (_) => MapEngineManager(
            engines: config.mapEngines.isNotEmpty
                ? config.mapEngines
                : defaultMapEngines,
          ),
        ),
      ];

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

  @override
  void initState() {
    super.initState();
    _dataProvider = OtpTransportDataProvider(
      otpConfiguration: OtpConfiguration(
        endpoint: widget.config.otpEndpoint,
        version: widget.config.otpVersion,
      ),
    );
  }

  @override
  void dispose() {
    _dataProvider.dispose();
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
          mapBuilder: (context, routeDetails) => _RouteMapView(
            route: routeDetails,
            defaultCenter: widget.config.defaultCenter,
          ),
        );
      },
    );
  }
}

/// Map view for displaying a route
class _RouteMapView extends StatefulWidget {
  final TransportRouteDetails? route;
  final LatLng defaultCenter;

  const _RouteMapView({
    required this.route,
    required this.defaultCenter,
  });

  @override
  State<_RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<_RouteMapView> {
  late final TrufiMapController _mapController;
  late final FitCameraLayer _fitCameraLayer;
  _RouteLayer? _routeLayer;

  @override
  void initState() {
    super.initState();
    _mapController = TrufiMapController(
      initialCameraPosition: TrufiCameraPosition(
        target: widget.defaultCenter,
        zoom: 13,
      ),
    );
    _fitCameraLayer = FitCameraLayer(
      _mapController,
      devicePixelRatio: MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first,
      ).devicePixelRatio,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRoute();
    });
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
    if (route == null || route.geometry == null) return;

    // Remove old layer if exists
    if (_routeLayer != null) {
      _mapController.removeLayer(_routeLayer!.id);
    }

    // Create new route layer
    _routeLayer = _RouteLayer(_mapController);
    _routeLayer!.setRoute(route);

    // Fit camera to route bounds
    final points =
        route.geometry!.map((p) => LatLng(p.latitude, p.longitude)).toList();

    if (points.length > 1) {
      _fitCameraLayer.setFitPoints(points);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Widget _buildMap(ITrufiMapEngine engine) {
    return engine.buildMap(
      controller: _mapController,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.watch(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        _fitCameraLayer.updateViewport(
          Size(constraints.maxWidth, constraints.maxHeight),
          MediaQuery.of(context).viewPadding,
        );
        return Stack(
          children: [
            // Map (full area)
            _buildMap(mapEngineManager.currentEngine),

            // Map Type Button (top-left)
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: MapTypeButton.fromEngines(
                  engines: mapEngineManager.engines,
                  currentEngineIndex: mapEngineManager.currentIndex,
                  onEngineChanged: (engine) {
                    mapEngineManager.setEngine(engine);
                  },
                  settingsAppBarTitle: 'Map Settings',
                  settingsSectionTitle: 'Map Type',
                  settingsApplyButtonText: 'Apply Changes',
                ),
              ),
            ),

            // Recenter button (top-right)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _fitCameraLayer.outOfFocusNotifier,
                  builder: (context, outOfFocus, _) {
                    if (!outOfFocus) return const SizedBox.shrink();
                    return Material(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 2,
                      child: InkWell(
                        onTap: _fitCameraLayer.reFitCamera,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.center_focus_strong_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
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

    final points =
        route.geometry!.map((p) => LatLng(p.latitude, p.longitude)).toList();

    // Add route line
    addLine(TrufiLine(
      id: 'route-line',
      position: points,
      color: route.backgroundColor ?? Colors.blue,
      lineWidth: 5,
    ));

    // Add start marker
    addMarker(TrufiMarker(
      id: 'start-marker',
      position: points.first,
      widget: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      size: const Size(20, 20),
    ));

    // Add end marker
    addMarker(TrufiMarker(
      id: 'end-marker',
      position: points.last,
      widget: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      size: const Size(20, 20),
    ));
  }
}
