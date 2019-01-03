import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class MapFitBoundsAnimation {
  MapFitBoundsAnimation(this.mapController);

  final MapController mapController;

  void fitBounds({
    @required LatLngBounds bounds,
    @required TickerProvider tickerProvider,
    int milliseconds,
  }) {
    final neLatitudeTween = new Tween<double>(
      begin: mapController.bounds.ne.latitude,
      end: bounds.ne.latitude,
    );
    final neLongitudeTween = new Tween<double>(
      begin: mapController.bounds.ne.longitude,
      end: bounds.ne.longitude,
    );
    final swLatitudeTween = new Tween<double>(
      begin: mapController.bounds.sw.latitude,
      end: bounds.sw.latitude,
    );
    final swLongitudeTween = new Tween<double>(
      begin: mapController.bounds.sw.longitude,
      end: bounds.sw.longitude,
    );
    final controller = AnimationController(
      duration: Duration(milliseconds: milliseconds),
      vsync: tickerProvider,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
    controller.addListener(() {
      mapController.fitBounds(
        LatLngBounds(
          LatLng(
            neLatitudeTween.evaluate(animation),
            neLongitudeTween.evaluate(animation),
          ),
          LatLng(
            swLatitudeTween.evaluate(animation),
            swLongitudeTween.evaluate(animation),
          ),
        ),
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
