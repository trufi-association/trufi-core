
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'trufi_localization.dart';

// ignore_for_file: unnecessary_brace_in_string_interps

/// The translations for Spanish Castilian (`es`).
class TrufiLocalizationEs extends TrufiLocalization {
  TrufiLocalizationEs([String locale = 'es']) : super(locale);

  @override
  String get aboutContent => 'Somos un equipo boliviano e internacional de personas que amamos y apoyamos el transporte público. Desarrollamos esta aplicación para facilitar el uso del transporte en la región de Cochabamba.';

  @override
  String get aboutLicenses => 'Licencias';

  @override
  String get aboutOpenSource => 'Esta aplicación está liberada como código abierto en GitHub. Siéntase libre de contribuir o llevarlo a su propia ciudad.';

  @override
  String get alertLocationServicesDeniedMessage => 'Por favor, asegúrese de que el GPS y las configuraciones de ubicación estén activadas en su dispositivo.';

  @override
  String get alertLocationServicesDeniedTitle => 'Sin acceso a la ubicación';

  @override
  String get appReviewDialogButtonAccept => 'Write review';

  @override
  String get appReviewDialogButtonDecline => 'Not now';

  @override
  String get appReviewDialogContent => 'Support us with a review on the Google Play Store.';

  @override
  String get appReviewDialogTitle => 'Enjoying Trufi?';

  @override
  String get chooseLocationPageSubtitle => 'Amplía y mueve el mapa para centrar el marcador';

  @override
  String get chooseLocationPageTitle => 'Elige un punto en el mapa';

  @override
  String get commonArrival => 'Arrival';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonCitybikes => 'Citybikes';

  @override
  String get commonCustomPlaces => 'Custom places';

  @override
  String get commonDeparture => 'Departure';

  @override
  String get commonDestination => 'Destino';

  @override
  String get commonError => 'Error';

  @override
  String get commonFailLoading => 'Error al cargar datos';

  @override
  String get commonFavoritePlaces => 'Favorite places';

  @override
  String get commonGoOffline => 'Salir de línea';

  @override
  String get commonGoOnline => 'Ir en línea';

  @override
  String get commonLeavingNow => 'Leaving now';

  @override
  String get commonNoInternet => 'Sin conexión a internet.';

  @override
  String get commonOK => 'Aceptar';

  @override
  String get commonOrigin => 'Origen';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonShowMap => 'Show on map';

  @override
  String get commonUnknownError => 'Error desconocido';

  @override
  String get commonWait => 'Wait';

  @override
  String get commonWalk => 'Walk';

  @override
  String defaultLocationAdd(Object defaultLocation) {
    return 'Versión {version}';
  }

  @override
  String get defaultLocationHome => 'Home';

  @override
  String get defaultLocationWork => 'Work';

  @override
  String description(Object cityName) {
    return 'La mejor forma de viajar con trufis, micros y buses a través de Cochabamba.';
  }

  @override
  String get donate => 'Donate';

  @override
  String get errorAmbiguousDestination => 'El planificador de rutas no está seguro de su destino. Por favor, seleccione una de las siguientes opciones o introduzca un destino más exacto.';

  @override
  String get errorAmbiguousOrigin => 'El planificador de rutas no está seguro de su origen. Por favor, seleccione una de las siguientes opciones o introduzca un origen más exacto.';

  @override
  String get errorAmbiguousOriginDestination => 'Origen y destino son ambiguos. Por favor, seleccione una de las siguientes opciones o introduzca un destino más exacto.';

  @override
  String get errorCancelledByUser => 'Canceled by user';

  @override
  String get errorEmailFeedback => 'Could not open mail feedback app, the URL or email is incorrect';

  @override
  String get errorNoBarrierFree => 'Origen y destino no son accesibles a silla de ruedas.';

  @override
  String get errorNoTransitTimes => 'No hay tiempos de tránsito disponibles. La información podría no ser válida para la fecha actual o no hay rutas disponibles para su viaje.';

