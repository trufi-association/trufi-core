import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapAreaSelector extends StatefulWidget {
  const MapAreaSelector({
    super.key,
    required this.mapController,
    required this.paint,
    this.position = const Offset(100, 100),
    this.size = const Size(150, 100),
  });

  final MapController mapController;
  final void Function(List<LatLng> polyLines) paint;
  final Offset position;
  final Size size;

  @override
  State<MapAreaSelector> createState() => MapAreaSelectorState();
}

class MapAreaSelectorState extends State<MapAreaSelector> {
  final double _padding = 5.0;
  final Size _minSize = const Size(150, 100);

  late Offset _position;
  late Size _size;

  @override
  void initState() {
    _position = widget.position;
    _size = widget.size;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCoordinates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _position = _position + details.delta;
              });
            },
            onPanEnd: (_) => _getCoordinates(),
            child: Container(
              margin: EdgeInsets.all(_padding),
              child: Container(
                width: _size.width,
                height: _size.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  color: Colors.black38,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final width = _size.width + details.delta.dx;
                  final height = _size.height + details.delta.dy;
                  _size = Size(
                    width > _minSize.width ? width : _minSize.width,
                    height > _minSize.height ? height : _minSize.height,
                  );
                });
              },
              onPanEnd: (_) => _getCoordinates(),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.crop_free,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getCoordinates() {
    LatLng? topLeft = widget.mapController.pointToLatLng(
        CustomPoint(_position.dx + _padding, _position.dy + _padding));

    LatLng? topRight = widget.mapController.pointToLatLng(CustomPoint(
        _position.dx + _size.width + _padding, _position.dy + _padding));

    LatLng? bottomLeft = widget.mapController.pointToLatLng(CustomPoint(
        _position.dx + _padding, _position.dy + _size.height + _padding));

    LatLng? bottomRight = widget.mapController.pointToLatLng(CustomPoint(
        _position.dx + _size.width + _padding,
        _position.dy + _size.height + _padding));

    if (topLeft != null &&
        bottomLeft != null &&
        bottomRight != null &&
        topRight != null) {
      widget.paint([
        topLeft,
        bottomLeft,
        bottomRight,
        topRight,
      ]);
    }
  }
}
