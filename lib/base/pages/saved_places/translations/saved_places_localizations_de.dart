


import 'saved_places_localizations.dart';

/// The translations for German (`de`).
class SavedPlacesLocalizationDe extends SavedPlacesLocalization {
  SavedPlacesLocalizationDe([String locale = 'de']) : super(locale);

  @override
  String get chooseNowLabel => 'Jetzt auswählen';

  @override
  String get chooseOnMap => 'Choose on map';

  @override
  String get commonCustomPlaces => 'Benutzerdefinierte Orte';

  @override
  String get commonFavoritePlaces => 'Lieblingsplätze';

  @override
  String defaultLocationAdd(Object defaultLocation) {
    return 'Hinzufügen $defaultLocation';
  }

  @override
  String get defaultLocationHome => 'Zuhause';

  @override
  String get defaultLocationWork => 'Arbeit';

  @override
  String get iconlabel => 'Icon';

  @override
  String instructionJunction(Object street1, Object street2) {
    return '$street1 und $street2';
  }

  @override
  String get menuYourPlaces => 'Ihre Orte';

  @override
  String get nameLabel => 'Name';

  @override
  String get savedPlacesEditLabel => 'Ort bearbeiten';

  @override
  String get savedPlacesEnterNameTitle => 'Name eingeben';

  @override
  String get savedPlacesEnterNameValidation => 'Der Name darf nicht leer sein';

  @override
  String get savedPlacesRemoveLabel => 'Platz entfernen';

  @override
  String get savedPlacesSelectIconTitle => 'Symbol auswählen';

  @override
  String get savedPlacesSetIconLabel => 'Symbol auswählen';

  @override
  String get savedPlacesSetNameLabel => 'Namen bearbeiten';

  @override
  String get savedPlacesSetPositionLabel => 'Position bearbeiten';

  @override
  String get searchTitleFavorites => 'Favoriten';

  @override
  String get searchTitleRecent => 'Zuletzt gesucht';

  @override
  String get searchTitleResults => 'Suchergebnisse';

  @override
  String get selectedOnMap => 'Auf Karte ausgewählt';
}
