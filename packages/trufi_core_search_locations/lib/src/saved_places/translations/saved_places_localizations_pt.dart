import 'saved_places_localizations.dart';

/// The translations for Portuguese (`pt`).
class SavedPlacesLocalizationPt extends SavedPlacesLocalization {
  SavedPlacesLocalizationPt([String locale = 'pt']) : super(locale);

  @override
  String get chooseNowLabel => 'Escolher agora';

  @override
  String get chooseOnMap => 'Escolha no mapa';

  @override
  String get commonCustomPlaces => 'Lugares personalizados';

  @override
  String get commonFavoritePlaces => 'Lugares favoritos';

  @override
  String defaultLocationAdd(Object defaultLocation) {
    return 'Versão $defaultLocation';
  }

  @override
  String get defaultLocationHome => 'Casa';

  @override
  String get defaultLocationWork => 'Trabalho';

  @override
  String get iconlabel => 'ícone';

  @override
  String instructionJunction(Object street1, Object street2) {
    return '$street1 e $street2';
  }

  @override
  String get menuYourPlaces => 'Seus lugares';

  @override
  String get nameLabel => 'Nome';

  @override
  String get savedPlacesEditLabel => 'Editar lugar';

  @override
  String get savedPlacesEnterNameTitle => 'Insira o nome';

  @override
  String get savedPlacesEnterNameValidation => 'O nome não pode ficar vazio';

  @override
  String get savedPlacesRemoveLabel => 'Remover lugar';

  @override
  String get savedPlacesSelectIconTitle => 'Selecionar símbolo';

  @override
  String get savedPlacesSetIconLabel => 'Mudar símbolo';

  @override
  String get savedPlacesSetNameLabel => 'Editar nome';

  @override
  String get savedPlacesSetPositionLabel => 'Editar posição';

  @override
  String get searchTitleFavorites => 'Favoritos';

  @override
  String get searchTitleRecent => 'Recente';

  @override
  String get searchTitleResults => 'Procurar resultados';

  @override
  String get selectedOnMap => 'Selecione no mapa';
}
