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
      builder: (context) => _MarkerSelectionSheet(
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
                  const SizedBox(height: 8),
                  // Debug button to show layer stats
                  _ActionButton(
                    icon: Icons.info_outline,
                    tooltip: 'Layer Stats',
                    onPressed: () => _showLayerStats(poiManager),
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
    );
  }

  void _showLayerStats(POILayersManager poiManager) {
    final stats = poiManager.getStats();
    final layerInfo = StringBuffer();

    layerInfo.writeln('📊 Layer Statistics\n');
    layerInfo.writeln('Initialized: ${stats['initialized']}');
    layerInfo.writeln('Total layers: ${stats['layer_count']}');

    final loaderStats = stats['loader_stats'] as Map<String, dynamic>;
    layerInfo.writeln('Cached categories: ${loaderStats['cached_categories']}');
    layerInfo.writeln('Total POIs: ${loaderStats['total_pois']}\n');

    layerInfo.writeln('Per-Layer Stats:');
    final layerStats = stats['layers'] as Map<String, dynamic>;
    for (final entry in layerStats.entries) {
      final layerData = entry.value as Map<String, dynamic>;
      final status = layerData['visible'] ? '✅' : '⚪';
      layerInfo.writeln(
          '$status ${entry.key}: ${layerData['poi_count']} POIs, ${layerData['visible_markers']} markers');
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

/// Bottom sheet for selecting from multiple nearby POIs
class _MarkerSelectionSheet extends StatelessWidget {
  final List<POI> pois;
  final void Function(POI poi) onPOISelected;

  const _MarkerSelectionSheet({
    required this.pois,
    required this.onPOISelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Seleccionar lugar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${pois.length} lugares',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // POI list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pois.length,
                itemBuilder: (context, index) {
                  final poi = pois[index];
                  return _MarkerSelectionTile(
                    poi: poi,
                    onTap: () => onPOISelected(poi),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual tile for marker selection
class _MarkerSelectionTile extends StatelessWidget {
  final POI poi;
  final VoidCallback onTap;

  const _MarkerSelectionTile({
    required this.poi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: poi.category.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                poi.type.icon,
                color: poi.category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // POI info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    poi.category.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
