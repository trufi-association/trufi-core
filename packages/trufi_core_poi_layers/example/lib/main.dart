import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart'
    hide LatLngBounds;

/// Example demonstrating POILayersManager usage with Provider.
///
/// This example shows how to use POILayersManager as a ChangeNotifier:
/// - Simplified POI layer management via Provider
/// - Automatic state synchronization
/// - Clean separation of concerns
void main() {
  runApp(const POILayersExampleApp());
}

class POILayersExampleApp extends StatelessWidget {
  const POILayersExampleApp({super.key});

  static final List<ITrufiMapEngine> mapEngines = [
    const FlutterMapEngine(
      tileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.trufi_core_poi_layers_example',
    ),
    const MapLibreEngine(
      styleString: 'https://tiles.openfreemap.org/styles/liberty',
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
        ChangeNotifierProvider(
          create: (_) => POILayersManager(
            assetsBasePath: 'assets/pois',
          ),
        ),
      ],
      child: MaterialApp(
        title: 'POI Layers Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        localizationsDelegates: POILayersLocalizations.localizationsDelegates,
        supportedLocales: POILayersLocalizations.supportedLocales,
        home: const POILayersDemoPage(),
      ),
    );
  }
}

class POILayersDemoPage extends StatefulWidget {
  const POILayersDemoPage({super.key});

  @override
  State<POILayersDemoPage> createState() => _POILayersDemoPageState();
}

class _POILayersDemoPageState extends State<POILayersDemoPage> {
  late final TrufiMapController _mapController;

  POI? _selectedPOI;

  // Cochabamba, Bolivia coordinates
  static const _initialPosition = latlng.LatLng(-17.3895, -66.1568);
  static const _initialZoom = 14.0;

  @override
  void initState() {
    super.initState();

    _mapController = TrufiMapController(
      initialCameraPosition: const TrufiCameraPosition(
        target: _initialPosition,
        zoom: _initialZoom,
      ),
    );

    // Initialize POI manager after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePOIs();
    });
  }

  Future<void> _initializePOIs() async {
    try {
      final poiManager = context.read<POILayersManager>();
      await poiManager.initialize(_mapController);
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing POIs: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _handlePOITap(POI poi) {
    setState(() {
      _selectedPOI = poi;
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _showMarkerSelectionDialog(List<POI> pois) {
    if (pois.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => POISelectionSheet(
        pois: pois,
        onPOISelected: (poi) {
          Navigator.pop(context);
          _handlePOITap(poi);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = context.watch<MapEngineManager>();
    final poiManager = context.watch<POILayersManager>();

    return Scaffold(
      body: Stack(
        children: [
          // Map
          mapEngineManager.currentEngine.buildMap(
            controller: _mapController,
            onMapClick: (pos) {
              final markers = _mapController.pickMarkersAt(pos, hitboxPx: 40.0);

              if (markers.isEmpty) {
                if (_selectedPOI != null) {
                  setState(() => _selectedPOI = null);
                }
              } else if (markers.length == 1) {
                final poi = poiManager.findPOIByMarkerId(markers.first.id);
                if (poi != null) {
                  _handlePOITap(poi);
                }
              } else {
                final pois = poiManager.findPOIsFromMarkers(markers);
                _showMarkerSelectionDialog(pois);
              }
            },
          ),

          // Loading indicator
          if (!poiManager.isInitialized)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Top-right action buttons
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Column(
                children: [
                  // Map Type + POI Layers button
                  MapTypeButton.fromEngines(
                    engines: mapEngineManager.engines,
                    currentEngineIndex: mapEngineManager.currentIndex,
                    onEngineChanged: (engine) {
                      mapEngineManager.setEngine(engine);
                    },
                    settingsAppBarTitle: 'Map Settings',
                    settingsSectionTitle: 'Map Type',
                    settingsApplyButtonText: 'Apply',
                    additionalSettings: Consumer<POILayersManager>(
                      builder: (context, manager, _) {
                        return POILayersSettingsSection(
                          enabledSubcategories: manager.enabledSubcategories,
                          availableSubcategories: manager.availableSubcategories,
                          onCategoryToggled: (category, enabled) {
                            manager.toggleCategory(category, enabled);
                          },
                          onSubcategoryToggled: (category, subcategory, enabled) {
                            manager.toggleSubcategory(
                                category, subcategory, enabled);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: Icons.my_location,
                    tooltip: 'Center Map',
                    onPressed: () {
                      _mapController.updateCamera(
                        target: _initialPosition,
                        zoom: _initialZoom,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // POI detail bottom sheet
          if (_selectedPOI != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: POIDetailPanel(
                  poi: _selectedPOI!,
                  onClose: () {
                    setState(() => _selectedPOI = null);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
