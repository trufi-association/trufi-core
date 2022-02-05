


import 'saved_places_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class SavedPlacesLocalizationEs extends SavedPlacesLocalization {
  SavedPlacesLocalizationEs([String locale = 'es']) : super(locale);

  @override
  String get chooseNowLabel => 'Choose now';

  @override
  String get chooseOnMap => 'Choose on map';

  @override
  String get commonCustomPlaces => 'Custom places';

  @override
  String get commonFavoritePlaces => 'Favorite places';

  @override
  String defaultLocationAdd(Object defaultLocation) {
    return 'Versión $defaultLocation';
  }

  @override
  String get defaultLocationHome => 'Home';

  @override
  String get defaultLocationWork => 'Work';

  @override
  String get iconlabel => 'Icon';

  @override
  String instructionJunction(Object street1, Object street2) {
    return '$street1 and $street2';
  }

  @override
  String get menuYourPlaces => 'Tus lugares';

  @override
  String get nameLabel => 'Name';

  @override
  String get savedPlacesEditLabel => 'Edit place';

  @override
  String get savedPlacesEnterNameTitle => 'Enter name';

  @override
  String get savedPlacesEnterNameValidation => 'The name cannot be empty';

  @override
  String get savedPlacesRemoveLabel => 'Remove place';

  @override
  String get savedPlacesSelectIconTitle => 'Select symbol';

  @override
  String get savedPlacesSetIconLabel => 'Change symbol';

  @override
  String get savedPlacesSetNameLabel => 'Edit name';

  @override
  String get savedPlacesSetPositionLabel => 'Edit position';

  @override
  String get searchTitleFavorites => 'Favoritos';

  @override
  String get searchTitleRecent => 'Recientes';

  @override
  String get searchTitleResults => 'Resultados de búsqueda';

  @override
  String get selectedOnMap => 'Selected on the map';
}
