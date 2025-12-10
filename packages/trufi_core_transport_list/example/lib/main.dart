import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing/trufi_core_routing.dart';
import 'package:trufi_core_transport_list/trufi_core_transport_list.dart';

void main() {
  runApp(const MyApp());
}

/// Available map engines for the app
final List<ITrufiMapEngine> _mapEngines = [
  const FlutterMapEngine(
    tileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.example.transport_list',
    displayName: 'OpenStreetMap',
    displayDescription: 'Standard OSM raster tiles',
  ),
  const MapLibreEngine(
    styleString: 'https://tiles.openfreemap.org/styles/liberty',
    displayName: 'MapLibre GL',
    displayDescription: 'Vector map with Liberty style',
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapEngineManager(engines: _mapEngines),
      child: MaterialApp(
        title: 'Transport List Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        localizationsDelegates: const [
          ...TransportListLocalizations.localizationsDelegates,
        ],
        supportedLocales: TransportListLocalizations.supportedLocales,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TransportListDataProvider _dataProvider;

  @override
  void initState() {
    super.initState();
    _dataProvider = OtpTransportDataProvider(
      otpConfiguration: const OtpConfiguration(
        endpoint: 'https://otp-240.trufi-core.trufi.dev',
        version: OtpVersion.v2_4,
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
          mapBuilder: (context, routeDetails) => RouteMapView(
            route: routeDetails,
            defaultCenter: const LatLng(-17.3988354, -66.1626903),
          ),
        );
      },
    );
  }
}

/// Map view for displaying a route
class RouteMapView extends StatefulWidget {
  final TransportRouteDetails? route;
  final LatLng defaultCenter;

  const RouteMapView({
    super.key,
    this.route,
    required this.defaultCenter,
  });

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
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
  void didUpdateWidget(covariant RouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.route != oldWidget.route) {
      _updateRoute();
    }
  }

  void _updateRoute() {
    final route = widget.route;
    if (route == null || route.geometry == null) return;

    if (_routeLayer != null) {
      _mapController.removeLayer(_routeLayer!.id);
    }

    _routeLayer = _RouteLayer(_mapController);
    _routeLayer!.setRoute(route);

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
            mapEngineManager.currentEngine.buildMap(controller: _mapController),
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: MapTypeButton.fromEngines(
                  engines: mapEngineManager.engines,
                  currentEngineIndex: mapEngineManager.currentIndex,
                  onEngineChanged: mapEngineManager.setEngine,
                  settingsAppBarTitle: 'Map Settings',
                  settingsSectionTitle: 'Map Type',
                  settingsApplyButtonText: 'Apply Changes',
                ),
              ),
            ),
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
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
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

class _RouteLayer extends TrufiLayer {
  _RouteLayer(super.controller) : super(id: 'route-layer', layerLevel: 1);

  void setRoute(TransportRouteDetails route) {
    clearMarkers();
    clearLines();

    if (route.geometry == null || route.geometry!.isEmpty) return;

    final points =
        route.geometry!.map((p) => LatLng(p.latitude, p.longitude)).toList();

    addLine(TrufiLine(
      id: 'route-line',
      position: points,
      color: route.backgroundColor ?? Colors.blue,
      lineWidth: 5,
    ));

    addMarker(TrufiMarker(
      id: 'start-marker',
      position: points.first,
      widget: _buildMarker(Colors.green),
      size: const Size(20, 20),
    ));

    addMarker(TrufiMarker(
      id: 'end-marker',
      position: points.last,
      widget: _buildMarker(Colors.red),
      size: const Size(20, 20),
    ));
  }

  Widget _buildMarker(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
