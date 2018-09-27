import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrufiLocalizations {
  static const String savedLanguageCode = "saved_language_code";
  static TrufiLocalizations of(BuildContext context) {
    return Localizations.of<TrufiLocalizations>(context, TrufiLocalizations);
  }

  TrufiLocalizations(this.locale);

  Locale locale;

  static const String Title = "title";
  static const String TagLine = "tag_line";
  static const String Description = "description";
  static const String AlertLocationServicesDeniedTitle =
      "alert_location_services_denied_title";
  static const String AlertLocationServicesDeniedMessage =
      "alert_location_services_denied_message";
  static const String CommonOK = "common_ok";
  static const String CommonCancel = "common_cancel";
  static const String CommonDestination = "common_destination";
  static const String CommonOrigin = "common_origin";
  static const String CommonNoInternetConnection =
      "common_no_internet_connection";
  static const String CommonFailLoadingData = "common_fail_loading_data";
  static const String CommonUnknownError = "common_unknown_error";
  static const String CommonError = "common_error";
  static const String SearchItemChooseOnMap = "search_item_choose_on_map";
  static const String SearchItemYourLocation = "search_item_your_location";
  static const String SearchItemNoResults = "search_item_no_results";
  static const String SearchSectionPlaces = "search_title_places";
  static const String SearchSectionRecent = "search_title_recent";
  static const String SearchSectionFavorites = "search_title_favorites";
  static const String SearchSectionResults = "search_title_result";
  static const String SearchCurrentPosition = "search_current_position";
  static const String SearchSectionPleaseSelect = "search_please_select";
  static const String SearchFailLoadingPlan = "search_fail_loading_plan";
  static const String SearchSectionMapMarker = "search_map_marker";
  static const String SearchNavigateToMarker = "search_navigate_to_map_marker";
  static const String ChooseLocationPageTitle = "choose_location_page_title";
  static const String ChooseLocationPageSubtitle =
      "choose_location_page_subtitle";
  static const String InstructionWalkStart = "instruction_walk_start";
  static const String InstructionWalk = "instruction_walk";
  static const String InstructionRide = "instruction_ride";
  static const String InstructionRideBus = "instruction_ride_bus";
  static const String InstructionMinutes = "instruction_minutes";
  static const String InstructionRideMicro = "instruction_ride_micro";
  static const String InstructionRideMinibus = "instruction_ride_minibus";
  static const String InstructionRideTrufi = "instruction_ride_trufi";
  static const String InstructionTo = "instruction_to";
  static const String InstructionFor = "instruction_for";
  static const String InstructionUnitKilometer = "instruction_unit_km";
  static const String InstructionUnitMeter = "instruction_unit_meter";
  static const String MenuConnections = "menu_connection";
  static const String MenuAbout = "menu_about";
  static const String MenuTeam = "menu_team";
  static const String MenuFeedback = "menu_feedback";
  static const String FeedbackContent = "feedback_content";
  static const String FeedbackTitle = "feedback_title";
  static const String AboutContent = "about_content";
  static const String LicenseButton = "license_button";
  static const String TeamContent = "team_content";
  static const String English = "english";
  static const String German = "german";
  static const String Spanish = "spanish";
  static const String Quechua = "quechua";

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      Title: 'Trufi App',
      TagLine: 'Public transportation in Cochabamba',
      Description:
          'The best way to travel with trufis, micros and busses through Cochabamba.',
      AlertLocationServicesDeniedTitle: 'No location',
      AlertLocationServicesDeniedMessage:
          'Please make sure your device has GPS and the Location settings are activated.',
      CommonOK: 'OK',
      CommonCancel: 'Cancel',
      CommonDestination: 'Destination',
      CommonOrigin: 'Origin',
      CommonNoInternetConnection: 'No internet connection.',
      CommonFailLoadingData: 'Failed to load data',
      CommonUnknownError: 'unknown error',
      CommonError: 'Error',
      SearchItemChooseOnMap: 'Choose on map',
      SearchItemYourLocation: 'Your location',
      SearchItemNoResults: 'No results',
      SearchSectionPlaces: 'Places',
      SearchSectionRecent: 'Recent',
      SearchSectionFavorites: 'Favorites',
      SearchSectionResults: 'Search Results',
      SearchCurrentPosition: 'Current Position',
      SearchSectionPleaseSelect: 'Please select',
      SearchFailLoadingPlan: 'Failed to load plan.',
      SearchSectionMapMarker: 'Map Marker',
      SearchNavigateToMarker: 'Navigate to',
      ChooseLocationPageTitle: 'Choose a point',
      ChooseLocationPageSubtitle: 'Tap on map to choose',
      InstructionWalk: 'Walk',
      InstructionRide: 'Ride',
      InstructionRideBus: 'Bus',
      InstructionMinutes: "min",
      InstructionRideMicro: 'Micro',
      InstructionRideMinibus: 'Minibus',
      InstructionRideTrufi: 'Trufi',
      InstructionTo: 'to',
      InstructionFor: 'for',
      InstructionUnitKilometer: 'km',
      InstructionUnitMeter: 'm',
      MenuConnections: 'Show routes',
      MenuAbout: 'About',
      MenuTeam: 'Contributors',
      MenuFeedback: 'Send Feedback',
      FeedbackContent:
          'Do you have suggestions for our app or found some errors in the data? We would love to hear from you! Please make sure to add your email address or telephone, so we can respond to you.',
      FeedbackTitle: 'Send us an E-mail',
      AboutContent:
          'We are a bolivian and international team of people that love and support public transport. We have developed this app to make it easy for people to use the transport system in Cochabamba and the surrounding area.',
      LicenseButton: 'Licenses',
      TeamContent: 'People and companies involved:',
      English: 'English',
      German: 'German',
      Spanish: 'Spanish',
      Quechua: 'Quechua'
    },
    'es': {
      Title: 'Trufi App',
      TagLine: 'Transporte público en Cochabamba',
      Description:
          'La mejor forma de viajar con trufis, micros y buses a través de Cochabamba.',
      AlertLocationServicesDeniedTitle: 'Sin acceso a la ubicación',
      AlertLocationServicesDeniedMessage:
          'Por favor, asegúrese de que el GPS y las configuraciones de ubicación esten activadas en su dispositivo.',
      CommonOK: 'Aceptar',
      CommonCancel: 'Cancelar',
      CommonDestination: 'Destino',
      CommonOrigin: 'Origen',
      CommonNoInternetConnection: 'Sin conexión a internet.',
      CommonFailLoadingData: 'Error al cargar datos',
      CommonUnknownError: 'Error desconocido',
      CommonError: 'Error',
      SearchItemChooseOnMap: 'Seleccionar en el mapa',
      SearchItemYourLocation: 'Tu ubicación',
      SearchItemNoResults: 'Ningun resultado',
      SearchSectionPlaces: 'Lugares',
      SearchSectionRecent: 'Recientes',
      SearchSectionFavorites: 'Favoritos',
      SearchSectionResults: 'Resultados de búsqueda',
      SearchCurrentPosition: 'Posición actual',
      SearchSectionPleaseSelect: 'Por favor seleccione',
      SearchFailLoadingPlan: 'Error al cargar plan.',
      SearchSectionMapMarker: 'Posición en el Mapa',
      SearchNavigateToMarker: 'Ir hasta',
      ChooseLocationPageTitle: 'Elige un punto en el mapa',
      ChooseLocationPageSubtitle: 'Toca el mapa para elegir un punto',
      InstructionWalk: 'Caminar',
      InstructionRide: 'Tomar',
      InstructionRideBus: 'Bus',
      InstructionMinutes: "minutos",
      InstructionRideMicro: 'Micro',
      InstructionRideMinibus: 'Minibus',
      InstructionRideTrufi: 'Trufi',
      InstructionTo: 'hasta',
      InstructionFor: 'por',
      InstructionUnitKilometer: 'kilómetros',
      InstructionUnitMeter: 'metros',
      MenuConnections: 'Muestra rutas',
      MenuAbout: 'Acerca',
      MenuTeam: 'Colaboradores',
      MenuFeedback: 'Envía comentarios',
      FeedbackContent:
          '¿Tienes sugerencias para nuestra aplicación o encontraste algunos errores en los datos? Nos encantaría saberlo! Asegúrate de agregar tu dirección de correo electrónico o teléfono para que podamos responderte.',
      FeedbackTitle: 'Envíanos un correo electrónico',
      AboutContent:
          'Somos un equipo boliviano e internacional de personas que amamos y apoyamos el transporte público. Desarrollamos esta aplicación para facilitar el uso del transporte en la región de Cochabamba.',
      LicenseButton: 'Licencias',
      TeamContent: 'Personas y empresas involucradas:',
      English: 'Inglés',
      German: 'Alemán',
      Spanish: 'Español',
      Quechua: 'Quechua'
    },
    'de': {
      Title: 'Trufi App',
      TagLine: 'Öffentliche Verkehrsmittel in Cochabamba',
      Description:
          'Der beste Weg mit Trufis, Mikros und Bussen durch Cochabamba zu reisen.',
      AlertLocationServicesDeniedTitle: 'Kein Standort',
      AlertLocationServicesDeniedMessage:
          'Bitte vergewissere dich, dass du ein GPS Signal empfängst und die Ortungsdienste aktiviert sind.',
      CommonOK: 'OK',
      CommonCancel: 'Abbrechen',
      CommonDestination: 'Fahrtziel',
      CommonOrigin: 'Startpunkt',
      CommonNoInternetConnection: 'Keine Internetverbindung.',
      CommonFailLoadingData: 'Fehler beim Laden der Daten',
      CommonUnknownError: 'Unbekannter Fehler',
      CommonError: 'Fehler',
      SearchItemChooseOnMap: 'Auf der Karte auswählen',
      SearchItemYourLocation: 'Ihr Standort',
      SearchItemNoResults: 'Keine Ergebnisse',
      SearchSectionPlaces: 'Orte',
      SearchSectionRecent: 'Zuletzt gesucht',
      SearchSectionFavorites: 'Favoriten',
      SearchSectionResults: 'Suchergebnisse',
      SearchCurrentPosition: 'Aktuelle Position',
      SearchSectionPleaseSelect: 'Bitte auswählen',
      SearchFailLoadingPlan: 'Fehler beim Laden des Plans.',
      SearchSectionMapMarker: 'Kartenmarkierung',
      SearchNavigateToMarker: 'Navigiere zur',
      ChooseLocationPageTitle: 'Ort auswählen',
      ChooseLocationPageSubtitle: 'Zum Anpassen auf die Karte tippen',
      InstructionWalk: 'Gehen Sie',
      InstructionRide: 'Fahren Sie mit',
      InstructionRideBus: 'dem Bus',
      InstructionMinutes: "Min",
      InstructionRideMicro: 'dem Micro',
      InstructionRideMinibus: 'dem Minibus',
      InstructionRideTrufi: 'der Trufi',
      InstructionTo: 'zur',
      InstructionFor: 'für',
      InstructionUnitKilometer: 'km',
      InstructionUnitMeter: 'm',
      MenuConnections: 'Verbindungen',
      MenuAbout: 'Über',
      MenuTeam: 'Mitwirkende',
      MenuFeedback: 'Feedback',
      FeedbackContent:
          'Haben Sie Vorschläge für unsere App oder haben Sie Fehler in den Daten gefunden? Wir würden gerne von Ihnen hören! Bitte geben Sie Ihre E-Mail-Adresse oder Ihre Telefonnummer an, damit wir Ihnen antworten können.',
      FeedbackTitle: 'E-Mail senden',
      AboutContent:
          'Wir sind ein bolivianisches und internationales Team, das den öffentlichen Nahverkehr liebt und unterstützen möchte. Wir haben diese App entwickelt, um den Menschen die Verwendung des öffentlichen Nahverkehrs in Cochabamba und der näheren Umgebung zu erleichtern.',
      LicenseButton: 'Lizenzen',
      TeamContent: 'Beteiligte Personen und Firmen:',
      English: 'Englisch',
      German: 'Deutsch',
      Spanish: 'Spanisch',
      Quechua: 'Quechua'
    },
    'qu': {
      Title: 'Trufi App',
      TagLine: 'Transporte público en Cochabamba',
      Description:
          "Trufis, microspi, buspi ima qhuchapampapi aswan sumaq ch’usanapaq.",
      AlertLocationServicesDeniedTitle: "Kay kiti mana tarikunchu",
      AlertLocationServicesDeniedMessage:
          "Celularniyki GPS ñisqayuqchu? Chantapis qhaway Ubicación ñisqa jap’ichisqa kananta.",
      CommonOK: 'Ari',
      CommonCancel: 'Mana',
      CommonDestination: 'Mayman',
      CommonOrigin: 'Maymanta',
      CommonNoInternetConnection: 'Mana internet canchu',
      CommonFailLoadingData: 'Mana aticunchu tariyta datusta',
      CommonUnknownError: 'Mana yachacunchu imachus pasan',
      CommonError: 'Error',
      SearchItemChooseOnMap: 'Ajllaw uj mapata',
      SearchItemYourLocation: 'Gan cashanqui',
      SearchItemNoResults: "Ningun resultado",
      SearchSectionPlaces: 'Lugares',
      SearchSectionRecent: "Kuintan masc'asgas",
      SearchSectionFavorites: "Favoritos",
      SearchSectionResults: "Masc'asgas",
      SearchCurrentPosition: 'Maypi cunan cashani',
      SearchSectionPleaseSelect: "Por favor seleccione",
      SearchFailLoadingPlan: 'Mana taricunchu mayninta rinapaj',
      SearchSectionMapMarker: 'Maypi cashani mapapy',
      SearchNavigateToMarker: 'Rina chaycamana',
      ChooseLocationPageTitle: 'Ajllaw uj puntuta mapapy',
      ChooseLocationPageSubtitle: "Ñit'iy mapapy",
      InstructionWalkStart: 'Juk chiqamanta',
      InstructionWalk: 'puriy',
      InstructionRide: 'ñisqata jap’iy',
      InstructionRideBus: "Bus",
      InstructionMinutes: "ch’inini-phani",
      InstructionRideMicro: 'Micro',
      InstructionRideMinibus: 'Minibus',
      InstructionRideTrufi: 'Trufi',
      InstructionTo: 'waq chiqaman',
      InstructionFor: 'kama',
      InstructionUnitKilometer: 'km',
      InstructionUnitMeter: 'mts',
      MenuConnections: "Ñankunata rikhuchiy",
      MenuAbout: "Imamanta yachayta munanki?",
      MenuTeam: "Ñuqaykuwan",
      MenuFeedback: "Yuyasqayniykita riqsichiwayku",
      FeedbackContent:
          "Imayna riqch’asunki Trufi App? Mayk’aqpis pantaykunata tarirqankichu? Riqsiyta munayku! Correo electrónico chanta yupaykita ima riqsirichiwayku sumaqta yanaparisunaykupaq.",
      FeedbackTitle: 'Correo electrónico ñiqta yuyasqasniykita apachimuwayku!',
      AboutContent:
          "Bolivia suyumantapacha waq jawa suyukunawan jukchasqa kayku, munayku chanta kallpanchayku ima transporte publico ñisqata. Kay thatkichiy ruwasqa kachkan Qhuchapampa jap’iypi, ukhupi jawaman ima, aswan sasata ch’usanaykipaq.",
      LicenseButton: 'Licencias',
      TeamContent: 'Personas y empresas involucradas:',
      English: 'Inglés simi',
      German: 'Aleman simi',
      Spanish: 'Castilla simi',
      Quechua: 'Quechua simi'
    }
  };

  String get title {
    return _localizedValues[locale.languageCode][Title];
  }

  String get tagLine {
    return _localizedValues[locale.languageCode][TagLine];
  }

  String get description {
    return _localizedValues[locale.languageCode][Description];
  }

  String get alertLocationServicesDeniedTitle {
    return _localizedValues[locale.languageCode]
        [AlertLocationServicesDeniedTitle];
  }

  String get alertLocationServicesDeniedMessage {
    return _localizedValues[locale.languageCode]
        [AlertLocationServicesDeniedMessage];
  }

  String get commonOK {
    return _localizedValues[locale.languageCode][CommonOK];
  }

  String get commonCancel {
    return _localizedValues[locale.languageCode][CommonCancel];
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

  String get commonError {
    return _localizedValues[locale.languageCode][CommonError];
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

  String get searchTitleFavorites {
    return _localizedValues[locale.languageCode][SearchSectionFavorites];
  }

  String get searchTitleResults {
    return _localizedValues[locale.languageCode][SearchSectionResults];
  }

  String get searchCurrentPosition {
    return _localizedValues[locale.languageCode][SearchCurrentPosition];
  }

  String get searchPleaseSelect {
    return _localizedValues[locale.languageCode][SearchSectionPleaseSelect];
  }

  String get searchFailLoadingPlan {
    return _localizedValues[locale.languageCode][SearchFailLoadingPlan];
  }

  String get searchMapMarker {
    return _localizedValues[locale.languageCode][SearchSectionMapMarker];
  }

  String get searchNavigate {
    return _localizedValues[locale.languageCode][SearchNavigateToMarker];
  }

  String get instructionWalkStart {
    return _localizedValues[locale.languageCode][InstructionWalkStart];
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

  String get instructionMinutes {
    return _localizedValues[locale.languageCode][InstructionMinutes];
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

  String get instructionUnitKm {
    return _localizedValues[locale.languageCode][InstructionUnitKilometer];
  }

  String get instructionUnitMeter {
    return _localizedValues[locale.languageCode][InstructionUnitMeter];
  }

  String get chooseLocationPageTitle {
    return _localizedValues[locale.languageCode][ChooseLocationPageTitle];
  }

  String get chooseLocationPageSubtitle {
    return _localizedValues[locale.languageCode][ChooseLocationPageSubtitle];
  }

  String get menuConnections {
    return _localizedValues[locale.languageCode][MenuConnections];
  }

  String get menuAbout {
    return _localizedValues[locale.languageCode][MenuAbout];
  }

  String get menuTeam {
    return _localizedValues[locale.languageCode][MenuTeam];
  }

  String get menuFeedback {
    return _localizedValues[locale.languageCode][MenuFeedback];
  }

  String get feedbackContent {
    return _localizedValues[locale.languageCode][FeedbackContent];
  }

  String get feedbackTitle {
    return _localizedValues[locale.languageCode][FeedbackTitle];
  }

  String get aboutContent {
    return _localizedValues[locale.languageCode][AboutContent];
  }

  String get license {
    return _localizedValues[locale.languageCode][LicenseButton];
  }

  String get teamContent {
    return _localizedValues[locale.languageCode][TeamContent];
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

  String get quechua {
    return _localizedValues[locale.languageCode][Quechua];
  }

  bool get isQuechua => locale.languageCode == 'qu';

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
      case "qu":
        return Locale('qu', 'BO');
        break;
      default:
        return Locale('es', 'ES');
        break;
    }
  }

  getLanguageCode(String languageString) {
    if (languageString == _localizedValues[locale.languageCode][English]) {
      return "en";
    } else if (languageString ==
        _localizedValues[locale.languageCode][German]) {
      return "de";
    } else if (languageString ==
        _localizedValues[locale.languageCode][Quechua]) {
      return "qu";
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
      case "qu":
        return _localizedValues[locale.languageCode][Quechua];
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

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'de', 'qu'].contains(locale.languageCode);
  }

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
    String languageCode = prefs.get(TrufiLocalizations.savedLanguageCode);
    return languageCode != null
        ? TrufiLocalizations(TrufiLocalizations.getLocale(languageCode))
        : null;
  }
}
