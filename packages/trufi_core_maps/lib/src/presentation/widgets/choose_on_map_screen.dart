import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../configuration/map_engine/map_engine_manager.dart';
import '../../domain/controller/map_controller.dart';
import '../../domain/entities/camera.dart';
import 'map_type_button.dart';

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
  final double initialLatitude;

  /// Initial longitude for the map center.
  final double initialLongitude;

  /// Initial zoom level.
  final double initialZoom;

  /// Whether to show the map type button.
  final bool showMapTypeButton;

  const ChooseOnMapConfiguration({
    this.title = 'Choose on Map',
    this.confirmButtonText = 'Confirm Location',
    this.centerMarker,
    this.showCoordinates = true,
    this.initialLatitude = 0.0,
    this.initialLongitude = 0.0,
    this.initialZoom = 14.0,
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
  late final TrufiMapController _mapController;
  late double _currentLatitude;
  late double _currentLongitude;

  @override
  void initState() {
    super.initState();
    _currentLatitude = widget.configuration.initialLatitude;
    _currentLongitude = widget.configuration.initialLongitude;

    _mapController = TrufiMapController(
      initialCameraPosition: TrufiCameraPosition(
        target: LatLng(_currentLatitude, _currentLongitude),
        zoom: widget.configuration.initialZoom,
      ),
    );

    _mapController.cameraPositionNotifier.addListener(_onCameraChanged);
  }

  @override
  void dispose() {
    _mapController.cameraPositionNotifier.removeListener(_onCameraChanged);
    _mapController.dispose();
    super.dispose();
  }

  void _onCameraChanged() {
    final position = _mapController.cameraPositionNotifier.value;
    setState(() {
      _currentLatitude = position.target.latitude;
      _currentLongitude = position.target.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapEngineManager = MapEngineManager.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.configuration.title),
      ),
      body: Stack(
        children: [
          // Map using the current engine
          mapEngineManager.currentEngine.buildMap(
            controller: _mapController,
          ),

          // Center marker
          Center(
            child: IgnorePointer(
              child: widget.configuration.centerMarker ??
                  const Icon(
                    Icons.location_on,
                    size: 50,
                    color: Colors.red,
                  ),
            ),
          ),

          // Coordinates display
          if (widget.configuration.showCoordinates)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Lat: ${_currentLatitude.toStringAsFixed(6)}, '
                    'Lng: ${_currentLongitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Map type button
          if (widget.configuration.showMapTypeButton &&
              mapEngineManager.engines.length > 1)
            Positioned(
              top: widget.configuration.showCoordinates ? 70 : 16,
              right: 16,
              child: SafeArea(
                child: MapTypeButton.fromEngines(
                  engines: mapEngineManager.engines,
                  currentEngineIndex: mapEngineManager.currentIndex,
                  onEngineChanged: (engine) {
                    mapEngineManager.setEngine(engine);
                  },
                ),
              ),
            ),

          // Confirm button
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: SafeArea(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                    MapLocationResult(
                      latitude: _currentLatitude,
                      longitude: _currentLongitude,
                    ),
                  );
                },
                child: Text(widget.configuration.confirmButtonText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
