import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:trufi_core/base/blocs/map_configuration/marker_configurations/marker_configuration.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core_maps/trufi_core_maps.dart';
import 'package:trufi_core_routing_ui/trufi_core_routing_ui.dart';

/// Centralized builder for creating TrufiMarker objects for routes.
///
/// Converts the marker building logic from leaflet_map_utils.dart to use
/// TrufiMarker instead of flutter_map Marker.
class RouteMarkerBuilder {
  final MarkerConfiguration markerConfiguration;
  final ThemeData? themeData;

  const RouteMarkerBuilder({
    required this.markerConfiguration,
    this.themeData,
  });

  /// Wraps a widget with Theme and Directionality for off-screen rendering.
  /// This is necessary for widgets that use Theme.of(context) when
  /// being rendered off-screen for MapLibre markers.
  Widget _wrapWithTheme(Widget widget) {
    if (themeData != null) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(data: themeData!, child: widget),
      );
    }
    return widget;
  }

  /// Build a transfer marker (where you change transport)
  TrufiMarker buildTransferMarker({
    required String id,
    required TrufiLatLng point,
    required Color color,
    int layerLevel = 10,
  }) {
    return TrufiMarker(
      id: id,
      position: latlng.LatLng(point.latitude, point.longitude),
      widget: Transform.scale(
        scale: 0.5,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
            color: color,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.white, width: 3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      size: const Size(30, 30),
      alignment: Alignment.center,
      layerLevel: layerLevel,
    );
  }

  /// Build a stop marker (intermediate stops on a route)
  TrufiMarker buildStopMarker({
    required String id,
    required TrufiLatLng point,
    int layerLevel = 9,
  }) {
    return TrufiMarker(
      id: id,
      position: latlng.LatLng(point.latitude, point.longitude),
      widget: Transform.scale(
        scale: 0.30,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 3.5),
            shape: BoxShape.circle,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.circle,
              color: Colors.grey[700],
              size: 20,
            ),
          ),
        ),
      ),
      size: const Size(30, 30),
      alignment: Alignment.center,
      layerLevel: layerLevel,
    );
  }

  /// Build a transport marker (bus, train, etc. with route info)
  TrufiMarker buildTransportMarker({
    required String id,
    required TrufiLatLng point,
    required Color color,
    required Color textColor,
    required Leg leg,
    VoidCallback? onTap,
    bool showIcon = true,
    bool showText = true,
    int layerLevel = 11,
  }) {
    return TrufiMarker(
      id: id,
      position: latlng.LatLng(point.latitude, point.longitude),
      widget: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                if (showIcon)
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: leg.transportMode.getImage(
                      color: textColor,
                    ),
                  ),
                if (showText)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      leg.route?.shortName ?? leg.headSign,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
      size: const Size(50, 40),
      alignment: Alignment.center,
      layerLevel: layerLevel,
    );
  }

  /// Build a from marker (start of route)
  TrufiMarker buildFromMarker({
    required String id,
    required TrufiLatLng point,
    int layerLevel = 12,
  }) {
    return TrufiMarker(
      id: id,
      position: latlng.LatLng(point.latitude, point.longitude),
      widget: _wrapWithTheme(markerConfiguration.fromMarker),
      size: const Size(24, 24),
      alignment: Alignment.center,
      layerLevel: layerLevel,
    );
  }

  /// Build a to marker (destination)
  TrufiMarker buildToMarker({
    required String id,
    required TrufiLatLng point,
    int layerLevel = 12,
  }) {
    return TrufiMarker(
      id: id,
      position: latlng.LatLng(point.latitude, point.longitude),
      widget: _wrapWithTheme(markerConfiguration.toMarker),
      size: const Size(40, 40),
      alignment: Alignment.topCenter,
      layerLevel: layerLevel,
    );
  }

  /// Build a your location marker
  TrufiMarker buildYourLocationMarker({
    required String id,
    required TrufiLatLng point,
    int layerLevel = 100,
  }) {
    return TrufiMarker(
      id: id,
      position: latlng.LatLng(point.latitude, point.longitude),
      widget: _wrapWithTheme(markerConfiguration.yourLocationMarker),
      size: const Size(30, 30),
      alignment: Alignment.center,
      layerLevel: layerLevel,
    );
  }

  /// Build a generic marker with icon
  TrufiMarker buildIconMarker({
    required String id,
    required TrufiLatLng point,
    required IconData iconData,
    required Color color,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    int layerLevel = 10,
  }) {
    return TrufiMarker(
      id: id,
      position: latlng.LatLng(point.latitude, point.longitude),
      widget: Container(
        decoration: decoration,
        child: Icon(iconData, color: color),
      ),
      size: const Size(30, 30),
      alignment: alignment,
      layerLevel: layerLevel,
    );
  }
}
