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
  String get buttonGoBack => 'Go back';
}
