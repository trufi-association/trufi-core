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

  String lookupMessage(
      String message_str, String locale, String name, List args, String meaning,
      {MessageIfAbsent ifAbsent}) {
    String failedLookup(String message_str, List args) {
      // If there's no message_str, then we are an internal lookup, e.g. an
      // embedded plural, and shouldn't fail.
      if (message_str == null) return null;
      // ignore: unnecessary_new
      throw new UnsupportedError(
          "No translation found for message '$name',\n"
          "  original text '$message_str'");
    }
    return super.lookupMessage(message_str, locale, name, args, meaning,
        ifAbsent: ifAbsent ?? failedLookup);
  }

  static m0(value) => "${value} km";

  static m1(value) => "${value} m";

  static m2(value) => "${value} min";

  static m3(vehicle, duration, distance, location) => "Tomar ${vehicle} por ${duration} (${distance}) hasta\n${location}";

  static m4(duration, distance, location) => "Caminar ${duration} (${distance}) hasta\n${location}";

  static m5(representatives) => "Representantes: ${representatives}";

  static m6(routeContributors, osmContributors) => "Rutas: ${routeContributors} y todos los usuarios que subieron rutas a OpenStreetMap, como ${osmContributors}. ¡Contáctanos si quieres unirte a la comunidad OpenStreetMap!";

  static m7(teamMembers) => "Equipo: ${teamMembers}";

  static m8(translators) => "Traducciones: ${translators}";

  static m9(version) => "Versión ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "aboutContent" : MessageLookupByLibrary.simpleMessage("Somos un equipo boliviano e internacional de personas que amamos y apoyamos el transporte público. Desarrollamos esta aplicación para facilitar el uso del transporte en la región de Accra."),
    "aboutLicenses" : MessageLookupByLibrary.simpleMessage("Licencias"),
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
    "description" : MessageLookupByLibrary.simpleMessage("La mejor forma de viajar con trufis, micros y buses a través de Accra."),
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
    "instructionRide" : m3,
    "instructionVehicleBus" : MessageLookupByLibrary.simpleMessage("Bus"),
    "instructionVehicleCar" : MessageLookupByLibrary.simpleMessage("Coche"),
    "instructionVehicleGondola" : MessageLookupByLibrary.simpleMessage("Góndola"),
    "instructionVehicleMicro" : MessageLookupByLibrary.simpleMessage("Micro"),
    "instructionVehicleMinibus" : MessageLookupByLibrary.simpleMessage("Minibus"),
    "instructionVehicleTrufi" : MessageLookupByLibrary.simpleMessage("Trufi"),
    "instructionWalk" : m4,
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
    "tagline" : MessageLookupByLibrary.simpleMessage("Transporte público en Accra"),
    "teamContent" : MessageLookupByLibrary.simpleMessage("Somos un equipo internacional llamado Trufi Association y hemos desarrollado esta app con la ayuda de muchos voluntarios. ¿Quieres mejorar la Trotro App y ser parte de nuestro equipo? Contáctanos a:"),
    "teamSectionRepresentatives" : m5,
    "teamSectionRoutes" : m6,
    "teamSectionTeam" : m7,
    "teamSectionTranslations" : m8,
    "title" : MessageLookupByLibrary.simpleMessage("Trotro App"),
    "version" : m9
  };
}
