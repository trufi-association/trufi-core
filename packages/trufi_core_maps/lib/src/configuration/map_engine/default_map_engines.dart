import 'maplibre_engine.dart';
import 'trufi_map_engine.dart';

/// Default map engines for Trufi apps.
///
/// Two MapLibre styles are available:
/// - Liberty: Light vector map style
/// - Dark: Dark vector map style for night viewing
const List<ITrufiMapEngine> defaultMapEngines = [
  MapLibreEngine(
    engineId: 'maplibre_liberty',
    styleString: 'https://tiles.openfreemap.org/styles/liberty',
    displayName: 'Liberty',
    displayDescription: 'Mapa vectorial claro',
  ),
  MapLibreEngine(
    engineId: 'maplibre_dark',
    styleString: 'https://tiles.openfreemap.org/styles/dark',
    displayName: 'Dark',
    displayDescription: 'Mapa vectorial oscuro',
  ),
];
