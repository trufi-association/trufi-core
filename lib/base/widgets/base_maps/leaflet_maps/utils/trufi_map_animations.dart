import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrufiMapAnimations {
  static void move({
    required LatLng center,
    required double zoom,
    required TickerProvider tickerProvider,
    required int milliseconds,
    required MapController mapController,
  }) {
    final latitudeTween = Tween<double>(
      begin: mapController.camera.center.latitude,
      end: center.latitude,
    );
    final longitudeTween = Tween<double>(
      begin: mapController.camera.center.longitude,
      end: center.longitude,
    );
    final zoomTween =
        Tween<double>(begin: mapController.camera.zoom, end: zoom);
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

  static void fitBounds({
    required LatLngBounds bounds,
    required TickerProvider tickerProvider,
    required int milliseconds,
    required MapController mapController,
  }) {
    final neLatitudeTween = Tween<double>(
      begin: mapController.camera.visibleBounds.northEast.latitude,
      end: bounds.northEast.latitude,
    );
    final neLongitudeTween = Tween<double>(
      begin: mapController.camera.visibleBounds.northEast.longitude,
      end: bounds.northEast.longitude,
    );
    final swLatitudeTween = Tween<double>(
      begin: mapController.camera.visibleBounds.southWest.latitude,
      end: bounds.southWest.latitude,
    );
    final swLongitudeTween = Tween<double>(
      begin: mapController.camera.visibleBounds.southWest.longitude,
      end: bounds.southWest.longitude,
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
      // TODO update fitBounds
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
        // TODO update FitBoundsOptions
        options: const FitBoundsOptions(
          padding: EdgeInsets.all(50),
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
