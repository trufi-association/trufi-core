import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart' hide LatLngBounds;

/// Example demonstrating the multi-instance POI layer pattern.
///
/// This example shows how to use POICategoryLayer with:
/// - One layer instance per POI category
/// - All data loaded upfront in parallel
/// - Direct layer creation without factory
/// - Subcategory-only toggling (categories derived from subcategories)
///
/// Compare this to the main.dart example which uses manual layer management.
void main() {
  runApp(const MultiInstanceExampleApp());
}

class MultiInstanceExampleApp extends StatelessWidget {
  const MultiInstanceExampleApp({super.key});

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
      ],
      child: MaterialApp(
        title: 'POI Layers Multi-Instance Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MultiInstanceDemoPage(),
      ),
    );
  }
}

class MultiInstanceDemoPage extends StatefulWidget {
  const MultiInstanceDemoPage({super.key});

  @override
  State<MultiInstanceDemoPage> createState() => _MultiInstanceDemoPageState();
}

class _MultiInstanceDemoPageState extends State<MultiInstanceDemoPage> {
  late final TrufiMapController _mapController;
  late final POILayersCubit _poiCubit;
  late final GeoJSONLoader _loader;
  List<POICategoryLayer> _poiLayers = [];

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

    // Create loader
    _loader = GeoJSONLoader(assetsBasePath: 'assets/pois');

    // Create POI cubit
    _poiCubit = POILayersCubit();

    // Initialize POIs
    _initializePOIs();
  }

  Future<void> _initializePOIs() async {
    try {
      // Load all GeoJSON data and create layers
      // 1. Load all categories in parallel
      final loadingFutures = POICategory.values
          .map((category) => _loader
              .loadCategory(category)
              .then((pois) => MapEntry(category, pois)))
          .toList();

      final loadedData = await Future.wait(loadingFutures);

      // 2. Create one layer per category with pre-loaded data
      _poiLayers = loadedData
          .map((entry) => POICategoryLayer(
                controller: _mapController,
                category: entry.key,
                pois: entry.value,
                cubit: _poiCubit,
              ))
          .toList();

      debugPrint('✅ Created ${_poiLayers.length} POI layer instances');
      for (final layer in _poiLayers) {
        debugPrint('  - Layer: ${layer.id}, POIs: ${layer.poiCount}, visible: ${layer.visible}');
      }

      if (mounted) {
        setState(() {});
      }
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
    _poiCubit.close();
    _mapController.dispose();
    super.dispose();
  }

  Widget _buildMap(ITrufiMapEngine engine) {
    return engine.buildMap(
      controller: _mapController,
      onMapClick: (pos) {
        // Use built-in marker picking from TrufiMapController
        final markers = _mapController.pickMarkersAt(pos, hitboxPx: 40.0);

        if (markers.isEmpty) {
          // Close bottom sheet if tapping on empty area
          if (_selectedPOI != null) {
            setState(() => _selectedPOI = null);
          }
        } else if (markers.length == 1) {
          // Single marker - find the POI
          final marker = markers.first;
          _findAndSelectPOI(marker.id);
        } else {
          // Multiple markers - show selection
          debugPrint('Found ${markers.length} markers nearby');
          // Could show selection dialog here
        }
      },
    );
  }

  void _findAndSelectPOI(String markerId) {
    // Extract category and POI ID from marker ID
    // Format: "poi_<category>_<poi_id>"
    final parts = markerId.split('_');
    if (parts.length < 3) return;

    final categoryName = parts[1];
    final poiId = parts.sublist(2).join('_');

    // Find the layer
    final layer = _poiLayers.firstWhere(
      (l) => l.category.name == categoryName,
      orElse: () => _poiLayers.first,
    );

    // Find the POI in the layer
    final poi = layer.pois.firstWhere(
      (p) => p.id == poiId,
      orElse: () => layer.pois.first,
    );
    _handlePOITap(poi);
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.watch(context);

    return BlocProvider.value(
      value: _poiCubit,
      child: Scaffold(
        body: Stack(
          children: [
            // Map
            _buildMap(mapEngineManager.currentEngine),

            // Top-right action buttons
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: Column(
                  children: [
                    // Map Type + POI Layers button
                    BlocBuilder<POILayersCubit, POILayersState>(
                      builder: (context, state) {
                        return MapTypeButton.fromEngines(
                          engines: mapEngineManager.engines,
                          currentEngineIndex: mapEngineManager.currentIndex,
                          onEngineChanged: (engine) {
                            mapEngineManager.setEngine(engine);
                          },
                          settingsAppBarTitle: 'Map Settings',
                          settingsSectionTitle: 'Map Type',
                          settingsApplyButtonText: 'Apply',
                          // Integrated POI layers settings
                          additionalSettings: POILayersSettingsSection(
                            enabledSubcategories: state.enabledSubcategories,
                            availableSubcategories: {
                              for (final layer in _poiLayers)
                                layer.category: layer.pois
                                    .where((poi) => poi.subcategory != null)
                                    .map((poi) => poi.subcategory!)
                                    .toSet(),
                            },
                            onCategoryToggled: (category, enabled) {
                              final subcats = _poiLayers
                                  .firstWhere((l) => l.category == category)
                                  .pois
                                  .where((poi) => poi.subcategory != null)
                                  .map((poi) => poi.subcategory!)
                                  .toSet();
                              _poiCubit.toggleCategory(category, enabled, subcats);
                            },
                            onSubcategoryToggled:
                                (category, subcategory, enabled) {
                              _poiCubit.toggleSubcategory(
                                  category, subcategory, enabled);
                            },
                          ),
                        );
                      },
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
                    const SizedBox(height: 8),
                    // Debug button to show layer stats
                    _ActionButton(
                      icon: Icons.info_outline,
                      tooltip: 'Layer Stats',
                      onPressed: _showLayerStats,
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
                child: _POIBottomSheet(
                  poi: _selectedPOI!,
                  onClose: () {
                    setState(() => _selectedPOI = null);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLayerStats() {
    final loaderStats = _loader.getStats();
    final layerInfo = StringBuffer();

    layerInfo.writeln('📊 Layer Statistics\n');
    layerInfo.writeln('Total layers: ${_poiLayers.length}');
    layerInfo.writeln(
        'Cached categories: ${loaderStats['cached_categories']}');
    layerInfo.writeln(
        'Loading categories: ${loaderStats['loading_categories']}');
    layerInfo.writeln('Total POIs: ${loaderStats['total_pois']}\n');

    layerInfo.writeln('Per-Layer Stats:');
    for (final layer in _poiLayers) {
      final status = layer.visible ? '✅' : '⚪';
      layerInfo.writeln(
          '$status ${layer.category.name}: ${layer.poiCount} POIs, ${layer.visibleMarkerCount} markers');
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Layer Statistics'),
        content: SingleChildScrollView(
          child: Text(
            layerInfo.toString(),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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

/// Simple bottom sheet for POI details
class _POIBottomSheet extends StatelessWidget {
  final POI poi;
  final VoidCallback onClose;

  const _POIBottomSheet({
    required this.poi,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grabber handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: poi.category.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          poi.type.icon,
                          color: poi.category.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              poi.displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${poi.category.name} • ${poi.type.name}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Details
                  if (poi.address != null) ...[
                    _InfoRow(
                        icon: Icons.location_on_outlined, text: poi.address!),
                    const SizedBox(height: 8),
                  ],
                  _InfoRow(
                    icon: Icons.pin_drop_outlined,
                    text:
                        '${poi.position.latitude.toStringAsFixed(5)}, ${poi.position.longitude.toStringAsFixed(5)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Info row widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
