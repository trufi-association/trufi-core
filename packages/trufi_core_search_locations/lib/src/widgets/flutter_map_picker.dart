import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core_maps/trufi_core_maps.dart';

import 'choose_on_map_screen.dart';

/// A flutter_map-based map picker for use with [ChooseOnMapScreen].
///
/// Uses [TrufiFlutterMap] from trufi_core_maps package.
class FlutterMapPicker extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final ValueChanged<MapCenter> onCenterChanged;

  /// Tile URL template for the map tiles.
  final String tileUrl;

  /// User agent package name for tile requests.
  final String? userAgentPackageName;

  const FlutterMapPicker({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.initialZoom,
    required this.onCenterChanged,
    this.tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.userAgentPackageName,
  });

  @override
  State<FlutterMapPicker> createState() => _FlutterMapPickerState();
}

class _FlutterMapPickerState extends State<FlutterMapPicker> {
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
    return TrufiFlutterMap(
      controller: _controller,
      tileUrl: widget.tileUrl,
      userAgentPackageName: widget.userAgentPackageName,
    );
  }
}
