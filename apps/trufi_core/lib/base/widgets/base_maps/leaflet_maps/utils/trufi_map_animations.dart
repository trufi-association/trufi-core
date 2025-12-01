import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrufiMapAnimations {
  const TrufiMapAnimations();
  static const _startedId = "AnimatedMapController#MoveStarted";
  static const _inProgressId = "AnimatedMapController#MoveInProgress";
  static const _finishedId = "AnimatedMapController#MoveFinished";

  static void move({
    required LatLng center,
    required double zoom,
    required TickerProvider vsync,
    required MapController mapController,
  }) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: center.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: center.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        "$_startedId#${center.latitude},${center.longitude},$zoom";
    var hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
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
    required TickerProvider vsync,
    required MapController mapController,
  }) {
    final cameraFit = CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(50),
    );
    final centerZoom = cameraFit.fit(mapController.camera);
    return move(
      center: centerZoom.center,
      zoom: centerZoom.zoom,
      vsync: vsync,
      mapController: mapController,
    );
  }
}
