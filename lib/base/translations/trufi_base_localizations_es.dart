


import 'trufi_base_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class TrufiBaseLocalizationEs extends TrufiBaseLocalization {
  TrufiBaseLocalizationEs([String locale = 'es']) : super(locale);

  @override
  String get alertLocationServicesDeniedMessage => 'Por favor, asegúrese de que el GPS y las configuraciones de ubicación estén activadas en su dispositivo.';

  @override
  String get alertLocationServicesDeniedTitle => 'Sin acceso a la ubicación';

  @override
  String get appReviewDialogButtonAccept => 'Puntuar';

  @override
  String get appReviewDialogButtonDecline => 'Ahora no';

  @override
  String get appReviewDialogContent => 'Apóyanos con una reseña en Google Play Store.';

  @override
  String get appReviewDialogTitle => '¿Disfrutando de Trufi?';

  @override
  String get chooseLocationPageSubtitle => 'Amplía y mueve el mapa para centrar el marcador';

  @override
  String get chooseLocationPageTitle => 'Elige un punto en el mapa';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirmLocation => 'Confirmar ubicación';

  @override
  String get commonDestination => 'Destino';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonError => 'Error';

  @override
  String get commonFromStation => 'de la estación';

  @override
  String get commonFromStop => 'desde la parada';

  @override
  String get commonItineraryNoTransitLegs => 'Salir cuando te convenga';

  @override
  String get commonLeavesAt => 'Sale';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonNoInternet => 'Sin conexión a internet.';

  @override
  String get commonNoResults => 'Ningún resultado';

  @override
  String get commonOK => 'Aceptar';

  @override
  String get commonOrigin => 'Origen';

  @override
  String get commonRemove => 'Eliminar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonTomorrow => 'Mañana';

  @override
  String get commonUnknownError => 'Error desconocido';

  @override
  String get commonUnkownPlace => 'Lugar desconocido';

  @override
  String get commonWait => 'Esperar';

  @override
  String get commonWalk => 'Caminar';

  @override
  String get commonYourLocation => 'Su ubicación';

  @override
  String get errorAmbiguousDestination => 'El planificador de rutas no está seguro de su destino. Por favor, seleccione una de las siguientes opciones o introduzca un destino más exacto.';

  @override
  String get errorAmbiguousOrigin => 'El planificador de rutas no está seguro de su origen. Por favor, seleccione una de las siguientes opciones o introduzca un origen más exacto.';

  @override
  String get errorAmbiguousOriginDestination => 'Origen y destino son ambiguos. Por favor, seleccione una de las siguientes opciones o introduzca un destino más exacto.';

  @override
  String get errorNoBarrierFree => 'Origen y destino no son accesibles a silla de ruedas.';

  @override
  String get errorNoConnectServer => 'Sin conexión con el servidor.';

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
  String get followOnFacebook => 'Síguenos en Facebook';

  @override
  String get followOnInstagram => 'Síguenos en Instagram';

  @override
  String get followOnTwitter => 'Síguenos en Twitter';

  @override
  String instructionDistanceKm(Object value) {
    return '$value km';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '$value m';
  }

  @override
  String instructionDurationHours(Object value) {
    return '$value h';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '$value min';
  }

  @override
  String get instructionVehicleBike => 'Bicicleta';

  @override
  String get instructionVehicleBus => 'Bus';

  @override
  String get instructionVehicleCar => 'Coche';

  @override
  String get instructionVehicleCarpool => 'Compartir coche';

  @override
  String get instructionVehicleCommuterTrain => 'Tren de cercanías';

  @override
  String get instructionVehicleGondola => 'Teleférico';

  @override
  String get instructionVehicleLightRail => 'Tren ligero';

  @override
  String get instructionVehicleMetro => 'Metro';

  @override
  String get instructionVehicleMicro => 'Micro';

  @override
  String get instructionVehicleMinibus => 'Minibus';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String get instructionVehicleWalk => 'Caminar';

  @override
  String get menuConnections => 'Planificador de rutas';

  @override
  String get menuSocialMedia => 'Redes sociales';

  @override
  String get menuTransportList => 'Mostrar lineas';

  @override
  String get noRouteError => 'Lo sentimos, no pudimos encontrar una ruta. ¿Qué quiere hacer?';

  @override
  String get noRouteErrorActionCancel => 'Prueba con otro destino';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Reportar una ruta faltante';

  @override
  String get noRouteErrorActionShowCarRoute => 'Mostrar ruta en auto';

  @override
  String get readOurBlog => 'Lee nuestro blog';

  @override
  String get searchFailLoadingPlan => 'Error al cargar el itinerario.';

  @override
  String get searchHintDestination => 'Seleccione destino';

  @override
  String get searchHintOrigin => 'Seleccione punto de origen';

  @override
  String get searchPleaseSelectDestination => 'Seleccione destino';

  @override
  String get searchPleaseSelectOrigin => 'Seleccione origen';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Descargar $appTitle, la aplicación de transporte público para $cityName, en $url';
  }

  @override
  String get themeModeDark => 'Modo oscuro';

  @override
  String get themeModeLight => 'Modo claro';

  @override
  String get themeModeSystem => 'Predeterminado del sistema';
}