  @override
  String get errorOutOfBoundary => 'Viaje no disponible. Puede que esté intentando planificar un viaje fuera de los límites disponibles.';

  @override
  String get errorPathNotFound => 'Viaje no disponible. Su punto de origen y/o destino pueden no ser seguros. Seleccione un inicio y final en calles residenciales.';

  @override
  String get errorServerCanNotHandleRequest => 'La solicitud tiene errores que el servidor no puede procesar.';

  @override
  String get errorServerTimeout => 'El planificador de rutas está tardando demasiado. Por favor, inténtelo más tarde.';

  @override
  String get errorServerUnavailable => 'Lo sentimos. El planificador de ruta está fuera de servicio temporalmente. Inténtelo más tarde.';

  @override
  String get errorTrivialDistance => 'Origen y destino están demasiado cerca.';

  @override
  String get errorUnknownDestination => 'Destino desconocido. ¿Podría ser un poco más preciso?';

  @override
  String get errorUnknownOrigin => 'Origen desconocido. ¿Podría ser un poco más preciso?';

  @override
  String get errorUnknownOriginDestination => 'Origen y destino desconocidos ¿Podría ser un poco más preciso?';

  @override
  String get feedbackContent => '¿Tiene sugerencias para nuestra aplicación o ha encontrado algunos errores en los datos? Nos encantaría saberlo! Asegúrese de agregar su dirección de correo electrónico o teléfono para que podamos responderlo.';

  @override
  String get feedbackTitle => 'Envíanos un correo electrónico';

  @override
  String get followOnFacebook => 'Follow us on Facebook';

  @override
  String get followOnInstagram => 'Follow us on Instagram';

  @override
  String get followOnTwitter => 'Follow us on Twitter';

  @override
  String instructionDistanceKm(Object value) {
    return '${value} km';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '${value} m';
  }

  @override
  String instructionDurationHours(Object value) {
    return '${value} min';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '${value} min';
  }

  @override
  String instructionJunction(Object street1, Object street2) {
    return '${street1} and ${street2}';
  }

  @override
  String instructionRide(Object vehicle, Object distance, Object duration, Object location) {
    return 'Tomar ${vehicle} por ${duration} (${distance}) hasta\n${location}';
  }

  @override
  String get instructionVehicleBus => 'Bus';

  @override
  String get instructionVehicleCar => 'Coche';

  @override
  String get instructionVehicleCarpool => 'Bus';

  @override
  String get instructionVehicleCommuterTrain => 'Bus';

  @override
  String get instructionVehicleGondola => 'Góndola';

  @override
  String get instructionVehicleLightRail => 'Light Rail Train';

  @override
  String get instructionVehicleMetro => 'Bus';

  @override
  String get instructionVehicleMicro => 'Micro';

  @override
  String get instructionVehicleMinibus => 'Minibus';

  @override
  String get instructionVehicleSharing => 'Bus';

  @override
  String get instructionVehicleSharingCarSharing => 'Bus';

  @override
  String get instructionVehicleSharingRegioRad => 'Bus';

  @override
  String get instructionVehicleSharingTaxi => 'Bus';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String instructionWalk(Object distance, Object duration, Object location) {
    return 'Caminar ${duration} (${distance}) hasta\n${location}';
  }

  @override
  String get mapTypeLabel => 'Map Type';

  @override
  String get mapTypeSatelliteCaption => 'Satellite';

  @override
  String get mapTypeStreetsCaption => 'Streets';

  @override
  String get mapTypeTerrainCaption => 'Terrain';

  @override
  String get menuAbout => 'Acerca';

  @override
  String get menuAppReview => 'Valora la aplicación';

  @override
  String get menuConnections => 'Muestra rutas';

  @override
  String get menuFeedback => 'Enviar comentarios';

  @override
  String get menuOnline => 'En línea';

