// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'saved_places_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SavedPlacesLocalizationsDe extends SavedPlacesLocalizations {
  SavedPlacesLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get menuSavedPlaces => 'Ihre Orte';

  @override
  String get yourPlaces => 'Ihre Orte';

  @override
  String get home => 'Zuhause';

  @override
  String get work => 'Arbeit';

  @override
  String get favorites => 'Favoriten';

  @override
  String get customPlaces => 'Favoriten';

  @override
  String get recentPlaces => 'Zuletzt gesucht';

  @override
  String get defaultPlaces => 'Standardorte';

  @override
  String get setHome => 'Heimatadresse festlegen';

  @override
  String get setWork => 'Arbeitsadresse festlegen';

  @override
  String get editPlace => 'Ort bearbeiten';

  @override
  String get removePlace => 'Ort entfernen';

  @override
  String removePlaceConfirmation(String placeName) {
    return 'Möchten Sie $placeName wirklich entfernen?';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get remove => 'Entfernen';

  @override
  String get save => 'Speichern';

  @override
  String get name => 'Name';

  @override
  String get enterName => 'Name eingeben';

  @override
  String get nameRequired => 'Name ist erforderlich';

  @override
  String get selectIcon => 'Symbol auswählen';

  @override
  String get clearHistory => 'Löschen';

  @override
  String get noPlacesSaved => 'Noch keine Orte gespeichert';

  @override
  String get addPlace => 'Ort hinzufügen';

  @override
  String get chooseOnMap => 'Auf der Karte auswählen';

  @override
  String get searchLocation => 'Ort suchen';

  @override
  String get type => 'Typ';

  @override
  String get location => 'Standort';

  @override
  String get noLocationSelected => 'Kein Standort ausgewählt';

  @override
  String get locationRequired => 'Standort ist erforderlich';

  @override
  String get locationSelected => 'Standort ausgewählt';

  @override
  String get tapToSelectLocation => 'Tippen, um auf der Karte auszuwählen';

  @override
  String get change => 'Ändern';
}
