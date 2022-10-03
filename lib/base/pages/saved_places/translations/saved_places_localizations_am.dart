import 'saved_places_localizations.dart';

/// The translations for Amharic (`am`).
class SavedPlacesLocalizationAm extends SavedPlacesLocalization {
  SavedPlacesLocalizationAm([String locale = 'am']) : super(locale);

  @override
  String get chooseNowLabel => 'አሁን ይምረጡ';

  @override
  String get chooseOnMap => 'ካርታው ላይ ይምረጡ';

  @override
  String get commonCustomPlaces => 'የተለዩ ቦታዎች';

  @override
  String get commonFavoritePlaces => 'ተመራጭ ቦታዎቾ';

  @override
  String defaultLocationAdd(Object defaultLocation) {
    return '$defaultLocation አድራሻዎን ያስቀምጡ';
  }

  @override
  String get defaultLocationHome => 'ቤት';

  @override
  String get defaultLocationWork => 'ስራ ቦታ';

  @override
  String get iconlabel => 'መለያ';

  @override
  String instructionJunction(Object street1, Object street2) {
    return '$street1 እና $street2';
  }

  @override
  String get menuYourPlaces => 'ቦታዎችዎ';

  @override
  String get nameLabel => 'ስም';

  @override
  String get savedPlacesEditLabel => 'ቦታውን አርትዕ';

  @override
  String get savedPlacesEnterNameTitle => 'ስም አስገባ';

  @override
  String get savedPlacesEnterNameValidation => 'ስም ባዶ መሆን አይችልም';

  @override
  String get savedPlacesRemoveLabel => 'ቦታውን አስወግድ';

  @override
  String get savedPlacesSelectIconTitle => 'ምስሉን ምረጥ';

  @override
  String get savedPlacesSetIconLabel => 'ምስሉን ለውጥ';

  @override
  String get savedPlacesSetNameLabel => 'ስም አርትዕ';

  @override
  String get savedPlacesSetPositionLabel => 'ቦታውን አርትዕ';

  @override
  String get searchTitleFavorites => 'ተመራጮች';

  @override
  String get searchTitleRecent => 'የቅርብ ጊዜ';

  @override
  String get searchTitleResults => 'የፍለጋ ውጤቶች';

  @override
  String get selectedOnMap => 'ካርታው ላይ የተመረጠ';
}
