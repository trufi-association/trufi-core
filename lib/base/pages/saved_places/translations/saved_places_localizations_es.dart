


import 'saved_places_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class SavedPlacesLocalizationEs extends SavedPlacesLocalization {
  SavedPlacesLocalizationEs([String locale = 'es']) : super(locale);

  @override
  String get chooseNowLabel => 'Elegir ahora';

  @override
  String get chooseOnMap => 'Elegir en el mapa';

  @override
  String get commonCustomPlaces => 'Lugares personalizados';

  @override
  String get commonFavoritePlaces => 'Lugares favoritos';

  @override
  String defaultLocationAdd(Object defaultLocation) {
    return 'Establecer $defaultLocation';
  }

  @override
  String get defaultLocationHome => 'Casa';

  @override
  String get defaultLocationWork => 'Trabajo';

  @override
  String get iconlabel => 'Icono';

  @override
  String instructionJunction(Object street1, Object street2) {
    return '$street1 y $street2';
  }

  @override
  String get menuYourPlaces => 'Tus lugares';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get savedPlacesEditLabel => 'Editar lugar';

  @override
  String get savedPlacesEnterNameTitle => 'Ingrese su nombre';

  @override
  String get savedPlacesEnterNameValidation => 'El nombre no puede ser vacio';

  @override
  String get savedPlacesRemoveLabel => 'Eliminar lugar';

  @override
  String get savedPlacesSelectIconTitle => 'Seleccionar icono';

  @override
  String get savedPlacesSetIconLabel => 'Cambiar icono';

  @override
  String get savedPlacesSetNameLabel => 'Editar nombre';

  @override
  String get savedPlacesSetPositionLabel => 'Editar posición';

  @override
  String get searchTitleFavorites => 'Favoritos';

  @override
  String get searchTitleRecent => 'Recientes';

  @override
  String get searchTitleResults => 'Resultados de búsqueda';

  @override
  String get selectedOnMap => 'Seleccionado en el mapa';
}
