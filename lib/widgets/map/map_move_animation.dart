import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class MapMoveAnimation {
  MapMoveAnimation(this.mapController);

  final MapController mapController;

  void move({
    @required LatLng center,
    @required double zoom,
    @required TickerProvider tickerProvider,
    int milliseconds,
  }) {
    final latitudeTween = new Tween<double>(
      begin: mapController.center.latitude,
      end: center.latitude,
    );
    final longitudeTween = new Tween<double>(
      begin: mapController.center.longitude,
      end: center.longitude,
    );
    final zoomTween = new Tween<double>(begin: mapController.zoom, end: zoom);
    final controller = AnimationController(
      duration: Duration(milliseconds: milliseconds),
      vsync: tickerProvider,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
    controller.addListener(() {
      mapController.move(
        LatLng(
          latitudeTween.evaluate(animation),
          longitudeTween.evaluate(animation),
        ),
        zoomTween.evaluate(animation),
      );
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }
}
