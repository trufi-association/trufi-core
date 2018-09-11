import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrufiLocalizations {
  TrufiLocalizations(this.locale);

  Locale locale;

  static const String SAVED_LANGUAGE_CODE = "LOCALE";

  static TrufiLocalizations of(BuildContext context) {
    return Localizations.of<TrufiLocalizations>(context, TrufiLocalizations);
  }

  static const String Title = "title";
  static const String CommonDestination = "common_destination";
  static const String CommonOrigin = "common_origin";
  static const String CommonNoInternetConnection =
      "common_no_internet_connection";
  static const String CommonFailLoadingData = "common_fail_loading_data";
  static const String CommonUnknownError = "common_unknown_error";
  static const String SearchItemChooseOnMap = "search_item_choose_on_map";
  static const String SearchItemYourLocation = "search_item_your_location";
  static const String SearchItemNoResults = "search_item_no_results";
  static const String SearchSectionPlaces = "search_title_places";
  static const String SearchSectionRecent = "search_title_recent";
  static const String SearchSectionResults = "search_title_result";
  static const String SearchCurrentPosition = "search_current_position";
  static const String SearchSectionMapMarker = "search_map_marker";
  static const String SearchNavigateToMarker = "search_navigate_to_map_marker";
  static const String SearchFailLoadingPlan = "search_fail_loading_plan";
  static const String MapSectionChoosePoint = "map_choose_point";
  static const String MapSectionTapToChoose = "map_tap_to_choose";
  static const String InstructionWalk = "instruction_walk";
  static const String InstructionRide = "instruction_ride";
  static const String InstructionRideBus = "instruction_ride_bus";
  static const String InstructionRideMicro = "instruction_ride_micro";
  static const String InstructionRideMinibus = "instruction_ride_minibus";
  static const String InstructionRideTrufi = "instruction_ride_trufi";
  static const String InstructionTo = "instruction_to";
  static const String InstructionFor = "instruction_for";
  static const String Connections = "connection";
  static const String About = "about";
  static const String Feedback = "feedback";
  static const String Language = "language";
  static const String English = "english";
  static const String German = "german";
  static const String Spanish = "spanish";

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      Title: 'TrufiApp',
      CommonDestination: 'Destination',
      CommonOrigin: 'Origin',
      CommonNoInternetConnection: 'No internet connection',
      CommonFailLoadingData: 'Failed to load data',
      CommonUnknownError: 'unknown error',
      SearchItemChooseOnMap: 'Choose on map',
      SearchItemYourLocation: 'Your location',
      SearchItemNoResults: 'No results',
      SearchSectionPlaces: 'Places',
      SearchSectionRecent: 'Recent',
      SearchSectionResults: 'Search Results',
      SearchCurrentPosition: 'Current Position',
      SearchFailLoadingPlan: 'Failed to load plan',
      SearchSectionMapMarker: 'Map Marker',
      SearchNavigateToMarker: 'Navigate to',
      MapSectionChoosePoint: 'Choose a point',
      MapSectionTapToChoose: 'Tap on map to choose',
      InstructionWalk: 'Walk',
      InstructionRide: 'Ride',
      InstructionRideBus: 'bus',
      InstructionRideMicro: 'micro',
      InstructionRideMinibus: 'minibus',
      InstructionRideTrufi: 'trufi',
      InstructionTo: 'to',
      InstructionFor: 'for',
      Connections: 'Connections',
      About: 'About',
      Feedback: 'Feedback',
      Language: 'Language',
      English: 'English',
      German: 'German',
      Spanish: 'Spanish'
    },
    'es': {
      Title: 'TrufiApp',
      CommonDestination: 'Destino',
      CommonOrigin: 'Origen',
      CommonNoInternetConnection: 'Sin conexión a internet',
      CommonFailLoadingData: 'Error al cargar datos',
      CommonUnknownError: 'Error desconocido',
      SearchItemChooseOnMap: 'Seleccionar en el mapa',
      SearchItemYourLocation: 'Tu ubicación',
      SearchItemNoResults: 'Ningun resultado',
      SearchSectionPlaces: 'Lugares',
      SearchSectionRecent: 'Recientes',
      SearchSectionResults: 'Resultados de búsqueda',
      SearchCurrentPosition: 'Posición actual',
      SearchFailLoadingPlan: 'Error al cargar plan',
      SearchSectionMapMarker: 'Posición en el Mapa',
      SearchNavigateToMarker: 'Ir hasta',
      MapSectionChoosePoint: 'Elige un punto en el mapa',
      MapSectionTapToChoose: 'Toca el mapa para elegir un punto',
      InstructionWalk: 'Camina',
      InstructionRide: 'Toma',
      InstructionRideBus: 'el bus',
      InstructionRideMicro: 'el micro',
      InstructionRideMinibus: 'el minibus',
      InstructionRideTrufi: 'la trufi',
      InstructionTo: 'hacia',
      InstructionFor: 'por',
      Connections: 'Conexiones',
      About: 'Sobre nosotros',
      Feedback: 'Feedback',
      Language: 'Idioma',
      English: 'Inglés',
      German: 'Alemán',
      Spanish: 'Español'
    },
    'de': {
      Title: 'TrufiApp',
      CommonDestination: 'Fahrtziel',
      CommonOrigin: 'Startpunkt',
      CommonNoInternetConnection: 'Keine Internetverbindung',
      CommonFailLoadingData: 'Fehler beim Laden der Daten',
      CommonUnknownError: 'Unbekannter Fehler',
      SearchItemChooseOnMap: 'Auf der Karte auswählen',
      SearchItemYourLocation: 'Ihr Standort',
      SearchItemNoResults: 'Keine Ergebnisse',
      SearchSectionPlaces: 'Orte',
      SearchSectionRecent: 'Zuletzt gesucht',
      SearchSectionResults: 'Suchergebnisse',
      SearchCurrentPosition: 'Aktuelle Position',
      SearchFailLoadingPlan: 'Fehler beim Laden dem Plan',
      SearchSectionMapMarker: 'Kartenmarkierung',
      SearchNavigateToMarker: 'Navigieren',
      MapSectionChoosePoint: 'Auf der Karte ein Punkt Auswählen',
      MapSectionTapToChoose: 'Auf der Karte ein Punkt Auswählen',
      InstructionWalk: 'Gehen Sie',
      InstructionRide: 'Fahren Sie mit ',
      InstructionRideBus: 'dem Bus',
      InstructionRideMicro: 'dem Micro',
      InstructionRideMinibus: 'dem Minibus',
      InstructionRideTrufi: 'der Trufi',
      InstructionTo: 'zur',
      InstructionFor: 'für',
      Connections: 'Verbindungen',
      About: 'Über',
      Feedback: 'Feedback',
      Language: 'Sprache',
      English: 'Englisch',
      German: 'Deutsch',
      Spanish: 'Spanisch'
    },
  };

  String get title {
    return _localizedValues[locale.languageCode][Title];
  }

  String get commonDestination {
    return _localizedValues[locale.languageCode][CommonDestination];
  }

  String get commonOrigin {
    return _localizedValues[locale.languageCode][CommonOrigin];
  }

  String get commonNoInternet {
    return _localizedValues[locale.languageCode][CommonNoInternetConnection];
  }

  String get commonFailLoading {
    return _localizedValues[locale.languageCode][CommonFailLoadingData];
  }

  String get commonUnknownError {
    return _localizedValues[locale.languageCode][CommonUnknownError];
  }

  String get searchItemChooseOnMap {
    return _localizedValues[locale.languageCode][SearchItemChooseOnMap];
  }

  String get searchItemYourLocation {
    return _localizedValues[locale.languageCode][SearchItemYourLocation];
  }

  String get searchItemNoResults {
    return _localizedValues[locale.languageCode][SearchItemNoResults];
  }

  String get searchTitlePlaces {
    return _localizedValues[locale.languageCode][SearchSectionPlaces];
  }

  String get searchTitleRecent {
    return _localizedValues[locale.languageCode][SearchSectionRecent];
  }

  String get searchTitleResults {
    return _localizedValues[locale.languageCode][SearchSectionResults];
  }

  String get searchCurrentPosition {
    return _localizedValues[locale.languageCode][SearchCurrentPosition];
  }

  String get searchMapMarker {
    return _localizedValues[locale.languageCode][SearchSectionMapMarker];
  }

  String get searchNavigate {
    return _localizedValues[locale.languageCode][SearchNavigateToMarker];
  }

  String get searchFailLoadingPlan {
    return _localizedValues[locale.languageCode][SearchFailLoadingPlan];
  }

  String get instructionWalk {
    return _localizedValues[locale.languageCode][InstructionWalk];
  }

  String get instructionRide {
    return _localizedValues[locale.languageCode][InstructionRide];
  }

  String get instructionRideBus {
    return _localizedValues[locale.languageCode][InstructionRideBus];
  }

  String get instructionRideMicro {
    return _localizedValues[locale.languageCode][InstructionRideMicro];
  }

  String get instructionRideMinibus {
    return _localizedValues[locale.languageCode][InstructionRideMinibus];
  }

  String get instructionRideTrufi {
    return _localizedValues[locale.languageCode][InstructionRideTrufi];
  }

  String get instructionTo {
    return _localizedValues[locale.languageCode][InstructionTo];
  }

  String get instructionFor {
    return _localizedValues[locale.languageCode][InstructionFor];
  }

  String get mapChoosePoint {
    return _localizedValues[locale.languageCode][MapSectionChoosePoint];
  }

  String get mapTapToChoose {
    return _localizedValues[locale.languageCode][MapSectionTapToChoose];
  }

  String get connections {
    return _localizedValues[locale.languageCode][Connections];
  }

  String get about {
    return _localizedValues[locale.languageCode][About];
  }

  String get feedback {
    return _localizedValues[locale.languageCode][Feedback];
  }

  String get language {
    return _localizedValues[locale.languageCode][Language];
  }

  String get english {
    return _localizedValues[locale.languageCode][English];
  }

  String get german {
    return _localizedValues[locale.languageCode][German];
  }

  String get spanish {
    return _localizedValues[locale.languageCode][Spanish];
  }

  void switchToLanguage(String languageCode) {
    locale = getLocale(languageCode);
  }

  static getLocale(String languageCode) {
    switch (languageCode) {
      case "en":
        return Locale('en', 'US');
        break;
      case "de":
        return Locale('de', 'DE');
        break;
      case "es":
        return Locale('es', 'ES');
        break;
      default:
        break;
    }
  }

  getLanguageCode(String languageString) {
    if (languageString == _localizedValues[locale.languageCode][English]) {
      return "en";
    } else if (languageString ==
        _localizedValues[locale.languageCode][German]) {
      return "de";
    } else {
      return "es";
    }
  }

  String getLanguageString(String languageCode) {
    switch (languageCode) {
      case "en":
        return _localizedValues[locale.languageCode][English];
        break;
      case "de":
        return _localizedValues[locale.languageCode][German];
        break;
      default:
        return _localizedValues[locale.languageCode][Spanish];
        break;
    }
  }
}

class TrufiLocalizationsDelegate
    extends LocalizationsDelegate<TrufiLocalizations> {
  TrufiLocalizations localizations;

  TrufiLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'de'].contains(locale.languageCode);

  @override
  Future<TrufiLocalizations> load(Locale locale) async {
    localizations = await _getLocalizations();
    if (localizations != null) {
      return localizations;
    }
    return SynchronousFuture<TrufiLocalizations>(TrufiLocalizations(locale));
  }

  @override
  bool shouldReload(TrufiLocalizationsDelegate old) =>
      localizations == null ? false : old.localizations != localizations;

  Future<TrufiLocalizations> _getLocalizations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.get(TrufiLocalizations.SAVED_LANGUAGE_CODE);
    return TrufiLocalizations((TrufiLocalizations.getLocale(languageCode)));
  }
}
