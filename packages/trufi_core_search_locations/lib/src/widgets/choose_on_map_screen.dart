import 'package:flutter/material.dart';

import '../models/search_location.dart';

/// Callback to build a map widget.
///
/// [onCenterChanged] should be called when the map center changes (e.g., on pan).
/// The implementation should track the map's center position.
typedef MapWidgetBuilder = Widget Function({
  required double initialLatitude,
  required double initialLongitude,
  required double initialZoom,
  required ValueChanged<MapCenter> onCenterChanged,
});

/// Represents the center position of the map.
class MapCenter {
  final double latitude;
  final double longitude;

  const MapCenter(this.latitude, this.longitude);
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

  const ChooseOnMapConfiguration({
    this.title = 'Choose on Map',
    this.confirmButtonText = 'Confirm Location',
    this.centerMarker,
    this.showCoordinates = true,
    this.initialLatitude = 0.0,
    this.initialLongitude = 0.0,
    this.initialZoom = 14.0,
  });

  ChooseOnMapConfiguration copyWith({
    String? title,
    String? confirmButtonText,
    Widget? centerMarker,
    bool? showCoordinates,
    double? initialLatitude,
    double? initialLongitude,
    double? initialZoom,
  }) {
    return ChooseOnMapConfiguration(
      title: title ?? this.title,
      confirmButtonText: confirmButtonText ?? this.confirmButtonText,
      centerMarker: centerMarker ?? this.centerMarker,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      initialLatitude: initialLatitude ?? this.initialLatitude,
      initialLongitude: initialLongitude ?? this.initialLongitude,
      initialZoom: initialZoom ?? this.initialZoom,
    );
  }
}

/// A screen for choosing a location on a map.
///
/// Requires a [mapBuilder] to provide the map widget implementation.
/// This allows using any map library (MapLibre, flutter_map, Google Maps, etc.)
///
/// Returns a [SearchLocation] when the user confirms their selection.
///
/// Example usage:
/// ```dart
/// final result = await Navigator.push<SearchLocation>(
///   context,
///   MaterialPageRoute(
///     builder: (context) => ChooseOnMapScreen(
///       configuration: const ChooseOnMapConfiguration(
///         initialLatitude: -17.3920,
///         initialLongitude: -66.1575,
///       ),
///       mapBuilder: ({
///         required initialLatitude,
///         required initialLongitude,
///         required initialZoom,
///         required onCenterChanged,
///       }) {
///         return MyMapWidget(
///           initialCenter: LatLng(initialLatitude, initialLongitude),
///           initialZoom: initialZoom,
///           onCameraMove: (center) => onCenterChanged(
///             MapCenter(center.latitude, center.longitude),
///           ),
///         );
///       },
///     ),
///   ),
/// );
/// ```
class ChooseOnMapScreen extends StatefulWidget {
  /// Configuration for the screen appearance.
  final ChooseOnMapConfiguration configuration;

  /// Builder function that creates the map widget.
  final MapWidgetBuilder mapBuilder;

  const ChooseOnMapScreen({
    super.key,
    this.configuration = const ChooseOnMapConfiguration(),
    required this.mapBuilder,
  });

  @override
  State<ChooseOnMapScreen> createState() => _ChooseOnMapScreenState();
}

class _ChooseOnMapScreenState extends State<ChooseOnMapScreen> {
  late double _currentLatitude;
  late double _currentLongitude;

  @override
  void initState() {
    super.initState();
    _currentLatitude = widget.configuration.initialLatitude;
    _currentLongitude = widget.configuration.initialLongitude;
  }

  void _onCenterChanged(MapCenter center) {
    setState(() {
      _currentLatitude = center.latitude;
      _currentLongitude = center.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.configuration.title),
      ),
      body: Stack(
        children: [
          // Map widget from builder
          widget.mapBuilder(
            initialLatitude: widget.configuration.initialLatitude,
            initialLongitude: widget.configuration.initialLongitude,
            initialZoom: widget.configuration.initialZoom,
            onCenterChanged: _onCenterChanged,
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
                    SearchLocation(
                      id: 'map_${DateTime.now().millisecondsSinceEpoch}',
                      displayName: 'Selected Location',
                      address:
                          '${_currentLatitude.toStringAsFixed(4)}, ${_currentLongitude.toStringAsFixed(4)}',
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
