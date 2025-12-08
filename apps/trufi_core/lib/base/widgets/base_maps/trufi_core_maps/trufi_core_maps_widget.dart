import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/base/blocs/map_configuration/map_configuration_cubit.dart';
import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';
import 'package:trufi_core/base/models/map_provider_collection/map_engine.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/widgets/base_maps/map_buttons/your_location_button.dart';
import 'package:trufi_core/base/widgets/base_maps/trufi_core_maps/trufi_core_maps_controller.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';

/// Widget that wraps map engines with trufi_core app integration.
///
/// Based on trufi_core_maps example pattern:
/// - Uses TrufiMapController for state management
/// - Supports layers via TrufiLayer
/// - Integrates with MapConfigurationCubit
/// - Uses ITrufiMapEngine for flexible map rendering
class TrufiCoreMapsWidget extends StatefulWidget {
  final TrufiCoreMapsController trufiMapController;
  final ITrufiMapEngine mapEngine;
  final Widget? floatingActionButtons;
  final void Function(latlng.LatLng)? onTap;
  final void Function(latlng.LatLng)? onLongPress;
  final void Function(TrufiCameraPosition)? onCameraChanged;
  final double? bottomPaddingButtons;
  final bool showLocationButton;
  final bool showAttribution;

  const TrufiCoreMapsWidget({
    super.key,
    required this.trufiMapController,
    required this.mapEngine,
    this.floatingActionButtons,
    this.onTap,
    this.onLongPress,
    this.onCameraChanged,
    this.bottomPaddingButtons,
    this.showLocationButton = true,
    this.showAttribution = true,
  });

  @override
  State<TrufiCoreMapsWidget> createState() => _TrufiCoreMapsWidgetState();
}

class _TrufiCoreMapsWidgetState extends State<TrufiCoreMapsWidget> {
  bool _isTrackingPosition = false;
  bool _mapReadyMarked = false;

  @override
  void initState() {
    super.initState();

    // Listen to camera changes
    widget.trufiMapController.mapController.cameraPositionNotifier
        .addListener(_onCameraChanged);

    // Update viewport for FitCameraLayer when layout is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateViewport();
    });
  }

  @override
  void dispose() {
    widget.trufiMapController.mapController.cameraPositionNotifier
        .removeListener(_onCameraChanged);
    super.dispose();
  }

  void _updateViewport() {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).viewPadding;
    widget.trufiMapController.fitCameraLayer?.updateViewport(size, padding);
  }

  void _onCameraChanged() {
    // Mark ready on first camera change (map is initialized)
    if (!_mapReadyMarked) {
      _mapReadyMarked = true;
      widget.trufiMapController.markReady();
    }

    widget.onCameraChanged?.call(
      widget.trufiMapController.mapController.cameraPositionNotifier.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapConfiguration = context.read<MapConfigurationCubit>().state;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Update viewport on layout changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final padding = MediaQuery.of(context).viewPadding;
          widget.trufiMapController.fitCameraLayer?.updateViewport(
            Size(constraints.maxWidth, constraints.maxHeight),
            padding,
          );
        });

        return Stack(
          children: [
            // Map widget using renderer
            StreamBuilder<TrufiLatLng?>(
              initialData: null,
              stream: GPSLocationProvider().streamLocation,
              builder: (context, snapshot) {
                final currentLocation = snapshot.data;

                // Add your location marker if available
                _updateLocationMarker(currentLocation, mapConfiguration);

                return widget.mapEngine.buildMap(
                  controller: widget.trufiMapController.mapController,
                  onMapClick: widget.onTap != null
                      ? (point) => widget.onTap!(
                          latlng.LatLng(point.latitude, point.longitude))
                      : null,
                  onMapLongClick: widget.onLongPress != null
                      ? (point) => widget.onLongPress!(
                          latlng.LatLng(point.latitude, point.longitude))
                      : null,
                );
              },
            ),

            // Floating action buttons
            if (widget.showLocationButton ||
                widget.floatingActionButtons != null)
              Positioned(
                bottom: widget.bottomPaddingButtons ?? 25.0,
                right: 16.0,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      if (widget.floatingActionButtons != null)
                        widget.floatingActionButtons!,
                      if (widget.floatingActionButtons != null)
                        const SizedBox(height: 8),
                      if (widget.showLocationButton)
                        YourLocationButton(
                          trufiMapController: widget.trufiMapController,
                          isTrackingPosition: _isTrackingPosition,
                          setTracking: (isTracking) {
                            setState(() => _isTrackingPosition = isTracking);
                          },
                        ),
                    ],
                  ),
                ),
              ),

            // Attribution
            if (widget.showAttribution)
              Positioned(
                bottom: 5.0,
                left: 10,
                child: SafeArea(
                  child: mapConfiguration.mapAttributionBuilder!(context),
                ),
              ),
          ],
        );
      },
    );
  }

  void _updateLocationMarker(
    TrufiLatLng? location,
    MapConfiguration mapConfiguration,
  ) {
    final locationLayer = widget.trufiMapController.locationLayer;
    if (locationLayer == null) return;

    if (location != null) {
      locationLayer.setMarkers([
        TrufiMarker(
          id: 'your-location',
          position: latlng.LatLng(location.latitude, location.longitude),
          widget: mapConfiguration.markersConfiguration.yourLocationMarker,
          size: const Size(20, 20),
          alignment: Alignment.center,
        ),
      ]);
    } else {
      locationLayer.clearMarkers();
    }
  }
}
