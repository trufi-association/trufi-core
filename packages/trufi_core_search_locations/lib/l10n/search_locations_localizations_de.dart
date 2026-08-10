// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'search_locations_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SearchLocationsLocalizationsDe extends SearchLocationsLocalizations {
  SearchLocationsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get selectOrigin => 'Startort auswählen';

  @override
  String get selectDestination => 'Zielort auswählen';

  @override
  String get searchOrigin => 'Startort suchen...';

  @override
  String get searchDestination => 'Zielort suchen...';

  @override
  String get yourLocation => 'Dein Standort';

  @override
  String get chooseOnMap => 'Auf der Karte wählen';

  @override
  String get yourPlaces => 'DEINE ORTE';

  @override
  String get searchResults => 'SUCHERGEBNISSE';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String cornersOf(String street) {
    return 'Kreuzungen: $street';
  }

  @override
  String get seeCorners => 'Kreuzungen anzeigen';
}
