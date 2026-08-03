import 'package:flutter/widgets.dart';

import '../../../l10n/maps_localizations.dart';
import 'maplibre_engine.dart';
import 'trufi_map_engine.dart';

String _libertyDescription(BuildContext context) =>
    MapsLocalizations.of(context).lightVectorMapDescription;

String _darkDescription(BuildContext context) =>
    MapsLocalizations.of(context).darkVectorMapDescription;

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
    descriptionBuilder: _libertyDescription,
  ),
  MapLibreEngine(
    engineId: 'maplibre_dark',
    styleString: 'https://tiles.openfreemap.org/styles/dark',
    displayName: 'Dark',
    descriptionBuilder: _darkDescription,
  ),
];
