import 'flutter_map_engine.dart';
import 'maplibre_engine.dart';
import 'trufi_map_engine.dart';

/// Default map engines for Trufi apps.
///
/// Both engines support automatic dark mode switching when [isDarkMode]
/// is passed to [buildMap].
const List<ITrufiMapEngine> defaultMapEngines = [
  MapLibreEngine(
    styleString: 'https://tiles.openfreemap.org/styles/liberty',
    darkStyleString: 'https://tiles.openfreemap.org/styles/dark',
    displayName: 'MapLibre GL',
    displayDescription: 'Vector map with Liberty style',
  ),
  FlutterMapEngine(
    tileUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    // Uses color filter for dark mode (no native dark tiles for OSM standard)
    userAgentPackageName: 'com.trufi.app',
    displayName: 'OpenStreetMap',
    displayDescription: 'Standard OSM raster tiles',
  ),
];
