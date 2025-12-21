import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_poi_layers/trufi_core_poi_layers.dart' hide LatLngBounds;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        title: 'POI Layers Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
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
  late final POILayersCubit _poiCubit;
  late final POITrufiLayer _poiLayer;
  late final POIPolygonOutlineLayer _polygonLayer;
  POI? _selectedPOI;
  double _currentZoom = _initialZoom;
  latlng.LatLng _currentCenter = _initialPosition;
  LatLngBounds? _currentBounds;
  static const String _poiLayerId = 'poi_markers';
  static const String _polygonLayerId = 'poi_polygon_outlines';

  // Debounce timer for camera updates
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 150);

  // Cochabamba, Bolivia coordinates
  static const _initialPosition = latlng.LatLng(-17.3895, -66.1568);
  static const _initialZoom = 14.0;

  // Maximum markers to render at once (for performance)
  static const int _maxMarkersToRender = 200;

  // All POIs in viewport (for tap detection in MapLibre)
  // This includes POIs hidden due to overlap filtering
  List<POI> _allViewportPOIs = [];

  @override
  void initState() {
    super.initState();

    _mapController = TrufiMapController(
      initialCameraPosition: const TrufiCameraPosition(
        target: _initialPosition,
        zoom: _initialZoom,
      ),
    );

    // Create POI layers
    _poiLayer = POITrufiLayer(_mapController, id: _poiLayerId);
    _polygonLayer = POIPolygonOutlineLayer(_mapController, id: _polygonLayerId);

    _poiCubit = POILayersCubit(
      config: const POILayerConfig(
        assetsBasePath: 'assets/pois',
      ),
      onPOITapped: _handlePOITap,
      defaultEnabledCategories: POICategory.values.toSet(),
    );

    _initializePOIs();

    // Listen to POI changes and update map
    _poiCubit.stream.listen((state) {
      _scheduleUpdate();
    });

    // Listen to camera changes with debouncing
    _mapController.cameraPositionNotifier.addListener(_onCameraChanged);
  }

  void _onCameraChanged() {
    final cam = _mapController.cameraPositionNotifier.value;
    final newZoom = cam.zoom;
    final newCenter = cam.target;
    final newBounds = cam.visibleRegion;

    // Check if camera moved significantly
    final zoomChanged = (newZoom - _currentZoom).abs() > 0.3;
    final centerChanged = _calculateDistance(_currentCenter, newCenter) > 0.001;

    if (zoomChanged || centerChanged) {
      _currentZoom = newZoom;
      _currentCenter = newCenter;
      _currentBounds = newBounds;
      _scheduleUpdate();
    }
  }

  /// Debounce updates to avoid excessive re-rendering during pan/zoom
  void _scheduleUpdate() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        _updatePOILayer(_poiCubit.state, _currentZoom);
      }
    });
  }

  /// Simple distance calculation for debouncing
  double _calculateDistance(latlng.LatLng a, latlng.LatLng b) {
    return math.sqrt(
      math.pow(a.latitude - b.latitude, 2) +
          math.pow(a.longitude - b.longitude, 2),
    );
  }
  
  // Cache marker widgets by category to avoid recreating identical widgets
  final Map<POICategory, Widget> _fullMarkerCache = {};
  final Map<POICategory, Widget> _dotMarkerCache = {};

  // Zoom thresholds for POI display
  static const int _minZoomForDots = 14; // Show dots from zoom 14
  static const int _minZoomForFullIcons = 17; // Show full icons from zoom 17

  // Minimum distance between markers in degrees (adjusted by zoom)
  // This prevents overlapping markers
  double _getMinMarkerDistance(int zoom) {
    // At zoom 14: ~0.001 degrees (~100m between markers)
    // At zoom 17: ~0.0001 degrees (~10m between markers)
    // At zoom 18+: very small, show almost all
    return 0.015 / math.pow(2, zoom - 10);
  }

  /// Get full marker widget with icon
  Widget _getFullMarkerWidget(POICategory category) {
    return _fullMarkerCache.putIfAbsent(
      category,
      () => Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: category.color, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          category.icon,
          color: category.color,
          size: 17,
        ),
      ),
    );
  }

  /// Get simple dot marker (colored circle without icon)
  Widget _getDotMarkerWidget(POICategory category) {
    return _dotMarkerCache.putIfAbsent(
      category,
      () => Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: category.color,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 1,
              offset: Offset(0, 0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if a POI is within the visible bounds (with padding)
  bool _isInViewport(POI poi, LatLngBounds? bounds) {
    if (bounds == null) return true; // Show all if bounds unknown

    // Add padding to bounds (10% extra on each side)
    final latPadding = (bounds.northEast.latitude - bounds.southWest.latitude) * 0.1;
    final lngPadding = (bounds.northEast.longitude - bounds.southWest.longitude) * 0.1;

    return poi.position.latitude >= bounds.southWest.latitude - latPadding &&
        poi.position.latitude <= bounds.northEast.latitude + latPadding &&
        poi.position.longitude >= bounds.southWest.longitude - lngPadding &&
        poi.position.longitude <= bounds.northEast.longitude + lngPadding;
  }

  void _updatePOILayer(POILayersState state, double zoom) {
    if (!state.isInitialized) return;

    final markers = <TrufiMarker>[];
    final polygonLines = <TrufiLine>[];
    final zoomInt = zoom.floor();

    // Don't show any POIs below zoom 14
    if (zoomInt < _minZoomForDots) {
      _poiLayer.setMarkers(markers);
      _polygonLayer.setLines(polygonLines);
      return;
    }

    // Collect POIs visible in viewport, prioritizing named POIs
    final namedPOIs = <POI>[];
    final unnamedPOIs = <POI>[];

    for (final category in state.enabledCategoriesSet) {
      // Skip if zoom is too low for this category
      if (zoomInt < category.minZoom) continue;

      final layer = state.layers[category];
      if (layer != null) {
        for (final poi in layer.pois) {
          // Skip if POI is not enabled (category/subcategory filtering)
          if (!state.isPOIEnabled(poi)) continue;

          // Skip large areas at lower zoom
          if (poi.isLargeArea && zoomInt < 15) continue;

          // Filter by viewport (partial rendering)
          if (!_isInViewport(poi, _currentBounds)) continue;

          // Separate named vs unnamed for priority
          if (poi.name != null && poi.name!.isNotEmpty) {
            namedPOIs.add(poi);
          } else {
            unnamedPOIs.add(poi);
          }
        }
      }
    }

    // Combine with named POIs first (they have priority)
    final allVisiblePOIs = [...namedPOIs, ...unnamedPOIs];

    // Filter out overlapping POIs - only show markers that don't overlap
    final minDistance = _getMinMarkerDistance(zoomInt);
    final visiblePOIs = _filterOverlappingPOIs(allVisiblePOIs, minDistance);

    // Limit total POIs for performance
    final poisToShow = visiblePOIs.length > _maxMarkersToRender
        ? visiblePOIs.sublist(0, _maxMarkersToRender)
        : visiblePOIs;

    // Create markers for non-overlapping POIs
    for (final poi in poisToShow) {
      final category = poi.category;
      // Show full icons at zoom 15+, dots below that
      final showFullIcon = zoomInt >= _minZoomForFullIcons;

      final imageKey = showFullIcon
          ? 'poi_full_${category.name}'
          : 'poi_dot_${category.name}';
      final markerWidget = showFullIcon
          ? _getFullMarkerWidget(category)
          : _getDotMarkerWidget(category);

      // Use fixed sizes in pixels
      // Full icons: 30x30, Dots: 4x4 (very small and subtle)
      final markerSize = showFullIcon ? const Size(30, 30) : const Size(4, 4);

      markers.add(
        TrufiMarker(
          id: '${category.name}_${poi.id}',
          position: poi.position,
          size: markerSize,
          layerLevel: 100,
          imageKey: imageKey,
          widget: GestureDetector(
            onTap: () => _onPOITapped(poi),
            child: markerWidget,
          ),
        ),
      );
    }

    // Render polygon outlines for POIs with area geometry
    // Show polygons starting from zoom 15
    if (zoomInt >= 15) {
      for (final category in state.enabledCategoriesSet) {
        final layer = state.layers[category];
        if (layer != null) {
          for (final poi in layer.pois) {
            // Skip if POI is not enabled (category/subcategory filtering)
            if (!state.isPOIEnabled(poi)) continue;

            // Only render POIs with polygon geometry
            if (poi.isArea && poi.polygonPoints != null && poi.polygonPoints!.isNotEmpty) {
              // Filter by viewport
              if (!_isInViewport(poi, _currentBounds)) continue;

              // Create line for polygon outline
              polygonLines.add(
                TrufiLine(
                  id: 'polygon_${category.name}_${poi.id}',
                  position: poi.polygonPoints!,
                  color: category.color.withValues(alpha: 0.3),
                  lineWidth: 2,
                ),
              );
            }
          }
        }
      }
    }

    debugPrint(
      'POI layer: ${markers.length} markers, ${polygonLines.length} polygons shown at zoom $zoomInt',
    );

    // Store ALL viewport POIs for tap detection (needed for MapLibre)
    // This includes POIs hidden due to overlap filtering
    _allViewportPOIs = allVisiblePOIs;

    _poiLayer.setMarkers(markers);
    _polygonLayer.setLines(polygonLines);
  }

  /// Filter out POIs that would overlap with already visible ones
  /// Named POIs and POIs that appear first have priority
  List<POI> _filterOverlappingPOIs(List<POI> pois, double minDistance) {
    final result = <POI>[];
    final occupiedPositions = <latlng.LatLng>[];

    for (final poi in pois) {
      // Check if this POI would overlap with any already visible POI
      bool overlaps = false;
      for (final occupied in occupiedPositions) {
        final distance = _calculateDistance(poi.position, occupied);
        if (distance < minDistance) {
          overlaps = true;
          break;
        }
      }

      if (!overlaps) {
        result.add(poi);
        occupiedPositions.add(poi.position);
      }
    }

    return result;
  }

  /// Handle POI tap
  void _onPOITapped(POI poi) {
    debugPrint('POI tapped: ${poi.name}');
    setState(() => _selectedPOI = poi);
    _showPOIDetails(poi);
  }

  Future<void> _initializePOIs() async {
    try {
      await _poiCubit.initialize();
      
      if (mounted) {
        setState(() {});
      }
      final state = _poiCubit.state;
      debugPrint('POI layers initialized: ${state.allLayers.length} layers');
      for (final layer in state.allLayers) {
        debugPrint('  ${layer.category.name}: ${layer.pois.length} POIs');
      }
      debugPrint('Enabled categories: ${state.enabledCategoriesSet.map((c) => c.name).join(", ")}');
      debugPrint('Total POIs: ${state.allLayers.fold<int>(0, (sum, layer) => sum + layer.pois.length)}');
      
      // Initial update
      _updatePOILayer(state, _currentZoom);
    } catch (e) {
      debugPrint('Error initializing POIs: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  void _handlePOITap(POI poi) {
    setState(() {
      _selectedPOI = poi;
    });
    _showPOIDetails(poi);
  }

  void _showPOIDetails(POI poi) {
    // Now using TrufiBottomSheet in the Stack, no modal needed
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _poiCubit.close();
    _mapController.dispose();
    super.dispose();
  }

  /// Find all POIs near a tap position within a threshold
  /// Searches ALL viewport POIs, including those hidden due to overlap filtering
  List<POI> _findNearbyPOIs(latlng.LatLng tapPosition) {
    if (_allViewportPOIs.isEmpty) return [];

    // Tap threshold in degrees - larger radius for easy tapping
    // At zoom 14: ~0.004 degrees (~400m radius)
    // At zoom 16: ~0.001 degrees (~100m radius)
    // At zoom 18: ~0.00025 degrees (~25m radius)
    // At zoom 20: ~0.00006 degrees (~6m radius)
    final zoomFactor = math.pow(2, (_currentZoom - 14).clamp(0, 6));
    final threshold = 0.004 / zoomFactor;

    final nearby = <_ScoredPOI>[];

    // Search ALL viewport POIs, not just displayed ones
    for (final poi in _allViewportPOIs) {
      final distance = _calculateDistance(poi.position, tapPosition);
      if (distance < threshold) {
        nearby.add(_ScoredPOI(poi, distance));
      }
    }

    // Sort by distance (closest first)
    nearby.sort((a, b) => a.distance.compareTo(b.distance));

    return nearby.map((s) => s.poi).toList();
  }

  /// Show selection popup when multiple POIs are near tap position
  void _showPOISelectionPopup(List<POI> pois) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _POISelectionSheet(
        pois: pois,
        onPOISelected: (poi) {
          Navigator.pop(context);
          _onPOITapped(poi);
        },
      ),
    );
  }

  Widget _buildMap(ITrufiMapEngine engine) {
    return engine.buildMap(
      controller: _mapController,
      onMapClick: (pos) {
        debugPrint('Map clicked at: $pos');
        // Find all POIs near the tap position
        final nearbyPOIs = _findNearbyPOIs(pos);

        if (nearbyPOIs.isEmpty) {
          // Close bottom sheet if tapping on empty area
          if (_selectedPOI != null) {
            setState(() => _selectedPOI = null);
          }
        } else if (nearbyPOIs.length == 1) {
          // Single POI - open directly
          debugPrint('Found POI: ${nearbyPOIs.first.displayName}');
          _onPOITapped(nearbyPOIs.first);
        } else {
          // Multiple POIs - show selection popup
          debugPrint('Found ${nearbyPOIs.length} POIs nearby');
          _showPOISelectionPopup(nearbyPOIs);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.watch(context);
    
    return BlocProvider.value(
      value: _poiCubit,
      child: Builder(
        builder: (context) => Scaffold(
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
                      MapTypeButton.fromEngines(
                        engines: mapEngineManager.engines,
                        currentEngineIndex: mapEngineManager.currentIndex,
                        onEngineChanged: (engine) {
                          mapEngineManager.setEngine(engine);
                        },
                        settingsAppBarTitle: 'Map Settings',
                        settingsSectionTitle: 'Map Type',
                        settingsApplyButtonText: 'Apply',
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        icon: Icons.layers,
                        tooltip: 'POI Layers',
                        onPressed: () => _showLayersBottomSheet(context),
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        icon: Icons.my_location,
                        tooltip: 'Center Map',
                        onPressed: _centerMap,
                      ),
                    ],
                  ),
                ),
              ),

              // POI detail bottom sheet - animated panel that works with MapLibre
              if (_selectedPOI != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _POIBottomSheet(
                    poi: _selectedPOI!,
                    onClose: () {
                      setState(() {
                        _selectedPOI = null;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLayersBottomSheet(BuildContext context) {
    final cubit = context.read<POILayersCubit>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<POILayersCubit, POILayersState>(
          builder: (context, state) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.layers),
                        const SizedBox(width: 12),
                        Text(
                          'POI Layers',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      child: POILayersSettingsSection(
                        enabledCategories: state.enabledCategories,
                        enabledSubcategories: state.enabledSubcategories,
                        availableSubcategories: {
                          for (final cat in POICategory.values)
                            cat: cubit.getSubcategories(cat),
                        },
                        onCategoryToggled: (category, enabled) {
                          _poiCubit.toggleCategory(category, enabled);
                        },
                        onSubcategoryToggled: (category, subcategory, enabled) {
                          _poiCubit.toggleSubcategory(category, subcategory, enabled);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _centerMap() {
    _mapController.updateCamera(
      target: _initialPosition,
      zoom: _initialZoom,
    );
  }
}

// Action button widget similar to the maps example
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

/// Simple concrete implementation of TrufiLayer for POI markers
class POITrufiLayer extends TrufiLayer {
  POITrufiLayer(
    super.controller, {
    required super.id,
  }) : super(layerLevel: 100);
}

/// TrufiLayer for POI polygon outlines (rendered below markers)
class POIPolygonOutlineLayer extends TrufiLayer {
  POIPolygonOutlineLayer(
    super.controller, {
    required super.id,
  }) : super(layerLevel: 50);
}

/// Animated bottom sheet for POI details - works with both FlutterMap and MapLibre
class _POIBottomSheet extends StatefulWidget {
  final POI poi;
  final VoidCallback onClose;

  const _POIBottomSheet({
    required this.poi,
    required this.onClose,
  });

  @override
  State<_POIBottomSheet> createState() => _POIBottomSheetState();
}

class _POIBottomSheetState extends State<_POIBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final poi = widget.poi;

    return SlideTransition(
      position: _slideAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
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
                      // Header with icon, name and close button
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
                                  poi.type.name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _close,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Details
                      if (poi.address != null) ...[
                        _InfoRow(icon: Icons.location_on_outlined, text: poi.address!),
                        const SizedBox(height: 10),
                      ],
                      if (poi.openingHours != null) ...[
                        _InfoRow(icon: Icons.access_time_outlined, text: poi.openingHours!),
                        const SizedBox(height: 10),
                      ],
                      if (poi.phone != null) ...[
                        _InfoRow(icon: Icons.phone_outlined, text: poi.phone!),
                        const SizedBox(height: 10),
                      ],
                      if (poi.website != null) ...[
                        _InfoRow(icon: Icons.language_outlined, text: poi.website!),
                        const SizedBox(height: 10),
                      ],

                      const SizedBox(height: 8),

                      // Coordinates
                      _InfoRow(
                        icon: Icons.pin_drop_outlined,
                        text: '${poi.position.latitude.toStringAsFixed(5)}, ${poi.position.longitude.toStringAsFixed(5)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Info row widget for POI details
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

/// Helper class for sorting POIs by distance
class _ScoredPOI {
  final POI poi;
  final double distance;

  _ScoredPOI(this.poi, this.distance);
}

/// Bottom sheet for selecting from multiple nearby POIs
class _POISelectionSheet extends StatelessWidget {
  final List<POI> pois;
  final void Function(POI) onPOISelected;

  const _POISelectionSheet({
    required this.pois,
    required this.onPOISelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
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
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app,
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
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pois.length,
              itemBuilder: (context, index) {
                final poi = pois[index];
                return _POIListTile(
                  poi: poi,
                  onTap: () => onPOISelected(poi),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// List tile for POI selection
class _POIListTile extends StatelessWidget {
  final POI poi;
  final VoidCallback onTap;

  const _POIListTile({
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
                    poi.type.name,
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
