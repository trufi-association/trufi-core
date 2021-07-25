import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:trufi_core/blocs/configuration/configuration.dart';
import 'package:trufi_core/blocs/configuration/models/animation_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/map_configuration.dart';
import 'package:trufi_core/blocs/configuration/models/url_collection.dart';
import 'package:trufi_core/trufi_app.dart';

void main() {
  enableFlutterDriverExtension();
  runApp(TrufiApp(
    theme: ThemeData(
      primaryColor: const Color(0xff263238),
      primaryColorLight: const Color(0xffeceff1),
      accentColor: const Color(0xffd81b60),
      backgroundColor: Colors.white,
    ),
    configuration: Configuration(
      urls: UrlCollection(),
      animations: AnimationConfiguration(),
      map: MapConfiguration(
        center: LatLng(-17.39000, -66.15400),
        southWest: LatLng(-17.79300, -66.75000),
        northEast: LatLng(-16.90400, -65.67400),
      ),
    ),
  ));
}
