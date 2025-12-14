import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import 'layers/click_markers_layer.dart';
import 'layers/debug_grid_layer.dart';
import 'layers/points_layer.dart';
import 'layers/route_layer.dart';
import 'widgets/map_controls.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define available map engines
  static final List<ITrufiMapEngine> mapEngines = [
    const FlutterMapEngine(
      tileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.trufi_core_maps_example',
      displayName: 'OpenStreetMap',
      displayDescription: 'Standard OSM raster tiles',
    ),
    const MapLibreEngine(
      styleString: 'https://tiles.openfreemap.org/styles/liberty',
      displayName: 'MapLibre GL',
      displayDescription: 'Vector map with Liberty style',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapEngineManager(
            engines: mapEngines,
            defaultCenter: const latlng.LatLng(-1.9403, 29.8739), // Kigali
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Trufi Core Maps Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MapExamplePage(),
      ),
    );
  }
}

class MapExamplePage extends StatefulWidget {
  const MapExamplePage({super.key});

  @override
  State<MapExamplePage> createState() => _MapExamplePageState();
}

class _MapExamplePageState extends State<MapExamplePage> {
  late final TrufiMapController _controller;
  late final FitCameraLayer _fitCameraLayer;
  late final PointsLayer _pointsLayer;
  late final RouteLayer _routeLayer;
  late final DebugGridLayer _debugGridLayer;
  late final ClickMarkersLayer _clickMarkersLayer;

  bool _showGrid = false;
  int _granularityLevels = 0;
  bool _clickMarkersEnabled = false;

  // Kigali, Rwanda coordinates
  static const _initialPosition = latlng.LatLng(-1.9403, 29.8739);
  static const _initialZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _controller = TrufiMapController(
      initialCameraPosition: const TrufiCameraPosition(
        target: _initialPosition,
        zoom: _initialZoom,
      ),
    );

    // Initialize layers
    _fitCameraLayer = FitCameraLayer(
      _controller,
      showCornerDots: false,
      debugFlag: false,
    );

    _pointsLayer = PointsLayer(_controller);
    _routeLayer = RouteLayer(_controller);
    _debugGridLayer = DebugGridLayer(_controller);
    _clickMarkersLayer = ClickMarkersLayer(_controller);

    // Add sample data
    _addSampleData();
  }

  void _addSampleData() {
    // Sample points around Kigali
    _pointsLayer.addSamplePoints([
      const latlng.LatLng(-1.9403, 29.8739), // Center
      const latlng.LatLng(-1.9350, 29.8800), // North-East
      const latlng.LatLng(-1.9450, 29.8650), // South-West
      const latlng.LatLng(-1.9380, 29.8680), // North-West
      const latlng.LatLng(-1.9480, 29.8820), // South-East
    ]);

    // Sample route
    _routeLayer.addSampleRoute([
      const latlng.LatLng(-1.9403, 29.8739),
      const latlng.LatLng(-1.9380, 29.8760),
      const latlng.LatLng(-1.9350, 29.8800),
      const latlng.LatLng(-1.9320, 29.8850),
    ]);
  }

  @override
  void dispose() {
    _debugGridLayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onMapClick(latlng.LatLng position) {
    debugPrint('Map clicked at: ${position.latitude}, ${position.longitude}');
    if (_clickMarkersEnabled) {
      _clickMarkersLayer.addMarkerAt(position);
    }
  }

  void _onMapLongClick(latlng.LatLng position) {
    debugPrint(
      'Map long-clicked at: ${position.latitude}, ${position.longitude}',
    );
  }

  void _fitToAllPoints() {
    final allPoints = <latlng.LatLng>[
      ..._pointsLayer.getPoints(),
      ..._routeLayer.getRoutePoints(),
    ];

    if (allPoints.isNotEmpty) {
      _fitCameraLayer.fitBoundsOnCamera(allPoints);
    }
  }

  void _resetCamera() {
    _controller.updateCamera(target: _initialPosition, zoom: _initialZoom);
  }

  void _onGridToggle(bool showGrid) {
    setState(() {
      _showGrid = showGrid;
      _debugGridLayer.setVisible(showGrid);
    });
  }

  void _onGranularityChanged(int level) {
    setState(() {
      _granularityLevels = level;
      _debugGridLayer.granularityLevels = level;
    });
  }

  Widget _buildMap(ITrufiMapEngine engine) {
    return engine.buildMap(
      controller: _controller,
      onMapClick: _onMapClick,
      onMapLongClick: _onMapLongClick,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the MapEngineManager for changes
    final mapEngineManager = MapEngineManager.watch(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Update viewport for fit camera
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final padding = MediaQuery.of(context).viewPadding;
            _fitCameraLayer.updateViewport(
              Size(constraints.maxWidth, constraints.maxHeight),
              padding,
            );
          });

          return Stack(
            children: [
              // Map (full screen)
              _buildMap(mapEngineManager.currentEngine),

              // Action Buttons (top-right, over the map)
              Positioned(
                top: 16,
                right: 16,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _fitCameraLayer.outOfFocusNotifier,
                  builder: (context, outOfFocus, _) {
                    return MapActionButtons(
                      onFitToPoints: _fitToAllPoints,
                      onResetCamera: _resetCamera,
                      showRecenter: outOfFocus,
                      onRecenter: _fitCameraLayer.reFitCamera,
                    );
                  },
                ),
              ),

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

              // Bottom Controls (Map Render + Layers + Grid) - centered
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MapControls(
                  currentEngineIndex: mapEngineManager.currentIndex,
                  engineNames:
                      mapEngineManager.engines.map((e) => e.name).toList(),
                  onEngineChanged: (index) {
                    mapEngineManager.setEngineByIndex(index);
                  },
                  layers: [
                    LayerInfo(
                      id: _pointsLayer.id,
                      name: 'Points',
                      icon: Icons.place,
                      visible: _pointsLayer.visible,
                    ),
                    LayerInfo(
                      id: _routeLayer.id,
                      name: 'Route',
                      icon: Icons.route,
                      visible: _routeLayer.visible,
                    ),
                    LayerInfo(
                      id: _clickMarkersLayer.id,
                      name: 'Tap',
                      icon: Icons.touch_app,
                      visible: _clickMarkersEnabled,
                    ),
                  ],
                  onLayerToggle: (layerId, visible) {
                    setState(() {
                      if (layerId == _clickMarkersLayer.id) {
                        _clickMarkersEnabled = visible;
                        _clickMarkersLayer.visible = visible;
                      } else {
                        _controller.toggleLayer(layerId, visible);
                      }
                    });
                  },
                  gridConfig: GridConfig(
                    showGrid: _showGrid,
                    granularityLevels: _granularityLevels,
                  ),
                  onGridToggle: _onGridToggle,
                  onGranularityChanged: _onGranularityChanged,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
