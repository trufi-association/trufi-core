import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

import 'layers/points_layer.dart';
import 'layers/route_layer.dart';
import 'widgets/map_controls.dart';

void main() {
  runApp(const TrufiMapsExampleApp());
}

class TrufiMapsExampleApp extends StatelessWidget {
  const TrufiMapsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trufi Core Maps Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MapExamplePage(),
    );
  }
}

enum MapRenderType { flutterMap, mapLibre }

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

  MapRenderType _currentRender = MapRenderType.flutterMap;

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
    _controller.dispose();
    super.dispose();
  }

  void _onMapClick(latlng.LatLng position) {
    debugPrint('Map clicked at: ${position.latitude}, ${position.longitude}');
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

  Widget _buildMap() {
    switch (_currentRender) {
      case MapRenderType.flutterMap:
        return TrufiFlutterMap(
          key: const ValueKey('flutter_map'),
          controller: _controller,
          onMapClick: _onMapClick,
          onMapLongClick: _onMapLongClick,
          tileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.trufi_core_maps_example',
        );
      case MapRenderType.mapLibre:
        return TrufiMapLibreMap(
          key: const ValueKey('maplibre'),
          controller: _controller,
          onMapClick: _onMapClick,
          onMapLongClick: _onMapLongClick,
          styleString: 'https://tiles.openfreemap.org/styles/liberty',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _buildMap(),

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

              // Bottom Controls (Map Render + Layers)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: MapControls(
                    currentRender: _currentRender,
                    onRenderChanged: (render) {
                      setState(() => _currentRender = render);
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
                    ],
                    onLayerToggle: (layerId, visible) {
                      setState(() {
                        _controller.toggleLayer(layerId, visible);
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
