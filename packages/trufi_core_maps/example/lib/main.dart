import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

import 'engines/flutter_map_engine.dart';
import 'layers/animated_markers_layer.dart';
import 'layers/animated_routes_layer.dart';
import 'layers/click_markers_layer.dart';
import 'layers/debug_grid_layer.dart';
import 'widgets/performance_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final List<ITrufiMapEngine> mapEngines = [
    const MapLibreEngine(
      styleString: 'https://tiles.openfreemap.org/styles/liberty',
      displayName: 'MapLibre GL',
      displayDescription: 'Vector map with Liberty style',
    ),
    const FlutterMapEngine(
      tileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.trufi_core_maps_example',
      displayName: 'OpenStreetMap',
      displayDescription: 'Standard OSM raster tiles',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapEngineManager(
            engines: mapEngines,
            defaultCenter: const latlng.LatLng(-17.3895, -66.1568),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Trufi Maps - Performance Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const PerformanceDemoPage(),
      ),
    );
  }
}

class PerformanceDemoPage extends StatefulWidget {
  const PerformanceDemoPage({super.key});

  @override
  State<PerformanceDemoPage> createState() => _PerformanceDemoPageState();
}

class _PerformanceDemoPageState extends State<PerformanceDemoPage> {
  final TrufiMapController _controller = TrufiMapController();
  late final AnimatedMarkersLayer _animatedMarkersLayer;
  late final AnimatedRoutesLayer _animatedRoutesLayer;
  late final DebugGridLayer _debugGridLayer;
  late final ClickMarkersLayer _clickMarkersLayer;

  bool _isAnimating = false;
  bool _showGrid = false;

  // Track camera for debug grid updates
  TrufiCameraPosition _camera = const TrufiCameraPosition(
    target: _initialPosition,
    zoom: _initialZoom,
  );

  // Performance test parameters
  int _markerCount = 100;
  int _lineCount = 20;
  int _fps = 30;

  // Cochabamba, Bolivia coordinates
  static const _initialPosition = latlng.LatLng(-17.3895, -66.1568);
  static const _initialZoom = 13.0;

  @override
  void initState() {
    super.initState();

    _animatedMarkersLayer = AnimatedMarkersLayer()
      ..onUpdate = () => setState(() {});
    _animatedRoutesLayer = AnimatedRoutesLayer()
      ..onUpdate = () => setState(() {});
    _debugGridLayer = DebugGridLayer()..onUpdate = () => setState(() {});
    _clickMarkersLayer = ClickMarkersLayer()..onUpdate = () => setState(() {});
  }

  @override
  void dispose() {
    _animatedMarkersLayer.dispose();
    _animatedRoutesLayer.dispose();
    super.dispose();
  }

  void _applySettings() {
    final center = _camera.target;

    debugPrint(
      'Applying settings: markers=$_markerCount, lines=$_lineCount, fps=$_fps',
    );
    debugPrint('Center: ${center.latitude}, ${center.longitude}');

    // Generate markers
    _animatedMarkersLayer.generateVehicles(
      center: center,
      count: _markerCount,
      spreadRadius: 0.03,
    );

    debugPrint('Generated ${_animatedMarkersLayer.vehicleCount} vehicles');

    // Generate routes
    _animatedRoutesLayer.generateRoutes(
      center: center,
      count: _lineCount,
      spreadRadius: 0.04,
      pointsPerRoute: 15,
    );

    debugPrint('Generated ${_animatedRoutesLayer.routeCount} routes');

    // Start animation
    _animatedMarkersLayer.startAnimation(fps: _fps);
    _animatedRoutesLayer.startAnimation(fps: _fps);

    setState(() {
      _isAnimating = true;
    });

    debugPrint('Animation started, isAnimating=$_isAnimating');
  }

  void _stopAll() {
    _animatedMarkersLayer.clearVehicles();
    _animatedRoutesLayer.clearRoutes();
    _clickMarkersLayer.clearClickMarkers();

    setState(() {
      _isAnimating = false;
    });
  }

  void _onMapClick(latlng.LatLng position) {
    debugPrint('Map clicked at: ${position.latitude}, ${position.longitude}');
    _clickMarkersLayer.addMarkerAt(position);
  }

  void _onCameraChanged(TrufiCameraPosition cam) {
    _camera = cam;
    _debugGridLayer.updateFromCamera(cam);
  }

  /// Build the list of TrufiLayer data objects from all layer state holders.
  List<TrufiLayer> _buildLayers() {
    return [
      TrufiLayer(
        id: AnimatedRoutesLayer.layerId,
        markers: _animatedRoutesLayer.markers,
        lines: _animatedRoutesLayer.lines,
        layerLevel: 4,
      ),
      TrufiLayer(
        id: AnimatedMarkersLayer.layerId,
        markers: _animatedMarkersLayer.markers,
        layerLevel: 7,
      ),
      TrufiLayer(
        id: ClickMarkersLayer.layerId,
        markers: _clickMarkersLayer.markers,
        layerLevel: 8,
      ),
      TrufiLayer(
        id: DebugGridLayer.layerId,
        lines: _debugGridLayer.lines,
        visible: _showGrid,
        layerLevel: 10,
      ),
    ];
  }

  Widget _buildMap(ITrufiMapEngine engine) {
    return engine.buildMap(
      controller: _controller,
      initialCamera: const TrufiCameraPosition(
        target: _initialPosition,
        zoom: _initialZoom,
      ),
      onCameraChanged: _onCameraChanged,
      onMapClick: _onMapClick,
      layers: _buildLayers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.watch(context);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          _buildMap(mapEngineManager.currentEngine),

          // Performance Stats (top-left)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: PerformanceStatsOverlay(
                statsNotifier: _animatedMarkersLayer.statsNotifier,
                lineCount: _animatedRoutesLayer.routeCount,
              ),
            ),
          ),

          // Action buttons (top-right)
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Column(
                children: [
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
                  _ActionButton(
                    icon: Icons.grid_on,
                    onPressed: () {
                      setState(() => _showGrid = !_showGrid);
                      _debugGridLayer.setVisible(_showGrid);
                    },
                    highlighted: _showGrid,
                  ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: Icons.my_location,
                    onPressed: () => _controller.moveCamera(
                      const TrufiCameraPosition(
                        target: _initialPosition,
                        zoom: _initialZoom,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control Panel (bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PerformanceControlPanel(
                  markerCount: _markerCount,
                  lineCount: _lineCount,
                  fps: _fps,
                  isAnimating: _isAnimating,
                  hasData: _animatedMarkersLayer.vehicleCount > 0,
                  onMarkerCountChanged: (v) =>
                      setState(() => _markerCount = v),
                  onLineCountChanged: (v) => setState(() => _lineCount = v),
                  onFpsChanged: (v) => setState(() => _fps = v),
                  onStart: _applySettings,
                  onStop: _stopAll,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool highlighted;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? Colors.blue : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: highlighted ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
