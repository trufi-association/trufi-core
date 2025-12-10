// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'transport_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class TransportListLocalizationsDe extends TransportListLocalizations {
  TransportListLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get menuTransportList => 'Linien';

  @override
  String get searchRoutes => 'Linien suchen';

  @override
  String get noRoutesFound => 'Keine Linien gefunden';

  @override
  String get shareRoute => 'Linie teilen';

  @override
  String stops(int count) {
    return '$count Haltestellen';
  }
}