  @override
  String get menuShareApp => 'Share the app';

  @override
  String get menuTeam => 'Sobre el equipo';

  @override
  String get menuYourPlaces => 'Tus lugares';

  @override
  String get noRouteError => 'Lo sentimos, no pudimos encontrar una ruta. ¿Qué quiere hacer?';

  @override
  String get noRouteErrorActionCancel => 'Prueba con otro destino';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Reportar una ruta faltante';

  @override
  String get noRouteErrorActionShowCarRoute => 'Mostrar ruta en auto';

  @override
  String get readOurBlog => 'Read our blog';

  @override
  String get savedPlacesEnterNameTitle => 'Enter name';

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
  String get searchFailLoadingPlan => 'Error al cargar el itinerario.';

  @override
  String get searchHintDestination => 'Seleccione destino';

  @override
  String get searchHintOrigin => 'Seleccione punto de origen';

  @override
  String get searchItemChooseOnMap => 'Seleccionar en el mapa';

  @override
  String get searchItemNoResults => 'Ningún resultado';

  @override
  String get searchItemYourLocation => 'Su ubicación';

  @override
  String get searchMapMarker => 'Posición en el Mapa';

  @override
  String get searchPleaseSelectDestination => 'Seleccione destino';

  @override
  String get searchPleaseSelectOrigin => 'Seleccione origen';

  @override
  String get searchTitleFavorites => 'Favoritos';

  @override
  String get searchTitlePlaces => 'Lugares';

  @override
  String get searchTitleRecent => 'Recientes';

  @override
  String get searchTitleResults => 'Resultados de búsqueda';

  @override
  String get settingPanelAccessibility => 'Accessibility';

  @override
  String get settingPanelAvoidTransfers => 'Avoid transfers';

  @override
  String get settingPanelAvoidWalking => 'Avoid walking';

  @override
  String get settingPanelBikingSpeed => 'Biking speed';

  @override
  String get settingPanelMyModesTransport => 'My modes of transport';

  @override
  String get settingPanelMyModesTransportBike => 'Bike';

  @override
  String get settingPanelMyModesTransportParkRide => 'Park and Ride';

  @override
  String get settingPanelTransportModes => 'Transport modes';

  @override
  String get settingPanelWalkingSpeed => 'Walking speed';

  @override
  String get settingPanelWheelchair => 'Wheelchair';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Download ${appTitle}, the public transport app for ${cityName}, at ${url}';
  }

  @override
  String tagline(Object city) {
    return 'Transporte público en Cochabamba';
  }

  @override
  String get teamContent => 'Somos un equipo internacional llamado Trufi Association y hemos desarrollado esta app con la ayuda de muchos voluntarios. ¿Quieres mejorar la Trufi App y ser parte de nuestro equipo? Contáctanos a:';

  @override
  String teamSectionRepresentatives(Object representatives) {
    return 'Representantes: ${representatives}';
  }

  @override
  String teamSectionRoutes(Object osmContributors, Object routeContributors) {
    return 'Rutas: ${routeContributors} y todos los usuarios que subieron rutas a OpenStreetMap, como ${osmContributors}. ¡Contáctanos si quieres unirte a la comunidad OpenStreetMap!';
  }

  @override
  String teamSectionTeam(Object teamMembers) {
    return 'Equipo: ${teamMembers}';
  }

  @override
  String teamSectionTranslations(Object translators) {
    return 'Traducciones: ${translators}';
  }

  @override
  String get title => 'Trufi App';

  @override
  String get typeSpeedAverage => 'Average';

  @override
  String get typeSpeedCalm => 'Calm';

  @override
  String get typeSpeedFast => 'Fast';

  @override
  String get typeSpeedPrompt => 'Prompt';

  @override
  String get typeSpeedSlow => 'Slow';

  @override
  String version(Object version) {
    return 'Versión ${version}';
  }
}
