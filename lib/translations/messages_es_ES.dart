// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es_ES locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'es_ES';

  static m0(value) => "${value} km";

  static m1(value) => "${value} m";

  static m2(value) => "${value} min";

  static m3(street1, street2) => "${street1} y ${street2}";

  static m4(vehicle, duration, distance, location) => "Tomar ${vehicle} por ${duration} (${distance}) hasta\n${location}";

  static m5(duration, distance, location) => "Caminar ${duration} (${distance}) hasta\n${location}";

  static m7(representatives) => "Representantes: ${representatives}";

  static m8(routeContributors, osmContributors) => "Rutas: ${routeContributors} y todos los usuarios que subieron rutas a OpenStreetMap, como ${osmContributors}. ¡Contáctanos si quieres unirte a la comunidad OpenStreetMap!";

  static m9(teamMembers) => "Equipo: ${teamMembers}";

  static m10(translators) => "Traducciones: ${translators}";

  static m11(version) => "Versión ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "aboutContent" : MessageLookupByLibrary.simpleMessage("Somos un equipo boliviano e internacional de personas que amamos y apoyamos el transporte público. Desarrollamos esta aplicación para facilitar el uso del transporte en la región de Cochabamba."),
    "aboutLicenses" : MessageLookupByLibrary.simpleMessage("Licencias"),
    "aboutOpenSource" : MessageLookupByLibrary.simpleMessage("This app is released as open source on GitHub. Feel free to contribute or bring it to your own city."),
    "alertLocationServicesDeniedMessage" : MessageLookupByLibrary.simpleMessage("Por favor, asegúrese de que el GPS y las configuraciones de ubicación esten activadas en su dispositivo."),
    "alertLocationServicesDeniedTitle" : MessageLookupByLibrary.simpleMessage("Sin acceso a la ubicación"),
    "chooseLocationPageSubtitle" : MessageLookupByLibrary.simpleMessage("Amplía y mueve el mapa para centrar el marcador"),
    "chooseLocationPageTitle" : MessageLookupByLibrary.simpleMessage("Elige un punto en el mapa"),
    "commonCancel" : MessageLookupByLibrary.simpleMessage("Cancelar"),
    "commonDestination" : MessageLookupByLibrary.simpleMessage("Destino"),
    "commonError" : MessageLookupByLibrary.simpleMessage("Error"),
    "commonFailLoading" : MessageLookupByLibrary.simpleMessage("Error al cargar datos"),
    "commonGoOffline" : MessageLookupByLibrary.simpleMessage("Salir de línea"),
    "commonGoOnline" : MessageLookupByLibrary.simpleMessage("Ir en línea"),
    "commonNoInternet" : MessageLookupByLibrary.simpleMessage("Sin conexión a internet."),
    "commonOK" : MessageLookupByLibrary.simpleMessage("Aceptar"),
    "commonOrigin" : MessageLookupByLibrary.simpleMessage("Origen"),
    "commonUnknownError" : MessageLookupByLibrary.simpleMessage("Error desconocido"),
    "description" : MessageLookupByLibrary.simpleMessage("La mejor forma de viajar con trufis, micros y buses a través de Cochabamba."),
    "errorAmbiguousDestination" : MessageLookupByLibrary.simpleMessage("El planificador de rutas no está seguro de su destino. Por favor, seleccione una de las siguientes opciones o introduzca un destino más exacto."),
    "errorAmbiguousOrigin" : MessageLookupByLibrary.simpleMessage("El planificador de rutas no está seguro de su origen. Por favor, seleccione una de las siguientes opciones o introduzca un origen más exacto."),
    "errorAmbiguousOriginDestination" : MessageLookupByLibrary.simpleMessage("Origen y destino son ambiguos. Por favor, seleccione una de las siguientes opciones o introduzca un destino más exacto."),
    "errorNoBarrierFree" : MessageLookupByLibrary.simpleMessage("Origen y destino no son accesibles a silla de ruedas."),
    "errorNoTransitTimes" : MessageLookupByLibrary.simpleMessage("No hay tiempos de tránsito disponibles. La información podría no ser válida para la fecha actual o no hay rutas disponibles para su viaje."),
    "errorOutOfBoundary" : MessageLookupByLibrary.simpleMessage("Viaje no disponible. Puede que esté intentando planificar un viaje fuera de los límites disponibles."),
    "errorPathNotFound" : MessageLookupByLibrary.simpleMessage("Viaje no disponible. Su punto de origen y/o destino pueden no ser seguros. Seleccione un inicio y final en calles residenciales."),
    "errorServerCanNotHandleRequest" : MessageLookupByLibrary.simpleMessage("La solicitud tiene errores que el servidor no puede procesar."),
    "errorServerTimeout" : MessageLookupByLibrary.simpleMessage("El planificador de rutas está tardando demasiado. Por favor, inténtelo más tarde."),
    "errorServerUnavailable" : MessageLookupByLibrary.simpleMessage("Lo sentimos. El planificador de ruta está fuera de servicio temporalmente. Inténtelo más tarde."),
    "errorTrivialDistance" : MessageLookupByLibrary.simpleMessage("Origen y destino están demasiado cerca."),
    "errorUnknownDestination" : MessageLookupByLibrary.simpleMessage("Destino desconocido. ¿Podría ser un poco más preciso?"),
    "errorUnknownOrigin" : MessageLookupByLibrary.simpleMessage("Origen desconocido. ¿Podría ser un poco más preciso?"),
    "errorUnknownOriginDestination" : MessageLookupByLibrary.simpleMessage("Origen y destino desconocidos ¿Podría ser un poco más preciso?"),
    "feedbackContent" : MessageLookupByLibrary.simpleMessage("¿Tiene sugerencias para nuestra aplicación o ha encontrado algunos errores en los datos? Nos encantaría saberlo! Asegúrese de agregar su dirección de correo electrónico o teléfono para que podamos responderlo."),
    "feedbackTitle" : MessageLookupByLibrary.simpleMessage("Envíanos un correo electrónico"),
    "instructionDistanceKm" : m0,
    "instructionDistanceMeters" : m1,
    "instructionDurationMinutes" : m2,
    "instructionJunction" : m3,
    "instructionRide" : m4,
    "instructionVehicleBus" : MessageLookupByLibrary.simpleMessage("Bus"),
    "instructionVehicleCar" : MessageLookupByLibrary.simpleMessage("Coche"),
    "instructionVehicleGondola" : MessageLookupByLibrary.simpleMessage("Góndola"),
    "instructionVehicleMicro" : MessageLookupByLibrary.simpleMessage("Micro"),
    "instructionVehicleMinibus" : MessageLookupByLibrary.simpleMessage("Minibus"),
    "instructionVehicleTrufi" : MessageLookupByLibrary.simpleMessage("Trufi"),
    "instructionWalk" : m5,
    "menuAbout" : MessageLookupByLibrary.simpleMessage("Acerca"),
    "menuAppReview" : MessageLookupByLibrary.simpleMessage("Valora la aplicación"),
    "menuConnections" : MessageLookupByLibrary.simpleMessage("Muestra rutas"),
    "menuFeedback" : MessageLookupByLibrary.simpleMessage("Enviar comentarios"),
    "menuOnline" : MessageLookupByLibrary.simpleMessage("En línea"),
    "menuTeam" : MessageLookupByLibrary.simpleMessage("Sobre el equipo"),
    "noRouteError" : MessageLookupByLibrary.simpleMessage("Lo sentimos, no pudimos encontrar una ruta. ¿Qué quiere hacer?"),
    "noRouteErrorActionCancel" : MessageLookupByLibrary.simpleMessage("Prueba con otro destino"),
    "noRouteErrorActionReportMissingRoute" : MessageLookupByLibrary.simpleMessage("Reportar una ruta faltante"),
    "noRouteErrorActionShowCarRoute" : MessageLookupByLibrary.simpleMessage("Mostrar ruta en auto"),
    "searchFailLoadingPlan" : MessageLookupByLibrary.simpleMessage("Error al cargar el itinerario."),
    "searchHintDestination" : MessageLookupByLibrary.simpleMessage("Seleccione destino"),
    "searchHintOrigin" : MessageLookupByLibrary.simpleMessage("Seleccione punto de origen"),
    "searchItemChooseOnMap" : MessageLookupByLibrary.simpleMessage("Seleccionar en el mapa"),
    "searchItemNoResults" : MessageLookupByLibrary.simpleMessage("Ningun resultado"),
    "searchItemYourLocation" : MessageLookupByLibrary.simpleMessage("Su ubicación"),
    "searchMapMarker" : MessageLookupByLibrary.simpleMessage("Posición en el Mapa"),
    "searchPleaseSelectDestination" : MessageLookupByLibrary.simpleMessage("Seleccione destino"),
    "searchPleaseSelectOrigin" : MessageLookupByLibrary.simpleMessage("Seleccione origen"),
    "searchTitleFavorites" : MessageLookupByLibrary.simpleMessage("Favoritos"),
    "searchTitlePlaces" : MessageLookupByLibrary.simpleMessage("Lugares"),
    "searchTitleRecent" : MessageLookupByLibrary.simpleMessage("Recientes"),
    "searchTitleResults" : MessageLookupByLibrary.simpleMessage("Resultados de búsqueda"),
    "tagline" : MessageLookupByLibrary.simpleMessage("Transporte público en Cochabamba"),
    "teamContent" : MessageLookupByLibrary.simpleMessage("Somos un equipo internacional llamado Trufi Association y hemos desarrollado esta app con la ayuda de muchos voluntarios. ¿Quieres mejorar la Trufi App y ser parte de nuestro equipo? Contáctanos a:"),
    "teamSectionRepresentatives" : m7,
    "teamSectionRoutes" : m8,
    "teamSectionTeam" : m9,
    "teamSectionTranslations" : m10,
    "title" : MessageLookupByLibrary.simpleMessage("Trufi App"),
    "version" : m11
  };
}
