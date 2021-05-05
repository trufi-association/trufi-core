import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong/latlong.dart';

import 'custom_layer.dart';

class BusStopLayer extends CustomLayer {
  List<Marker> markers = [];
  BusStopLayer() : super("BusStopLayer") {
    loop();
  }
  Future<void> loop() async {
    refresh();
    await Future.delayed(const Duration(seconds: 2));
    log("loop");
    final color =
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    markers = [
      Marker(
        width: 30,
        height: 30,
        point: LatLng(-17.39000, -66.15400),
        anchorPos: AnchorPos.align(AnchorAlign.center),
        builder: (context) => GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                30,
              ),
            ),
            child: const Icon(Icons.bus_alert),
          ),
        ),
      ),
      Marker(
        width: 30,
        height: 30,
        point: LatLng(-17.34000, -66.18400),
        anchorPos: AnchorPos.align(AnchorAlign.center),
        builder: (context) => GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                30,
              ),
            ),
            child: const Icon(Icons.business),
          ),
        ),
      ),
      Marker(
        width: 30,
        height: 30,
        point: LatLng(-17.38000, -66.14400),
        anchorPos: AnchorPos.align(AnchorAlign.center),
        builder: (context) => GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                30,
              ),
            ),
            child: const Icon(Icons.bus_alert),
          ),
        ),
      ),
    ];
    loop();
  }

  double pos = 150;
  @override
  LayerOptions get layerOptions => MarkerLayerOptions(markers: markers);
}
