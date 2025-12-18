import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../configuration/map_engine/map_engine_manager.dart';
import '../../configuration/map_engine/trufi_map_engine.dart';
import '../../domain/controller/map_controller.dart';
import '../../domain/entities/camera.dart';
import 'map_type_settings_screen.dart';

/// Represents the center position of the map.
class MapCenter {
  final double latitude;
  final double longitude;

  const MapCenter(this.latitude, this.longitude);
}

/// Result returned by [ChooseOnMapScreen] when user confirms selection.
class MapLocationResult {
  final double latitude;
  final double longitude;

  const MapLocationResult({
    required this.latitude,
    required this.longitude,
  });
}

/// Configuration for the ChooseOnMapScreen appearance.
class ChooseOnMapConfiguration {
  /// Title shown in the app bar.
  final String title;

  /// Text for the confirm button.
  final String confirmButtonText;

  /// Widget to show as the center marker.
  final Widget? centerMarker;

  /// Whether to show coordinates card.
  final bool showCoordinates;

  /// Initial latitude for the map center.
  /// If null, uses MapEngineManager.defaultCenter.latitude from context.
  final double? initialLatitude;

  /// Initial longitude for the map center.
  /// If null, uses MapEngineManager.defaultCenter.longitude from context.
  final double? initialLongitude;

  /// Initial zoom level.
  /// If null, uses MapEngineManager.defaultZoom from context.
  final double? initialZoom;

  /// Whether to show the map type button.
  final bool showMapTypeButton;

  const ChooseOnMapConfiguration({
    this.title = 'Choose on Map',
    this.confirmButtonText = 'Confirm Location',
    this.centerMarker,
    this.showCoordinates = true,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom,
    this.showMapTypeButton = true,
  });

  ChooseOnMapConfiguration copyWith({
    String? title,
    String? confirmButtonText,
    Widget? centerMarker,
    bool? showCoordinates,
    double? initialLatitude,
    double? initialLongitude,
    double? initialZoom,
    bool? showMapTypeButton,
  }) {
    return ChooseOnMapConfiguration(
      title: title ?? this.title,
      confirmButtonText: confirmButtonText ?? this.confirmButtonText,
      centerMarker: centerMarker ?? this.centerMarker,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      initialLatitude: initialLatitude ?? this.initialLatitude,
      initialLongitude: initialLongitude ?? this.initialLongitude,
      initialZoom: initialZoom ?? this.initialZoom,
      showMapTypeButton: showMapTypeButton ?? this.showMapTypeButton,
    );
  }
}

/// A screen for choosing a location on a map.
///
/// Uses [MapEngineManager] from Provider to render the map.
/// Make sure to provide a [MapEngineManager] in the widget tree.
///
/// Returns a [MapLocationResult] when the user confirms their selection.
///
/// Example usage:
/// ```dart
/// // Ensure MapEngineManager is provided in the widget tree
/// ChangeNotifierProvider(
///   create: (_) => MapEngineManager(engines: defaultMapEngines),
///   child: ...,
/// )
///
/// // Then use ChooseOnMapScreen
/// final result = await Navigator.push<MapLocationResult>(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const ChooseOnMapScreen(
///       configuration: ChooseOnMapConfiguration(
///         initialLatitude: -17.3920,
///         initialLongitude: -66.1575,
///       ),
///     ),
///   ),
/// );
/// ```
class ChooseOnMapScreen extends StatefulWidget {
  /// Configuration for the screen appearance.
  final ChooseOnMapConfiguration configuration;

  const ChooseOnMapScreen({
    super.key,
    this.configuration = const ChooseOnMapConfiguration(),
  });

  @override
  State<ChooseOnMapScreen> createState() => _ChooseOnMapScreenState();
}

class _ChooseOnMapScreenState extends State<ChooseOnMapScreen> {
  TrufiMapController? _mapController;
  late double _currentLatitude;
  late double _currentLongitude;
  bool _initialized = false;

  void _initializeIfNeeded(MapEngineManager mapEngineManager) {
    if (!_initialized) {
      _initialized = true;
      final config = widget.configuration;
      _currentLatitude =
          config.initialLatitude ?? mapEngineManager.defaultCenter.latitude;
      _currentLongitude =
          config.initialLongitude ?? mapEngineManager.defaultCenter.longitude;
      final zoom = config.initialZoom ?? mapEngineManager.defaultZoom;

      _mapController = TrufiMapController(
        initialCameraPosition: TrufiCameraPosition(
          target: LatLng(_currentLatitude, _currentLongitude),
          zoom: zoom,
        ),
      );

      _mapController!.cameraPositionNotifier.addListener(_onCameraChanged);
    }
  }

  @override
  void dispose() {
    _mapController?.cameraPositionNotifier.removeListener(_onCameraChanged);
    _mapController?.dispose();
    super.dispose();
  }

  void _onCameraChanged() {
    final position = _mapController?.cameraPositionNotifier.value;
    if (position == null) return;
    setState(() {
      _currentLatitude = position.target.latitude;
      _currentLongitude = position.target.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.watch(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    _initializeIfNeeded(mapEngineManager);

    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Map using the current engine
          mapEngineManager.currentEngine.buildMap(
            controller: _mapController!,
            isDarkMode: isDarkMode,
          ),

          // Center marker with modern design
          Center(
            child: IgnorePointer(
              child: widget.configuration.centerMarker ??
                  _DefaultCenterMarker(colorScheme: colorScheme),
            ),
          ),

          // Modern header with back button and title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    // Back button
                    Material(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      elevation: 2,
                      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: colorScheme.onSurface,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title card
                    Expanded(
                      child: Material(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        elevation: 2,
                        shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            widget.configuration.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Map type button
                    if (widget.configuration.showMapTypeButton &&
                        mapEngineManager.engines.length > 1) ...[
                      const SizedBox(width: 12),
                      Material(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        elevation: 2,
                        shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _openMapTypeSettings(context, mapEngineManager);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.layers_rounded,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Coordinates display with modern styling
          if (widget.configuration.showCoordinates)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 72),
                  child: Center(
                    child: _CoordinatesCard(
                      latitude: _currentLatitude,
                      longitude: _currentLongitude,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom action area with confirm button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.surface.withValues(alpha: 0),
                      colorScheme.surface.withValues(alpha: 0.8),
                      colorScheme.surface,
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(
                      context,
                      MapLocationResult(
                        latitude: _currentLatitude,
                        longitude: _currentLongitude,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 22),
                  label: Text(widget.configuration.confirmButtonText),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMapTypeSettings(
      BuildContext context, MapEngineManager mapEngineManager) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapTypeSettingsScreen(
          currentMapIndex: mapEngineManager.currentIndex,
          mapOptions: mapEngineManager.engines.toMapTypeOptions(),
          onMapTypeChanged: (index) {
            mapEngineManager.setEngine(mapEngineManager.engines[index]);
          },
        ),
      ),
    );
  }
}

/// Default center marker with modern design
class _DefaultCenterMarker extends StatelessWidget {
  final ColorScheme colorScheme;

  const _DefaultCenterMarker({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.place_rounded,
            color: colorScheme.onPrimary,
            size: 28,
          ),
        ),
        // Pin tail
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Coordinates card with modern styling
class _CoordinatesCard extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _CoordinatesCard({
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.my_location_rounded,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
