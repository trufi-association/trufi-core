import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

import 'choose_on_map_screen.dart';

/// A MapLibre-based map picker for use with [ChooseOnMapScreen].
///
/// Uses [TrufiMapLibreMap] from trufi_core_maps package.
class MapLibreMapPicker extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final ValueChanged<MapCenter> onCenterChanged;

  /// MapLibre style URL.
  final String styleString;

  const MapLibreMapPicker({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.initialZoom,
    required this.onCenterChanged,
    this.styleString = 'https://tiles.openfreemap.org/styles/liberty',
  });

  @override
  State<MapLibreMapPicker> createState() => _MapLibreMapPickerState();
}

class _MapLibreMapPickerState extends State<MapLibreMapPicker> {
  late final TrufiMapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TrufiMapController(
      initialCameraPosition: TrufiCameraPosition(
        target: latlng.LatLng(widget.initialLatitude, widget.initialLongitude),
        zoom: widget.initialZoom,
      ),
    );
    _controller.cameraPositionNotifier.addListener(_onCameraChanged);
  }

  @override
  void dispose() {
    _controller.cameraPositionNotifier.removeListener(_onCameraChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onCameraChanged() {
    final position = _controller.cameraPositionNotifier.value;
    widget.onCenterChanged(
      MapCenter(position.target.latitude, position.target.longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TrufiMapLibreMap(
      controller: _controller,
      styleString: widget.styleString,
    );
  }
}
