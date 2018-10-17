import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

const String languageCodeEnglish = "en";
const String languageCodeGerman = "de";
const String languageCodeQuechua = "qu";
const String languageCodeSpanish = "es";
const List<String> languageCodes = [
  languageCodeEnglish,
  languageCodeGerman,
  languageCodeQuechua,
  languageCodeSpanish,
];
const Locale localeEnglish = Locale('en', 'US'); // English
const Locale localeGerman = Locale('de', 'DE'); // German
const Locale localeQuechua = Locale('qu', 'BO'); // Quechua
const Locale localeSpanish = Locale('es', 'ES'); // Spanish
const List<Locale> locales = <Locale>[
  localeEnglish,
  localeGerman,
  localeQuechua,
  localeSpanish,
];

class TrufiLocalizations {
  static TrufiLocalizations of(BuildContext context) {
    return Localizations.of<TrufiLocalizations>(context, TrufiLocalizations);
  }

  TrufiLocalizations(this.locale);

  final Locale locale;

  static const String Title = "title";
  static const String TagLine = "tag_line";
  static const String Description = "description";
  static const String AlertLocationServicesDeniedTitle =
      "alert_location_services_denied_title";
  static const String AlertLocationServicesDeniedMessage =
      "alert_location_services_denied_message";
  static const String CommonOK = "common_ok";
  static const String CommonCancel = "common_cancel";
  static const String CommonGoOffline = "common_go_offline";
  static const String CommonGoOnline = "common_go_online";
  static const String CommonDestination = "common_destination";
  static const String CommonOrigin = "common_origin";
  static const String CommonNoInternetConnection =
      "common_no_internet_connection";
  static const String CommonFailLoadingData = "common_fail_loading_data";
  static const String CommonUnknownError = "common_unknown_error";
  static const String CommonError = "common_error";
  static const String RouteRequestErrorServerUnavailable =
      "route_request_error_server_unavailable";
  static const String RouteRequestErrorOutOfBoundary =
      "route_request_error_out_of_boundary";
  static const String RouteRequestErrorPathNotFound =
      "route_request_error_path_not_found";
  static const String RouteRequestErrorNoTransitTimes =
      "route_request_error_no_transit_times";
  static const String RouteRequestErrorServerTimeout =
      "route_request_error_server_time_out";
  static const String RouteRequestErrorTrivialDistance =
      "route_request_error_trivial_distance";
  static const String RouteRequestErrorServerCanNotHandleRequest =
      "route_request_error_server_can_not_handle";
  static const String RouteRequestErrorUnknownOrigin =
      "route_request_error_unknown_origin";
  static const String RouteRequestErrorUnknownDestination =
      "route_request_error_unknown_destination";
  static const String RouteRequestErrorOriginDestinationUnknown =
      "route_request_error_origin_destination_unknown";
  static const String RouteRequestErrorNoBarrierFree =
      "route_request_error_no_barrier_free";
  static const String RouteRequestErrorAmbiguousOrigin =
      "route_request_error_ambiguous_origin";
  static const String RouteRequestErrorAmbiguousDestination =
      "route_request_error_ambiguous_destination";
  static const String RouteRequestErrorOriginDestinationAmbiguous =
      "route_request_error_origin_destination_ambiguous";
  static const String SearchItemChooseOnMap = "search_item_choose_on_map";
  static const String SearchItemYourLocation = "search_item_your_location";
  static const String SearchItemNoResults = "search_item_no_results";
  static const String SearchSectionPlaces = "search_title_places";
  static const String SearchSectionRecent = "search_title_recent";
  static const String SearchSectionFavorites = "search_title_favorites";
  static const String SearchSectionResults = "search_title_result";
  static const String SearchSectionPleaseSelectOrigin =
      "search_please_select_origin";
  static const String SearchSectionPleaseSelectDestination =
      "search_please_select_destination";
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
  static const String MenuOnline = "menu_online";
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
      CommonGoOffline: 'Go offline',
      CommonGoOnline: 'Go online',
      CommonDestination: 'Destination',
      CommonOrigin: 'Origin',
      CommonNoInternetConnection: 'No internet connection.',
      CommonFailLoadingData: 'Failed to load data',
      CommonUnknownError: 'unknown error',
      CommonError: 'Error',
      RouteRequestErrorServerUnavailable:
          "We\'re sorry. The trip planner is temporarily unavailable. Please try again later.",
      RouteRequestErrorOutOfBoundary:
          'Trip is not possible.  You might be trying to plan a trip outside the map data boundary.',
      RouteRequestErrorPathNotFound:
          'Trip is not possible. Your start or end point might not be safely accessible (for instance, you might be starting on a residential street connected only to a highway).',
      RouteRequestErrorNoTransitTimes:
          'No transit times available. The date may be past or too far in the future or there may not be transit service for your trip at the time you chose.',
      RouteRequestErrorServerTimeout:
          'The trip planner is taking way too long to process your request. Please try again later.',
      RouteRequestErrorTrivialDistance:
          'Origin is within a trivial distance of the destination.',
      RouteRequestErrorServerCanNotHandleRequest:
          'The request has errors that the server is not willing or able to process.',
      RouteRequestErrorUnknownOrigin:
          'Origin is unknown. Can you be a bit more descriptive?',
      RouteRequestErrorUnknownDestination:
          'Destination is unknown.  Can you be a bit more descriptive?',
      RouteRequestErrorOriginDestinationUnknown:
          'Both origin and destination are unknown. Can you be a bit more descriptive?',
      RouteRequestErrorNoBarrierFree:
          'Both origin and destination are not wheelchair accessible',
      RouteRequestErrorAmbiguousOrigin:
          'The trip planner is unsure of the location you want to start from. Please select from the following options, or be more specific.',
      RouteRequestErrorAmbiguousDestination:
          'The trip planner is unsure of the destination you want to go to. Please select from the following options, or be more specific.',
      RouteRequestErrorOriginDestinationAmbiguous:
          'Both origin and destination are ambiguous. Please select from the following options, or be more specific.',
      SearchItemChooseOnMap: 'Choose on map',
      SearchItemYourLocation: 'Your location',
      SearchItemNoResults: 'No results',
      SearchSectionPlaces: 'Places',
      SearchSectionRecent: 'Recent',
      SearchSectionFavorites: 'Favorites',
      SearchSectionResults: 'Search Results',
      SearchSectionPleaseSelectOrigin: 'Please select origin',
      SearchSectionPleaseSelectDestination: 'Please select destination',
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
      MenuOnline: 'Online',
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
      CommonGoOffline: 'Go offline', // TODO
      CommonGoOnline: 'Go online', // TODO
      CommonDestination: 'Destino',
      CommonOrigin: 'Origen',
      CommonNoInternetConnection: 'Sin conexión a internet.',
      CommonFailLoadingData: 'Error al cargar datos',
      CommonUnknownError: 'Error desconocido',
      CommonError: 'Error',
      RouteRequestErrorServerUnavailable:
          'Lo sentimos. El planificador de ruta está fuera de servicio temporalmente. Inténtelo más tarde.',
      RouteRequestErrorOutOfBoundary:
          'Viaje no disponible. Puede que estés intentando planificar un viaje fuera de los límites disponibles.',
      RouteRequestErrorPathNotFound:
          'Viaje no disponible. Tu punto partida o destino puede que no sean seguros, selecciona un inicio y final en calles residenciales.',
      RouteRequestErrorNoTransitTimes:
          'Tiempos no disponibles. La información disponible podría no ser válida para la fecha actual o no hay rutas disponibles para tu viaje.',
      RouteRequestErrorServerTimeout:
          'El planificador de rutas está tardando demasiado. Por favor, inténtalo más tarde.',
      RouteRequestErrorTrivialDistance:
          'Origen y destino están demasiado cerca.',
      RouteRequestErrorServerCanNotHandleRequest:
          'Error en la petición, el server no puede procesar la información.',
      RouteRequestErrorUnknownOrigin:
          'Origen desconocido. ¿Puedes ser un poco más descriptivo?',
      RouteRequestErrorUnknownDestination:
          'Destino desconocido. ¿Puedes ser un poco más descriptivo?',
      RouteRequestErrorOriginDestinationUnknown:
          'Origen y destino desconocidos ¿Puedes ser un poco más descriptivo?',
      RouteRequestErrorNoBarrierFree:
          'Origen y destino no son accesibles a silla de ruedas.',
      RouteRequestErrorAmbiguousOrigin:
          'El planificador de rutas no está seguro de tu origen. Por favor, seleccione una de las siguientes opciones o introduzca un origen más exacto.',
      RouteRequestErrorAmbiguousDestination:
          'El planificador de rutas no está seguro de tu destino. Por favor, seleccione una de las siguientes opciones o introduzca un destino más exacto.',
      RouteRequestErrorOriginDestinationAmbiguous:
          'Origen y destino son ambiguos. Por favor, seleccione una de las siguientes opciones o introduzca un destino más exacto.',
      SearchItemChooseOnMap: 'Seleccionar en el mapa',
      SearchItemYourLocation: 'Tu ubicación',
      SearchItemNoResults: 'Ningun resultado',
      SearchSectionPlaces: 'Lugares',
      SearchSectionRecent: 'Recientes',
      SearchSectionFavorites: 'Favoritos',
      SearchSectionResults: 'Resultados de búsqueda',
      SearchSectionPleaseSelectOrigin: 'Por favor seleccione origen',
      SearchSectionPleaseSelectDestination: 'Por favor seleccione destino',
      SearchFailLoadingPlan: 'Error al cargar plan.',
      SearchSectionMapMarker: 'Posición en el Mapa',
      SearchNavigateToMarker: 'Ir hasta',
      ChooseLocationPageTitle: 'Elige un punto en el mapa',
      ChooseLocationPageSubtitle: 'Toca el mapa para elegir un punto',
      InstructionWalk: 'Caminar',
      InstructionRide: 'Tomar',
      InstructionRideBus: 'Bus',
      InstructionMinutes: "min",
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
      MenuOnline: 'Online',
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
      CommonGoOffline: 'Offline gehen',
      CommonGoOnline: 'Online gehen',
      CommonDestination: 'Fahrtziel',
      CommonOrigin: 'Startpunkt',
      CommonNoInternetConnection: 'Keine Internetverbindung.',
      CommonFailLoadingData: 'Fehler beim Laden der Daten',
      CommonUnknownError: 'Unbekannter Fehler',
      CommonError: 'Fehler',
      RouteRequestErrorServerUnavailable:
          "Es tut uns leid. Der Reiseplaner ist vorübergehend nicht verfügbar. Bitte versuche es später erneut.",
      RouteRequestErrorOutOfBoundary:
          'Trip ist nicht möglich. Sie versuchen möglicherweise, eine Reise außerhalb der Kartendatengrenze zu planen.',
      RouteRequestErrorPathNotFound:
          'Trip ist nicht möglich. Ihr Start- oder Endpunkt ist möglicherweise nicht sicher zugänglich (Sie könnten beispielsweise in einer Wohnstraße beginnen, die nur mit einer Autobahn verbunden ist).',
      RouteRequestErrorNoTransitTimes:
          'Keine Laufzeiten verfügbar. Das Datum kann in der Zukunft zu alt oder zu weit sein, oder es kann zu dem von Ihnen gewählten Zeitpunkt keinen Transitservice für Ihre Reise geben.',
      RouteRequestErrorServerTimeout:
          'Der Reiseplaner dauert zu lange, um Ihre Anfrage zu bearbeiten. Bitte versuchen Sie es später erneut.',
      RouteRequestErrorTrivialDistance:
          'Der Startpunkt liegt in einer trivialen Entfernung vom Ziel.',
      RouteRequestErrorServerCanNotHandleRequest:
          'Die Anfrage enthält Fehler, die der Server nicht verarbeiten kann.',
      RouteRequestErrorUnknownOrigin:
          'Der Startpunkt ist unbekannt. Können Sie ein bisschen deutlicher sein?',
      RouteRequestErrorUnknownDestination:
          'Das Ziel ist unbekannt. Können Sie ein bisschen deutlicher sein?',
      RouteRequestErrorOriginDestinationUnknown:
          'Startpunkt und Ziel sind unbekannt. Können Sie ein bisschen deutlicher sein?',
      RouteRequestErrorNoBarrierFree:
          'Der Startpunkt und das Ziel sind nicht für Rollstuhlfahrer zugänglich',
      RouteRequestErrorAmbiguousOrigin:
          'Der Reiseplaner weiß nicht genau, von welchem Ort aus Sie starten möchten. Bitte wählen Sie aus den folgenden Optionen oder geben Sie eine deutliche Beschreibung.',
      RouteRequestErrorAmbiguousDestination:
          'Der Reiseplaner weiß nicht genau, wohin er fahren möchte. Bitte wählen Sie aus den folgenden Optionen oder geben Sie eine deutliche Beschreibung.',
      RouteRequestErrorOriginDestinationAmbiguous:
          'Der Startpunkt und das Ziel sind unklar. Bitte wählen Sie aus den folgenden Optionen oder geben Sie eine deutliche Beschreibung.',
      SearchItemChooseOnMap: 'Auf der Karte auswählen',
      SearchItemYourLocation: 'Ihr Standort',
      SearchItemNoResults: 'Keine Ergebnisse',
      SearchSectionPlaces: 'Orte',
      SearchSectionRecent: 'Zuletzt gesucht',
      SearchSectionFavorites: 'Favoriten',
      SearchSectionResults: 'Suchergebnisse',
      SearchSectionPleaseSelectOrigin: 'Bitte Startpunkt auswählen',
      SearchSectionPleaseSelectDestination: 'Bitte Ziel auswählen',
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
      MenuOnline: 'Online',
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
      CommonGoOffline: 'Go offline', // TODO
      CommonGoOnline: 'Go online', // TODO
      CommonDestination: 'Mayman',
      CommonOrigin: 'Maymanta',
      CommonNoInternetConnection: 'Mana internet canchu',
      CommonFailLoadingData: 'Mana aticunchu tariyta datusta',
      CommonUnknownError: 'Mana yachacunchu imachus pasan',
      CommonError: 'Error',
      RouteRequestErrorServerUnavailable:
          'Lo sentimos. El planificador de ruta está fuera de servicio temporalmente. Inténtelo más tarde.',
      RouteRequestErrorOutOfBoundary:
          'Viaje no disponible. Puede que estés intentando planificar un viaje fuera de los límites disponibles.',
      RouteRequestErrorPathNotFound:
          'Viaje no disponible. Tu punto partida o destino puede que no sean seguros, selecciona un inicio y final en calles residenciales.',
      RouteRequestErrorNoTransitTimes:
          'Tiempos no disponibles. La información disponible podría no ser válida para la fecha actual o no hay rutas disponibles para tu viaje.',
      RouteRequestErrorServerTimeout:
          'El planificador de rutas está tardando demasiado. Por favor, inténtalo más tarde.',
      RouteRequestErrorTrivialDistance:
          'Origen y destino están demasiado cerca.',
      RouteRequestErrorServerCanNotHandleRequest:
          'Error en la petición, el server no puede procesar la información.',
      RouteRequestErrorUnknownOrigin:
          'Origen desconocido. ¿Puedes ser un poco más descriptivo?',
      RouteRequestErrorUnknownDestination:
          'Destino desconocido. ¿Puedes ser un poco más descriptivo?',
      RouteRequestErrorOriginDestinationUnknown:
          'Origen y destino desconocidos ¿Puedes ser un poco más descriptivo?',
      RouteRequestErrorNoBarrierFree:
          'Origen y destino no son accesibles a silla de ruedas.',
      RouteRequestErrorAmbiguousOrigin:
          'El planificador de rutas no está seguro de tu origen. Por favor, seleccione una de las siguientes opciones o introduzca un origen más exacto.',
      RouteRequestErrorAmbiguousDestination:
          'El planificador de rutas no está seguro de tu destino. Por favor, seleccione una de las siguientes opciones o introduzca un destino más exacto.',
      RouteRequestErrorOriginDestinationAmbiguous:
          'Origen y destino son ambiguos. Por favor, seleccione una de las siguientes opciones o introduzca un destino más exacto.',
      SearchItemChooseOnMap: 'Ajllaw uj mapata',
      SearchItemYourLocation: 'Gan cashanqui',
      SearchItemNoResults: "Ningun resultado",
      SearchSectionPlaces: 'Lugares',
      SearchSectionRecent: "Kuintan masc'asgas",
      SearchSectionFavorites: "Favoritos",
      SearchSectionResults: "Masc'asgas",
      SearchSectionPleaseSelectOrigin: "Por favor seleccione origen",
      SearchSectionPleaseSelectDestination: "Por favor seleccione destino",
      SearchFailLoadingPlan: 'Mana taricunchu mayninta rinapaj',
      SearchSectionMapMarker: 'Maypi cashani mapapy',
      SearchNavigateToMarker: 'Rina chaycamana',
      ChooseLocationPageTitle: 'Ajllaw uj puntuta mapapy',
      ChooseLocationPageSubtitle: "Ñit'iy mapapy",
      InstructionWalkStart: 'Juk chiqamanta',
      InstructionWalk: 'puriy',
      InstructionRide: 'ñisqata jap’iy',
      InstructionRideBus: "Bus",
      InstructionMinutes: "min",
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
      MenuOnline: 'Online',
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

