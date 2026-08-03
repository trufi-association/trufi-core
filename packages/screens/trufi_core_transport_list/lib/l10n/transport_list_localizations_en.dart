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
}
