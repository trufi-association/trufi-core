// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'transport_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class TransportListLocalizationsEn extends TransportListLocalizations {
  TransportListLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menuTransportList => 'Routes';

  @override
  String get searchRoutes => 'Search routes';

  @override
  String get noRoutesFound => 'No routes found';

  @override
  String get shareRoute => 'Share route';

  @override
  String stops(int count) {
    return '$count stops';
  }

  @override
  String get routeNotFound => 'Route not found';

  @override
  String get routeLoadError => 'The route could not be loaded';

  @override
  String get pullDownToRefresh => 'Pull down to refresh';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get buttonGoBack => 'Go back';

  @override
  String routeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'routes',
      one: 'route',
    );
    return '$count $_temp0';
  }

  @override
  String get labelDistance => 'Distance';

  @override
  String get labelStops => 'Stops';

  @override
  String get labelMode => 'Mode';

  @override
  String get noStopsAvailable => 'No stops available';

  @override
  String get loadingRoute => 'Loading route...';

  @override
  String get otherAgencies => 'Others';

  @override
  String shareRouteMessage(String uri) {
    return 'Share: $uri';
  }

  @override
  String get defaultModeBus => 'Bus';

  @override
  String get mapSettingsTitle => 'Map Settings';

  @override
  String get mapTypeLabel => 'Map Type';

  @override
  String get applyChanges => 'Apply Changes';

  @override
  String get stopStart => 'Start';

  @override
  String get stopEnd => 'End';

  @override
  String get stopInfoNotAvailable =>
      'Stop information is not available for this route';

  @override
  String get errorLoadingRoutes => 'Could not load routes';

  @override
  String get retry => 'Retry';

  @override
  String get qrShareSubtitle => 'Scan to open this operator\'s routes';

  @override
  String get copyQrImage => 'Copy QR';

  @override
  String get copyQrImageFailed => 'Couldn\'t copy the QR';

  @override
  String get modeTram => 'Tram';

  @override
  String get modeSubway => 'Subway';

  @override
  String get modeRail => 'Rail';

  @override
  String get modeBus => 'Bus';

  @override
  String get modeFerry => 'Ferry';

  @override
  String get modeCableTram => 'Cable Tram';

  @override
  String get modeAerialLift => 'Aerial Lift';

  @override
  String get modeFunicular => 'Funicular';

  @override
  String get modeTrolleybus => 'Trolleybus';

  @override
  String get modeMonorail => 'Monorail';

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String distanceMeters(String value) {
    return '$value m';
  }

  @override
  String get copiedToClipboard => 'Copied';

  @override
  String get menuNearbyLines => 'Nearby lines';

  @override
  String get nearbyAnchorYourLocation => 'Your location';

  @override
  String get nearbyAnchorPinned => 'Pinned location';

  @override
  String get nearbyAnchorDefault => 'City center (location unavailable)';

  @override
  String nearbyAnchorAlongStreet(String street) {
    return 'Along $street';
  }

  @override
  String get nearbyUseMyLocation => 'Use my location';

  @override
  String get nearbyMovePinHint => 'Long-press the map to move the pin';

  @override
  String nearbyRadiusChip(int meters, int count) {
    return '$meters m ($count)';
  }

  @override
  String nearbyLinesInRadius(int count, int meters) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
    );
    return '$_temp0 within $meters m';
  }

  @override
  String nearbyAtDistance(String distance) {
    return 'At $distance';
  }

  @override
  String nearbyPassesAtDistance(String distance) {
    return 'Passes by at $distance';
  }

  @override
  String nearbyStopName(String name) {
    return 'Stop $name';
  }

  @override
  String nearbyTowards(String headsign) {
    return 'To $headsign';
  }

  @override
  String nearbySelectedLine(String name) {
    return 'Highlighted: $name';
  }

  @override
  String nearbyEmptyTitle(int meters) {
    return 'No lines pass within $meters m';
  }

  @override
  String nearbyEmptyInRadius(int meters) {
    return 'No lines within $meters m. Try a larger radius.';
  }

  @override
  String get nearbyUnavailableTitle =>
      'Nearby lines need the offline GTFS planner';

  @override
  String get nearbyUnavailableHint =>
      'Add a local TrufiPlannerProvider with a bundled GTFS feed to the routing engines.';

  @override
  String get nearbyLoadingData => 'Loading offline data…';

  @override
  String get nearbyFooterNote => 'Based on GTFS routes and schedules';

  @override
  String get nearbyOpenDetails => 'Line details';

  @override
  String get nearbyClearSelection => 'Clear highlight';

  @override
  String get nearbyClose => 'Close';
}