  String get commonGoOffline {
    return _localizedValues[locale.languageCode][CommonGoOffline];
  }

  String get commonGoOnline {
    return _localizedValues[locale.languageCode][CommonGoOnline];
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

  String get errorServerUnavailable {
    return _localizedValues[locale.languageCode]
    [RouteRequestErrorServerUnavailable];
  }

  String get errorOutOfBoundary {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorOutOfBoundary];
  }

  String get errorPathNotFound {
    return _localizedValues[locale.languageCode][RouteRequestErrorPathNotFound];
  }


  String get errorNoTransitTimes {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorNoTransitTimes];
  }

  String get errorServerTimeout {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorServerTimeout];
  }

  String get errorTrivialDistance {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorTrivialDistance];
  }

  String get errorServerCanNotHandleRequest {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorServerCanNotHandleRequest];
  }

  String get errorUnknownOrigin {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorUnknownOrigin];
  }

  String get errorUnknownDestination {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorUnknownDestination];
  }

  String get errorUnknownOriginDestination {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorOriginDestinationUnknown];
  }

  String get errorNoBarrierFree {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorNoBarrierFree];
  }

  String get errorAmbiguousOrigin {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorAmbiguousOrigin];
  }

  String get errorAmbiguousDestination {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorAmbiguousDestination];
  }

  String get errorAmbiguousOriginDestination {
    return _localizedValues[locale.languageCode]
        [RouteRequestErrorOriginDestinationAmbiguous];
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

  String get searchPleaseSelectOrigin {
    return _localizedValues[locale.languageCode]
        [SearchSectionPleaseSelectOrigin];
  }

  String get searchPleaseSelectDestination {
    return _localizedValues[locale.languageCode]
        [SearchSectionPleaseSelectDestination];
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

  String get menuOnline {
    return _localizedValues[locale.languageCode][MenuOnline];
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

  bool get isQuechua => locale.languageCode == languageCodeQuechua;
}

class TrufiMaterialLocalizations extends DefaultMaterialLocalizations {
  static TrufiMaterialLocalizations of(BuildContext context) {
    return MaterialLocalizations.of(context);
  }

  TrufiMaterialLocalizations(this.locale);

  final Locale locale;

  @override
  String get searchFieldLabel {
    switch (locale.languageCode) {
      case languageCodeGerman:
        return "Suchen";
      case languageCodeQuechua:
        return "Mask'ay";
      case languageCodeSpanish:
        return "Buscar";
      default:
        return super.searchFieldLabel;
    }
  }
}

class TrufiLocalizationsDelegate
    extends TrufiLocalizationsDelegateBase<TrufiLocalizations> {
  TrufiLocalizationsDelegate(String languageCode) : super(languageCode);

  @override
  Future<TrufiLocalizations> load(Locale locale) async {
    return SynchronousFuture<TrufiLocalizations>(
      TrufiLocalizations(
        languageCode != null ? localeForLanguageCode(languageCode) : locale,
      ),
    );
  }
}

class TrufiMaterialLocalizationsDelegate
    extends TrufiLocalizationsDelegateBase<MaterialLocalizations> {
  TrufiMaterialLocalizationsDelegate(String languageCode) : super(languageCode);

  @override
  Future<TrufiMaterialLocalizations> load(Locale locale) async {
    return SynchronousFuture<TrufiMaterialLocalizations>(
      TrufiMaterialLocalizations(
        languageCode != null ? localeForLanguageCode(languageCode) : locale,
      ),
    );
  }
}

abstract class TrufiLocalizationsDelegateBase<T>
    extends LocalizationsDelegate<T> {
  TrufiLocalizationsDelegateBase(this.languageCode);

  final String languageCode;

  @override
  bool isSupported(Locale locale) {
    return languageCodes.contains(locale.languageCode);
  }

  @override
  bool shouldReload(TrufiLocalizationsDelegateBase<T> old) {
    return old.languageCode != languageCode;
  }

  Locale localeForLanguageCode(String languageCode) {
    switch (languageCode) {
      case languageCodeEnglish:
        return localeEnglish;
        break;
      case languageCodeGerman:
        return localeGerman;
        break;
      case languageCodeQuechua:
        return localeQuechua;
        break;
      default:
        return localeSpanish;
        break;
    }
  }
}
