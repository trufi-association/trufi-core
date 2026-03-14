import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../configuration/map_engine/map_engine_manager.dart';
import '../../configuration/map_engine/trufi_map_engine.dart';
import '../../domain/entities/camera.dart';
import 'map_type_settings_screen.dart';

class MapCenter {
  final double latitude;
  final double longitude;
  const MapCenter(this.latitude, this.longitude);
}

class MapLocationResult {
  final double latitude;
  final double longitude;
  const MapLocationResult({required this.latitude, required this.longitude});
}

class ChooseOnMapConfiguration {
  final String title;
  final String confirmButtonText;
  final Widget? centerMarker;
  final bool showCoordinates;
  final double? initialLatitude;
  final double? initialLongitude;
  final double? initialZoom;
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

class ChooseOnMapScreen extends StatefulWidget {
  final ChooseOnMapConfiguration configuration;

  const ChooseOnMapScreen({
    super.key,
    this.configuration = const ChooseOnMapConfiguration(),
  });

  @override
  State<ChooseOnMapScreen> createState() => _ChooseOnMapScreenState();
}

class _ChooseOnMapScreenState extends State<ChooseOnMapScreen> {
  late double _currentLatitude;
  late double _currentLongitude;
  late TrufiCameraPosition _initialCamera;
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

      _initialCamera = TrufiCameraPosition(
        target: LatLng(_currentLatitude, _currentLongitude),
        zoom: zoom,
      );
    }
  }

  void _onCameraChanged(TrufiCameraPosition position) {
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          mapEngineManager.currentEngine.buildMap(
            initialCamera: _initialCamera,
            onCameraChanged: _onCameraChanged,
          ),
          Center(
            child: IgnorePointer(
              child:
                  widget.configuration.centerMarker ??
                  _DefaultCenterMarker(colorScheme: colorScheme),
            ),
          ),
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
    BuildContext context,
    MapEngineManager mapEngineManager,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapTypeSettingsScreen(
          currentMapIndex: mapEngineManager.currentIndex,
          mapOptions: mapEngineManager.engines.toMapTypeOptions(context),
          onMapTypeChanged: (index) {
            mapEngineManager.setEngine(mapEngineManager.engines[index]);
          },
        ),
      ),
    );
  }
}

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

class _CoordinatesCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  const _CoordinatesCard({required this.latitude, required this.longitude});

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
