import 'flutter_map_engine.dart';
import 'maplibre_engine.dart';
import 'trufi_map_engine.dart';

/// Default map engines for Trufi apps
const List<ITrufiMapEngine> defaultMapEngines = [
  FlutterMapEngine(
    tileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.trufi.app',
    displayName: 'OpenStreetMap',
    displayDescription: 'Standard OSM raster tiles',
  ),
  MapLibreEngine(
    styleString: 'https://tiles.openfreemap.org/styles/liberty',
    displayName: 'MapLibre GL',
    displayDescription: 'Vector map with Liberty style',
  ),
];
