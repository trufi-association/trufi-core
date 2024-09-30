import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:trufi_core/base/models/enums/transport_mode.dart';
import 'package:trufi_core/base/models/journey_plan/plan.dart';
import 'package:trufi_core/base/models/trufi_latlng.dart';

Marker buildTransferMarker({required TrufiLatLng point, required Color color}) {
  return Marker(
    point: point.toLatLng(),
    alignment: Alignment.center,
    child: Transform.scale(
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
  );
}

Marker buildStopMarker(TrufiLatLng point) {
  return Marker(
    point: point.toLatLng(),
    alignment: Alignment.center,
    child: Transform.scale(
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
  );
}

Marker buildTransportMarker(
  TrufiLatLng point,
  Color color,
  Color textColor,
  Leg leg, {
  VoidCallback? onTap,
  bool showIcon = true,
  bool showText = true,
}) {
  return Marker(
    width: 50.0,
    point: point.toLatLng(),
    alignment: Alignment.center,
    child: GestureDetector(
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
  );
}

Marker buildMarker(
  TrufiLatLng point,
  IconData iconData,
  Alignment alignment,
  anchorPos,
  Color color, {
  Decoration? decoration,
}) {
  return Marker(
    point: point.toLatLng(),
    alignment: alignment,
    child: Container(
      decoration: decoration,
      child: Icon(iconData, color: color),
    ),
  );
}

Marker buildFromMarker(TrufiLatLng point, Widget fromMarker) {
  return Marker(
    point: point.toLatLng(),
    width: 18,
    height: 18,
    alignment: Alignment.center,
    child: fromMarker,
  );
}

Marker buildToMarker(TrufiLatLng point, Widget toMarker) {
  return Marker(
    point: point.toLatLng(),
    alignment: Alignment.topCenter,
    child: toMarker,
  );
}

Marker buildYourLocationMarker(TrufiLatLng? point, Widget toMarker) {
  return (point != null)
      ? Marker(
          width: 50.0,
          height: 50.0,
          point: point.toLatLng(),
          alignment: Alignment.center,
          child: toMarker,
        )
      : Marker(
          width: 0,
          height: 0,
          point: const TrufiLatLng(0, 0).toLatLng(),
          child: Container(),
        );
}

// @override
// MarkerLayerOptions buildFromMarkerLayerOptions(TrufiLatLng point) {
//   return MarkerLayerOptions(markers: [buildFromMarker(point)]);
// }

// @override
// MarkerLayerOptions buildToMarkerLayerOptions(TrufiLatLng point) {
//   return MarkerLayerOptions(markers: [buildToMarker(point)]);
// }

// @override
// MarkerLayerOptions buildYourLocationMarkerLayerOptions(TrufiLatLng? point) {
//   return MarkerLayerOptions(markers: [buildYourLocationMarker(point)]);
// }
