import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class TrufiMapAnimations {
  TrufiMapAnimations(this.mapController);

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

  void fitBounds({
    @required LatLngBounds bounds,
    @required TickerProvider tickerProvider,
    int milliseconds,
  }) {
    final neLatitudeTween = new Tween<double>(
      begin: mapController.bounds.northEast.latitude,
      end: bounds.northEast.latitude,
    );
    final neLongitudeTween = new Tween<double>(
      begin: mapController.bounds.northEast.longitude,
      end: bounds.northEast.longitude,
    );
    final swLatitudeTween = new Tween<double>(
      begin: mapController.bounds.southWest.latitude,
      end: bounds.southWest.latitude,
    );
    final swLongitudeTween = new Tween<double>(
      begin: mapController.bounds.southWest.longitude,
      end: bounds.southWest.longitude,
    );
    final paddingTween = new Tween<double>(begin: 0.0, end: 12.0);
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
        options: FitBoundsOptions(
          padding: EdgeInsets.all(paddingTween.evaluate(animation)),
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
